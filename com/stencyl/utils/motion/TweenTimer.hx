package com.stencyl.utils.motion;

class TweenTimer extends TweenObject
{
	public function new()
	{
		super();
	}
	
	public function tween(duration:Int):TweenTimer
	{
		_tween(Easing.linear, duration);
		return this;
	}
	
	override public function updateValue()
	{
	}
}