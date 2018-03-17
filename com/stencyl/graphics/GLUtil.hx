package com.stencyl.graphics;

#if (lime_opengl)

import lime.graphics.opengl.GLTexture;
import lime.graphics.GLRenderContext;

import openfl.display.BitmapData;


@:access(openfl.display.BitmapData)

class GLUtil
{
	public static var gl(default, null):GLRenderContext;
	
	public static var textureMaxSize(default, null):Null<Int> = null;
	private static var MAX_TEXTURE_CAP = 4096;
	
	public static function initialize():Void
	{
		if(gl != null) return;
		
		gl = switch(com.stencyl.Engine.stage.window.renderer.context)
		{
			case OPENGL(gl): gl;
			default: null;
		};
		
		textureMaxSize = cast gl.getParameter(gl.MAX_TEXTURE_SIZE);
		trace("GL value of MAX_TEXTURE_SIZE: " + textureMaxSize);
		
		textureMaxSize = Std.int(textureMaxSize / 2);
		if(textureMaxSize > MAX_TEXTURE_CAP)
			textureMaxSize = MAX_TEXTURE_CAP;
		
		if(BitmapData.__supportsBGRA == null)
		{
			new BitmapData(1, 1, true, 0).getTexture(gl);
		}
	}
	
	public static function uploadTexture(img:BitmapData, dispose:Bool):Void
	{
		img.getTexture(gl);
		
		if(dispose)
		{
			disposeSoftwareBuffer(img);
		}
	}
	
	public static function disposeSoftwareBuffer(img:BitmapData):Void
	{
		img.image = null;
		img.readable = false;
		img.__surface = null;
		img.__buffer = null;
		img.__framebuffer = null;
		img.__framebufferContext = null;
	}
	
	public static function createNewTexture(size:Int):BitmapData
	{
		var texture = gl.createTexture();
		
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		
		var internalFormat = BitmapData.__textureInternalFormat;
		var format = BitmapData.__textureFormat;
		gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, size, size, 0, format, gl.UNSIGNED_BYTE, 0);
		
		var bitmapData = new BitmapData(0, 0, true, 0);
		bitmapData.__resize(size, size);
		bitmapData.readable = false;
		bitmapData.__texture = texture;
		bitmapData.__textureContext = gl;
		bitmapData.__isValid = true;
		bitmapData.image = null;
		
		return bitmapData;
	}
}

#end