package com.stencyl.models.actor;

import com.stencyl.models.Resource;

class Sprite extends Resource
{
	public var defaultAnimation:Int;
	public var animations:Map<Int, Animation>;
	
	public function new(ID:Int, atlasID:Int, name:String, defaultAnimation:Int)
	{
		super(ID, name, atlasID);
		
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

	override public function reloadGraphics(subID:Int)
	{
		if(subID == -1)
		{
			unloadGraphics();
			loadGraphics();
		}
		else
		{
			animations.get(subID).unloadGraphics();
			animations.get(subID).loadGraphics();
		}

		for(actor in Engine.engine.allActors)
		{
			if(actor != null && !actor.dead && !actor.recycled)
			{
				if(actor.type.spriteID == ID)
				{
					actor.reloadAnimationGraphics(subID);
				}
			}
		}
	}
}