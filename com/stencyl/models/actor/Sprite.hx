package com.stencyl.models.actor;

import com.stencyl.models.Resource;

class Sprite extends Resource
{
	public var defaultAnimation:Int;
	public var animations:Map<Int, Animation>;
	public var readableImages:Bool;

	@:deprecated("Get width from individual animations") public var width(get, never):Int;
	@:deprecated("Get height from individual animations") public var height(get, never):Int;
	
	public function new(ID:Int, atlasID:Int, name:String, defaultAnimation:Int, readableImages:Bool)
	{
		super(ID, name, atlasID);
		
		this.defaultAnimation = defaultAnimation;
		this.readableImages = readableImages;
		
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

	private function get_width():Int
	{
		var defaultAnim = animations.get(defaultAnimation);
		return Std.int(defaultAnim.imgWidth / defaultAnim.framesAcross);
	}

	private function get_height():Int
	{
		var defaultAnim = animations.get(defaultAnimation);
		return Std.int(defaultAnim.imgHeight / defaultAnim.framesDown);
	}
}