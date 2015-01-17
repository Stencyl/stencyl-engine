package com.stencyl.graphics.transitions;

import openfl.display.Graphics;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.display.Shape;
import openfl.display.BlendMode;
import openfl.display.Shape;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import com.stencyl.Engine;
import com.stencyl.utils.Utils;

import motion.Actuate;
import motion.easing.Linear;

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
			endRadius = Std.int(Math.ceil(Point.distance(new Point(0, 0), new Point(Engine.screenWidthHalf * Engine.SCALE, Engine.screenHeightHalf * Engine.SCALE))));
		}
		
		else if(direction == Transition.OUT)
		{
			beginRadius = Std.int(Math.ceil(Point.distance(new Point(0, 0), new Point(Engine.screenWidthHalf * Engine.SCALE, Engine.screenHeightHalf * Engine.SCALE))));
			endRadius = 0;
		}
	}
	
	override public function start()
	{
		active = true;
			
		s = new Shape();
		circleImg = new BitmapData(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		radius = beginRadius;
		
		if (direction == Transition.IN)
		{
			var graphics:Graphics  = s.graphics;
			graphics.beginFill(color);
			graphics.drawRect(0, 0, Engine.screenWidth * Engine.SCALE, Engine.screenHeight * Engine.SCALE);
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
		s.graphics.drawRect(0, 0, Engine.screenWidth * Engine.SCALE, Engine.screenHeight * Engine.SCALE);
		s.graphics.endFill();
		
		circleImg.draw(Engine.engine.master);
		s.graphics.beginBitmapFill(circleImg);
		s.graphics.drawCircle(Engine.screenWidthHalf * Engine.SCALE, Engine.screenHeightHalf * Engine.SCALE, radius);
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