package com.stencyl.graphics.transitions;

import openfl.display.Graphics;

class Transition
{
	public var duration:Float;
	public var direction:String;
	
	var active:Bool;
	var complete:Bool;
	
	public static var IN:String = "in";
	public static var OUT:String = "out";
	public static var THROUGH:String = "through";
	
	public function new(duration:Float)
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
		// complete = true;
	}
	
	public function reset()
	{
		complete = false;
	}
	
	public function stop()
	{
		complete = true;
	}
	
	public function deactivate()
	{
		active = false;
	}
	
	//Usually hides the transition
	public function cleanup()
	{
	}
	
	public function isActive():Bool
	{
		return active;
	}
	
	public function isComplete():Bool
	{
		return complete;
	}
	
	public function update(elapsedTime:Float)
	{
	}
	
	public function draw(g:Graphics)
	{
	}
	
	public function getDuration():Float
	{
		return duration;
	}
}
