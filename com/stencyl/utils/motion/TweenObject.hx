package com.stencyl.utils.motion;

class TweenObject
{
	public var easing:Easing;
	public var time:Int;
	public var duration:Int;
	
	public var active:Bool;
	public var paused:Bool;
	public var updated:Bool;
	public var finished:Bool;
	
	public var onUpdate:Void->Void;
	public var onComplete:Void->Void;
	
	public function new()
	{
		active = false;
		finished = false;
		paused = false;
	}
	
	public function _tween(easing:Easing, duration:Int)
	{
		if(duration == 0)
			duration = 1;
		if(easing == null)
			easing = Easing.linear;
		
		this.easing = easing;
		this.duration = duration;
		
		if(!active)
		{
			TweenManager.markActive(this);
		}
		
		time = 0;
		active = true;
		updated = false;
		finished = false;
		paused = false;
	}
	
	public function update(dt:Int):Void
	{
		if(paused) return;
		
		time += dt;
		if(time > duration)
			time = duration;
		
		updateValue();
		updated = true;
		
		if(time == duration)
		{
			active = false;
			finished = true;
			if(onUpdate != null)
				onUpdate();
			if(onComplete != null)
				onComplete();
		}
		else if(onUpdate != null)
			onUpdate();
	}
	
	public function updateValue(){}
	
	public function doOnUpdate(onUpdate:Void->Void):TweenObject
	{
		this.onUpdate = onUpdate;
		return this;
	}
	
	public function doOnComplete(onComplete:Void->Void):TweenObject
	{
		this.onComplete = onComplete;
		return this;
	}
}