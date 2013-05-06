package com.stencyl.models.scene.layers;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.PixelSnapping;

import com.stencyl.models.background.ImageBackground;

//TODO:
//Botched implementation of drawTiles
//Wrong because tilesheet only contains one frame at a time (not ideal)
//Also doesn't even draw/work.

#if(flash || js || cpp)

#else
import nme.display.Tilesheet;
#end

#if(flash || js || cpp)
class BackgroundLayer extends Bitmap 
#else
class BackgroundLayer extends Sprite 
#end
{	
	public var model:ImageBackground;
	
	public var isAnimated:Bool;
	public var frameCount:Int;
	
	public var currIndex:Int;
	public var currTime:Float;
	
	public var cacheWidth:Float;
	public var cacheHeight:Float;
	
	#if(flash || js || cpp)

	#else
	public var sheet:Tilesheet;
	public var data:Array<Float>;
	#end

	public function new(bitmapData:BitmapData, model:ImageBackground) 
	{
		#if(flash || js || cpp)
		super(bitmapData, PixelSnapping.AUTO, true);
		#else
		super();
		this.sheet = new Tilesheet(bitmapData);
		data = [0.0, 0.0, 0];
		
		var dummy = new Bitmap(model.img);
		addChild(dummy);
		#end

		this.model = model;
		
		currIndex = 0;
		currTime = 0;
		
		isAnimated = model.frames.length > 1;
		frameCount = model.frames.length;
		
		#if(flash || js || cpp)
		#else
		updateAnimation(0);
		#end
	}
	
	public function setImage(bitmapData:BitmapData)
	{
		#if(flash || js || cpp)
		this.bitmapData = bitmapData;
		#else
		this.sheet = new Tilesheet(bitmapData);
		data = [0.0, 0.0, 0];
		#end
		
		currIndex = 0;
		currTime = 0;
		
		isAnimated = model.frames.length > 1;
		frameCount = model.frames.length;
		
		#if(flash || js || cpp)
		#else
		updateAnimation(0);
		#end
	}
	
	public function updateAnimation(elapsedTime:Float)
	{
		currTime += elapsedTime;

		if(model != null && currTime >= model.durations[currIndex])
		{
			currTime = 0;
			currIndex++;
			
			if(currIndex >= frameCount)
			{
				currIndex = 0;
			}
			
			#if(flash || js || cpp)
			bitmapData = model.frames[currIndex];
			#else
			data[0] = 0;
			data[1] = 0;
			data[2] = currIndex;
	
	  		graphics.clear();
	  		sheet.drawTiles(graphics, data, true);
			#end
		}
	}
}
