package behavior;

import models.Actor;

class ActorScript extends Script
{	
	public var actor:Actor;

	public function new(actor:Actor, engine:Engine) 
	{	
		super(engine);
		
		this.actor = actor;
	}		
	
	//*-----------------------------------------------
	//* Messaging
	//*-----------------------------------------------
	
	public function getValue(behaviorName:String, attributeName:String):Dynamic
	{
		return actor.getValue(behaviorName, attributeName);
	}
	
	public function setValue(behaviorName:String, attributeName:String, value:Dynamic)
	{
		actor.setValue(behaviorName, attributeName, value);
	}
	
	public function shout(msg:String, args:Array<Dynamic>):Dynamic
	{
		return actor.shout(msg, args);
	}
	
	override public function disableThisBehavior()
	{
		actor.disableBehavior(wrapper.name);
	}
}
