package com.stencyl.graphics.transitions;

import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.display.Shape;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;

class FadeInTransition extends Transition
{
	public var color:Int;
	public var rect:Shape;
	public var rectAlpha:TweenFloat;
	
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
		g.drawRect(0, 0, Engine.screenWidth * Engine.SCALE + 4, Engine.screenHeight * Engine.SCALE + 4);
		g.endFill();
		
		Engine.engine.transitionLayer.addChild(rect);
		
		rectAlpha = new TweenFloat();
		rectAlpha.tween(1, 0, Easing.linear, Std.int(duration*1000)).doOnComplete(stop);
	}
	
	override public function update(elapsedTime:Float)
	{
		rect.alpha = rectAlpha.value;
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