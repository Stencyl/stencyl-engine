package com.stencyl.models.scene;

import com.stencyl.models.actor.ActorType;

class DeferredActor
{
	public var type:ActorType;
	
	public var x:Float;
	public var y:Float;
	
	//Script.FRONT/MIDDLE/BACK
	public var layer:Int;
	
	public function new(type:ActorType, x:Float, y:Float, layer:Int)
	{
		this.type = type;
		this.x = x;
		this.y = y;
		this.layer = layer;
	}
}