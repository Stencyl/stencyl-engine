package com.stencyl.graphics.transitions;

import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.display.Shape;

import com.stencyl.Engine;

import motion.Actuate;
import motion.easing.Linear;

class FadeInTransition extends Transition
{
	public var color:Int;
	public var rect:Shape;
	
	public function new(duration:Float, color:Int=0xff000000)
	{
		super(duration);
		
		this.color = color;
		this.direction = Transition.IN;
	}
	
	override public function start()
	{
		active = true;
	
		rect = new Shape();
		var g = rect.graphics;
		g.beginFill(color);
		g.drawRect(0, 0, Engine.screenWidth * Engine.SCALE, Engine.screenHeight * Engine.SCALE);
		g.endFill();
		Engine.engine.transitionLayer.addChild(rect);
		
		Actuate.tween(rect, duration, {alpha:0}).ease(Linear.easeNone).onComplete(stop);
	}
	
	override public function cleanup()
	{
		if(rect != null)
		{
			Engine.engine.transitionLayer.removeChild(rect);
			rect = null;
		}
	}
}