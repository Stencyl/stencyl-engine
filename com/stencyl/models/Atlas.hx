package com.stencyl.models;

class Atlas 
{
	public var ID:Int;
	public var name:String;
	public var active:Bool;
	public var members:Array<Int>;
	
	public function new(ID:Int, name:String, members:Array<Int>, active:Bool) 
	{	
		this.ID = ID;
		this.name = name;
		this.members = members;
		this.active = active;
	}		
}
