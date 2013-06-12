package com.stencyl.models.scene;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.Sprite;

import com.stencyl.models.Scene;
import com.stencyl.utils.Utils;
import com.stencyl.utils.HashMap;
import com.stencyl.models.collision.Grid;

#if cpp
import nme.display.Tilesheet;
#end

class TileLayer extends Sprite
{
	public var layerID:Int;
	public var zOrder:Int;
		
	//Data
	public var rows:Array<Array<Tile>>;
	public var grid:Grid;
	
	public var scene:Scene;
	public var numRows:Int;
	public var numCols:Int;

	//Internal/Temporary stuff
	public var bitmapData:BitmapData;
	private var pixels:BitmapData;
	private var flashPoint:Point;
	
	private static var cacheSource = new HashMap<Tile, Rectangle>();
	
	public function new(layerID:Int, zOrder:Int, scene:Scene, numCols:Int, numRows:Int)
	{
		super();
		
		this.layerID = layerID;
		this.zOrder = zOrder;
		
		this.scene = scene;
		this.numRows = numRows;
		this.numCols = numCols;

		rows = new Array<Array<Tile>>();
		
		for(row in 0...numRows)
		{
			rows[row] = new Array<Tile>();
			
			for(col in 0...numCols)
			{
				rows[row][col] = null;
			}
		}	
		
		flashPoint = new Point();
	}
	
	public function reset()
	{
		#if !cpp
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
		#end
		
		alpha = 1;
	}
	
	public function clearBitmap()
	{
		#if !cpp		
		while (numChildren > 0)
		{
			removeChildAt(0);
		}
		
		bitmapData.dispose();
		bitmapData = null;
		
		#end
	}
	
	public function setPosition(x:Float, y:Float)
	{
		#if (flash || js)
		this.x = x % (scene.tileWidth * Engine.SCALE);
		this.y = y % (scene.tileHeight * Engine.SCALE);
		#end
		
		#if cpp
		this.x = x;
		this.y = y;
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
			Utils.INT_MAX,
			GameModel.TERRAIN_ID,
			0, 
			0, 
			Engine.engine.getTopLayer(),
			grid.width, 
			grid.height, 
			null, 
			new Hash<Dynamic>(),
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
		
		Engine.engine.getGroup(GameModel.TERRAIN_ID).list.set(a, a);
	}
	
	public function setTileAt(row:Int, col:Int, tile:Tile)
	{
		if(col < 0 || row < 0 || col >= numCols || row >= numRows)
		{
			return;
		}
		
		rows[row][col] = tile;			
	}
	
	public function getTileAt(row:Int, col:Int):Tile
	{
		if(col < 0 || row < 0 || col >= numCols || row >= numRows)
		{
			return null;
		}
		
		return rows[row][col];
	}
	
	//We're directly drawing since pre-rendering the layer might not be so memory friendly on large levels 
	//and I don't know if it clips.
	public function draw(viewX:Int, viewY:Int)
	{
		#if cpp
		graphics.clear();
		#end
		
		#if !cpp
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
													
				if(cacheSource.get(t) == null || t.updateSource)
				{
					if(t.pixels == null)
					{
						cacheSource.set(t, t.parent.getImageSourceForTile(t.tileID, tw, th));
					}
					
					else
					{						
						cacheSource.set(t, t.getSource(tw, th));
						t.updateSource = false;
					}						
				}
				
				var source:Rectangle = cacheSource.get(t);
														
				if(source == null)
				{
					x++;
					px += tw;
					continue;
				}
				
				else
				{					
					//If animated, used animated tile pixels
					if(t.pixels == null)
					{
						pixels = t.parent.pixels;
					}
					
					else 
					{
						pixels = t.pixels;
					}
					
					if(source != null)
					{
						#if (flash || js)
						flashPoint.x = px * Engine.SCALE;
						flashPoint.y = py * Engine.SCALE;
						
						if(pixels != null)
						{
							bitmapData.copyPixels(pixels, source, flashPoint, null, null, true);
						}
						#end
						
						#if cpp		
						flashPoint.x = x * tw * Engine.SCALE;
						flashPoint.y = y * th * Engine.SCALE;
						
						t.parent.data[0] = flashPoint.x;
						t.parent.data[1] = flashPoint.y;
						
						if(t.data == null)
						{
							t.parent.data[2] = t.parent.sheetMap.get(t.tileID);
							
							if(t.parent.tilesheet != null)
							{
								t.parent.tilesheet.drawTiles(graphics, t.parent.data, scripts.MyAssets.antialias);
							}
						}
						
						else
						{
							t.parent.data[2] = t.currFrame;
							t.data.drawTiles(graphics, t.parent.data, scripts.MyAssets.antialias);
						}						
				  		#end
					}
				}
				
				x++;
				px += tw;
			}
			
			px = 0;
			py += th;
			
			y++;
		}		
	}
}