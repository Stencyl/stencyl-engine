package com.stencyl.graphics;

import com.stencyl.models.actor.Animation;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import com.stencyl.Engine;

//TODO: It would be better to pass in the frames, broken up and swap between the frames.
class BitmapAnimation extends Bitmap implements AbstractAnimation
{
	private var model:Animation;

	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	//Made public for html5 filters.
	public var sheet:BitmapData;
	private var durations:Array<Int>;
	private var individualDurations:Bool;
	private var numFrames:Int;
	private var across:Int;
	private var down:Int;
	
	private var frameWidth:Int;
	private var frameHeight:Int;
	private var region:Rectangle;
	private var pt:Point;
	
	private var finished:Bool;
	private var needsUpdate:Bool;
	
	public function new(sheet:BitmapData, numFrames:Int, across:Int, down:Int, durations:Array<Int>, looping:Bool, model:Animation) 
	{
		super(new BitmapData(Std.int(sheet.width/across), Std.int(sheet.height/down)));
		
		this.model = model;
		
		this.across = across;
		this.down = down;
		this.frameWidth = Std.int(sheet.width / across);
		this.frameHeight = Std.int(sheet.height / down);
		
		//html5 rounds strangely when pixel snapping
		#if js
		this.x = Math.round(-sheet.width/(2 * across) * Engine.SCALE);
		this.y = Math.round(-sheet.height/(2 * down) * Engine.SCALE);			
		#else
		this.x = -sheet.width/(2 * across) * Engine.SCALE;
		this.y = -sheet.height/(2 * down) * Engine.SCALE;
		#end
		
		this.timer = 0;
		this.frameIndex = 0;
		this.looping = looping;
		this.sheet = sheet;
		this.durations = durations;
		this.individualDurations = false;
		this.numFrames = numFrames;
		this.smoothing = scripts.MyAssets.antialias;
		
		region = new Rectangle(0, 0, frameWidth* Engine.SCALE, frameHeight* Engine.SCALE);
		pt = new Point(0, 0);
		
		finished = (numFrames <= 1);
		
		updateBitmap();
	}		

	public inline function update(elapsedTime:Float)
	{
		//Non-synced animations
		if(model == null || !looping)
		{
			timer += elapsedTime;
		
			if(numFrames > 0 && timer > durations[frameIndex])
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
		
		//Q: should we be altering the shared instance?
		if(model != null)
		{
			model.sharedFrameIndex = frame;
		}
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
		region.x = frameWidth * (frameIndex % across);
		region.y = frameHeight * Math.floor(frameIndex/ across);
		
		bitmapData.fillRect(this.bitmapData.rect, 0x00000000);
		bitmapData.copyPixels(sheet, region, pt);
		
		needsUpdate = false;
	}
	
	public inline function draw(g:G, x:Float, y:Float, angle:Float, alpha:Float)
	{
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
	
	public function getCurrentImage():BitmapData
	{
		return bitmapData;
	}
}
