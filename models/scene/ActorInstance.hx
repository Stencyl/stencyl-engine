package models.scene;

import behavior.BehaviorInstance;
import models.actor.ActorType;

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
	public var behaviorValues:Array<BehaviorInstance>;		
	
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
		behaviors:Array<BehaviorInstance>,
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
		
		//TODO
		//actorType = Assets.get().resources[actorID];
		
		//behaviorValues can be null, signifying to use the default ActorType config.
	}	

}
