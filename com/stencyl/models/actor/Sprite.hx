package com.stencyl.models.actor;

import com.stencyl.models.Resource;

class Sprite extends Resource
{
	public var width:Int;
	public var height:Int;
	public var defaultAnimation:Int;
	public var animations:Map<Int, Animation>;
	
	public function new(ID:Int, atlasID:Int, name:String, width:Int, height:Int, defaultAnimation:Int)
	{
		super(ID, name, atlasID);
		
		this.width = width;
		this.height = height;
		this.defaultAnimation = defaultAnimation;
		
		animations = new Map<Int, Animation>();
	}
	
	//For Atlases
	
	override public function loadGraphics()
	{
		for(a in animations.iterator())
		{
			a.loadGraphics();
		}
	}
	
	override public function unloadGraphics()
	{
		for(a in animations)
		{
			a.unloadGraphics();
		}
	}
}