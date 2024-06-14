package com.stencyl.models.scene;

import com.stencyl.graphics.TileSource;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if use_actor_tilemap
import openfl.display.TileContainer;
import openfl.display.Tile;
#end

import com.stencyl.Engine;

class ScrollingBitmap extends #if use_actor_tilemap TileContainer #else Sprite #end
{
	public var tiles:Array<Array<#if use_actor_tilemap Tile #else Bitmap #end>>;
	
	public var running:Bool;
	public var parallax:Bool;
	public var scrolling:Bool;
	
	public var cacheWidth:Float;
	public var cacheHeight:Float;
	
	public var xP:Float;
	public var yP:Float;
	public var xPos:Float;
	public var yPos:Float;
	public var xVelocity:Float;
	public var yVelocity:Float;
	public var parallaxX:Float;
	public var parallaxY:Float;
	public var lastXPos:Float;
	public var lastYPos:Float;
	
	public var backgroundID:Int;
	public var repeats:Bool;
	
	public function new(img:BitmapData, dx:Float, dy:Float, px:Float=0, py:Float=0, ID:Int=0, repeats:Bool = true) 
	{
		super();
		
		running = true;
		this.repeats = repeats;
		
		cacheWidth = img.width;
		cacheHeight = img.height;
        
		tiles = createTiles(img, Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		
		for(line in tiles)
		{
			for(tile in line)
			{
				#if use_actor_tilemap
				addTile(tile);
				#else
				addChild(tile);
				#end
			}
		}
		
		xP = 0;
		yP = 0;
		
		xPos = 0;
        yPos = 0;
        
        xVelocity = dx;
        yVelocity = dy;
		
		parallaxX = px;
		parallaxY = py;
		
		lastXPos = 0;
		lastYPos = 0;
		
		scrolling = (dx  != 0 || dy != 0);
		parallax = (px != 0 || py != 0);
		
		backgroundID = ID;
	}
	
	public static function createTiles(img:BitmapData, screenWidth:Int, screenHeight:Int):Array<Array<#if use_actor_tilemap Tile #else Bitmap #end>>
	{
		var tw:Float = img.width;
		var th:Float = img.height;
		
		//So it doesn't cutoff, extend width/height
		if (tw < screenWidth)
		{
			screenWidth += Std.int(tw) - (screenWidth % Std.int(tw));
		}
		
		if (th < screenHeight)
		{
			screenHeight += Std.int(th) - (screenHeight % Std.int(th));
		}
		
		#if use_actor_tilemap
		var ts = TileSource.fromBitmapData(img);
		#end

		var tiles = [];
		
		for(yPos in 0...Std.int(screenHeight / th) + 1)
		{
			var line = [];
			
			for(xPos in 0...Std.int(screenWidth / tw) + 1)
			{
				#if use_actor_tilemap
				var tile = new Tile();
				tile.tileset = ts.tileset;
				tile.id = ts.tileID;
				#else
				var tile = new Bitmap(img);
				#end
				tile.x = xPos * tw;
				tile.y = yPos * th;
				line.push(tile);
			}
			
			tiles.push(line);
		}
		
		return tiles;
	}
	
	public function setImage(img:BitmapData)
	{
		#if use_actor_tilemap
		var ts = TileSource.fromBitmapData(img);
		@:privateAccess for(tile in __tiles)
		{
			tile.tileset = ts.tileset;
			tile.id = ts.tileID;
		}
		#else
		for(line in tiles)
		{
			for(tile in line)
			{
				tile.bitmapData = img;
			}
		}
		#end
	}
	
	public function update(x:Float, y:Float, elapsedTime:Float)
	{
		if(parallax)
		{
			xPos = -Std.int(x * parallaxX);
			yPos = -Std.int(y * parallaxY);
		}
		else if(running)
		{
			xPos = 0;
			yPos = 0;
		}
		else
		{
			xPos = xP;
			yPos = yP;
		}

		if(scrolling && running)
		{
			xP += xVelocity / 10.0 * Engine.SCALE;
			yP += yVelocity / 10.0 * Engine.SCALE;
			
			if (this.repeats)
			{
				if(xP < -cacheWidth || xP > cacheWidth)
				{
					xP = xP % cacheWidth;
				}
				
				if(yP < -cacheHeight || yP > cacheHeight)
				{
					yP = yP % cacheHeight;
				}
			}
	        
	        xPos += Math.floor(xP);
	        yPos += Math.floor(yP);
		}
		
		if (this.repeats)
		{
			if (xPos < -cacheWidth)
			{
				xPos = xPos % cacheWidth;
			}
			
			else if (xPos > 0)
			{
				xPos -= cacheWidth;
			}
			
			if (yPos < -cacheHeight)
			{
				yPos = yPos % cacheHeight;
			}
			
			else if (yPos > 0)
			{
				yPos -= cacheHeight;
			}
		}
		
		if(xPos != lastXPos || yPos != lastYPos)
		{
			lastXPos = xPos;
			lastYPos = yPos;
			//TODO: optimize?
			resetPositions();
		}
	}
	
	public function resetPositions()
	{
		var firstTile = tiles[0][0];
		#if use_actor_tilemap
		var rect = firstTile.tileset.getRect(firstTile.id);
		#else
		var rect = firstTile.bitmapData.rect;
		#end
		cacheWidth = rect.width;
		cacheHeight = rect.height;
		
		var tileX = xPos;
		var tileY = yPos;
		
		for(line in tiles)
		{
			tileX = xPos;
			
			for(tile in line)
			{
				tile.x = tileX;
				tile.y = tileY;
				tileX += cacheWidth;
			}
			
			tileY += cacheHeight;
		}
	}
	
	public function start()
	{
		running = true;
	}
	
	public function stop()
	{
		running = false;
	}
}
