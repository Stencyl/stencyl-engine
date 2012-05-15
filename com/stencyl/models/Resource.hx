package com.stencyl.models;

class Resource 
{
	public var ID:Int;
	public var name:String;
	
	public function new(ID:Int, name:String) 
	{
		this.ID = ID;
		this.name = name;
	}	
	
	public function toString():String
	{
		return ID + "," + name;
	}	
}
