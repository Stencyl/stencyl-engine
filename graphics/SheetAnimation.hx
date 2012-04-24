package graphics;

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
	
	public function new(tilesheet:Tilesheet, durations:Array<Int>) 
	{
		super();
		
		this.timer = 0;
		this.frameIndex = 0;
		this.looping = true;
		this.tilesheet = tilesheet;
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
}
