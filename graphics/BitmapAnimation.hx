package graphics;

import nme.display.Bitmap;
import nme.display.BitmapData;

class BitmapAnimation extends Bitmap, implements AbstractAnimation
{
	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	private var images:Array<BitmapData>;
	private var durations:Array<Int>;
	private var numFrames:Int;
	
	public function new(images:Array<BitmapData>, durations:Array<Int>) 
	{
		super(images[0]);
		
		this.timer = 0;
		this.frameIndex = 0;
		this.looping = true;
		this.images = images;
		this.durations = durations;
		
		numFrames = images.length;
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
			
			this.bitmapData = images[frameIndex];
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
		this.bitmapData = images[frameIndex];
	}
}
