package com.stencyl.graphics;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.geom.Point;

//TODO: It would be better to pass in the frames, broken up and swap between the frames.
class BitmapAnimation extends Bitmap, implements AbstractAnimation
{
	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	private var sheet:BitmapData;
	private var durations:Array<Int>;
	private var numFrames:Int;
	
	private var frameWidth:Int;
	private var region:Rectangle;
	private var pt:Point;
	
	public function new(sheet:BitmapData, numFrames:Int, durations:Array<Int>) 
	{
		super(new BitmapData(Std.int(sheet.width/numFrames), sheet.height));
		
		this.frameWidth = Std.int(sheet.width/numFrames);
		
		//TODO: Offset
		//this.x = -sheet.width/(2 * numFrames);
		//this.y = -sheet.height/2;
		
		this.timer = 0;
		this.frameIndex = 0;
		this.looping = true;
		this.sheet = sheet;
		this.durations = durations;
		this.numFrames = numFrames;
		
		region = new Rectangle(0, 0, frameWidth, sheet.height);
		pt = new Point(0, 0);
		
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
		region.x = frameWidth * frameIndex;
		
		bitmapData.fillRect(this.bitmapData.rect, 0x00000000);
		bitmapData.copyPixels(sheet, region, pt);
	}
	
	public function draw(g:G, x:Float, y:Float)
	{
		g.drawImage(bitmapData, x, y);
	}
}
