package graphics;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.geom.Point;

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
		
		this.x = -sheet.width/(2 * numFrames);
		this.y = -sheet.height/2;
		
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
	
	public function reset()
	{
		timer = 0;
		frameIndex = 0;
		updateBitmap();
	}
	
	private function updateBitmap()
	{
		region.x = frameWidth * frameIndex;
		
		this.bitmapData.fillRect(this.bitmapData.rect, 0x00000000);
		this.bitmapData.copyPixels(sheet, region, pt);
	}
}
