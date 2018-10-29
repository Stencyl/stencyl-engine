package com.stencyl.models.actor;

import com.stencyl.utils.motion.*;

class ActorTweenProperties
{
	public var xy:TweenFloat2;
	public var angle:TweenFloat;
	public var alpha:TweenFloat;
	public var realScaleXY:TweenFloat2;
	
	public function new()
	{
		xy = new TweenFloat2();
		angle = new TweenFloat();
		alpha = new TweenFloat();
		realScaleXY = new TweenFloat2();
	}
	
	public function pause()
	{
		xy.paused = true;
		angle.paused = true;
		alpha.paused = true;
		realScaleXY.paused = true;
	}
	
	public function unpause()
	{
		xy.paused = false;
		angle.paused = false;
		alpha.paused = false;
		realScaleXY.paused = false;
	}
	
	public function cancel()
	{
		if(xy.active)
			TweenManager.cancel(xy);
		if(angle.active)
			TweenManager.cancel(angle);
		if(alpha.active)
			TweenManager.cancel(alpha);
		if(realScaleXY.active)
			TweenManager.cancel(realScaleXY);
	}
}