package com.stencyl.models.scene.layers;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.PixelSnapping;

import com.stencyl.models.background.ImageBackground;

//TODO: Use drawTiles on CPP/Mobile
class BackgroundLayer extends Bitmap 
{	
	public var model:ImageBackground;
	
	public var isAnimated:Bool;
	public var frameCount:Int;
	
	public var currIndex:Int;
	public var currTime:Float;
	
	public var cacheWidth:Float;
	public var cacheHeight:Float;

	public function new(?bitmapData:BitmapData, ?model:ImageBackground) 
	{
		super(bitmapData, PixelSnapping.AUTO, true);
		this.model = model;
		
		currIndex = 0;
		currTime = 0;
		
		isAnimated = model.frames.length > 1;
		frameCount = model.frames.length;
	}
	
	public function updateAnimation(elapsedTime:Float)
	{
		currTime += elapsedTime;
			
		if(currTime >= model.durations[currIndex])
		{
			currTime = 0;
			currIndex++;
			
			if(currIndex >= frameCount)
			{
				currIndex = 0;
			}
			
			bitmapData = model.frames[currIndex];
		}
	}
}
