package io;

import haxe.xml.Fast;
import models.Resource;
import models.Sound;

class TilesetReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == "tileset";
	}
	
	public function read(ID:Int, type:String, name:String, xml:Fast):Resource
	{
		trace("Reading Tileset (" + ID + ") - " + name);

		var framesAcross:Number = Std.parseInt(xml.att.across);
		var framesDown:Number = Std.parseInt(xml.att.down);
		var tiles:Array<Tile> = new Array<Tile>();

		var tset:Tileset = new Tileset(ID, name, framesAcross, framesDown, tiles, Assets.get().resourceAssets[ID + ".png"]);
		
		for each(e in xml.elements)
		{
			tiles[Std.parseInt(e.att.id)] = readTile(e, tset);
		}

		return tset;
	}
	
	public function readTile(xml:XML, parent:Tileset):Tile
	{
		var tileID:Int = Std.parseInt(xml.att.id);
		var looping:Bool = Utils.toBoolean(xml.att.loop);
		var collisionID:Int = Std.parseInt(xml.att.collision);
		
		//Always single for now!
		var frameID:Int = Std.parseInt(xml.att.frames);
		
		//Animated Tiles
		var imgData:Dynamic = null;
		var durations:Array<Int> = new Array<Int>();
		var counter:Int = 0;
		
		var s:String = xml.att.durations;
		var frames:Array<String> = s.split(",");
		
		for(f in frames)
		{
			//Round to the nearest 10ms - there's no more granularity than this and makes it much easier for me.
			durations[counter] = Std.parseInt(f);
			
			durations[counter] /= 10;
			durations[counter] *= 10;
			
			counter++;
		}
		
		if(durations.length > 1)
		{
			imgData = Assets.get().resourceAssets[parent.ID + "-" + tileID + ".png"];				
		}
		
		return new Tile(tileID, collisionID, frameID, durations, imgData, parent);
	}
}
