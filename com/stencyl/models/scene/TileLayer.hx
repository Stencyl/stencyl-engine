package com.stencyl.models.scene;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.Sprite;

import com.stencyl.models.Scene;
import com.stencyl.utils.Utils;
import com.stencyl.models.collision.Grid;

#if (cpp || neko)
import openfl.display.Tilesheet;
#end

class TileLayer extends Sprite
{
	public var layerID:Int;
	public var zOrder:Int;
		
	//Data
	public var rows:Array<Array<Tile>>;
	public var autotileData:Array<Array<Int>>;
	public var grid:Grid;
	
	public var scene:Scene;
	public var numRows:Int;
	public var numCols:Int;
	public var blendName:String = "NORMAL";

	//Internal/Temporary stuff
	public var bitmapData:BitmapData;
	private var pixels:BitmapData;
	private var flashPoint:Point;
	private var noTiles:Bool;
	
	private static var TILESET_CACHE_MULTIPLIER = 1000000;
	private static var cacheSource = new Map<Int,Rectangle>();
	
	public function new(layerID:Int, zOrder:Int, scene:Scene, numCols:Int, numRows:Int)
	{
		super();
		
		this.layerID = layerID;
		this.zOrder = zOrder;
		
		this.scene = scene;
		this.numRows = numRows;
		this.numCols = numCols;
		this.noTiles = true;

		rows = [];
		autotileData = [];

		for(row in 0...numRows)
		{
			rows[row] = [];
			autotileData[row] = [];

			for(col in 0...numCols)
			{
				rows[row][col] = null;
				autotileData[row][col] = 0;
			}
		}
		
		flashPoint = new Point();
	}
	
	public function reset()
	{
		#if (!cpp && !neko)
		if(noTiles)
		{
		}
		
		else
		{
			bitmapData = new BitmapData
			(
				Std.int((Engine.screenWidth * Engine.SCALE) + (scene.tileWidth * Engine.SCALE)), 
				Std.int((Engine.screenHeight * Engine.SCALE) + (scene.tileHeight * Engine.SCALE)), 
				true, 
				0
			);
			
			var bmp = new Bitmap(bitmapData);
			bmp.smoothing = scripts.MyAssets.antialias;
			addChild(bmp);
		}
		#end
		
		alpha = 1;
	}
	
	public function clearBitmap()
	{
		#if (!cpp && !neko)
		while(numChildren > 0)
		{
			removeChildAt(0);
		}
		
		if(bitmapData != null)
		{
			bitmapData.dispose();
		}
		
		bitmapData = null;
		
		#end
	}
	
	public function setPosition(x:Int, y:Int)
	{
		#if (flash || js)
		this.x = x - x % (scene.tileWidth * Engine.SCALE);
		this.y = y - y % (scene.tileHeight * Engine.SCALE);
		#end
		
		#if (cpp || neko)
		//this.x = x;
		//this.y = y;
		#end
	}
	
	//TODO: It makes more sense to mount it to this, than make a new actor for it
	public function mountGrid()
	{
		if(grid == null)
		{
			return;
		}
	
		var a = new Actor
		(
			Engine.engine, 
			Utils.INTEGER_MAX,
			GameModel.TERRAIN_ID,
			0, 
			0, 
			Engine.engine.getTopLayer(),
			grid.width, 
			grid.height, 
			null, 
			new Map<String,Dynamic>(),
			null,
			null, 
			false, 
			true, 
			false,
			false, 
			grid,
			-1,
			Engine.NO_PHYSICS
		);
		
		a.name = "Terrain";
		a.typeID = -1;
		a.visible = false;
		a.ignoreGravity = true;
		
		Engine.engine.getGroup(GameModel.TERRAIN_ID).addChild(a);
	}
	
	public function setTileAt(row:Int, col:Int, tile:Tile, ?updateAutotile:Bool = true)
	{
		if(col < 0 || row < 0 || col >= numCols || row >= numRows)
		{
			return;
		}
		
		if(noTiles && tile != null)
		{
			noTiles = false;

			#if (!cpp && !neko)
			if(bitmapData == null)
				reset();
			#end
		}

		var old:Tile = rows[row][col];
		if(updateAutotile)
		{
			updateAutotile =
	        	(old != null && old.autotiles != null) ||
	        	(tile != null && tile.autotiles != null);
        }

        rows[row][col] = tile;
		autotileData[row][col] = 0;

		if(updateAutotile)
        {
        	updateAutotilesNear(row, col);
        }
	}
	
	public function getTileAt(row:Int, col:Int):Tile
	{
		if(col < 0 || row < 0 || col >= numCols || row >= numRows)
		{
			return null;
		}
		
		return rows[row][col];
	}

	public function updateAutotilesNear(yc:Int, xc:Int):Void
	{
		//trace('update near $xc, $yc');
		for(y in yc - 1...yc + 2)
		{
			for (x in xc - 1...xc + 2)
			{
				if(x < 0 || y < 0 || x >= numCols || y >= numRows)
					continue;

				updateAutotile(y, x);
			}
		}
	}

	private static var autotileFlagPointMap:Map<Int, Point> = 
	[
		Autotile.CORNER_TL => new Point(-1, -1),
		Autotile.CORNER_TR => new Point(1, -1),
		Autotile.CORNER_BL => new Point(-1, 1),
		Autotile.CORNER_BR => new Point(1, 1),
		Autotile.SIDE_T => new Point(0, -1),
		Autotile.SIDE_B => new Point(0, 1),
		Autotile.SIDE_L => new Point(-1, 0),
		Autotile.SIDE_R => new Point(1, 0)
	];

