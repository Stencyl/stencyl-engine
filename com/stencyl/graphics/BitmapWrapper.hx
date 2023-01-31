package com.stencyl.graphics;

import openfl.display.BitmapData;
#if !use_actor_tilemap
import openfl.display.Bitmap;
import openfl.display.Sprite;
#else
import openfl.display.Tile;
import openfl.display.TileContainer;
#end
import openfl.geom.Point;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Utils;

class BitmapWrapper extends #if use_actor_tilemap TileContainer #else Sprite #end implements EngineScaleUpdateListener
{
	#if !use_actor_tilemap
	public var img:Bitmap;
	#else
	public var img:Tile;
	#end

	private var offsetX:Float;
	private var offsetY:Float;

	public var cacheParentAnchor:Point = Utils.zero;
	
	@:isVar public var smoothing (get, set):Bool;
	@:isVar public var imgX (get, set):Float;
	@:isVar public var imgY (get, set):Float;
	
	@:isVar public var tweenProps (get, null):BitmapTweenProperties;

	public function new(img:BitmapData)
	{
		super();
		
		offsetX = 0;
		offsetY = 0;
		
		#if !use_actor_tilemap

		this.img = new Bitmap(img);
		addChild(this.img);

		#else

		var e = Engine.engine;
		var tilesetMapping = e.loadedBitmaps.get(img);
		if(tilesetMapping == null)
		{
			tilesetMapping = new BitmapTilesetMapping();
			e.loadedBitmaps.set(img, tilesetMapping);
		}
		if(!tilesetMapping.tilesetInitialized)
		{
			while(e.nextTileset >= e.actorTilesets.length)
			{
				e.actorTilesets.push(new DynamicTileset());
			}
			if(!tilesetMapping.initializeInTileset(img, e.actorTilesets[e.nextTileset]))
			{
				e.actorTilesets.push(new DynamicTileset());
				tilesetMapping.initializeInTileset(img, e.actorTilesets[++e.nextTileset]);
			}
		}

		this.img = new Tile();
		this.img.tileset = tilesetMapping.tileset.tileset;
		this.img.id = tilesetMapping.frameIndexOffset;
		addTile(this.img);

		#end
	}

	public function set_imgX(x:Float):Float
	{
		this.x = (x + offsetX) * Engine.SCALE - cacheParentAnchor.x;

		return imgX = x;
	}
	
	public function get_imgX():Float
	{
		return imgX;
	}

	public function set_imgY(y:Float):Float
	{
		this.y = (y + offsetY) * Engine.SCALE - cacheParentAnchor.y;

		return imgY = y;
	}
	
	public function get_imgY():Float
	{
		return imgY;
	}

	public function set_smoothing(smoothing:Bool):Bool
	{
		#if !use_actor_tilemap
		return img.smoothing = smoothing;
		#else
		return this.smoothing = smoothing;
		#end
	}
	
	public function get_smoothing():Bool
	{
		#if !use_actor_tilemap
		return img.smoothing;
		#else
		return this.smoothing;
		#end
	}

	public function setOrigin(x:Float, y:Float):Void
	{
		this.x += (x - offsetX) * Engine.SCALE;
		this.y += (y - offsetY) * Engine.SCALE;
		offsetX = x;
		offsetY = y;

		img.x = -x * Engine.SCALE;
		img.y = -y * Engine.SCALE;
	}

	public function updateScale():Void
	{
		updatePosition();
	}

	public function updatePosition():Void
	{
		x = (imgX + offsetX) * Engine.SCALE - cacheParentAnchor.x;
		y = (imgY + offsetY) * Engine.SCALE - cacheParentAnchor.y;
	}
	
	public function get_tweenProps():BitmapTweenProperties
	{
		if(tweenProps == null)
			tweenProps = new BitmapTweenProperties(this);
		return tweenProps;
	}
}

class BitmapTweenProperties
{
	public var xy:TweenFloat2;
	public var angle:TweenFloat;
	public var alpha:TweenFloat;
	public var scaleXY:TweenFloat2;
	
	private var bmp:BitmapWrapper;
	
	public function new(bmp:BitmapWrapper)
	{
		this.bmp = bmp;
		
		xy = cast new TweenFloat2().doOnUpdate(onUpdateXY);
		angle = cast new TweenFloat().doOnUpdate(onUpdateAngle);
		alpha = cast new TweenFloat().doOnUpdate(onUpdateAlpha);
		scaleXY = cast new TweenFloat2().doOnUpdate(onUpdateScaleXY);
	}
	
	public function pause()
	{
		xy.paused = true;
		angle.paused = true;
		alpha.paused = true;
		scaleXY.paused = true;
	}
	
	public function unpause()
	{
		xy.paused = false;
		angle.paused = false;
		alpha.paused = false;
		scaleXY.paused = false;
	}
	
	public function cancel()
	{
		if(xy.active)
			TweenManager.cancel(xy);
		if(angle.active)
			TweenManager.cancel(angle);
		if(alpha.active)
			TweenManager.cancel(alpha);
		if(scaleXY.active)
			TweenManager.cancel(scaleXY);
	}
	
	function onUpdateXY():Void { bmp.imgX = xy.value1; bmp.imgY = xy.value2; }
	function onUpdateAngle():Void { bmp.rotation = angle.value; }
	function onUpdateAlpha():Void { bmp.alpha = alpha.value; }
	function onUpdateScaleXY():Void { bmp.scaleX = scaleXY.value1; bmp.scaleY = scaleXY.value2; }
}