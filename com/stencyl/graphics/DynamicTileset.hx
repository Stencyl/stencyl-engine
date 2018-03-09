package com.stencyl.graphics;

#if (use_actor_tilemap)

import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import haxe.io.Output;
import sys.FileSystem;
import sys.io.File;
import flash.utils.ByteArray;

@:access(openfl.display.BitmapData)

class DynamicTileset
{
	public var tileset:Tileset;
	private var point:Point;
	private var nextLine:Int;
	
	private static var textureMaxSize:Null<Int> = null;
	private static var MAX_TEXTURE_CAP = 4096;
	private static var FRAME_PADDING = 1;
	
	public function new()
	{
		if(textureMaxSize == null)
		{
			var gl = getGL();
			textureMaxSize = cast gl.getParameter(gl.MAX_TEXTURE_SIZE);
			trace("GL value of MAX_TEXTURE_SIZE: " + textureMaxSize);
			
			textureMaxSize = Std.int(textureMaxSize / 2);
			if(textureMaxSize > MAX_TEXTURE_CAP)
				textureMaxSize = MAX_TEXTURE_CAP;
		}
		
		trace("Creating new dynamic tileset (size: " + textureMaxSize + ")");
		
		tileset = new Tileset(new BitmapData(textureMaxSize, textureMaxSize, true, 0));
		point = new Point(0, 0);
		nextLine = 0;
	}
	
	public function checkForSpace(frameWidth:Int, frameHeight:Int, frameCount:Int):Bool
	{
		var x = point.x;
		var y = point.y;
		var i = 0;
		var _nextLine = nextLine;
		
		while(y + frameHeight < textureMaxSize)
		{
			while(x + frameWidth < textureMaxSize)
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
	
	public function addFrames(imgData:BitmapData, frameWidth:Int, frameHeight:Int, framesAcross:Int, frameCount:Int):Int
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
	}
	
	private function getGL()
	{
		switch(Engine.stage.window.renderer.context)
		{
			case OPENGL(gl): return gl;
			default: throw "Can't get gl context.";
		}
	}
	
	public function saveImage(image:BitmapData, outputFile:String):Void
	{
		var imageData:ByteArray = image.encode(image.rect, new flash.display.PNGEncoderOptions());
		var fo:Output = sys.io.File.write(outputFile, true);
		fo.writeBytes(imageData, 0, imageData.length);
		fo.close();
	}
}
#end