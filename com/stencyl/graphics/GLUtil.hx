package com.stencyl.graphics;

#if (lime_opengl || lime_opengles || lime_webgl)

import com.stencyl.utils.Log;

import lime.graphics.opengl.GLTexture;
import lime.graphics.RenderContext;
import lime.ui.Window;

import openfl.display.BitmapData;
import openfl.display.OpenGLRenderer;
import openfl.display3D.Context3D;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.TextureBase;

@:access(openfl.display.BitmapData)
@:access(openfl.display3D.textures.TextureBase)

class GLUtil
{
	public static var gl (default, null):lime.graphics.WebGLRenderContext;
	
	public static var renderer(default, null):OpenGLRenderer;
	public static var context(default, null):RenderContext;
	public static var context3D(default, null):Context3D;
	
	public static var textureMaxSize(default, null):Null<Int> = null;
	private static var MAX_TEXTURE_CAP = 4096;
	
	public static function initialize(window:Window):Void
	{
		if(gl != null) return;
		context = window.context;
		context3D = window.stage.context3D;
		gl = context;
		@:privateAccess renderer = cast window.stage.__renderer;
		
		textureMaxSize = cast gl.getParameter(gl.MAX_TEXTURE_SIZE);
		Log.debug("GL value of MAX_TEXTURE_SIZE: " + textureMaxSize);
		
		textureMaxSize = Std.int(textureMaxSize / 2);
		if(textureMaxSize > MAX_TEXTURE_CAP)
			textureMaxSize = MAX_TEXTURE_CAP;
		
		if(TextureBase.__supportsBGRA == null)
		{
			new BitmapData(1, 1, true, 0).getTexture(context3D);
		}
	}
	
	public static function uploadTexture(img:BitmapData, dispose:Bool):Void
	{
		img.getTexture(context3D);
		
		if(dispose)
		{
			disposeSoftwareBuffer(img);
		}
	}
	
	public static function disposeSoftwareBuffer(img:BitmapData):Void
	{
		@:privateAccess img.image.buffer.__srcCanvas = null; //Browser.document.createElement("canvas")
		@:privateAccess img.image.buffer.__srcContext = null; //js.Syntax.code('buffer.__srcCanvas.getContext ("2d", { alpha: false })');
															  //buffer.__srcCanvas.getContext("2d");
		@:privateAccess img.image.buffer.__srcImageData = null; //buffer.__srcContext.getImageData(0, 0, buffer.width, buffer.height)
                                                                //buffer.__srcContext.createImageData(buffer.width, buffer.height)
		img.image = null;
		img.readable = false;
		img.__surface = null;
		img.__vertexBuffer = null;
		img.__framebuffer = null;
		img.__framebufferContext = null;
	}
	
	public static function createNewTexture(size:Int):BitmapData
	{
		var texture = context3D.createRectangleTexture(size, size, BGRA, false);
		//texture.__setSamplerState(new openfl._internal.renderer.SamplerState());
		texture.uploadFromTypedArray(null);
		
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
		var rt:RectangleTexture = cast img.__texture;
		rt.uploadFromTypedArray(null);
		
		/*gl.bindTexture(gl.TEXTURE_2D, img.__texture);
		gl.clearTexImage(gl.TEXTURE_2D, 0, BitmapData.__textureFormat, gl.UNSIGNED_BYTE, 0);*/
	}
}

#end