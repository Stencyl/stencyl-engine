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
import com.stencyl.utils.HashMap;

class TileLayer extends Sprite
{
	public var layerID:Int;
	public var zOrder:Int;
		
	//Data
	public var rows:Array<Array<Tile>>;
	
	public var scene:Scene;
	public var numRows:Int;
	public var numCols:Int;
	
	//What's actually drawn
	public var bitmap:Bitmap;
	public var bitmapData:BitmapData;
	
	//Internal/Temporary stuff
	private var pixels:BitmapData;
	private var flashPoint:Point;

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
		
		bitmapData = new BitmapData(Engine.screenWidth, Engine.screenHeight);
		bitmap = new Bitmap(bitmapData);
		addChild(bitmap);
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
	
	//We're directly drawing since pre-rendering the layer might not be so memory friendly on large levels and I don't know if it clips.
	public function draw(viewX:Int, viewY:Int, alpha:Float)
	{
		bitmapData.fillRect(bitmapData.rect, 0);
	
		this.alpha = alpha;
	
		viewX = Math.round(Math.abs(viewX));
		viewY = Math.round(Math.abs(viewY));
		
		var width:Int = numCols;
		var height:Int = numRows;
		
		var tw:Int = scene.tileWidth;
		var th:Int = scene.tileHeight;
		
		var startX:Int = Std.int(viewX / tw);
		var startY:Int = Std.int(viewY / th);
		var endX:Int = 2 + startX + Std.int(Engine.screenWidth / tw);
		var endY:Int = 2 + startY + Std.int(Engine.screenHeight / th);
		
		endX = Std.int(Math.min(endX, width));
		endY = Std.int(Math.min(endY, height));
		
		var px:Int = startX * tw;
		var py:Int = startY * th;
		
		var cacheSource = new HashMap<Tile, Rectangle>();
		
		var y = startY;
		
		while(y < endY)
		{
			var x = startX;
			
			while(x < endX)
			{
				var t:Tile = getTileAt(y, x);
									
				px += tw;
				
				if(t == null)
				{
					x++;
					continue;
				}
													
				if(cacheSource.get(t) == null)
				{
					if(t.pixels == null)
					{
						cacheSource.set(t, t.parent.getImageSourceForTile(t.tileID, tw, th));
					}
					
					else
					{
						cacheSource.set(t, t.getSource(tw, th));
					}						
				}
				
				var source:Rectangle = cacheSource.get(t);
														
				if(source == null)
				{
					x++;
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
					
					flashPoint.x = x * tw - viewX;
					flashPoint.y = y * th - viewY;

					if(source != null)
					{
						//TODO: Use drawTiles for CPP targets.
						bitmapData.copyPixels(pixels, source, flashPoint, null, null, true);
					}
				}
				
				x++;
			}
			
			px = startX * tw;
			py += th;
			
			y++;
		}
	}
}