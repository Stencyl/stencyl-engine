package com.stencyl.graphics;

import com.stencyl.models.actor.Animation;
import nme.display.Sprite;
import nme.display.BitmapData;

#if !js
import nme.display.Tilesheet;
#end

import com.stencyl.Engine;

class SheetAnimation extends Sprite, implements AbstractAnimation
{
	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	
	#if !js
	private var tilesheet:Tilesheet;
	#end
	
	private var durations:Array<Int>;
	public var numFrames:Int;
	
	private var data:Array<Float>;
	
	private var model:Animation;
	
	#if !js
	public function new(tilesheet:Tilesheet, durations:Array<Int>, width:Int, height:Int, looping:Bool, model:Animation) 
	#end
	#if js
	public function new(tilesheet:Dynamic, durations:Array<Int>, width:Int, height:Int, looping:Bool, model:Animation) 
	#end
	{
		super();
		
		this.model = model;
		
		this.x = -width/2 * Engine.SCALE;
		this.y = -height/2 * Engine.SCALE;
		
		this.timer = 0;
		this.frameIndex = 0;
		this.looping = looping;
		#if !js
		this.tilesheet = tilesheet;
		#end
		this.durations = durations;
		
		numFrames = durations.length;

		data = [0.0, 0.0, 0];
		
		updateBitmap();
	}		

	public inline function update(elapsedTime:Float)
	{
		//Non-synced animations
		if(model == null || !looping)
		{
			timer += elapsedTime;
		
			if(numFrames > 1 && timer > durations[frameIndex])
			{
				var old = frameIndex;
			
				timer -= durations[frameIndex];
				
				frameIndex++;
				
				if(frameIndex >= numFrames)
				{
					if(looping)
					{
						frameIndex = 0;
					}
					
					else
					{	
						frameIndex--;
					}
				}
				
				if(old != frameIndex)
				{
					updateBitmap();
				}
			}
		
			return;
		}
	
		var old = frameIndex;
	
		timer = model.sharedTimer;
		frameIndex = model.sharedFrameIndex;
		
		if(old != frameIndex)
		{
			updateBitmap();
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
		
		frameIndex = frame;
		updateBitmap();
		
		//Q: should we be altering the shared instance?
		if(model != null)
		{
			model.sharedFrameIndex = frame;
		}
	}
	
	public function isFinished():Bool
	{
		return !looping && frameIndex >= numFrames -1;
	}
	
	public inline function reset()
	{
		timer = 0;
		frameIndex = 0;
		updateBitmap();
	}
	
	private inline function updateBitmap()
	{
		#if !js
		data[0] = 0;
		data[1] = 0;
		data[2] = frameIndex;

  		graphics.clear();
  		tilesheet.drawTiles(graphics, data, scripts.MyAssets.antialias);
  		#end
	}
	
	public inline function draw(g:G, x:Float, y:Float, angle:Float)
	{
		#if !js
		data[0] = x;
		data[1] = y;
		data[2] = frameIndex;
		data[3] = angle;

  		tilesheet.drawTiles(g.graphics, data, scripts.MyAssets.antialias, Tilesheet.TILE_ROTATION);
  		#end
	}
	
	public function getFrameDurations():Array<Int>
	{
		return durations;
	}
	
	public function setFrameDurations(time:Int)
	{
		if(durations != null)
		{
			for(i in 0...durations.length)
			{
				durations[i] = time;
			}
		}
	}
}
