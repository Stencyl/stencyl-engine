package com.stencyl.models.scene;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;

#if (cpp || neko)
import openfl.display.Tilesheet;
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
	
	#if (cpp || neko)
	public var tilesheet:Tilesheet;
	public var data:Array<Float>;
	
	//tileID -> sheetID
	public var sheetMap:Map<Int,Int>;
	#end
	
	public function new(ID:Int, atlasID:Int, name:String, framesAcross:Int, framesDown:Int, tileWidth:Int, tileHeight:Int, tiles:Array<Tile>)
	{
		super(ID, name, atlasID);
		
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.tiles = tiles;

		if(isAtlasActive())
		{
			loadGraphics();
		}
		
		temp = new Rectangle();
	}
	
	public function setupTilesheet()
	{
		#if (cpp || neko)
		sheetMap = new Map<Int,Int>();
		data = [0.0,0.0,0];
		
		if(pixels != null)
		{
			// The tile line fix now affects all scale modes.  Set to false if this causes any problems.
			if(true)
			{
				// The tilesheet needs to be modified to avoid pixel bleeding when stretching.
				tilesheet = new Tilesheet(convertPixels(pixels));
			}
			else
			{
				tilesheet = new Tilesheet(pixels);
			}
			
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
			
			#if (cpp || neko)
			// The tile line fix now affects all scale modes.  Set to false if this causes any problems.
			if(true)
			{
				temp.x = ((col * tileWidth * Engine.SCALE) + (col * 2) + 1);
				temp.y = ((row * tileHeight * Engine.SCALE) + (row * 2) + 1);
			}
			else
			{
				temp.x = col * tileWidth * Engine.SCALE;
				temp.y = row * tileHeight * Engine.SCALE;
			}
			#else
			temp.x = col * tileWidth * Engine.SCALE;
			temp.y = row * tileHeight * Engine.SCALE;
			#end

			temp.width = tileWidth * Engine.SCALE;
			temp.height = tileHeight * Engine.SCALE;
			
			return temp.clone();
		}
	}
	
	//For Atlases
	
	override public function loadGraphics()
	{
		pixels = Data.get().getGraphicAsset
		(
			ID + ".png",
			"assets/graphics/" + Engine.IMG_BASE + "/tileset-" + ID + ".png"
		);
		
		for (tile in tiles)
		{
			if (tile != null)
			{
				tile.loadGraphics();
			}
		}
		
		//On a first read, this won't be ready to do, and we'll load when we're OK
		if(tiles.length > 0)
		{
			setupTilesheet();
		}
	}
	
	override public function unloadGraphics()
	{
		pixels = null;
	
		#if (cpp || neko)
		tilesheet = null;
		#end
		
		for (tile in tiles)
		{
			if (tile != null)
			{
				tile.unloadGraphics();
			}
		}
		
		Data.get().resourceAssets.remove(ID + ".png");
	}
	
	private function convertPixels(oldPixels:BitmapData):BitmapData
	{
		var scaledTileWidth = Std.int(tileWidth * Engine.SCALE);
		var scaledTileHeight = Std.int(tileHeight * Engine.SCALE);
		var widthInTiles = Std.int(oldPixels.width / scaledTileWidth);
		var heightInTiles = Std.int(oldPixels.height / scaledTileHeight);
		var newWidth = Std.int(oldPixels.width + (widthInTiles * 2));
		var newHeight = Std.int(oldPixels.height + (heightInTiles * 2));
		var tempPixels = new BitmapData(newWidth, newHeight, true, 0x00000000);
		var heightIndex;
		var widthIndex;
		var pointX:Int;
		var pointY:Int;
		var rect:Rectangle;
		var point:Point;
			
		// Move the old tiles into the new BitmapData in a way that gives all tiles a 1px border.
		heightIndex = 0;
		while (heightIndex < heightInTiles)
		{
			widthIndex = 0;
			while (widthIndex < widthInTiles)
			{
				pointX = Std.int((widthIndex * scaledTileWidth) + (widthIndex * 2) + 1);
				pointY = Std.int((heightIndex * scaledTileHeight) + (heightIndex * 2) + 1);
				rect = new Rectangle((widthIndex * scaledTileWidth), (heightIndex * scaledTileHeight), (scaledTileWidth), (scaledTileHeight));
				point = new Point(pointX,pointY);
				tempPixels.copyPixels(oldPixels, rect, point);
				widthIndex ++;
			}
			heightIndex ++;
		}
			
		var index0:Int;
		var tilePixel:Int;
			
		// Duplicate the border pixels.
		heightIndex = 0;
		while (heightIndex < heightInTiles)
		{
			widthIndex = 0;
			while (widthIndex < widthInTiles)
			{
				pointX = Std.int((widthIndex * scaledTileWidth) + (widthIndex * 2) + 1);			
				pointY = Std.int((heightIndex * scaledTileHeight) + (heightIndex * 2) + 1);
					
				index0 = 0;
				while (index0 < scaledTileWidth)
				{
					// Duplicating top pixels...
					tilePixel = tempPixels.getPixel32((pointX + index0), pointY);
					tempPixels.setPixel32((pointX + index0),(pointY - 1),tilePixel);
						
					// Duplicating bottom pixels...
					tilePixel = tempPixels.getPixel32((pointX + index0), (pointY + scaledTileHeight - 1));
					tempPixels.setPixel32((pointX + index0),(pointY + scaledTileHeight),tilePixel);
						
					index0 ++;
				}

				index0 = 0;
				while (index0 < scaledTileHeight)
				{
					// Duplicating left pixels...
					tilePixel = tempPixels.getPixel32(pointX, (pointY + index0));
					tempPixels.setPixel32((pointX - 1),(pointY + index0),tilePixel);
						
					// Duplicating right pixels...
					tilePixel = tempPixels.getPixel32((pointX + scaledTileWidth - 1), (pointY + index0));
					tempPixels.setPixel32((pointX + scaledTileWidth),(pointY + index0),tilePixel);
						
					index0 ++;
				}
				widthIndex ++;
			}
			heightIndex ++;
		}
		// This is the new BitmapData with duplicated pixels.
		return tempPixels;
	}
}