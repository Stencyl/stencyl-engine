package com.stencyl.models;

import com.stencyl.Data;

class Resource 
{
	public var ID:Int;
	public var atlasID:Int;
	public var name:String;
	
	public function new(ID:Int, name:String, atlasID:Int) 
	{
		this.ID = ID;
		this.atlasID = atlasID;
		this.name = name;
	}	
	
	public function toString():String
	{
		return ID + "," + name;
	}	
	
	//For Atlases
	
	public function isAtlasActive():Bool
	{
		var atlas = GameModel.get().atlases.get(atlasID);
		
		if(atlas == null)
		{
			return false;
		}
		
		return atlas.active;
	}
	
	public function loadGraphics()
	{
	}
	
	public function unloadGraphics()
	{
	}
}
