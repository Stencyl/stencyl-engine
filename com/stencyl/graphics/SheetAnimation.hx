package com.stencyl.graphics;

import com.stencyl.models.actor.Animation;
import openfl.display.BitmapData;

import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;

import openfl.geom.Matrix;

import com.stencyl.Engine;

class SheetAnimation extends Tilemap implements AbstractAnimation
{
	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	private var finished:Bool;
	private var needsUpdate:Bool;
	
	public var framesAcross:Int;
	public var frameWidth:Int;
	public var frameHeight:Int;
	
	private var durations:Array<Int>;
	private var individualDurations:Bool;
	public var numFrames:Int;
	
	private var data:Array<Float>;
	
	private var model:Animation;
	
	public function new(tileset:Tileset, durations:Array<Int>, width:Int, height:Int, looping:Bool, model:Animation) 

	{
		super(width, height, tileset, scripts.MyAssets.antialias);
		
		this.model = model;
		
		this.x = -width/2 * Engine.SCALE;
		this.y = -height/2 * Engine.SCALE;
		
		this.timer = 0;
		this.frameIndex = 0;
		this.frameWidth = width;
		this.frameHeight = height;
		this.looping = looping;
		this.durations = durations;
		
		numFrames = durations.length;

		data = [0.0, 0.0, 0];

		addTile(new Tile());
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
		getTileAt(0).id = frameIndex;
		needsUpdate = false;
	}

	public inline function draw(g:G, x:Float, y:Float, angle:Float, alpha:Float)
	{
		//TODO: Are angle and alpha reflected here?
		//should they be?
		var bitmapData = new BitmapData(frameWidth, frameHeight, true, 0);
		bitmapData.draw(this);

		g.graphics.beginBitmapFill(bitmapData, new Matrix(1, 0, 0, 1, x, y));
		g.graphics.drawRect(x, y, frameWidth, frameHeight);
 	 	g.graphics.endFill();
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
		#if flash
		return null;
		#else
		var img = new BitmapData(Std.int(width) , Std.int(height), true, 0x00ffffff);
		img.copyPixels(getBitmap(), new openfl.geom.Rectangle((frameIndex % framesAcross) * width, Math.floor(frameIndex / framesAcross) * height, Std.int(width), Std.int(height)), new openfl.geom.Point(0, 0), null, null, false);
		return img;
		#end
		
	}

	#if !flash
	public inline function getBitmap():BitmapData
	{
		return tileset.bitmapData;
	}
	#end
}
