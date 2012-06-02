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

//TODO: Totally broken - get Justin to fix this instead. Basically, use Engine.engine.transitionLayer (a Sprite) to do what you need to do.
class CircleTransition extends Transition
{
	public var color:Int;
	public var radius:Int;
		
	private var beginRadius:Int;
	private var endRadius:Int;
	private var circleImg:BitmapData;
	private var circleImgRect:Rectangle;
	private var s:Shape;
	
	private var buffer:BitmapData;
	private var bitmap:Bitmap;
	
	public function new(direction:String, duration:Float, color:Int=0xff000000)
	{
		super(duration);
		
		this.color = color;
		
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
		//s.blendMode = BlendMode.LAYER;
		circleImg = new BitmapData(Engine.screenWidth, Engine.screenHeight, true, color);
		circleImgRect = new Rectangle(0, 0, circleImg.width, circleImg.height);
		radius = beginRadius;
		
		//---
		
		buffer = new BitmapData(Engine.screenWidth, Engine.screenHeight);
		bitmap = new Bitmap(buffer);
		Engine.engine.transitionLayer.addChild(bitmap);
		
		//---

		Actuate.tween(this, duration, {radius:endRadius}).ease(Linear.easeNone).onComplete(stop);
	}
	
	override public function draw(g:Graphics)
	{
		s.graphics.clear();
		s.graphics.beginBitmapFill(buffer);
		s.graphics.drawCircle(Engine.screenWidthHalf, Engine.screenHeightHalf, radius);
		s.graphics.endFill();
		
		circleImg.fillRect(circleImgRect, color);
		circleImg.draw(s);
	}
	
	override public function cleanup()
	{
		Engine.engine.transitionLayer.removeChild(bitmap);
	}
}