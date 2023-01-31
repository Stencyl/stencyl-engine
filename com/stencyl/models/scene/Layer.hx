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
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, tileLayer:TileLayer #if use_actor_tilemap , sceneWidth:Int, sceneHeight:Int #end)
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		
		tiles = tileLayer;
		if(tiles != null) //null only for HUD layer
		{
			tiles.name = name + " - TileLayer";
			tiles.blendMode = blendMode;
		}

		actorContainer = new ActorLayer(#if (use_actor_tilemap) sceneWidth, sceneHeight, null, Config.antialias #end);
		actorContainer.name = name + " - ActorLayer";
		#if (use_actor_tilemap) actorContainer.tileColorTransformEnabled = false; #end
		overlay = new Sprite();
		overlay.name = name + " - Overlay";

		if(tiles != null) addChild(tiles);
		addChild(actorContainer);
		addChild(overlay);
		
		attachedImages = new Array<BitmapWrapper>();
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
