package graphics.transitions;

import nme.display.Graphics;

class Transition
{
	public var duration:Int;
	public var direction:String;
	
	var active:Bool;
	var complete:Bool;
	
	public static var IN:String = "in";
	public static var OUT:String = "out";
	public static var THROUGH:String = "through";
	
	public function new(duration:Int)
	{
		this.duration = duration;
		active = false;
		complete = false;
		
		if(duration == 0)
		{
			complete = true;
		}
	}
	
	public function start()
	{
		complete = true;
	}
	
	public function reset()
	{
		complete = false;
	}
	
	public function stop()
	{
		active = false;
	}
	
	public function isActive():Bool
	{
		return active;
	}
	
	public function isComplete():Bool
	{
		return complete;
	}
	
	public function update(engine:Engine, elapsedTime:Float)
	{
	}
	
	public function draw(sengine:Engine, g:Graphics)
	{
	}
	
	public function getDuration():Int
	{
		return duration;
	}
}
