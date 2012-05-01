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
}
