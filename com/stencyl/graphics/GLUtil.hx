package com.stencyl.graphics;

#if (lime_opengl || lime_opengles || lime_webgl)

import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;

import openfl.display.BitmapData;
import openfl.display.OpenGLRenderer;

@:access(openfl.display.BitmapData)

class GLUtil
{
	#if lime_opengl
	public static var gl (default, null):lime.graphics.OpenGLRenderContext;
	#elseif lime_opengles
	public static var gl (default, null):lime.graphics.OpenGLES2RenderContext;
	#elseif lime_webgl
	public static var gl (default, null):lime.graphics.WebGLRenderContext;
	#end
	
	public static var renderer(default, null):OpenGLRenderer;
	public static var context(default, null):RenderContext;
	
	public static var textureMaxSize(default, null):Null<Int> = null;
	private static var MAX_TEXTURE_CAP = 4096;
	
	public static function initialize():Void
	{
		if(gl != null) return;
		context = com.stencyl.Engine.stage.window.context;
		gl = context;
		@:privateAccess renderer = cast com.stencyl.Engine.stage.__renderer;
		
		textureMaxSize = cast gl.getParameter(gl.MAX_TEXTURE_SIZE);
		trace("GL value of MAX_TEXTURE_SIZE: " + textureMaxSize);
		
		textureMaxSize = Std.int(textureMaxSize / 2);
		if(textureMaxSize > MAX_TEXTURE_CAP)
			textureMaxSize = MAX_TEXTURE_CAP;
		
		if(BitmapData.__supportsBGRA == null)
		{
			new BitmapData(1, 1, true, 0).getTexture(renderer);
		}
	}
	
	public static function uploadTexture(img:BitmapData, dispose:Bool):Void
	{
		img.getTexture(renderer);
		
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
		
		#if (lime_opengl || lime_opengles)
		gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat,  size, size,  0,  format, gl.UNSIGNED_BYTE, 0);
		#elseif lime_webgl
		gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat,  size, size,  0,  format, gl.UNSIGNED_BYTE);
		#end
		
		var bitmapData = new BitmapData(0, 0, true, 0);
		bitmapData.__resize(size, size);
		bitmapData.readable = false;
		bitmapData.__texture = texture;
		bitmapData.__textureContext = context;
		bitmapData.__isValid = true;
		bitmapData.image = null;
		
		return bitmapData;
	}
	
	public static function clearTexture(img:BitmapData):Void
	{
		var internalFormat = BitmapData.__textureInternalFormat;
		var format = BitmapData.__textureFormat;
		
		gl.bindTexture(gl.TEXTURE_2D, img.__texture);
		
		#if (lime_opengl || lime_opengles)
		gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat,  img.width, img.height,  0,  format, gl.UNSIGNED_BYTE, 0);
		#elseif lime_webgl
		gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat,  img.width, img.height,  0,  format, gl.UNSIGNED_BYTE);
		#end
		
		/*gl.bindTexture(gl.TEXTURE_2D, img.__texture);
		gl.clearTexImage(gl.TEXTURE_2D, 0, BitmapData.__textureFormat, gl.UNSIGNED_BYTE, 0);*/
	}
}

#end