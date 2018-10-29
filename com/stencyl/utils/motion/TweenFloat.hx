package com.stencyl.utils.motion;

import tweenxcore.Tools.FloatTools;

class TweenFloat extends TweenObject
{
	public var startValue:Float;
	public var endValue:Float;
	public var value:Float;
	
	public function new()
	{
		super();
	}
	
	public function tween(startValue:Float, endValue:Float, easing:Easing, duration:Int):TweenFloat
	{
		_tween(easing, duration);
		
		this.startValue = startValue;
		this.endValue = endValue;
		value = startValue;
		
		return this;
	}
	
	override public function updateValue()
	{
		value = FloatTools.lerp(easing.apply(time/duration), startValue, endValue);
	}
}