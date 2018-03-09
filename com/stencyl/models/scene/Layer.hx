package com.stencyl.models.scene;

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
	
	public var cameraMoved:Bool = true;
	public var cameraOldX:Int = 1;
	public var cameraOldY:Int = 1;
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, tileLayer:TileLayer)
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		
		tiles = tileLayer;
		tiles.reset();
		tiles.blendMode = blendMode;

		actorContainer = new ActorLayer(#if (use_actor_tilemap) 0, 0, null, Config.antialias #end);
		overlay = new Sprite();

		addChild(tiles);
		addChild(actorContainer);
		addChild(overlay);
	}

	override public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{	
		var xScrolled = Std.int(x * scrollFactorX);
		var yScrolled = Std.int(y * scrollFactorY);

		if(Config.pixelsnap) x = Math.round(x) else x = Std.int(x);
		if(Config.pixelsnap) y = Math.round(y) else y = Std.int(y);	
		
		overlay.x = -x;
		overlay.y = -y;
		tiles.setPosition(-xScrolled, -yScrolled);
		
		this.x = Std.int(x * scrollFactorX);
		this.y = Std.int(y * scrollFactorY);
		
		var tempX = Std.int(xScrolled / (Engine.engine.scene.tileWidth * Engine.SCALE));
		var tempY = Std.int(yScrolled / (Engine.engine.scene.tileHeight * Engine.SCALE));
		
		cameraMoved = cameraMoved || cameraOldX != tempX || cameraOldY != tempY;
		
		cameraOldX = tempX;
		cameraOldY = tempY;
	}
}
