package com.stencyl.models.actor;

import com.stencyl.utils.HashMap;

class Group 
{
	public var list:HashMap<Actor, Actor>;
	public var name:String;
	public var ID:Int;
	
	public function new(ID:Int, name:String) 
	{	
		this.name = name;
		this.ID = ID;
		
		list = new HashMap<Actor,Actor>();
	}		

	public function addChild(a:Actor)
	{
		list.set(a, a);
	}
	
	public function removeChild(a:Actor)
	{
		list.delete(a);
	}
}
