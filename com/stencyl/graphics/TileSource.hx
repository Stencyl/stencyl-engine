package com.stencyl.graphics;

#if use_tilemap

import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Rectangle;

@:access(openfl.display.BitmapData)

class TileSource
{
	public var tileset:Tileset;
	public var tileID:Int;
	public var width:Int;
	public var height:Int;

	public function new()
	{
		
	}

	public static function fromBitmapData(img:BitmapData):TileSource
	{
		if(img.__tileSource == null)
		{
			var tileset = new Tileset(img);
			var ts = new TileSource();
			ts.tileset = tileset;
			ts.tileID = tileset.addRect(img.rect);
			ts.width = img.width;
			ts.height = img.height;
			img.__tileSource = ts;
		}
		return img.__tileSource;
	}
	
	public static function createSubImage(img:BitmapData, x:Int, y:Int, width:Int, height:Int):BitmapData
	{
		var ts = fromBitmapData(img);
		var img = new BitmapData(0, 0, true, 0);
		img.__resize(width, height);
		
		var subTs = new TileSource();
		subTs.tileset = ts.tileset;
		subTs.tileID = TilesetUtils.getSubFrame(ts.tileset, ts.tileID, x, y, width, height);
		subTs.width = width;
		subTs.height = height;
		img.__tileSource = subTs;
		return img;
	}
}

#end
