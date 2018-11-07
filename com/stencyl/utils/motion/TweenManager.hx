package com.stencyl.utils.motion;

class TweenManager
{
	static var activeObjects:Array<TweenObject> = [];
	static var finishedObjects:Array<TweenObject> = [];
	
	public static function resetStatics():Void
	{
		activeObjects = [];
		finishedObjects = [];
	}
	
	public static function markActive(o:TweenObject):Void
	{
		activeObjects.push(o);
	}
	
	public static function cancel(o:TweenObject):Void
	{
		var i = activeObjects.indexOf(o);
		if(i != -1)
		{
			o.active = false;
			o.updated = false;
			o.finished = false;
			o.paused = false;
		
			//fast splice
			activeObjects[i] = activeObjects[activeObjects.length - 1];
			activeObjects.pop();
		}
	}
	
	public static function update(dt:Int):Void
	{
		var i = finishedObjects.length;
		
		while(i-- > 0)
		{
			finishedObjects.pop().updated = false;
		}
		
		i = activeObjects.length;
		
		while(i-- > 0)
		{
			var o:TweenObject = activeObjects[i];
			
			o.update(dt);
			
			if(o.finished)
			{
				//fast splice
				activeObjects[i] = activeObjects[activeObjects.length - 1];
				activeObjects.pop();
				
				finishedObjects.push(o);
			}
		}
	}
	
	public static function timer(duration:Int):TweenTimer
	{
		var timer = new TweenTimer();
		return timer.tween(duration);
	}
}