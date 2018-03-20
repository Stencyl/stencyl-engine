package com.stencyl.io;

import com.stencyl.utils.Utils;

import com.stencyl.io.mbs.scene.*;
import com.stencyl.io.mbs.scene.MbsTileset.*;
import com.stencyl.models.GameModel;
import com.stencyl.models.Resource;
import com.stencyl.models.scene.AutotileFormat;
import com.stencyl.models.scene.Tileset;
import com.stencyl.models.scene.Tile;

class TilesetReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == MBS_TILESET.getName();
	}
	
	public function read(obj:Dynamic):Resource
	{
		//trace("Reading Tileset (" + ID + ") - " + name);

		var r:MbsTileset = cast obj;

		var framesAcross = r.getAcross();
		var framesDown = r.getDown();
		var tileWidth = r.getTileWidth();
		var tileHeight = r.getTileHeight();
		var readable = r.getReadableImages();
		var tiles = new Array<Tile>();

		var tset = new Tileset(r.getId(), r.getAtlasID(), r.getName(), framesAcross, framesDown, tileWidth, tileHeight, readable, tiles);
		
		var tileList = r.getTiles();

		for(i in 0...tileList.length())
		{
			var tileReader = tileList.getNextObject();
			tiles[tileReader.getId()] = readTile(tileReader, tset);
		}
		
		if(tset.isAtlasActive())
		{
			tset.loadGraphics();
		}

		return tset;
	}
	
	public function readTile(r:MbsTile, parent:Tileset):Tile
	{
		var tileID = r.getId();
		var collisionID = r.getCollision();
		var metadata = r.getMetadata();
		//Always single for now!
		var frameID = r.getFrames();
		
		//Animated Tiles
		var imgData:Dynamic = null;
		var durations = new Array<Int>();
		var counter = 0;
		
		var durList = r.getDurations();
		for(i in 0...durList.length())
		{
			//Round to the nearest 10ms - there's no more granularity than this and makes it much easier for me.
			durations[counter] = durList.readInt();
			
			durations[counter] =  Math.floor(durations[counter] / 10);
			durations[counter] *= 10;
			
			counter++;
		}

		var autotileFormat:AutotileFormat = null;
		if(r.getAutotile() != -1)
			autotileFormat = GameModel.get().autotileFormats.get(r.getAutotile());

		var autotileMergeSet:Map<Int, Int> = null;
		if(r.getAutotileMerge().length() != 0)
		{
			autotileMergeSet = new Map<Int, Int>();
			var mergeList = r.getAutotileMerge();
			for(i in 0...mergeList.length())
			{
				var mergeID = mergeList.readInt();
				autotileMergeSet.set(mergeID, mergeID);
			}
		}

		return new Tile(tileID, collisionID, metadata, frameID, durations, autotileFormat, autotileMergeSet, parent);
	}
}
