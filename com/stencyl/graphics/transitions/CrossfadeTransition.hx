package com.stencyl.graphics.transitions;

import openfl.display.Bitmap;
import openfl.display.Graphics;
import openfl.display.Sprite;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;

class CrossfadeTransition extends Transition
{
	private var oldImg:Sprite;
	private var snapshot:TransitionSnapshot;

	public var rect:Bitmap;
	public var rectAlpha:TweenFloat;

	public function new(oldImg:Sprite, duration:Float)
	{
		super(duration);
		this.oldImg = oldImg;
	}

	override public function memoOldScene()
	{
		snapshot = TransitionSnapshot.capture(oldImg);
	}

	override public function start()
	{
		active = true;

		rect = snapshot.createBitmap();
		snapshot.addToDisplay(rect);

		rectAlpha = new TweenFloat();
		rectAlpha.tween(1, 0, Easing.linear, Std.int(duration * 1000)).doOnComplete(stop);
	}

	override public function update(elapsedTime:Float)
	{
		if(rect != null && rectAlpha != null)
			rect.alpha = rectAlpha.value;
	}

	override public function draw(g:Graphics) {}

	override public function cleanup()
	{
		oldImg = null;
		rectAlpha = null;

		if(rect != null)
		{
			if(rect.parent != null) rect.parent.removeChild(rect);
			rect.bitmapData = null;
			rect = null;
		}

		if(snapshot != null)
		{
			snapshot.dispose();
			snapshot = null;
		}
	}
}
