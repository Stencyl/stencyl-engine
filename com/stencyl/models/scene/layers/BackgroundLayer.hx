package com.stencyl.models.scene.layers;

import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;

import com.stencyl.models.scene.ScrollingBitmap;
import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.background.ScrollingBackground;

//TODO:
//Botched implementation of drawTiles
//Wrong because tilesheet only contains one frame at a time (not ideal)
//Also doesn't even draw/work. (==SEE BELOW==)

class BackgroundLayer extends RegularLayer
{
	public var model:ImageBackground;
	public var bitmap:Bitmap;

	public var resourceID:Int;
	public var customScroll:Bool;

	public var isAnimated:Bool;
	public var frameCount:Int;
	
	public var currIndex:Int;
	public var currTime:Float;
	
	public var cacheWidth:Float;
	public var cacheHeight:Float;

	private var bgChild:Dynamic; //Bitmap or ScrollingBitmap
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, resourceID:Int, customScroll:Bool) 
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		this.resourceID = resourceID;
		this.customScroll = customScroll;

		model = cast(Data.get().resources.get(resourceID), ImageBackground);
	}

	public function load()
	{
		if(model == null || model.img == null)
		{
			trace("Warning: Could not load a background. Ignoring...");
            return;
		}

		bitmap = new Bitmap(model.img, PixelSnapping.AUTO, true);
		bitmap.smoothing = scripts.MyAssets.antialias;
		
		currIndex = 0;
		currTime = 0;
		
		isAnimated = model.frames.length > 1;
		frameCount = model.frames.length;

		if(model.repeats && !model.repeated)
		{
			model.drawRepeated(this, Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		}
		
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
			var bgWidth:Int = model.img.width;
			var bgHeight:Int = model.img.height;
			var screenWidth:Int = Std.int(Engine.screenWidth * Engine.SCALE);
			var screenHeight:Int = Std.int(Engine.screenHeight * Engine.SCALE);
			var sceneWidth:Int = Std.int(Engine.sceneWidth * Engine.SCALE);
			var sceneHeight:Int = Std.int(Engine.sceneHeight * Engine.SCALE);
			
			if(bgWidth > screenWidth && bgWidth < sceneWidth)
				parallaxX = 1 - ((sceneWidth - bgWidth) / (sceneWidth - screenWidth));
			
			if(bgHeight > screenHeight && bgHeight < sceneHeight)
				parallaxY = 1 - ((sceneHeight - bgHeight) / (sceneHeight - screenHeight));
		}

		if(Std.is(model, ScrollingBackground))
		{
			var scroller = cast(model, ScrollingBackground);

			var img = new ScrollingBitmap(model.img, scroller.xVelocity, scroller.yVelocity, parallaxX, parallaxY, resourceID);
			addChild(bgChild = img);
		}
		else if(model.repeats)
		{
			var img = new ScrollingBitmap(model.img, 0, 0, parallaxX, parallaxY, resourceID);
			addChild(bgChild = img);
		}
		else
		{
			cacheWidth = model.img.width;
			cacheHeight = model.img.height;
			scrollFactorX = parallaxX;
			scrollFactorY = parallaxY;

			addChild(bgChild = bitmap);
		}
	}

	public function loadFromImg(img:BitmapData, tiled:Bool)
	{
		model = new ScrollingBackground(-1, -1, "", [100], 0, 0, tiled, 0, 0);
		model.img = img;
		model.frames = [img];

		load();
	}

	public function setScrollFactor(x:Float, y:Float)
	{
		scrollFactorX = x;
		scrollFactorY = y;

		if(Std.is(bgChild, ScrollingBitmap))
		{
			var bmp = cast(bgChild, ScrollingBitmap);
			bmp.parallaxX = x;
			bmp.parallaxY = y;
		}
	}

	public function setScrollSpeed(x:Float, y:Float)
	{
		if(Std.is(bgChild, ScrollingBitmap))
		{
			var bg = cast(bgChild, ScrollingBitmap);
			
			bg.xVelocity = x;
			bg.yVelocity = y;
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
		bitmap.bitmapData = bitmapData;
		
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
			
			if (Std.is(bgChild, ScrollingBitmap))
			{
				var b:Bitmap = bgChild.image1;
				b.bitmapData = model.frames[currIndex];				
				b = bgChild.image2;
				b.bitmapData = model.frames[currIndex];		
				b = bgChild.image3;
				b.bitmapData = model.frames[currIndex];
				b = bgChild.image4;
				b.bitmapData = model.frames[currIndex];
				b = bgChild.image5;
				b.bitmapData = model.frames[currIndex];
				b = bgChild.image6;
				b.bitmapData = model.frames[currIndex];
				b = bgChild.image7;
				b.bitmapData = model.frames[currIndex];
				b = bgChild.image8;
				b.bitmapData = model.frames[currIndex];
				b = bgChild.image9;
				b.bitmapData = model.frames[currIndex];				
			}
			
			else
			{
				bitmap.bitmapData = model.frames[currIndex];
			}			
		}
	}

	override public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{
		if(Std.is(bgChild, ScrollingBitmap))
		{
			var bg = cast(bgChild, ScrollingBitmap);
			bg.update(x, y, elapsedTime);
		}
		
		else
		{
			this.x = Std.int(x * scrollFactorX);
			this.y = Std.int(y * scrollFactorY);
		}
		
		if(isAnimated)
		{
			updateAnimation(elapsedTime);
		}
	}

	public function getBitmap():Dynamic
	{
		return bgChild;
	}
}

/*************************************\
* ==========   OLD   =================|
\*************************************/

/*
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;

import com.stencyl.models.background.ImageBackground;

//TODO:
//Botched implementation of drawTiles
//Wrong because tilesheet only contains one frame at a time (not ideal)
//Also doesn't even draw/work.

#if(flash || js || cpp)

#else
import openfl.display.Tilesheet;
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
		dummy.smoothing = scripts.MyAssets.antialias;
		addChild(dummy);
		#end

		this.model = model;
		this.smoothing = scripts.MyAssets.antialias;
		
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
*/