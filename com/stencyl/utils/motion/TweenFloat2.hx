package com.stencyl.utils.motion;

import tweenxcore.Tools.FloatTools;

class TweenFloat2 extends TweenObject
{
	public var startValue1:Float;
	public var endValue1:Float;
	public var value1:Float;
	
	public var startValue2:Float;
	public var endValue2:Float;
	public var value2:Float;
	
	public function new()
	{
		super();
	}
	
	public function tween(startValue1:Float, endValue1:Float, startValue2:Float, endValue2:Float, easing:EasingFunction, duration:Int):TweenFloat2
	{
		_tween(easing, duration);
		
		this.startValue1 = startValue1;
		this.endValue1 = endValue1;
		value1 = startValue1;
		
		this.startValue2 = startValue2;
		this.endValue2 = endValue2;
		value2 = startValue2;
		
		return this;
	}
	
	override public function updateValue()
	{
		var rate = easing.apply(time/duration);
		value1 = FloatTools.lerp(rate, startValue1, endValue1);
		value2 = FloatTools.lerp(rate, startValue2, endValue2);
	}
}