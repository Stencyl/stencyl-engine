package com.stencyl.graphics;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
#if !flash
import openfl.display.Shader;
#end
#if !use_actor_tilemap
import openfl.display.Sprite;
#else
import openfl.display.Tile;
import openfl.display.TileContainer;
#end
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;

import com.stencyl.Engine;
import com.stencyl.graphics.ColorMatrixShader;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.ColorMatrix;
import com.stencyl.utils.Log;
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

	#if !flash
	private var bitmapFilters:Array<BitmapFilter>;
	private var filtersAsShader:Shader;
	private var usingSoftwareFilter:Bool;
	@:isVar public var filtersWrapper (get, set):Array<BitmapFilter>;
	#end

	public function new(?img:Bitmap, ?imgData:BitmapData #if use_actor_tilemap , ?imgTile:Tile #end)
	{
		super();
		
		offsetX = 0;
		offsetY = 0;
		
		if(img != null)
		{
			initializeFromBitmap(img);
		}
		else if(imgData != null)
		{
			initializeFromBitmapData(imgData);
		}
		#if use_actor_tilemap
		else if(imgTile != null)
		{
			initializeFromTile(imgTile);
		}
		#end
		else
		{
			Log.error("Couldn't initialize bitmap wrapper");
		}
	}

	private function initializeFromBitmap(img:Bitmap)
	{
		#if !use_actor_tilemap

		this.img = img;
		addChild(img);

		#else

		initializeFromBitmapData(img.bitmapData);

		#end
	}	

	private function initializeFromBitmapData(img:BitmapData)
	{
		#if !use_actor_tilemap

		initializeFromBitmap(new Bitmap(img));

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

		var tile = new Tile();
		tile.tileset = tilesetMapping.tileset.tileset;
		tile.id = tilesetMapping.frameIndexOffset;
		initializeFromTile(tile);

		#end
	}

	#if use_actor_tilemap
	private function initializeFromTile(tile:Tile)
	{
		this.img = tile;
		addTile(this.img);
	}
	#end

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

	public function get_filtersWrapper():Array<BitmapFilter>
	{
		if(filtersWrapper == null)
			return [];
		return filtersWrapper.copy();
	}

	public function set_filtersWrapper(value:Array<BitmapFilter>):Array<BitmapFilter>
	{
		if(value == null || value.length == 0)
		{
			#if flash
				filters = [];
			#else
				bitmapFilters = null;
				usingSoftwareFilter = false;
				filtersAsShader = null;
				img.shader = null;
			#end

			return [];
		}

		#if flash
			filters = filters.concat(value);
			return filters;
		#else
			if(bitmapFilters == null)
				bitmapFilters = [];
			bitmapFilters = bitmapFilters.concat(value);
			usingSoftwareFilter = Lambda.exists(bitmapFilters, f -> !Std.is(f, ColorMatrixFilter));

			if(!usingSoftwareFilter)
			{
				var cm = new ColorMatrix();
				var first = true;
				for(f in bitmapFilters)
				{
					var cmf = cast(f, ColorMatrixFilter);
					if(first)
						cm.matrix = cmf.matrix;
					else
					{
						var cm2 = new ColorMatrix();
						cm2.matrix = cmf.matrix;
						var cm3 = new ColorMatrix();
						
						ColorMatrix.mulMatrixMatrix(cm, cm2, cm3);
						cm = cm3;
					}
				}
				var cms = new ColorMatrixShader();
				cms.init(cm.matrix);
				filtersAsShader = cms;
			}
			else
			{
				filtersAsShader = null;
			}
			
			if(usingSoftwareFilter)
			{
				#if use_actor_tilemap
				Log.error("software filters not implemented");
				#else
				filters = bitmapFilters;
				#end
			}
			img.shader = filtersAsShader;
			return bitmapFilters;
		#end
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