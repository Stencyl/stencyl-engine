package com.stencyl.models.scene.layers;

import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;

import com.stencyl.Config;
import com.stencyl.models.scene.ScrollingBitmap;
import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.background.ScrollingBackground;
import com.stencyl.utils.Log;

class BackgroundLayer extends RegularLayer
{
	public var model:ImageBackground;

	public var resourceID:Int;
	public var customScroll:Bool;

	public var isAnimated:Bool;
	public var frameCount:Int;
	
	public var currIndex:Int;
	public var currTime:Float;
	
	private var bgChild:DisplayObject; //Bitmap or ScrollingBitmap
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, resourceID:Int, customScroll:Bool) 
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		this.resourceID = resourceID;
		this.customScroll = customScroll;

		model = cast(Data.get().resources.get(resourceID), ImageBackground);
	}

	public function load()
	{
		if(model == null || model.frames.length == 0)
		{
			Log.warn("Warning: Could not load a background. Ignoring...");
            return;
		}
		
		var firstFrame = model.frames[0];

		currIndex = 0;
		currTime = 0;
		
		isAnimated = model.frames.length > 1;
		frameCount = model.frames.length;
		
		var parallaxX:Float = 0;
		var parallaxY:Float = 0;
		if(customScroll)
		{
			parallaxX = scrollFactorX;
			parallaxY = scrollFactorY;
		}
		else if(model.repeats)
		{
			parallaxX = model.parallaxX;
			parallaxY = model.parallaxY;
		}
		else
		{
			var bgWidth:Int = firstFrame.width;
			var bgHeight:Int = firstFrame.height;
			var screenWidth:Int = Std.int(Engine.screenWidth * Engine.SCALE);
			var screenHeight:Int = Std.int(Engine.screenHeight * Engine.SCALE);
			var sceneWidth:Int = Std.int(Engine.sceneWidth * Engine.SCALE);
			var sceneHeight:Int = Std.int(Engine.sceneHeight * Engine.SCALE);
			
			if(bgWidth > screenWidth && bgWidth < sceneWidth)
				parallaxX = 1 - ((sceneWidth - bgWidth) / (sceneWidth - screenWidth));
			
			if(bgHeight > screenHeight && bgHeight < sceneHeight)
				parallaxY = 1 - ((sceneHeight - bgHeight) / (sceneHeight - screenHeight));
		}

		if(Std.isOfType(model, ScrollingBackground))
		{
			var scroller = cast(model, ScrollingBackground);

			var img = new ScrollingBitmap(firstFrame, scroller.xVelocity, scroller.yVelocity, parallaxX, parallaxY, resourceID, model.repeats);
			addChild(bgChild = img);
		}
		else if(model.repeats)
		{
			var img = new ScrollingBitmap(firstFrame, 0, 0, parallaxX, parallaxY, resourceID);
			addChild(bgChild = img);
		}
		else
		{
			var bitmap = new Bitmap(firstFrame, PixelSnapping.AUTO, true);
			bitmap.smoothing = Config.antialias;
		
			scrollFactorX = parallaxX;
			scrollFactorY = parallaxY;

			addChild(bgChild = bitmap);
		}
	}

	public function loadFromImg(img:BitmapData, tiled:Bool)
	{
		model = new ScrollingBackground(-1, -1, "", [100], 0, 0, tiled, 0, 0);
		model.frames = [img];

		load();
	}

	public function setScrollFactor(x:Float, y:Float)
	{
		scrollFactorX = x;
		scrollFactorY = y;

		if(Std.isOfType(bgChild, ScrollingBitmap))
		{
			var bmp = cast(bgChild, ScrollingBitmap);
			bmp.parallaxX = x;
			bmp.parallaxY = y;
			bmp.parallax = (x  != 0 || y != 0);
		}
	}

	public function setScrollSpeed(x:Float, y:Float)
	{
		if(Std.isOfType(bgChild, ScrollingBitmap))
		{
			var bg = cast(bgChild, ScrollingBitmap);
			
			bg.xVelocity = x;
			bg.yVelocity = y;
			bg.scrolling = (x  != 0 || y != 0);
		}

		else
		{
			//TODO: Make it so you can set a non-scrolling background to scroll?
		}
	}

	public function reload(bgID:Int)
	{
		if(bgChild != null)
		{
			removeChild(bgChild);
			bgChild = null;
		}

		resourceID = bgID;

		model = cast(Data.get().resources.get(resourceID), ImageBackground);

		load();
	}
	
	public function setImage(bitmapData:BitmapData)
	{
		if(Std.isOfType(bgChild, ScrollingBitmap))
		{
			var bg = cast(bgChild, ScrollingBitmap);
			bg.setImage(bitmapData);
		}

		else
		{
			var bg = cast(bgChild, Bitmap);
			bg.bitmapData = bitmapData;
		}
		
		currIndex = 0;
		currTime = 0;
		
		isAnimated = model.frames.length > 1;
		frameCount = model.frames.length;
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
			
			if (Std.isOfType(bgChild, ScrollingBitmap))
			{
				var bg = cast(bgChild, ScrollingBitmap);
				bg.setImage(model.frames[currIndex]);
			}
			
			else
			{
				var bg = cast(bgChild, Bitmap);
				bg.bitmapData = bitmapData;
			}			
		}
	}

	override public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{
		if(Std.isOfType(bgChild, ScrollingBitmap))
		{
			var bg = cast(bgChild, ScrollingBitmap);
			bg.update(x, y, elapsedTime);
		}
		
		else
		{
			this.x = -Std.int(x * scrollFactorX);
			this.y = -Std.int(y * scrollFactorY);
		}
		
		if(isAnimated)
		{
			updateAnimation(elapsedTime);
		}
	}

	public function getBitmap():DisplayObject
	{
		return bgChild;
	}
}