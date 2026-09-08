package com.stencyl.graphics.transitions;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;

class PixelizeTransition extends Transition
{
	private var pixelSizeTween:TweenFloat;
	private var beginPixelSize:Int;
	private var endPixelSize:Int;
	private var displayImg:BitmapData;
	private var displayBitmap:Bitmap;
	private var drawMatrix:Matrix;
	private var drawRect:Rectangle;
	private var bufferWidth:Int;
	private var bufferHeight:Int;

	public function new(duration:Float, beginPixelSize:Int, endPixelSize:Int)
	{
		super(duration);
		this.beginPixelSize = beginPixelSize;
		this.endPixelSize = endPixelSize;
	}

	override public function start()
	{
		active = true;
		drawMatrix = new Matrix();
		drawRect = new Rectangle();

		var screenWidth:Int = Std.int(Engine.screenWidth * Engine.SCALE);
		var screenHeight:Int = Std.int(Engine.screenHeight * Engine.SCALE);
		var smallestPixel:Int = Std.int(Math.min(beginPixelSize, endPixelSize));
		if(smallestPixel < 2) smallestPixel = 2;

		if(Math.max(beginPixelSize, endPixelSize) > 1)
		{
			bufferWidth = Math.ceil(screenWidth / smallestPixel);
			bufferHeight = Math.ceil(screenHeight / smallestPixel);
			displayImg = new BitmapData(bufferWidth, bufferHeight, true, 0x00000000);
			displayBitmap = new Bitmap(displayImg);
			displayBitmap.smoothing = false;
			Engine.engine.transitionLayer.addChild(displayBitmap);
		}

		pixelSizeTween = new TweenFloat();
		pixelSizeTween.tween(beginPixelSize, endPixelSize, Easing.linear, Std.int(duration * 1000)).doOnComplete(stop);
	}

	override public function draw(g:Graphics)
	{
		if(displayBitmap == null) return;

		var pixelSize:Int = Std.int(pixelSizeTween.value);
		if(pixelSize < 1) pixelSize = 1;

		if(pixelSize == 1)
		{
			displayBitmap.visible = false;
			return;
		}

		displayBitmap.visible = true;

		var screenWidth:Int = Std.int(Engine.screenWidth * Engine.SCALE);
		var screenHeight:Int = Std.int(Engine.screenHeight * Engine.SCALE);
		var columns:Int = Math.ceil(screenWidth / pixelSize);
		var rows:Int = Math.ceil(screenHeight / pixelSize);
		var xOverflow:Float = columns * pixelSize - screenWidth;
		var yOverflow:Float = rows * pixelSize - screenHeight;

		drawRect.setTo(0, 0, columns, rows);
		displayImg.fillRect(drawRect, 0x00000000);

		drawMatrix.setTo(
			1 / pixelSize,
			0,
			0,
			1 / pixelSize,
			xOverflow / (2 * pixelSize),
			yOverflow / (2 * pixelSize)
		);

		displayImg.draw(Engine.engine.colorLayer, drawMatrix, null, null, drawRect, false);
		displayImg.draw(Engine.engine.master, drawMatrix, null, null, drawRect, false);

		displayBitmap.scrollRect = drawRect;
		displayBitmap.x = -xOverflow / 2;
		displayBitmap.y = -yOverflow / 2;
		displayBitmap.scaleX = pixelSize;
		displayBitmap.scaleY = pixelSize;
	}

	override public function cleanup()
	{
		pixelSizeTween = null;
		drawMatrix = null;
		drawRect = null;

		if(displayBitmap != null)
		{
			if(displayBitmap.parent != null) displayBitmap.parent.removeChild(displayBitmap);
			displayBitmap.bitmapData = null;
			displayBitmap = null;
		}

		if(displayImg != null)
		{
			displayImg.dispose();
			displayImg = null;
		}

		bufferWidth = 0;
		bufferHeight = 0;
	}
}
