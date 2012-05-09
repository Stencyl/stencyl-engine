package com.stencyl.graphics.transitions;

import nme.display.BitmapData;
import nme.geom.ColorTransform;

import com.stencyl.Engine;

class FadeInTransition extends Transition
{
	public var color:Int;
	
	public function new(duration:Float, color:Int=0xff000000)
	{
		super(duration);
		
		this.color = color;
		this.direction = Transition.IN;
	}
	
	override public function start()
	{
		/*FlxG.log("Start Fade In");
		active = true;
		
		FlxG.flash.start(color, duration / 1000, function():void {active = false; complete = true;}, true);*/
	}
	
	override public function stop()
	{
		//active = false;
		//FlxG.flash.stop();
	}
}