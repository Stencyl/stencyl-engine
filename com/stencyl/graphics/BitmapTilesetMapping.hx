package com.stencyl.graphics;

#if use_actor_tilemap

import openfl.display.BitmapData;

import com.stencyl.Engine;

class BitmapTilesetMapping
{
	public var tilesetInitialized = false;
	public var tileset:DynamicTileset = null;
	public var frameIndexOffset:Int;

	public function new()
	{
	
	}
	
	public function initializeInTileset(bitmapData:BitmapData, tileset:DynamicTileset):Bool
	{
		if(!tileset.checkForSpace(bitmapData.width, bitmapData.height, 1))
		{
			return false;
		}
		
		frameIndexOffset = tileset.addFrames([bitmapData]);
		this.tileset = tileset;
		tilesetInitialized = true;
		
		Engine.engine.loadedBitmaps.set(bitmapData, this);
		
		//@:privateAccess trace("Uploaded bitmap wrapper to gpu texture " + tileset.tileset.bitmapData.__texture.__textureID);
		
		return true;
	}
}

#end
