package com.stencyl.models.scene;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;

class Tileset extends Resource
{
	public var framesAcross:Int;
	public var framesDown:Int;
	public var tiles:Array<Tile>;
	
	public var pixels:BitmapData;
	
	public function new(ID:Int, name:String, framesAcross:Int, framesDown:Int, tiles:Array<Tile>, imgData:Dynamic)
	{
		super(ID, name);
		
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		this.tiles = tiles;

		/*if(imgData is Bitmap)
		{
			pixels = FlxG.addLoadedBitmap(imgData, false, false);
		}
		
		else
		{
			pixels = FlxG.addBitmap(imgData, false, false);
		}*/
	}
	
	public function getImageSourceForTile(tileID:Int, tileWidth:Int, tileHeight:Int):Rectangle
	{
		var tile:Tile = tiles[tileID];
		
		if(tile == null)
		{
			return new Rectangle(0, 0, tileWidth, tileHeight);
		}	
		
		else
		{
			var row:Int = Math.floor(tile.frameIndex / framesAcross);
			var col:Int = Math.floor(tile.frameIndex % framesAcross);
			
			return new Rectangle(col * tileWidth, row * tileHeight, tileWidth, tileHeight);
		}
	}
}