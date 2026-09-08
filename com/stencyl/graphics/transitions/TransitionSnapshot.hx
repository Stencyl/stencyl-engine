package com.stencyl.graphics.transitions;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.IBitmapDrawable;

import com.stencyl.Config;
import com.stencyl.Engine;

#if (lime_opengl || lime_opengles)
import com.stencyl.graphics.GLUtil;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.textures.RectangleTexture;
#end

@:access(openfl.display.BitmapData)
#if (lime_opengl || lime_opengles)
@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.textures.TextureBase)
#end
class TransitionSnapshot
{
	public var bitmap(default, null):BitmapData;
	public var fromBackBuffer(default, null):Bool = false;
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;

	#if (lime_opengl || lime_opengles)
	private var texture:RectangleTexture;
	#end

	private function new() {}

	public static function capture(content:IBitmapDrawable, background:IBitmapDrawable = null):TransitionSnapshot
	{
		var snapshot = new TransitionSnapshot();

		#if (lime_opengl || lime_opengles)
		if(snapshot.captureBackBuffer()) return snapshot;
		#end

		snapshot.captureSoftware(content, background);
		return snapshot;
	}

	#if (lime_opengl || lime_opengles)
	private function captureBackBuffer():Bool
	{
		if(GLUtil.context3D == null || GLUtil.gl == null) return false;

		width = GLUtil.context3D.backBufferWidth;
		height = GLUtil.context3D.backBufferHeight;

		if(width <= 0) width = Engine.stage.stageWidth;
		if(height <= 0) height = Engine.stage.stageHeight;
		if(width <= 0 || height <= 0) return false;

		try
		{
			texture = GLUtil.context3D.createRectangleTexture(
				width,
				height,
				Context3DTextureFormat.BGRA,
				false
			);

			GLUtil.context3D.setRenderToBackBuffer();
			GLUtil.context3D.__flushGL();
			GLUtil.context3D.__bindGLTexture2D(texture.__textureID);
			GLUtil.gl.copyTexSubImage2D(
				GLUtil.gl.TEXTURE_2D,
				0,
				0,
				0,
				0,
				0,
				width,
				height
			);
			GLUtil.context3D.__bindGLTexture2D(null);

			bitmap = new BitmapData(0, 0, true, 0);
			bitmap.__resize(width, height);
			bitmap.readable = false;
			bitmap.__texture = texture;
			bitmap.__textureContext = GLUtil.context;
			bitmap.__isValid = true;
			bitmap.image = null;
			fromBackBuffer = true;
			return true;
		}
		catch(e:Dynamic)
		{
			GLUtil.context3D.__bindGLTexture2D(null);
			if(texture != null) texture.dispose();
			texture = null;
			width = 0;
			height = 0;
			return false;
		}
	}
	#end

	private function captureSoftware(content:IBitmapDrawable, background:IBitmapDrawable):Void
	{
		width = Std.int(Engine.screenWidth * Engine.SCALE);
		height = Std.int(Engine.screenHeight * Engine.SCALE);
		bitmap = new BitmapData(width, height, true, 0x00000000);

		if(background != null)
			bitmap.draw(background, null, null, null, null, Config.antialias);
		if(content != null)
			bitmap.draw(content, null, null, null, null, Config.antialias);
	}

	public function createBitmap():Bitmap
	{
		var display = new Bitmap(bitmap);
		display.smoothing = Config.antialias;

		if(fromBackBuffer)
		{
			var stageWidth:Float = Engine.stage.stageWidth;
			var stageHeight:Float = Engine.stage.stageHeight;
			display.scaleX = stageWidth / width;
			display.scaleY = -(stageHeight / height);
			display.y = stageHeight;
		}

		return display;
	}

	public function addToDisplay(display:Bitmap):Void
	{
		if(fromBackBuffer)
			Engine.engine.root.parent.addChild(display);
		else
			Engine.engine.transitionLayer.addChild(display);
	}

	public function dispose():Void
	{
		if(bitmap != null)
		{
			bitmap.dispose();
			bitmap = null;
		}

		#if (lime_opengl || lime_opengles)
		if(texture != null)
		{
			texture.dispose();
			texture = null;
		}
		#end

		fromBackBuffer = false;
		width = 0;
		height = 0;
	}
}
