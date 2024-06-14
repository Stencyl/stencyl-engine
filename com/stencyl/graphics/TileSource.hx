package com.stencyl.graphics;

import openfl.display.BitmapData;
import openfl.display.Tileset;

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
}