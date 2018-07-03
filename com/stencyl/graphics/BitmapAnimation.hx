package com.stencyl.graphics;

import com.stencyl.models.actor.Animation;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import com.stencyl.Config;
import com.stencyl.Engine;

class BitmapAnimation extends Bitmap implements AbstractAnimation
{
	public var model(default, null):Animation;

	private var frameIndex:Int;
	private var timer:Float;
	private var finished:Bool;
	private var needsUpdate:Bool;
	
	private var durations:Array<Int>;
	private var individualDurations:Bool;
	private var numFrames:Int;
	
	public function new(model:Animation) 
	{
		super(model.frames[0]);
		
		this.model = model;
		
		#if js
		x = Math.round(-model.frameWidth / 2 * Engine.SCALE);
		y = Math.round(-model.frameHeight / 2 * Engine.SCALE);
		#else
		x = -model.frameWidth / 2 * Engine.SCALE;
		y = -model.frameHeight / 2 * Engine.SCALE;
		#end
		
		this.timer = 0;
		this.frameIndex = 0;
		
		this.individualDurations = false;
		this.durations = model.durations;
		
		this.numFrames = durations.length;
		this.smoothing = Config.antialias;
		
		finished = (numFrames <= 1);
		
		updateBitmap();
	}		

	public inline function update(elapsedTime:Float)
	{
		//Non-synced animations
		if(!(model.sync && model.looping))
		{
			timer += elapsedTime;
		
			if(numFrames > 0 && timer > durations[frameIndex])
			{
				var old = frameIndex;
			
				timer -= durations[frameIndex];
				
				frameIndex++;
				
				if(frameIndex >= numFrames)
				{
					if(model.looping)
					{
						frameIndex = 0;
					}
					
					else
					{
						finished = true;
						frameIndex--;
					}
				}
				
				if(old != frameIndex)
				{
					needsUpdate = true;
				}
			}
		
			return;
		}
	
		var old = frameIndex;
	
		timer = model.sharedTimer;
		frameIndex = model.sharedFrameIndex;
		
		if(old != frameIndex)
		{
			needsUpdate = true;
		}
	}
	
	public function getCurrentFrame():Int
	{
		return frameIndex;
	}
	
	public function getNumFrames():Int
	{
		return numFrames;
	}
	
	public function setFrame(frame:Int):Void
	{
		if(frame < 0 || frame >= numFrames)
		{
			frame = 0;
		}
		
		if(frame != frameIndex)
		{
			frameIndex = frame;
			needsUpdate = true;
		}

		timer = 0;
		finished = false;
	}
	
	public function isFinished():Bool
	{
		return finished;
	}
	
	public function needsBitmapUpdate():Bool
	{
		return needsUpdate;
	}
	
	public inline function reset()
	{
		timer = 0;
		frameIndex = 0;
		finished = false;
		needsUpdate = true;
	}
	
	public inline function updateBitmap()
	{
		bitmapData = model.frames[frameIndex];
		smoothing = Config.antialias;
		needsUpdate = false;
	}
	
	public inline function draw(g:G, x:Float, y:Float, angle:Float, alpha:Float)
	{
		if(Config.disposeImages && !model.checkImageReadable())
			return;
		
		g.drawImage(bitmapData, x, y, angle);
	}
	
	public function getFrameDurations():Array<Int>
	{
		return durations;
	}
	
	public function setFrameDurations(time:Int)
	{	
		if(durations != null)
		{
			var newDurations:Array<Int> = new Array<Int>();
			for(i in 0...durations.length)
			{
				newDurations.push(time);
			}
			durations = newDurations;
			individualDurations = true;
		}
	}
	
	public function setFrameDuration(frame:Int, time:Int):Void
	{
		if (!individualDurations)
		{
			var newDurations:Array<Int> = new Array<Int>();
			for(i in 0...durations.length)
			{
				newDurations.push(durations[i]);
			}
			durations = newDurations;
			individualDurations = true;
		}
		
		if (frame >= 0 && frame < durations.length)
		{
			durations[frame] = time;
		}
	}

	public function framesUpdated():Void
	{
		//html5 rounds strangely when pixel snapping
		#if js
		x = Math.round(-model.frameWidth / 2 * Engine.SCALE);
		y = Math.round(-model.frameHeight / 2 * Engine.SCALE);
		#else
		x = -model.frameWidth / 2 * Engine.SCALE;
		y = -model.frameHeight / 2 * Engine.SCALE;
		#end
		
		updateBitmap();
	}
	
	public function getCurrentImage():BitmapData
	{
		if(Config.disposeImages && !model.checkImageReadable())
			return Animation.UNLOADED;
		
		return bitmapData;
	}
	
	public inline function activate() {}
}
