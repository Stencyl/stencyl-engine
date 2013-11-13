package com.stencyl.models.scene;

import com.stencyl.behavior.BehaviorInstance;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.Resource;

class ActorInstance 
{	
	public var elementID:Int;
	public var x:Int;
	public var y:Int;
	public var scaleX:Float;
	public var scaleY:Float;
	public var layerID:Int;
	public var angle:Int;
	public var groupID:Int;
	public var actorID:Int;
	public var isCustomized:Bool;
	public var behaviorValues:Map<String,BehaviorInstance>;		
	
	public var actorType:ActorType;
	
	public function new
	(
		elementID:Int,
		x:Int,
		y:Int,
		scaleX:Float,
		scaleY:Float,
		layerID:Int,
		angle:Int,
		groupID:Int,
		actorID:Int,
		behaviors:Map<String,BehaviorInstance>,
		isCustomized:Bool
	)
	{
		this.elementID = elementID;
		this.x = x;
		this.y = y;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.layerID = layerID;
		this.angle = angle;
		this.groupID = groupID;
		
		this.actorID = actorID;
		this.behaviorValues = behaviors;
		this.isCustomized = isCustomized;
		
		this.actorType = cast(Data.get().resources.get(actorID), ActorType);
		
		//behaviorValues can be null, signifying to use the default ActorType config.
	}	

}
