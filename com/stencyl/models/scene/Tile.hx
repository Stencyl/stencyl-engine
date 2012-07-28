package com.stencyl.models.scene;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;

class Tile
{
	public var tileID:Int;
	public var collisionID:Int;
	public var frameIndex:Int;
	public var parent:Tileset;
			
	//For animated tiles
	public var pixels:BitmapData;
	public var durations:Array<Int>;
	public var frames:Array<Int>;
	public var currFrame:Int;
	public var currTime:Int;
	public var updateSource:Bool;
	public var data:Tilesheet;
	
	public function new(tileID:Int, collisionID:Int, frameIndex:Int, durations:Array<Int>, imgData:BitmapData, parent:Tileset)
	{
		this.tileID = tileID;
		this.collisionID = collisionID;
		this.frameIndex = frameIndex;
		this.durations = durations;
		this.parent = parent;		
		pixels = imgData;
		
		#if cpp		
		if (imgData != null)
		{
			data = new Tilesheet(imgData);
		
			for (i in 0 ... durations.length)
			{
				currFrame = i;
				data.addTileRect( getSource(parent.tileWidth, parent.tileHeight) );
			}
		}
		#end
		
		currFrame = 0;
		currTime = 0;
		updateSource = false;
	}
	
	public function update(elapsedTime:Float)
	{
		if (durations.length == 1)
		{
			return;
		}
		
		currTime += Math.floor(elapsedTime);
				
		if (currTime > Std.int(durations[currFrame]))
		{
			currTime -= Std.int(durations[currFrame]);
			
			if (currFrame + 1 < durations.length)
			{
				currFrame++;					
			}
			
			else
			{
				currFrame = 0;
			}
			
			updateSource = true;
		}
	}
	
	//TODO: Don't return new Rectangle.  Prebuild for animated tiles since it isn't the same.
	public function getSource(tileWidth:Int, tileHeight:Int):Rectangle
	{			
		return new Rectangle(currFrame * tileWidth, 0, tileWidth, tileHeight);
	}
}