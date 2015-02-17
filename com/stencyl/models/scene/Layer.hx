package com.stencyl.models.scene;

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
	//For Image API
	public var underActors:Sprite;
	public var overActors:Sprite;
	//Actors
	public var actorContainer:Sprite;
	//Custom Drawing (graphics)
	public var overlay:Sprite;
	//More custom Drawing (canvas)
	#if (js)
	public var bitmapOverlay:Bitmap;
	#else
	public var bitmapOverlay:Sprite;
	#end

	public var color:Int; //???

	public var drawnOn:Bool;

	public var cameraMoved:Bool = true;
	public var cameraOldX:Int = 1;
	public var cameraOldY:Int = 1;
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode, tileLayer:TileLayer)
	{
		super(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode);
		
		tiles = tileLayer;
		tiles.reset();
		tiles.blendName = Std.string(blendMode);

		underActors = new Sprite();
		actorContainer = new Sprite();
		overActors = new Sprite();
		overlay = new Sprite();

		#if (js)
		bitmapOverlay = new Bitmap(new BitmapData(Engine.screenWidth, Engine.screenHeight, true, 0));
		#else
		bitmapOverlay = new Sprite();
		#end
		
		addChild(tiles);
		addChild(underActors);
		addChild(actorContainer);
		addChild(overActors);
		addChild(overlay);
		addChild(bitmapOverlay);

		drawnOn = true;
	}

	override public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{
		x = Std.int(x);
		y = Std.int(y);
		var xScrolled = Std.int(x * scrollFactorX);
		var yScrolled = Std.int(y * scrollFactorY);

		this.x = xScrolled;
		this.y = yScrolled;
		overlay.x = -x;
		overlay.y = -y;
		bitmapOverlay.x = -x;
		bitmapOverlay.y = -y;
		tiles.setPosition(-xScrolled, -yScrolled);

		var tempX = Std.int(xScrolled / (Engine.engine.scene.tileWidth * Engine.SCALE));
		var tempY = Std.int(yScrolled / (Engine.engine.scene.tileHeight * Engine.SCALE));
		
		cameraMoved = cameraMoved || cameraOldX != tempX || cameraOldY != tempY;
		
		cameraOldX = tempX;
		cameraOldY = tempY;
	}
}