package com.stencyl.models.scene;

import com.stencyl.models.actor.ActorType;

class DeferredActor
{
	public var type:ActorType;
	
	public var x:Int;
	public var y:Int;
	
	//Script.FRONT/MIDDLE/BACK
	public var layer:Int;
	
	public function DeferredActor(type:ActorType, x:Int, y:Int, layer:Int)
	{
		this.type = type;
		this.x = x;
		this.y = y;
		this.layer = layer;
	}
}