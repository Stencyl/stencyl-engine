package com.stencyl.graphics.transitions;

import nme.display.Graphics;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.ColorTransform;
import nme.display.Shape;
import nme.display.BlendMode;
import nme.display.Shape;
import nme.geom.Point;
import nme.geom.Rectangle;

import com.stencyl.Engine;
import com.stencyl.utils.Utils;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;

class CircleTransition extends Transition
{
	public var color:Int;
	public var radius:Int;
		
	private var beginRadius:Int;
	private var endRadius:Int;
	private var circleImg:BitmapData;
	private var s:Shape;
	
	public function new(direction:String, duration:Float, color:Int=0xff000000)
	{
		super(duration);
		
		this.color = color;
		this.direction = direction;
		
		if(direction == Transition.IN)
		{
			beginRadius = 0; 
			endRadius = Std.int(Math.ceil(Point.distance(new Point(0, 0), new Point(Engine.screenWidthHalf, Engine.screenHeightHalf))));
		}
		
		else if(direction == Transition.OUT)
		{
			beginRadius = Std.int(Math.ceil(Point.distance(new Point(0, 0), new Point(Engine.screenWidthHalf, Engine.screenHeightHalf))));
			endRadius = 0;
		}
	}
	
	override public function start()
	{
		active = true;
			
		s = new Shape();
		circleImg = new BitmapData(Engine.screenWidth, Engine.screenHeight);
		radius = beginRadius;
		
		if (direction == Transition.IN)
		{
			var graphics:Graphics  = s.graphics;
			graphics.beginFill(color);
			graphics.drawRect(0, 0, Engine.screenWidth, Engine.screenHeight);
			graphics.endFill();
		}
		
		Engine.engine.transitionLayer.addChild(s);
		
		//---

		Actuate.tween(this, duration, {radius:endRadius}).ease(Linear.easeNone).onComplete(stop);
	}
	
	override public function draw(g:Graphics)
	{
		s.graphics.clear();
		
		s.graphics.beginFill(color);
		s.graphics.drawRect(0, 0, Engine.screenWidth, Engine.screenHeight);
		s.graphics.endFill();
		
		circleImg.draw(Engine.engine.master);
		s.graphics.beginBitmapFill(circleImg);
		s.graphics.drawCircle(Engine.screenWidthHalf, Engine.screenHeightHalf, radius);
		s.graphics.endFill();		
	}
	
	override public function cleanup()
	{
		if(s != null)
		{
			Engine.engine.transitionLayer.removeChild(s);
			s = null;
		}
	}
}