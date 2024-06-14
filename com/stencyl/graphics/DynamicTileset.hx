package com.stencyl.graphics;

#if ((lime_opengl || lime_opengles || lime_webgl) && use_actor_tilemap)

import com.stencyl.utils.Log;

import haxe.io.Bytes;

import lime.graphics.opengl.GLTexture;
import lime.utils.UInt8Array;

import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.display3D.textures.TextureBase;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.Vector;

@:access(openfl.display.BitmapData)
@:access(openfl.display.Tileset)
@:access(openfl.display3D.textures.TextureBase)

class DynamicTileset
{
	public var tileset:Tileset;
	private var texture:GLTexture;
	private var point:Point;
	private var nextLine:Int;
	
	private static var FRAME_PADDING = 1;
	
	public function new()
	{
		Log.debug("Creating new dynamic tileset (size: " + GLUtil.textureMaxSize + ")");
		
		tileset = new Tileset(GLUtil.createNewTexture(GLUtil.textureMaxSize));
		texture = @:privateAccess tileset.bitmapData.__texture.__textureID;
		point = new Point(0, 0);
		nextLine = 0;
	}
	
	public function checkForSpace(frameWidth:Int, frameHeight:Int, frameCount:Int):Bool
	{
		var x = point.x;
		var y = point.y;
		var i = 0;
		var _nextLine = nextLine;
		
		while(y + frameHeight < GLUtil.textureMaxSize)
		{
			while(x + frameWidth < GLUtil.textureMaxSize)
			{
				x += frameWidth + FRAME_PADDING;
				++i;
				if(i >= frameCount)
				{
					return true;
				}
			}
			y = _nextLine;
			x = 0;
			_nextLine += frameHeight + FRAME_PADDING;
		}
		
		return false;
	}
	
	private var zero:Point = new Point(0, 0);
	
	public function addFrames(frames:Array<BitmapData>):Int
	{
		//Log.verbose("Adding " + frames.length + " frames to dynamicTileset.");
		
		@:privateAccess var offset = tileset.__data.length;
		
		var newRects = [];
		
		for(frame in frames)
		{
			if(point.x + frame.width > GLUtil.textureMaxSize)
			{
				point.x = 0;
				point.y = nextLine;
			}
			
			var rect = new Rectangle(point.x, point.y, frame.width, frame.height);
			tileset.addRect(rect);
			newRects.push(rect);
			
			point.x += frame.width + FRAME_PADDING;
			if(nextLine < point.y + frame.height)
				nextLine = Std.int(point.y + frame.height + FRAME_PADDING);
		}
		
		//Log.verbose(newRects);
		
		var gl = GLUtil.gl;
		var internalFormat = TextureBase.__textureInternalFormat;
		var format = TextureBase.__textureFormat;
		
		gl.bindTexture (gl.TEXTURE_2D, texture);
		
		for(i in 0...newRects.length)
		{
			var r = newRects[i];
			var newFrame = frames[i];
			
			gl.texSubImage2D(gl.TEXTURE_2D, 0, Std.int(r.x), Std.int(r.y), Std.int(r.width), Std.int(r.height), format, gl.UNSIGNED_BYTE, newFrame.image.data);
			
			var ts = new TileSource();
			ts.tileset = tileset;
			ts.tileID = offset + i;
			ts.width = newFrame.width;
			ts.height = newFrame.height;
			newFrame.__tileSource = ts;
		}
		
		return offset;
	}
	
	public function clearSheet():Void
	{
		GLUtil.clearTexture(tileset.bitmapData);
		point = new Point(0, 0);
		nextLine = 0;
		
		tileset.rectData = new Vector<Float>();
		tileset.__data = new Array();
	}
	
	public function addFramesFromStrip(imgData:BitmapData, frameWidth:Int, frameHeight:Int, framesAcross:Int, frameCount:Int):Int
	{
		//Log.verbose("Adding " + frameCount + " frames to dynamicTileset.");
		
		@:privateAccess var offset = tileset.__data.length;
		
		var newTexture = tileset.bitmapData.__texture == null;
		var newRects = [];
		var frameDatas = [];
		
		for(i in 0...frameCount)
		{
			if(point.x + frameWidth > GLUtil.textureMaxSize)
			{
				point.x = 0;
				point.y = nextLine;
			}
			var sourceRect = new Rectangle(frameWidth * (i % framesAcross), Math.floor(i / framesAcross) * frameHeight, frameWidth, frameHeight);
			tileset.bitmapData.copyPixels(imgData, sourceRect, point);
			
			if(!newTexture)
			{
				var pixels = ByteArray.fromBytes(imgData.image.getPixels(@:privateAccess sourceRect.__toLimeRectangle(), #if js RGBA32 #else BGRA32 #end));
				pixels.endian = Endian.BIG_ENDIAN;
				
				//var pixels = imgData.getPixels(sourceRect);//argb32,big endian
				var data = UInt8Array.fromBytes(Bytes.ofData(pixels));

				//re-premultiply, since getPixels un-premultiplies the data
				{
					var length = Std.int(data.length / 4);
					var pixel:lime.math.RGBA = 0;

					for (i in 0...length)
					{
						pixel.readUInt8(data, i * 4, lime.graphics.PixelFormat.RGBA32, false);
						pixel.writeUInt8(data, i * 4, lime.graphics.PixelFormat.RGBA32, true);
					}
				}

				frameDatas.push(data);
			}
			
			sourceRect.setTo(point.x, point.y, sourceRect.width, sourceRect.height);
			tileset.addRect(sourceRect);
			if(!newTexture)
				newRects.push(sourceRect);
			
			point.x += frameWidth + FRAME_PADDING;
			if(nextLine < point.y + frameHeight)
				nextLine = Std.int(point.y + frameHeight + FRAME_PADDING);
		}
		
		if(!newTexture)
		{
			var gl = GLUtil.gl;
			var internalFormat = TextureBase.__textureInternalFormat;
			var format = TextureBase.__textureFormat;
			
			gl.bindTexture (gl.TEXTURE_2D, texture);
			
			for(i in 0...newRects.length)
			{
				var r = newRects[i];
				var frameData = frameDatas[i];
				gl.texSubImage2D(gl.TEXTURE_2D, 0, Std.int(r.x), Std.int(r.y), Std.int(r.width), Std.int(r.height), format, gl.UNSIGNED_BYTE, frameData);
			}
			
			//tileset.bitmapData.__textureVersion = tileset.bitmapData.image.version;
		}
		
		//saveImage(tileset.bitmapData, "out-" + offset + ".png");
		
		return offset;
	}
}
#end