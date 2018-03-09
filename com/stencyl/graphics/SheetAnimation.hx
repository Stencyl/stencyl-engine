package com.stencyl.graphics;

#if(use_actor_tilemap)

import com.stencyl.models.actor.Animation;
import com.stencyl.models.Actor;
import openfl.display.BitmapData;

import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;

import openfl.geom.Point;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import com.stencyl.Config;
import com.stencyl.Engine;

class SheetAnimation implements AbstractAnimation
{
	private var frameIndex:Int;
	private var looping:Bool;
	private var timer:Float;
	private var finished:Bool;
	private var needsUpdate:Bool;
	
	private var framesAcross:Int;
	private var frameWidth:Int;
	private var frameHeight:Int;
	
	private var durations:Array<Int>;
	private var individualDurations:Bool;
	private var numFrames:Int;
	
	private var imgData:BitmapData;
	private var model:Animation;
	private var parent:Actor;
	
	public var x(get, never):Float;
	public var y(get, never):Float;
	public var width(get, never):Int;
	public var height(get, never):Int;
	
	public function new(imgData:BitmapData, durations:Array<Int>, width:Int, height:Int, looping:Bool, model:Animation, parent:Actor)
	{
		this.model = model;
		this.parent = parent;
		this.timer = 0;
		this.frameIndex = 0;
		this.frameWidth = width;
		this.frameHeight = height;
		this.looping = looping;
		this.durations = durations;
		
		numFrames = durations.length;
		
		framesAcross = model != null ? model.framesAcross : numFrames;
	}
	
	public inline function update(elapsedTime:Float)
	{
		//Non-synced animations
		if(model == null || !model.sync || !looping)
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
		if(model != null && model.sync)
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
	
	public inline function activate()
	{
		if(!model.tilesetInitialized)
		{
			var arr = Engine.engine.actorTilesets;
			if(arr.length == 0 || !model.initializeInTileset(arr[arr.length-1]))
			{
				arr.push(new DynamicTileset());
				model.initializeInTileset(arr[arr.length-1]);
			}
		}
		
		parent.originX = frameWidth/2 * Engine.SCALE;
		parent.originY = frameHeight/2 * Engine.SCALE;
		parent.tileset = model.tileset.tileset;
		updateBitmap();
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
		parent.id = frameIndex + model.frameIndexOffset;
		needsUpdate = false;
	}

	public inline function draw(g:G, x:Float, y:Float, angle:Float, alpha:Float)
	{
		var bitmapData = new BitmapData(frameWidth, frameHeight, true, 0);
		
		if (g.alpha == 1)
		{
			bitmapData.draw(getCurrentImage());
		}
		else
		{
			var colorTransformation = new openfl.geom.ColorTransform(1,1,1,g.alpha,0,0,0,0);
			bitmapData.draw(getCurrentImage(), null, colorTransformation);
		}

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
		var img = new BitmapData(frameWidth, frameHeight, true, 0x00ffffff);
		img.copyPixels(getBitmap(), new Rectangle((frameIndex % framesAcross) * frameWidth, Math.floor(frameIndex / framesAcross) * frameHeight, frameWidth, frameHeight), new Point(0, 0), null, null, false);
		return img;
	}

	public function setBitmap(imgData:BitmapData):Void
	{
		/*
		var updateSize = (imgData.width != tileset.bitmapData.width) || (imgData.height != tileset.bitmapData.height);

		if(updateSize)
		{
			var across = model.framesAcross;
			var down = model.framesDown;

			width = imgData.width / across;
			height = imgData.height / down;
			frameWidth = Std.int(width);
			frameHeight = Std.int(height);
			
			parent.originX = -width/2 * Engine.SCALE;
			parent.originY = -height/2 * Engine.SCALE;

			var tiles = [for(i in 0...numFrames) new Rectangle(width * (i % across), Math.floor(i / across) * height, width, height)];
			
			tileset = new Tileset(imgData, tiles);
		}
		else
		{
			tileset.bitmapData = imgData;
		}
		*/
	}

	public inline function getBitmap():BitmapData
	{
		return imgData;
	}
	
	private function get_x():Float
	{
		return parent.originX;
	}
	
	private function get_y():Float
	{
		return parent.originY;
	}
	
	private function get_width():Int
	{
		return frameWidth;
	}
	
	private function get_height():Int
	{
		return frameHeight;
	}
}

#end