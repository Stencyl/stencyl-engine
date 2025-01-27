package com.stencyl.models.scene.layers;

import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;
#if use_actor_tilemap
import openfl.display.Tile;
import openfl.display.Tilemap;
#end

import com.stencyl.Config;
import com.stencyl.graphics.TileSource;
import com.stencyl.models.scene.ScrollingBitmap;
import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.background.ScrollingBackground;
import com.stencyl.utils.Log;

#if (haxe_ver >= 4.1)
import Std.isOfType as isOfType;
#else
import Std.is as isOfType;
#end

class BackgroundLayer extends RegularLayer
{
	public var model:ImageBackground;

	public var resourceID:Int;
	public var customScroll:Bool;

	public var isAnimated:Bool;
	public var frameCount:Int;
	
	public var currIndex:Int;
	public var currTime:Float;
	
	#if use_actor_tilemap
	private var tilemap:Tilemap;
	#end
	
	//if DisplayObject, it's either Bitmap or ScrollingBitmap (which extends Sprite)
	//if Tile, it's either Tile or ScrollingBitmap (which extends TileContainer)
	private var bgChild: #if use_actor_tilemap Tile #else DisplayObject #end;
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, resourceID:Int, customScroll:Bool) 
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		this.resourceID = resourceID;
		this.customScroll = customScroll;

		model = cast(Data.get().resources.get(resourceID), ImageBackground);
		
		#if use_actor_tilemap
		tilemap = new Tilemap(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE), null, Config.antialias);
		tilemap.name = name + " - Background";
		tilemap.tileColorTransformEnabled = false;

		addChild(tilemap);
		#end
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

		if(isOfType(model, ScrollingBackground))
		{
			var scroller = cast(model, ScrollingBackground);

			var img = new ScrollingBitmap(firstFrame, scroller.xVelocity, scroller.yVelocity, parallaxX, parallaxY, resourceID, model.repeats);
			#if use_actor_tilemap
			tilemap.addTile(bgChild = img);
			#else
			addChild(bgChild = img);
			#end
		}
		else if(model.repeats)
		{
			var img = new ScrollingBitmap(firstFrame, 0, 0, parallaxX, parallaxY, resourceID);
			#if use_actor_tilemap
			tilemap.addTile(bgChild = img);
			#else
			addChild(bgChild = img);
			#end
		}
		else
		{
			#if use_actor_tilemap
			
			var ts = TileSource.fromBitmapData(firstFrame);
			var tile = new Tile();
			tile.tileset = ts.tileset;
			tile.id = ts.tileID;
			
			tilemap.addTile(bgChild = tile);
			
			#else
			
			var bitmap = new Bitmap(firstFrame, PixelSnapping.AUTO, true);
			bitmap.smoothing = Config.antialias;
			
			addChild(bgChild = bitmap);
			
			#end
		
			scrollFactorX = parallaxX;
			scrollFactorY = parallaxY;
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

		if(isOfType(bgChild, ScrollingBitmap))
		{
			var bmp = cast(bgChild, ScrollingBitmap);
			bmp.parallaxX = x;
			bmp.parallaxY = y;
			bmp.parallax = (x  != 0 || y != 0);
		}
	}

	public function setScrollSpeed(x:Float, y:Float)
	{
		if(isOfType(bgChild, ScrollingBitmap))
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
			#if use_actor_tilemap
			tilemap.removeTile(bgChild);
			#else
			removeChild(bgChild);
			#end
			bgChild = null;
		}

		resourceID = bgID;

		model = cast(Data.get().resources.get(resourceID), ImageBackground);

		load();
	}
	
	public function setImage(bitmapData:BitmapData)
	{
		if(isOfType(bgChild, ScrollingBitmap))
		{
			var bg = cast(bgChild, ScrollingBitmap);
			bg.setImage(bitmapData);
		}

		else
		{
			#if use_actor_tilemap
			var ts = TileSource.fromBitmapData(bitmapData);
			bgChild.tileset = ts.tileset;
			bgChild.id = ts.tileID;
			#else
			var bg = cast(bgChild, Bitmap);
			bg.bitmapData = bitmapData;
			#end
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
			
			if (isOfType(bgChild, ScrollingBitmap))
			{
				var bg = cast(bgChild, ScrollingBitmap);
				bg.setImage(model.frames[currIndex]);
			}
			
			else
			{
				#if use_actor_tilemap
				var ts = TileSource.fromBitmapData(model.frames[currIndex]);
				bgChild.tileset = ts.tileset;
				bgChild.id = ts.tileID;
				#else
				var bg = cast(bgChild, Bitmap);
				bg.bitmapData = model.frames[currIndex];
				#end
			}			
		}
	}

	override public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{
		if(isOfType(bgChild, ScrollingBitmap))
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

	public function getBitmap():#if use_actor_tilemap Tile #else DisplayObject #end
	{
		return bgChild;
	}
}