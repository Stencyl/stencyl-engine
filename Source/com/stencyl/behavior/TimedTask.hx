package com.stencyl.behavior;

import com.stencyl.models.Actor;

class TimedTask
{
	public var toExecute:TimedTask->Void;
	public var interval:Int;
	public var repeats:Bool;
	public var actor:Actor;
	
	private var timer:Int;
	
	public var done:Bool;
	
	//Used as an efficient way to tell different "incarnations" of recycled actors apart.
	public var actorCreateTime:Float;
	
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
		if(actor != null && !actor.isAlive())
		{
			done = true;
			return;
		}
		
		if((actor == null && Engine.engine.isPaused()) || (actor != null && actor.isPaused()))
		{
			return;
		}		
		
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
