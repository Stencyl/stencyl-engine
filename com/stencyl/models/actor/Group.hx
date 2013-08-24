package com.stencyl.models.actor;

class Group 
{
	public var list:Array<Actor>;
	public var name:String;
	public var ID:Int;
	public var sID:String;
	
	public function new(ID:Int, name:String) 
	{	
		this.name = name;
		this.ID = ID;
		
		sID = "[Group " + ID + "," + name + "]";
		
		list = new Array<Actor>();
	}		

	public function addChild(a:Actor)
	{
		list.push(a);
	}
	
	public function removeChild(a:Actor)
	{
		
	}
	
	public function toString():String
	{
		return sID;
	}
}
