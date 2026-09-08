package com.stencyl.graphics.transitions;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Shape;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;

class BubblesTransition extends Transition
{
	public var color:Int;
	public var numBubbles:Int;

	private var radius:TweenFloat;
	private var beginRadius:Float;
	private var endRadius:Float;
	private var rect:Shape;
	private var graphics:Graphics;
	private var bubblePositions:Array<Point>;
	private var screenWidth:Int;
	private var screenHeight:Int;

	private var sceneMask:Shape;
	private var colorMask:Shape;
	private var transitionColor:Shape;
	private var previousSceneMask:DisplayObject;
	private var previousColorMask:DisplayObject;

	public function new(direction:String, duration:Float, numBubbles:Int = 50, color:Int = 0xff000000)
	{
		super(duration);
		this.color = color;
		this.direction = direction;
		this.numBubbles = numBubbles;
	}

	override public function start()
	{
		active = true;
		screenWidth = Std.int(Engine.screenWidth * Engine.SCALE);
		screenHeight = Std.int(Engine.screenHeight * Engine.SCALE);

		var screenRatio:Float = screenWidth / screenHeight;
		var vertBubbles:Int = Std.int(Math.sqrt(numBubbles / screenRatio));
		var horzBubbles:Int = Std.int(vertBubbles * screenRatio);
		var bubbleSize:Float = screenHeight / vertBubbles;
		var c:Int = Math.ceil(horzBubbles);
		var r:Int = Math.ceil(vertBubbles);
		var xOverflow:Int = Std.int(c * bubbleSize - screenWidth);
		var yOverflow:Int = Std.int(r * bubbleSize - screenHeight);
		var bubbleRect = new Rectangle(-xOverflow / 2, -yOverflow / 2, bubbleSize, bubbleSize);

		bubblePositions = new Array<Point>();
		for(i in 0...r)
		{
			for(j in 0...c)
			{
				bubblePositions.push(new Point(
					bubbleRect.x + Math.floor(Math.random() * (bubbleSize + 1)),
					bubbleRect.y + Math.floor(Math.random() * (bubbleSize + 1))
				));
				bubbleRect.x += bubbleSize;
			}

			bubbleRect.x = -xOverflow / 2;
			bubbleRect.y += bubbleSize;
		}

		beginRadius = 0;
		endRadius = Math.ceil(Math.sqrt(bubbleSize * bubbleSize * 2));
		radius = new TweenFloat();

		if(direction == Transition.IN)
		{
			transitionColor = new Shape();
			transitionColor.graphics.beginFill(color);
			transitionColor.graphics.drawRect(0, 0, screenWidth, screenHeight);
			transitionColor.graphics.endFill();

			sceneMask = new Shape();
			colorMask = new Shape();
			previousSceneMask = Engine.engine.master.mask;
			previousColorMask = Engine.engine.colorLayer.mask;

			var colorIndex:Int = Engine.engine.root.getChildIndex(Engine.engine.colorLayer);
			Engine.engine.root.addChildAt(transitionColor, colorIndex);
			Engine.engine.root.addChild(sceneMask);
			Engine.engine.root.addChild(colorMask);
			Engine.engine.master.mask = sceneMask;
			Engine.engine.colorLayer.mask = colorMask;
		}
		else
		{
			rect = new Shape();
			graphics = rect.graphics;
			Engine.engine.transitionLayer.addChild(rect);
		}

		radius.tween(beginRadius, endRadius, Easing.linear, Std.int(duration * 1000)).doOnComplete(stop);
	}

	override public function draw(g:Graphics)
	{
		if(direction == Transition.IN)
		{
			drawBubbleMask(sceneMask.graphics);
			drawBubbleMask(colorMask.graphics);
		}
		else if(direction == Transition.OUT)
		{
			graphics.clear();
			for(p in bubblePositions)
			{
				graphics.beginFill(color);
				graphics.drawCircle(p.x, p.y, radius.value);
				graphics.endFill();
			}
		}
	}

	private function drawBubbleMask(g:Graphics):Void
	{
		g.clear();
		for(p in bubblePositions)
		{
			g.beginFill(0xffffff);
			g.drawCircle(p.x, p.y, radius.value);
			g.endFill();
		}
	}

	override public function cleanup()
	{
		radius = null;
		bubblePositions = null;
		graphics = null;

		if(direction == Transition.IN)
		{
			Engine.engine.master.mask = previousSceneMask;
			Engine.engine.colorLayer.mask = previousColorMask;
			previousSceneMask = null;
			previousColorMask = null;

			if(sceneMask != null)
			{
				if(sceneMask.parent != null) sceneMask.parent.removeChild(sceneMask);
				sceneMask.graphics.clear();
				sceneMask = null;
			}

			if(colorMask != null)
			{
				if(colorMask.parent != null) colorMask.parent.removeChild(colorMask);
				colorMask.graphics.clear();
				colorMask = null;
			}

			if(transitionColor != null)
			{
				if(transitionColor.parent != null) transitionColor.parent.removeChild(transitionColor);
				transitionColor.graphics.clear();
				transitionColor = null;
			}
		}

		if(rect != null)
		{
			if(rect.parent != null) rect.parent.removeChild(rect);
			rect.graphics.clear();
			rect = null;
		}
	}
}
