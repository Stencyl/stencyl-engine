package com.stencyl.models.scene;

import com.stencyl.graphics.BitmapWrapper;
import com.stencyl.utils.Utils;
import com.stencyl.Config;

import openfl.display.Sprite;
import openfl.geom.ColorTransform;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

import com.stencyl.models.scene.layers.RegularLayer;

class Layer extends RegularLayer
{
	//Tiles
	public var tiles:TileLayer;
	//Actors
	public var actorContainer:ActorLayer;
	//Custom Drawing
	public var overlay:Sprite;
	//Images
	public var attachedImages:Array<BitmapWrapper>;
	
	public var cameraMoved:Bool = true;
	public var cameraOldX:Float = -1;
	public var cameraOldY:Float = -1;
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, tileLayer:TileLayer)
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		
		tiles = tileLayer;
		if(tiles != null) //null only for HUD layer
		{
			tiles.blendMode = blendMode;
		}

		actorContainer = new ActorLayer(#if (use_actor_tilemap) 0, 0, null, Config.antialias #end);
		#if (use_actor_tilemap) actorContainer.tileColorTransformEnabled = false; #end
		overlay = new Sprite();

		if(tiles != null) addChild(tiles);
		addChild(actorContainer);
		addChild(overlay);
		
		attachedImages = new Array<BitmapWrapper>();
	}

	override public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{	
		if(Config.pixelsnap) x = Math.round(x);
		if(Config.pixelsnap) y = Math.round(y);	
		
		var xScrolled = x * scrollFactorX;
		var yScrolled = y * scrollFactorY;

		overlay.x = x;
		overlay.y = y;
		tiles.setPosition(xScrolled, yScrolled);
		
		this.x = -x * scrollFactorX;
		this.y = -y * scrollFactorY;
		
		var tempX = xScrolled / (Engine.engine.scene.tileWidth * Engine.SCALE);
		var tempY = yScrolled / (Engine.engine.scene.tileHeight * Engine.SCALE);
		
		cameraMoved = cameraMoved || cameraOldX != tempX || cameraOldY != tempY;
		
		cameraOldX = tempX;
		cameraOldY = tempY;
	}
	
	public function clear()
	{
		for(b in attachedImages)
		{
			removeChild(b);
		}
		attachedImages = new Array<BitmapWrapper>();
		
		#if use_actor_tilemap
		Utils.removeAllTiles(actorContainer);
		#else
		Utils.removeAllChildren(actorContainer);
		#end
		
		overlay.graphics.clear();
		
		if(tiles != null)
		{
			tiles.clear();
		}
	}
}
