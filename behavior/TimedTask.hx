package behavior;

import models.Actor;

class TimedTask
{
	public var toExecute:TimedTask->Void;
	public var interval:Int;
	public var repeats:Bool;
	public var actor:Actor;
	
	private var timer:Int;
	
	public var done:Bool;
	
	public function new(toExecute:TimedTask->Void, interval:Int, repeats:Bool, actor:Actor = null)
	{
		this.toExecute = toExecute;
		this.interval = interval;
		this.repeats = repeats;
		this.actor = actor;
		
		done = false;
		
		timer = interval;
	}
	
	public function update(timeElapsed:Int)
	{
		/*if(actor != null && !actor.isAlive())
		{
			done = true;
			return;
		}
		
		if(FlxG.pause || (actor != null && actor.isPaused()))
		{
			return;
		}*/				
		
		timer -= timeElapsed;
		
		if(timer <= 0)
		{
			toExecute(this);
			done = !repeats;
			
			if(repeats)
			{
				timer += interval;
			}
		}
	}
}
