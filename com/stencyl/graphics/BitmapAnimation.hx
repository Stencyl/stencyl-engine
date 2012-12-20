package com.stencyl.graphics;

import com.stencyl.models.actor.Animation;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.geom.Point;
import com.stencyl.Engine;

//TODO: It would be better to pass in the frames, broken up and swap between the frames.
class BitmapAnimation extends Bitmap, implements AbstractAnimation
{
	private var model:Animation;

	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	private var sheet:BitmapData;
	private var durations:Array<Int>;
	private var numFrames:Int;
	
	private var frameWidth:Int;
	private var region:Rectangle;
	private var pt:Point;
	
	public function new(sheet:BitmapData, numFrames:Int, durations:Array<Int>, looping:Bool, model:Animation) 
	{
		super(new BitmapData(Std.int(sheet.width/numFrames), sheet.height));
		
		this.model = model;
		
		this.frameWidth = Std.int(sheet.width/numFrames);		
		
		this.x = -sheet.width/(2 * numFrames) * Engine.SCALE;
		this.y = -sheet.height/2 * Engine.SCALE;		
		
		this.timer = 0;
		this.frameIndex = 0;
		this.looping = looping;
		this.sheet = sheet;
		this.durations = durations;
		this.numFrames = numFrames;
		this.smoothing = scripts.MyAssets.antialias;
		
		region = new Rectangle(0, 0, frameWidth, sheet.height);
		pt = new Point(0, 0);
		
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
		region.x = frameWidth * frameIndex;
		
		bitmapData.fillRect(this.bitmapData.rect, 0x00000000);
		bitmapData.copyPixels(sheet, region, pt);
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
			for(i in 0...durations.length)
			{
				durations[i] = time;
			}
		}
	}
}
