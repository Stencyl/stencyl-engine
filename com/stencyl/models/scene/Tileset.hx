package com.stencyl.models.scene;

import com.stencyl.utils.Assets;
import com.stencyl.Engine;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Tileset as FLTileset;
import openfl.geom.Rectangle;
import openfl.geom.Point;

class Tileset extends Resource
{
	public var framesAcross:Int;
	public var framesDown:Int;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var tiles:Array<Tile>;
	public var readableImages:Bool;
	
	public var pixels:BitmapData;
	public static var temp:Rectangle = new Rectangle();
	
	public var graphicsLoaded:Bool;
	
	#if (use_tilemap)
	public var flTileset:FLTileset;
	
	//tileID -> sheetID
	public var sheetMap:Map<Int,Int>;
	#end
	
	public function new(ID:Int, atlasID:Int, name:String, framesAcross:Int, framesDown:Int, tileWidth:Int, tileHeight:Int, readable:Bool, tiles:Array<Tile>)
	{
		super(ID, name, atlasID);
		
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.readableImages = readable;
		this.tiles = tiles;
	}
	
	#if (use_tilemap)
	public function setupFLTileset()
	{
		sheetMap = new Map<Int,Int>();
		
		if(pixels != null)
		{
			// The tile line fix now affects all scale modes.  Set to false if this causes any problems.
			var tileLineFix = true;
			
			if(tileLineFix)
			{
				// The tileset needs to be modified to avoid pixel bleeding when stretching.
				flTileset = new FLTileset(convertPixels(pixels));
			}
			else
			{
				flTileset = new FLTileset(pixels);
			}
			
			for(tile in tiles)
			{
				if(tile == null)
				{
					continue;
				}
				
				var r = getImageSourceForTile(tile.tileID, Std.int(tileWidth), Std.int(tileHeight));
				
				sheetMap.set(tile.tileID, flTileset.addRect(r));
			}
			
			#if (lime_opengl || lime_opengles || lime_webgl)
			//var shouldDispose = flTileset.bitmapData != pixels;
			//com.stencyl.graphics.GLUtil.uploadTexture(flTileset.bitmapData, shouldDispose);
			#end
		}
	}
	#end
	
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
			
			#if (use_tilemap)
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
		if(graphicsLoaded)
			return;
		
		pixels = Assets.getBitmapData
		(
			"assets/graphics/" + Engine.IMG_BASE + "/tileset-" + ID + ".png",
			false
		);
		
		for (tile in tiles)
		{
			if (tile != null)
			{
				tile.loadGraphics();
			}
		}
		
		#if (use_tilemap)
		setupFLTileset();
		
		if(Config.disposeImages && !readableImages)
		{
			pixels.dispose();
		}
		#end
		
		graphicsLoaded = true;
	}
	
	override public function unloadGraphics()
	{
		if(!graphicsLoaded)
			return;
		
		if(pixels.readable)
			pixels.dispose();
		pixels = null;
	
		#if (use_tilemap)
		flTileset = null;
		#end
		
		for (tile in tiles)
		{
			if (tile != null)
			{
				tile.unloadGraphics();
			}
		}
		
		graphicsLoaded = false;
	}

	override public function reloadGraphics(subID:Int)
	{
		if(subID == -1)
		{
			unloadGraphics();
			loadGraphics();
		}
		else
		{
			var tile = tiles[subID];
			if(tile != null)
			{
				tile.unloadGraphics();
				tile.loadGraphics();
			}
		}

		Engine.engine.tileUpdated = true;
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