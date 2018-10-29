package com.stencyl.graphics.transitions;

import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.display.Shape;
import openfl.geom.Transform;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;

class CrossfadeTransition extends Transition
{	
	private var oldImg:Sprite;
	private var bitmap:BitmapData;

	public var rect:Shape;
	public var rectAlpha:TweenFloat;
		
	public function new(oldImg:Sprite, duration:Float) 
	{
		super(duration);
		
		this.oldImg = oldImg;
	}
	
	override public function start()
	{
		active = true;
				
		bitmap = new BitmapData(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		bitmap.draw(oldImg);

		rect = new Shape();
		var g = rect.graphics;
		g.beginBitmapFill(bitmap);
		g.drawRect(0, 0, Engine.screenWidth * Engine.SCALE, Engine.screenHeight * Engine.SCALE);
		g.endFill(); 
				
		Engine.engine.transitionLayer.addChild(rect);					
		
		rectAlpha = new TweenFloat();
		rectAlpha.tween(1, 0, Easing.linear, Std.int(duration*1000)).doOnComplete(stop);
	}
	
	override public function update(elapsedTime:Float)
	{
		rect.alpha = rectAlpha.value;
	}
	
	override public function draw(g:Graphics)	
	{
	}
	
	override public function cleanup()
	{
		oldImg = null;
		bitmap = null;
		
		if(rect != null)
		{
			Engine.engine.transitionLayer.removeChild(rect);
			rect = null;
		}
	}
	
}