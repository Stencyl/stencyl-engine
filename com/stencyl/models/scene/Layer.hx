package com.stencyl.models.scene;

import com.stencyl.graphics.BitmapWrapper;
import com.stencyl.utils.Utils;
import com.stencyl.Config;

import openfl.display.Sprite;
import openfl.geom.ColorTransform;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
#if use_actor_tilemap
import openfl.display.Tilemap;
#end

import com.stencyl.models.scene.layers.RegularLayer;

class Layer extends RegularLayer
{
	#if use_actor_tilemap
	public var frontImageLayer:Tilemap;
	public var backImageLayer:Tilemap;
	private var _width:Int;
	private var _height:Int;
	#end

	//Tiles
	public var tiles:TileLayer;
	//Actors
	public var actorContainer:ActorLayer;
	//Custom Drawing
	public var overlay:DrawingLayer;
	//Images
	public var attachedImages:Array<BitmapWrapper>;
	
	public var cameraMoved:Bool = true;
	public var cameraOldX:Float = -1;
	public var cameraOldY:Float = -1;
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, tileLayer:TileLayer #if use_actor_tilemap , width:Int, height:Int #end)
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		
		tiles = tileLayer;
		if(tiles != null) //null only for HUD layer
		{
			tiles.name = name + " - TileLayer";
			tiles.blendMode = blendMode;
		}

		actorContainer = new ActorLayer(#if (use_actor_tilemap) Std.int(width * Engine.SCALE), Std.int(height * Engine.SCALE), null, Config.antialias #end);
		actorContainer.name = name + " - ActorLayer";
		#if (use_actor_tilemap) actorContainer.tileColorTransformEnabled = false; #end
		overlay = new DrawingLayer();
		overlay.name = name + " - Overlay";

		if(tiles != null) addChild(tiles);
		addChild(actorContainer);
		addChild(overlay);
		
		attachedImages = new Array<BitmapWrapper>();

		#if (use_actor_tilemap)
		_width = width;
		_height = height;
		#end
	}

	override public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{	
		var xScrolled:Float = 0;
		var yScrolled:Float = 0;
		var tempX:Float = 0;
		var tempY:Float = 0;
		
		if (Config.pixelsnap)
		{
			xScrolled = Std.int(x * scrollFactorX);
			yScrolled = Std.int(y * scrollFactorY);

			x = Math.round(x);
			y = Math.round(y);
			
			this.x = -Std.int(x * scrollFactorX);
			this.y = -Std.int(y * scrollFactorY);
			
			tempX = Std.int(xScrolled / (Engine.engine.scene.tileWidth * Engine.SCALE));
			tempY = Std.int(yScrolled / (Engine.engine.scene.tileHeight * Engine.SCALE));
		}
		else
		{
			xScrolled = x * scrollFactorX;
			yScrolled = y * scrollFactorY;

			this.x = -x * scrollFactorX;
			this.y = -y * scrollFactorY;
			
			tempX = xScrolled / (Engine.engine.scene.tileWidth * Engine.SCALE);
			tempY = yScrolled / (Engine.engine.scene.tileHeight * Engine.SCALE);
		}
		
		tiles.setPosition(xScrolled, yScrolled);
		overlay.x = x;
		overlay.y = y;
		
		cameraMoved = cameraMoved || cameraOldX != tempX || cameraOldY != tempY;
		
		cameraOldX = tempX;
		cameraOldY = tempY;
	}

	#if use_actor_tilemap
	public function getFrontImageLayer():Tilemap
	{
		if(frontImageLayer == null)
		{
			frontImageLayer = new Tilemap(Std.int(_width * Engine.SCALE), Std.int(_height * Engine.SCALE), null, Config.antialias);
			frontImageLayer.name = name + " - Front ImageLayer";
			frontImageLayer.tileColorTransformEnabled = false;
			addChild(frontImageLayer);
		}
		return frontImageLayer;
	}

	public function getBackImageLayer():Tilemap
	{
		if(backImageLayer == null)
		{
			backImageLayer = new Tilemap(Std.int(_width * Engine.SCALE), Std.int(_height * Engine.SCALE), null, Config.antialias);
			backImageLayer.name = name + " - Back ImageLayer";
			backImageLayer.tileColorTransformEnabled = false;
			addChildAt(backImageLayer, 0);
		}
		return backImageLayer;
	}

	public function setSize(width:Int, height:Int):Void
	{
		_width = width;
		_height = height;

		var scaledWidth = Std.int(width * Engine.SCALE);
		var scaledHeight = Std.int(height * Engine.SCALE);

		actorContainer.width = scaledWidth;
		actorContainer.height = scaledHeight;
		if(frontImageLayer != null)
		{
			frontImageLayer.width = scaledWidth;
			frontImageLayer.height = scaledHeight;
		}
		if(backImageLayer != null)
		{
			backImageLayer.width = scaledWidth;
			backImageLayer.height = scaledHeight;
		}
	}
	#end
	
	public function clear()
	{
		#if use_actor_tilemap
		
		for(b in attachedImages)
		{
			if(b.parent != null) b.parent.removeTile(b);
		}
		attachedImages = new Array<BitmapWrapper>();
		
		Utils.removeAllTiles(actorContainer);
		if(frontImageLayer != null) Utils.removeAllTiles(frontImageLayer);
		if(backImageLayer != null) Utils.removeAllTiles(backImageLayer);

		#else
		
		for(b in attachedImages)
		{
			removeChild(b);
		}
		attachedImages = new Array<BitmapWrapper>();
		
		Utils.removeAllChildren(actorContainer);

		#end

		overlay.clearFrame();
		
		if(tiles != null)
		{
			tiles.clear();
		}
	}
}
