package com.stencyl.graphics;

import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.Tilesheet;

class SheetAnimation extends Sprite, implements AbstractAnimation
{
	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	
	#if !js
	private var tilesheet:Tilesheet;
	#end
	
	private var durations:Array<Int>;
	private var numFrames:Int;
	
	private var data:Array<Float>;
	
	public function new(tilesheet:Tilesheet, durations:Array<Int>, width:Int, height:Int) 
	{
		super();
		
		//TODO: Offset
		this.x = -width/2;
		this.y = -height/2;
		
		this.timer = 0;
		this.frameIndex = 0;
		this.looping = true;
		#if !js
		this.tilesheet = tilesheet;
		#end
		this.durations = durations;
		
		numFrames = durations.length;
		
		data = [0.0, 0.0, 0];
		
		updateBitmap();
	}		

	public function update(elapsedTime:Float)
	{
		timer += elapsedTime;
		
		if(timer > durations[frameIndex])
		{
			timer -= durations[frameIndex];
			
			frameIndex++;
			
			if(frameIndex >= numFrames)
			{
				frameIndex = 0;
			}
			
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
	}
	
	public function isFinished():Bool
	{
		return !looping && frameIndex >= numFrames -1;
	}
	
	public function reset()
	{
		timer = 0;
		frameIndex = 0;
		updateBitmap();
	}
	
	private function updateBitmap()
	{
		#if !js
		data[0] = 0;
		data[1] = 0;
		data[2] = frameIndex;

  		graphics.clear();
  		tilesheet.drawTiles(graphics, data, true);
  		#end
	}
	
	public function draw(g:G, x:Float, y:Float)
	{
		#if !js
		data[0] = x;
		data[1] = y;
		data[2] = frameIndex;

  		tilesheet.drawTiles(g.graphics, data, true);
  		#end
	}
}
