package com.stencyl.models.scene;

import nme.display.Sprite;
import nme.geom.ColorTransform;

import nme.display.Bitmap;
import nme.display.BitmapData;

import com.stencyl.models.scene.layers.RegularLayer;

class Layer extends RegularLayer
{
	private var tiles:TileLayer;
	
	public var ID:Int;
	public var order:Int;
	public var color:Int;
	
	public var overlay:Sprite;
	public var bitmapOverlay:Dynamic;
	public var drawnOn:Bool;
	
	public function new(ID:Int, order:Int, tiles:TileLayer, overlay:Sprite, bitmapOverlay:Dynamic)
	{
		super();
		
		this.tiles = tiles;
		this.overlay = overlay;
		this.bitmapOverlay = bitmapOverlay;
		
		this.ID = ID;
		this.layerID = ID;
		this.order = order;

		//scrollFactor.x = 0;
		//scrollFactor.y = 0;
		
		drawnOn = true;
	}
}