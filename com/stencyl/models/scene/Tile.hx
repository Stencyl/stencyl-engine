package com.stencyl.models.scene;

import nme.display.Bitmap;
import nme.display.BitmapData;
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
	
	public function new(tileID:Int, collisionID:Int, frameIndex:Int, durations:Array<Int>, imgData:Dynamic, parent:Tileset)
	{
		this.tileID = tileID;
		this.collisionID = collisionID;
		this.frameIndex = frameIndex;
		this.durations = durations;
		this.parent = parent;
					
		currFrame = 0;
		currTime = 0;
					
		/*if(imgData != null && imgData is Bitmap)
		{
			pixels = FlxG.addLoadedBitmap(imgData, false, false);
		}
		
		else if (imgData != null)
		{
			pixels = FlxG.addBitmap(imgData, false, false);
		}*/
	}
	
	public function update(elapsedTime:Float)
	{
		currTime += Math.floor(elapsedTime * 1000);
					
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
		}
	}
	
	public function getSource(tileWidth:Int, tileHeight:Int):Rectangle
	{			
		return new Rectangle(currFrame * tileWidth, 0, tileWidth, tileHeight);
	}
}