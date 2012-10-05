package com.stencyl.models.background;

import nme.display.Graphics;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.geom.Point;

import com.stencyl.Engine;

class ImageBackground extends Resource, implements Background 
{
	public var currFrame:Int;
	public var currTime:Float;
	
	public var img:BitmapData;
	public var frames:Array<Dynamic>;
	public var durations:Array<Int>;
	
	public var parallaxX:Float;
	public var parallaxY:Float;
	
	public var repeats:Bool;
		
	public function new
	(
		ID:Int,
		atlasID:Int,
		name:String,
		durations:Array<Int>,
		parallaxX:Float,
		parallaxY:Float,
		repeats:Bool
	)
	{	
		super(ID, name, atlasID);
		
		this.parallaxX = parallaxX;
		this.parallaxY = parallaxY;
		this.durations = durations;
		this.repeats = repeats;
					
		this.currTime = 0;
		this.currFrame = 0;
		
		if(isAtlasActive())
		{
			loadGraphics();		
		}
	}	
	
	public function update()
	{
	}
	
	public function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int)
	{
	}		
	
	//TODO: drawTiles on CPP
	public function drawRepeated(bitmap:Bitmap, screenWidth:Int, screenHeight:Int)
	{
		var texture = new BitmapData(screenWidth, screenHeight);	
		var tw:Float = img.width;
		var th:Float = img.height;
		var rect = new Rectangle(0, 0, tw, th);
		
		for(yPos in 0...Std.int(screenHeight / th) + 1)
		{
			for(xPos in 0...Std.int(screenWidth / tw) + 1)
			{
				texture.copyPixels(img, rect, new Point(xPos * tw, yPos * th));
			}
		}
		
		bitmap.bitmapData = texture;
	}
	
	//For Atlases
	
	override public function loadGraphics()
	{
		var frameData = new Array<Dynamic>();
		var numFrames = durations.length;
		
		if(numFrames > 0)
		{
			for(i in 0...numFrames)
			{
				frameData.push(Data.get().resourceAssets.get(ID + "-" + i + ".png"));
			}
		}
		
		else
		{
			frameData.push(Data.get().resourceAssets.get(ID + "-0.png"));
		}
		
		//---
	
		this.frames = new Array<Dynamic>();
		
		for(i in 0...frameData.length)
		{
			this.frames.push(frameData[i]);				
		}
		
		this.img = frames[0];
	}
	
	override public function unloadGraphics()
	{
		//Replace with a 1x1 px blank - graceful fallback
		img = new BitmapData(1, 1);
		currFrame = 0;
		
		frames = [];
		
		for(d in durations)
		{
			frames.push(img);
		}
	}
}
