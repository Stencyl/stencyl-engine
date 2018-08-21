package com.stencyl.graphics;

#if ((lime_opengl || lime_opengles || lime_webgl) && use_actor_tilemap)

import lime.graphics.opengl.GLTexture;
import lime.graphics.GLRenderContext;

import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Vector;

@:access(openfl.display.BitmapData)
@:access(openfl.display.Tileset)

class DynamicTileset
{
	public var tileset:Tileset;
	private var texture:GLTexture;
	private var point:Point;
	private var nextLine:Int;
	
	private static var FRAME_PADDING = 1;
	
	public function new()
	{
		trace("Creating new dynamic tileset (size: " + GLUtil.textureMaxSize + ")");
		
		tileset = new Tileset(GLUtil.createNewTexture(GLUtil.textureMaxSize));
		texture = tileset.bitmapData.__texture;
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
		//trace("Adding " + frames.length + " frames to dynamicTileset.");
		
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
		
		//trace(newRects);
		
		var gl = GLUtil.gl;
		var internalFormat = BitmapData.__textureInternalFormat;
		var format = BitmapData.__textureFormat;
		
		gl.bindTexture (gl.TEXTURE_2D, texture);
		
		for(i in 0...newRects.length)
		{
			var r = newRects[i];
			var newFrame = frames[i];
			
			gl.texSubImage2D(gl.TEXTURE_2D, 0, Std.int(r.x), Std.int(r.y), Std.int(r.width), Std.int(r.height), format, gl.UNSIGNED_BYTE, newFrame.image.data);
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
	
	/*public function addFramesFromStrip(imgData:BitmapData, frameWidth:Int, frameHeight:Int, framesAcross:Int, frameCount:Int):Int
	{
		//trace("Adding " + frameCount + " frames to dynamicTileset.");
		
		@:privateAccess var offset = tileset.__data.length;
		
		var newTexture = tileset.bitmapData.__texture == null;
		var newRects = [];
		var newFrames = [];
		
		for(i in 0...frameCount)
		{
			if(point.x + frameWidth > textureMaxSize)
			{
				point.x = 0;
				point.y = nextLine;
			}
			var sourceRect = new Rectangle(frameWidth * (i % framesAcross), Math.floor(i / framesAcross) * frameHeight, frameWidth, frameHeight);
			tileset.bitmapData.copyPixels(imgData, sourceRect, point);
			
			if(!newTexture)
			{
				var newFrame = new BitmapData(frameWidth, frameHeight, true, 0);
				newFrame.copyPixels(imgData, sourceRect, zero);
				newFrames.push(newFrame);
			}
			
			sourceRect.setTo(point.x, point.y, sourceRect.width, sourceRect.height);
			tileset.addRect(sourceRect);
			if(!newTexture)
				newRects.push(sourceRect);
			
			point.x += frameWidth + FRAME_PADDING;
			if(nextLine < point.y + frameHeight)
				nextLine = Std.int(point.y + frameHeight + FRAME_PADDING);
		}
		
		//trace(newRects);
		
		if(!newTexture)
		{
			var gl = getGL();
			var textureImage = tileset.bitmapData.image;
			var internalFormat = BitmapData.__textureInternalFormat;
			var format = BitmapData.__textureFormat;
			
			gl.bindTexture (gl.TEXTURE_2D, tileset.bitmapData.__texture);
			
			for(i in 0...newRects.length)
			{
				var r = newRects[i];
				var newFrame = newFrames[i];
				
				#if (js && html5)
				
				if(newFrame.image.type == DATA)
				{
					gl.texSubImage2D(gl.TEXTURE_2D, 0, Std.int(r.x), Std.int(r.y), Std.int(r.width), Std.int(r.height), format, gl.UNSIGNED_BYTE, newFrame.image.data);
				}
				else
				{
					(gl:WebGLContext).texSubImage2D(gl.TEXTURE_2D, 0, Std.int(r.x), Std.int(r.y), Std.int(r.width), Std.int(r.height), format, gl.UNSIGNED_BYTE, newFrame.image.src);
				}
				
				#else
				
				gl.texSubImage2D(gl.TEXTURE_2D, 0, Std.int(r.x), Std.int(r.y), Std.int(r.width), Std.int(r.height), format, gl.UNSIGNED_BYTE, newFrame.image.data);
				
				#end
			}
			
			tileset.bitmapData.__textureVersion = tileset.bitmapData.image.version;
		}
		
		//saveImage(tileset.bitmapData, "out-" + offset + ".png");
		
		return offset;
	}*/
}
#end