package com.stencyl.models.scene;

import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.Sprite;

class TileLayer extends Sprite
{
	public var layerID:Int;
	public var zOrder:Int;
	
	//placeholder
	public function new(layerID:Int, zOrder:Int, scene:Scene, numCols:Int, numRows:Int)
	{
		super();
	}
	
	//Data
	/*public var rows:Array;
	
	public var scene:Scene;
	public var numRows:Number;
	public var numCols:Number;
	
	//Internal
	protected var _pixels:BitmapData;
	protected var _data:Array;
	protected var _rects:Array;
	protected var original:ColorTransform;
	protected var _mtx:Matrix;
	
	//Semi-transparent tile drawing
	protected var _translatedSource:Rectangle;
	protected var _alphaCT:ColorTransform;
	
	public function TileLayer(layerID:Number, zOrder:Number, scene:Scene, numCols:Number, numRows:Number)
	{
		this.layerID = layerID;
		this.zOrder = zOrder;
		
		this.scene = scene;
		this.numRows = numRows;
		this.numCols = numCols;
		
		original = new ColorTransform();
		_mtx = new Matrix();
		
		_translatedSource = new Rectangle();
		_alphaCT = new ColorTransform(1, 1, 1, 1);

		rows = new Array();
		
		for(var row:Number = 0; row < numRows; row++)
		{
			rows[row] = new Array();
			
			for(var col:Number = 0; col < numCols; col++)
			{
				rows[row][col] = null;
			}
		}			
	}
	
	public function setTileAt(row:Number, col:Number, tile:Tile):void
	{
		if(col < 0 || row < 0 || col >= numCols || row >= numRows)
		{
			return;
		}
		
		rows[row][col] = tile;			
	}
	
	public function getTileAt(row:Number, col:Number):Tile
	{
		if(col < 0 || row < 0 || col >= numCols || row >= numRows)
		{
			return null;
		}
		
		return rows[row][col];
	}
			
	public function draw(viewX:Number, viewY:Number, alpha:Number):void
	{
		viewX = Math.round(Math.abs(viewX));
		viewY = Math.round(Math.abs(viewY));
		
		var width:uint = numCols;
		var height:uint = numRows;
		
		var tw:uint = scene.tileWidth;
		var th:uint = scene.tileHeight;
		
		var startX:uint = viewX / tw;
		var startY:uint = viewY / th;
		var endX:uint = 2 + startX + FlxG.width / tw;
		var endY:uint = 2 + startY + FlxG.height / th;
		
		endX = Math.min(endX, width);
		endY = Math.min(endY, height);
		
		var px:Number = startX * tw;
		var py:Number = startY * th;
		
		var cacheSource:Array = new Array();
		
		for(var y:uint = startY; y < endY; y++)
		{
			for(var x:uint = startX; x < endX; x++)
			{
				var t:Tile = getTileAt(y, x);
									
				px += tw
				
				if(t == null)
				{
					continue;
				}
				
				var key:String = t.toString();
														
				if(cacheSource[key] == null)
				{
					
					if (t.pixels == null)
					{
						cacheSource[key] = t.parent.getImageSourceForTile(t.tileID, tw, th);
					}
					
					else
					{
						cacheSource[key] = t.getSource(tw, th);
					}						
				}
				
				var source:Rectangle = cacheSource[key];
														
				if(source == null)
				{
					continue
				}
				
				else
				{
					//If animated, used animated tile pixels
					if (t.pixels == null)
					{
						_pixels = t.parent.pixels;
					}
					else 
					{
						_pixels = t.pixels;
					}
					
					_flashPoint.x = x * tw - viewX;
					_flashPoint.y = y * th - viewY;

					if(source != null)
					{
						if(alpha >= 255)
						{
							FlxG.buffer.copyPixels(_pixels, source, _flashPoint, null, null, true);
						}
						
						else
						{
							FlxG.workaround.bitmapData = _pixels;
							FlxG.workaround.pixelSnapping = PixelSnapping.AUTO;
							FlxG.workaround.smoothing = true;
							
							_mtx.identity();
							_mtx.translate((-source.x + _flashPoint.x), (-source.y + _flashPoint.y));
							
							_alphaCT.alphaMultiplier = alpha / 255;
							
							_translatedSource.x = _flashPoint.x;
							_translatedSource.y = _flashPoint.y;
							_translatedSource.width = source.width;
							_translatedSource.height = source.height; 
							
							FlxG.buffer.draw(FlxG.workaround, _mtx, _alphaCT, null, _translatedSource);
						}
					}
				}
			}
			
			px = startX * tw;
			py += th;
		}
	}*/
}