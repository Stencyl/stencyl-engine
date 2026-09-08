package com.stencyl.graphics.transitions;

import openfl.display.Graphics;
import openfl.display.Shape;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Log;

class RectangleTransition extends Transition
{
	private var graphics:Graphics;

	public var color:Int;
	private var size:TweenFloat2;
	private var beginWidth:Int;
	private var endWidth:Int;
	private var beginHeight:Int;
	private var endHeight:Int;

	public var rect:Shape;

	public function new(direction:String, duration:Float, color:Int)
	{
		super(duration);
		this.color = color;
		this.direction = direction;
	}

	override public function start()
	{
		var screenWidth:Int = Std.int(Engine.screenWidth * Engine.SCALE);
		var screenHeight:Int = Std.int(Engine.screenHeight * Engine.SCALE);

		if(direction == Transition.IN)
		{
			beginWidth = 0;
			beginHeight = 0;
			endWidth = screenWidth;
			endHeight = screenHeight;
		}
		else if(direction == Transition.OUT)
		{
			beginWidth = screenWidth;
			beginHeight = screenHeight;
			endWidth = 0;
			endHeight = 0;
		}
		else
		{
			Log.error("Invalid transition direction: " + direction);
			complete = true;
			return;
		}

		active = true;
		size = new TweenFloat2();
		rect = new Shape();
		graphics = rect.graphics;
		Engine.engine.transitionLayer.addChild(rect);

		size.onComplete = stop;
		size.tween(beginWidth, endWidth, beginHeight, endHeight, Easing.linear, Std.int(duration * 1000));
	}

	override public function draw(g:Graphics)
	{
		var screenWidth:Float = Engine.screenWidth * Engine.SCALE;
		var screenHeight:Float = Engine.screenHeight * Engine.SCALE;
		var holeWidth:Float = size.value1;
		var holeHeight:Float = size.value2;
		var holeX:Float = (screenWidth - holeWidth) / 2;
		var holeY:Float = (screenHeight - holeHeight) / 2;

		graphics.clear();
		graphics.beginFill(color);
		graphics.drawRect(0, 0, screenWidth, holeY);
		graphics.drawRect(0, holeY, holeX, holeHeight);
		graphics.drawRect(holeX + holeWidth, holeY, screenWidth - holeX - holeWidth, holeHeight);
		graphics.drawRect(0, holeY + holeHeight, screenWidth, screenHeight - holeY - holeHeight);
		graphics.endFill();
	}

	override public function cleanup()
	{
		size = null;
		graphics = null;

		if(rect != null)
		{
			if(rect.parent != null) rect.parent.removeChild(rect);
			rect.graphics.clear();
			rect = null;
		}
	}
}