	public function updateAutotile(y:Int, x:Int):Void
    {
    	var t:Tile = rows[y][x];
    	
		//No need for contextual update if this isn't an autotile, or it's an autotile with an explicitly chosen pattern.
    	if(t == null || t.autotiles == null)
		{
			return;
		}
		
		//trace('Update autotile: $x, $y');

    	var autotileFlags = 0;
    	
    	for(flag in autotileFlagPointMap.keys())
    	{
    		var point = autotileFlagPointMap.get(flag);
    		var col = Std.int(x + point.x);
    		var row = Std.int(y + point.y);
    		
    		//If the surrounding tile is outside bounds, or equal to this tile, don't add an obstruction flag
    		//TODO: this is where to add a case for autotile merge IDs.
    		if(col < 0 || row < 0 || col >= numCols || row >= numRows || rows[row][col] == t)
    		{
    			continue;
    		}
    		
    		autotileFlags |= flag;
    	}
    	
    	//trace('Adding flags: $autotileFlags');

    	autotileData[y][x] = t.autotileFormat.animIndex[autotileFlags];
    }
	
	//We're directly drawing since pre-rendering the layer might not be so memory friendly on large levels 
	//and I don't know if it clips.
	public function draw(viewX:Int, viewY:Int)
	{
		if(noTiles)
		{
			return;
		}
		
		#if (cpp || neko)
		graphics.clear();
		#end
		
		#if (!cpp && !neko)
		if(bitmapData == null)
		{
			return;
		}
		
		bitmapData.fillRect(bitmapData.rect, 0);
		#end
		
		viewX = Math.floor(Math.abs(viewX));
		viewY = Math.floor(Math.abs(viewY));
		
		var width:Int = numCols;
		var height:Int = numRows;
		
		var tw:Int = scene.tileWidth;
		var th:Int = scene.tileHeight;
		
		var startX:Int = Std.int(viewX/Engine.SCALE / tw);
		var startY:Int = Std.int(viewY/Engine.SCALE / th);
		var endX:Int = 2 + startX + Std.int(Engine.screenWidth / tw);
		var endY:Int = 2 + startY + Std.int(Engine.screenHeight / th);
		
		endX = Std.int(Math.min(endX, width));
		endY = Std.int(Math.min(endY, height));
		
		var px:Int = 0;
		var py:Int = 0;
		
		var y:Int = startY;	
		
		while(y < endY)
		{
			var x:Int = startX;
			
			while(x < endX)
			{
				var t:Tile = getTileAt(y, x);
				
				if(t == null)
				{
					x++;
					px += tw;
					continue;
				}

				if(cacheSource.get(t.parent.ID * TILESET_CACHE_MULTIPLIER + t.tileID) == null || t.updateSource)
				{
					if(t.pixels == null && t.autotiles == null)
					{
						cacheSource.set(t.parent.ID * TILESET_CACHE_MULTIPLIER + t.tileID, t.parent.getImageSourceForTile(t.tileID, tw, th));
					}
					
					else
					{
						cacheSource.set(t.parent.ID * TILESET_CACHE_MULTIPLIER + t.tileID, t.getSource(tw, th));
						t.updateSource = false;
					}						
				}
				
				var source:Rectangle = cacheSource.get(t.parent.ID * TILESET_CACHE_MULTIPLIER + t.tileID);
				
				if(source == null)
				{
					x++;
					px += tw;
					continue;
				}
				
				//If an autotile, swap out the tileset tile for the desired generated tile.
				if(t.autotiles != null)
				{
					t = t.autotiles[autotileData[y][x]];
				}
				
				//If animated or an autotile, used animated tile pixels
				if(t.pixels == null)
				{
					pixels = t.parent.pixels;
				}
				else
				{
					pixels = t.pixels;
				}
				
				#if (flash || js)
				flashPoint.x = px * Engine.SCALE;
				flashPoint.y = py * Engine.SCALE;
				
				if(pixels != null)
				{
					bitmapData.copyPixels(pixels, source, flashPoint, null, null, true);
				}
				#end
				
				#if (cpp || neko)
				flashPoint.x = x * tw * Engine.SCALE;
				flashPoint.y = y * th * Engine.SCALE;
				
				t.parent.data[0] = flashPoint.x;
				t.parent.data[1] = flashPoint.y;
				
				if(t.data == null)
				{
					t.parent.data[2] = t.parent.sheetMap.get(t.tileID);
					
					if(t.parent.tilesheet != null)
					{
						t.parent.tilesheet.drawTiles(graphics, t.parent.data, scripts.MyAssets.antialias, switch(blendName)
						{
							case "ADD": Tilesheet.TILE_BLEND_ADD;
							case "MULTIPLY": Tilesheet.TILE_BLEND_MULTIPLY;
							case "SCREEN": Tilesheet.TILE_BLEND_SCREEN;
							default: Tilesheet.TILE_BLEND_NORMAL;	
						});
					}
				}
				else
				{
					t.parent.data[2] = t.currFrame;
					
					t.data.drawTiles(graphics, t.parent.data, scripts.MyAssets.antialias, switch(blendName)
					{
						case "ADD": Tilesheet.TILE_BLEND_ADD;
						case "MULTIPLY": Tilesheet.TILE_BLEND_MULTIPLY;
						case "SCREEN": Tilesheet.TILE_BLEND_SCREEN;
						default: Tilesheet.TILE_BLEND_NORMAL;	
					});
				}
		  		#end
				
				x++;
				px += tw;
			}
			
			px = 0;
			py += th;
			
			y++;
		}		
	}
}