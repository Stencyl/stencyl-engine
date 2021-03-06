package com.stencyl.graphics.transitions;

import openfl.geom.Rectangle;
import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Shape;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;

class PixelizeTransition extends Transition
{
	private var pixelSizeTween:TweenFloat;
		
	private var beginPixelSize:Int;
	private var endPixelSize:Int;
	
	private var srcImg:BitmapData;
	private var displayImg:BitmapData;
	private var displayBitmap:Bitmap;
	
	private var c:Int;
	private var r:Int;
			
	private var xOverflow:Int;
	private var yOverflow:Int;
			
	private var pixelRect:Rectangle;
	private var halfSize:Int;
	
	public function new(duration:Float, beginPixelSize:Int, endPixelSize:Int) 
	{
		super(duration);
			
		this.beginPixelSize = beginPixelSize;
		this.endPixelSize = endPixelSize;
	}
	
	override public function start()
	{
		active = true;
		
		srcImg = new BitmapData(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		displayImg = new BitmapData(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		pixelRect = new Rectangle(0, 0, 0, 0);		
		
		Engine.engine.transitionLayer.addChild(displayBitmap = new Bitmap(displayImg));
		
		pixelSizeTween = new TweenFloat();
		pixelSizeTween.tween(beginPixelSize, endPixelSize, Easing.linear, Std.int(duration*1000)).doOnComplete(stop);
	}
	
	override public function draw(g:Graphics)
	{
		var pixelSize:Int = Std.int(pixelSizeTween.value);
		
		if(pixelSize == 1)
		{
			displayImg.draw(Engine.engine.colorLayer);
			displayImg.draw(Engine.engine.master);
		
			return;
		}
		
		srcImg.draw(Engine.engine.colorLayer);
		srcImg.draw(Engine.engine.master);
		
		c = Math.ceil((Engine.screenWidth * Engine.SCALE) / pixelSize);
		r = Math.ceil((Engine.screenHeight * Engine.SCALE) / pixelSize);
			
		xOverflow = Std.int(c * pixelSize - (Engine.screenWidth * Engine.SCALE));
		yOverflow = Std.int(r * pixelSize - (Engine.screenHeight * Engine.SCALE));
			
		pixelRect.x = -xOverflow / 2;
		pixelRect.y = -yOverflow / 2;
		pixelRect.height = pixelRect.width = pixelSize;
		
		halfSize = Std.int(pixelSize / 2);
		
		var color = 0;
		
		displayImg.lock();
		
		for(i in 0...r)
		{
			for(j in 0...c)
			{
				color = srcImg.getPixel32(Std.int(pixelRect.x + halfSize), Std.int(pixelRect.y + halfSize));
				for(k in Std.int(pixelRect.x)...Std.int(pixelRect.x+pixelRect.width))
				{
					for(l in Std.int(pixelRect.y)...Std.int(pixelRect.y+pixelRect.height))
					{
						displayImg.setPixel32(k, l, color);
					}
				}
				
				pixelRect.x += pixelSize;
			}
			
			pixelRect.x = -xOverflow / 2;
			pixelRect.y += pixelSize;
		}
		
		displayImg.unlock();
	}
	
	override public function cleanup()
	{
		if(displayBitmap != null)
		{
			Engine.engine.transitionLayer.removeChild(displayBitmap);
		}
	}
	
}