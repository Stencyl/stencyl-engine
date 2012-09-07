package com.stencyl.models.scene;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.geom.Point;

#if cpp
import nme.display.Tilesheet;
#end

class Tileset extends Resource
{
	public var framesAcross:Int;
	public var framesDown:Int;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var tiles:Array<Tile>;
	
	public var pixels:BitmapData;
	public static var temp:Rectangle;
	
	#if cpp
	public var tilesheet:Tilesheet;
	public var data:Array<Float>;
	
	//tileID -> sheetID
	public var sheetMap:IntHash<Int>;
	#end
	
	public function new(ID:Int, name:String, framesAcross:Int, framesDown:Int, tileWidth:Int, tileHeight:Int, tiles:Array<Tile>, imgData:BitmapData)
	{
		super(ID, name);
		
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.tiles = tiles;

		pixels = imgData;
		temp = new Rectangle();
	}
	
	public function setupTilesheet()
	{
		#if cpp
		sheetMap = new IntHash<Int>();
		data = [0.0,0.0,0];
		tilesheet = new Tilesheet(pixels);
		
		var counter = 0;
		
		for(tile in tiles)
		{
			if(tile == null)
			{
				continue;
			}
			
			var r = getImageSourceForTile(tile.tileID, Std.int(tileWidth), Std.int(tileHeight));
			tilesheet.addTileRect(r);
			
			sheetMap.set(tile.tileID, counter);
			counter++;
		}
		#end
	}
	
	public function getImageSourceForTile(tileID:Int, tileWidth:Int, tileHeight:Int):Rectangle
	{
		var tile:Tile = tiles[tileID];
		
		if(tile == null)
		{
			temp.x = 0;
			temp.y = 0;
			temp.width = tileWidth * Engine.SCALE;
			temp.height = tileHeight * Engine.SCALE;
			
			return temp.clone();
		}	
		
		else
		{
			var row:Int = Math.floor(tile.frameIndex / framesAcross);
			var col:Int = Math.floor(tile.frameIndex % framesAcross);
			
			temp.x = col * tileWidth * Engine.SCALE;
			temp.y = row * tileHeight * Engine.SCALE;
			temp.width = tileWidth * Engine.SCALE;
			temp.height = tileHeight * Engine.SCALE;
			
			return temp.clone();
		}
	}
}