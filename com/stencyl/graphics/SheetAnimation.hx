package com.stencyl.graphics;

#if use_actor_tilemap

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

class SheetAnimation extends Tile implements AbstractAnimation
{
	private var frameIndex:Int;
	private var timer:Float;
	private var finished:Bool;
	
	private var durations:Array<Int>;
	private var numFrames:Int;
	private var individualDurations:Bool;
	
	public var model(default, null):Animation;
	
	public function new(model:Animation)
	{
		super();
		
		this.model = model;
		this.timer = 0;
		this.frameIndex = 0;
		
		this.individualDurations = false;
		this.durations = model.durations;
		numFrames = durations.length;
		
		x = -width/2;
		y = -height/2;
	}
	
	public inline function update(elapsedTime:Float)
	{
		//Non-synced animations
		if(!model.sync || !model.looping)
		{
			timer += elapsedTime;
		
			if(numFrames > 0 && timer > durations[frameIndex])
			{
				var old = frameIndex;
			
				timer -= durations[frameIndex];
				
				frameIndex++;
				
				if(frameIndex >= numFrames)
				{
					if(model.looping)
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
		
		if(frame != frameIndex)
		{
			frameIndex = frame;
			updateBitmap();
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
	
	public inline function activate()
	{
		if(!model.tilesetInitialized)
		{
			var e = Engine.engine;
			while(e.nextTileset >= e.actorTilesets.length)
			{
				e.actorTilesets.push(new DynamicTileset());
			}
			if(!model.initializeInTileset(e.actorTilesets[e.nextTileset]))
			{
				e.actorTilesets.push(new DynamicTileset());
				model.initializeInTileset(e.actorTilesets[++e.nextTileset]);
			}
			tileset = model.tileset.tileset;
		}
		else if(tileset == null)
		{
			tileset = model.tileset.tileset;
		}
		
		updateBitmap();
	}
	
	public inline function reset()
	{
		timer = 0;
		frameIndex = 0;
		finished = false;
		updateBitmap();
	}
	
	public inline function updateBitmap()
	{
		id = frameIndex + model.frameIndexOffset;
	}

	public inline function draw(g:G, x:Float, y:Float, angle:Float, alpha:Float)
	{
		if(Config.disposeImages && !model.checkImageReadable())
			return;
		
		var bitmapData = model.imgData;
		var srcXOffset = 0;
		var srcYOffset = 0;

		if (g.alpha == 1)
		{
			srcXOffset = frameIndex % model.framesAcross * get_width();
			srcYOffset = Std.int(frameIndex / model.framesAcross) * get_height();
		}
		else
		{
			bitmapData = new BitmapData(get_width(), get_height(), true, 0);
			var colorTransformation = new openfl.geom.ColorTransform(1,1,1,g.alpha,0,0,0,0);
			bitmapData.draw(model.imgData, new Matrix(1, 0, 0, 1, -srcXOffset, -srcYOffset), colorTransformation);
			srcXOffset = 0;
			srcYOffset = 0;
		}

		g.graphics.beginBitmapFill(bitmapData, new Matrix(1, 0, 0, 1, x - srcXOffset, y - srcYOffset));
		g.graphics.drawRect(x, y, bitmapData.width, bitmapData.height);
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
		if(Config.disposeImages && !model.checkImageReadable())
			return Animation.UNLOADED;
		
		var srcXOffset = frameIndex % model.framesAcross * get_width();
		var srcYOffset = Std.int(frameIndex / model.framesAcross) * get_height();
		var bitmapData = new BitmapData(get_width(), get_height(), true, 0);
		bitmapData.draw(model.imgData, new Matrix(1, 0, 0, 1, -srcXOffset, -srcYOffset));

		return bitmapData;
	}
	
	public function framesUpdated():Void
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
			
			x = -width/2;
			y = -height/2;

			var tiles = [for(i in 0...numFrames) new Rectangle(width * (i % across), Math.floor(i / across) * height, width, height)];
			
			tileset = new Tileset(imgData, tiles);
		}
		else
		{
			tileset.bitmapData = imgData;
		}
		*/
	}
	
	private override function get_width():Int
	{
		return Std.int(model.frameWidth * Engine.SCALE);
	}
	
	private override function get_height():Int
	{
		return Std.int(model.frameHeight * Engine.SCALE);
	}
}

#end