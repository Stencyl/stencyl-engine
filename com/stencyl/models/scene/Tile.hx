package com.stencyl.models.scene;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if !js
import openfl.display.Tilesheet;
#end
import openfl.geom.Rectangle;

class Tile
{
	public var tileID:Int;
	public var collisionID:Int;
	public var metadata:String;
	public var frameIndex:Int;
	public var parent:Tileset;
			
	//For animated tiles
	public var pixels:BitmapData;
	public var durations:Array<Int>;
	public var frames:Array<Int>;
	public var currFrame:Int;
	public var currTime:Int;
	public var updateSource:Bool;
	
	#if !js
	public var data:Tilesheet;
	#end
	
	#if !js
	public function new(tileID:Int, collisionID:Int, metadata:String, frameIndex:Int, durations:Array<Int>, parent:Tileset)
	#end
	#if js
	public function new(tileID:Int, collisionID:Int, metadata:String, frameIndex:Int, durations:Array<Int>, parent:Dynamic)
	#end
	{
		this.tileID = tileID;
		this.collisionID = collisionID;
		this.metadata = metadata;
		this.frameIndex = frameIndex;
		this.durations = durations;
		this.parent = parent;	
		
		var atlas = GameModel.get().atlases.get(parent.atlasID);
		
		if(atlas != null && atlas.active)
		{
			loadGraphics();
		}
	
		currFrame = 0;
		currTime = 0;
		updateSource = false;
	}
	
	public function update(elapsedTime:Float)
	{
		if(durations.length == 1)
		{
			return;
		}
		
		currTime += Math.floor(elapsedTime);
				
		if(currTime > Std.int(durations[currFrame]))
		{
			currTime -= Std.int(durations[currFrame]);
			
			if(currFrame + 1 < durations.length)
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
		return new Rectangle(currFrame * tileWidth * Engine.SCALE, 0, tileWidth * Engine.SCALE, tileHeight * Engine.SCALE);
	}
	
	//For Atlases
	
	public function loadGraphics()
	{
		var imgData:BitmapData = null;
		
		if(durations.length > 1)
		{
			imgData = Data.get().getGraphicAsset
			(
				parent.ID + "-" + tileID + ".png",
				"assets/graphics/" + Engine.IMG_BASE + "/tileset-" + parent.ID + "-" + tileID + ".png"
			);				
		}
		
		pixels = imgData;
		
		#if (cpp || neko)
		if(imgData != null)
		{
			data = new Tilesheet(imgData);
		
			for(i in 0 ... durations.length)
			{
				currFrame = i;
				data.addTileRect(getSource(parent.tileWidth, parent.tileHeight));
			}
		}
		#end
	}
	
	public function unloadGraphics()
	{
		pixels = null;
	
		#if !js
		data = null;
		#end
		
		if(durations.length > 1)
		{
			Data.get().resourceAssets.remove(parent.ID + "-" + tileID + ".png");				
		}
	}
}