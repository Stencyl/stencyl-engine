package com.stencyl.models.background;

import openfl.display.Graphics;
import openfl.display.BitmapData;

import com.stencyl.Engine;
import com.stencyl.models.scene.layers.BackgroundLayer;
import com.stencyl.utils.Assets;

class ImageBackground extends Resource implements Background 
{
	public var frames:Array<BitmapData>;
	public var durations:Array<Int>;
	
	public var parallaxX:Float;
	public var parallaxY:Float;
	
	public var repeats:Bool;
	
	public var graphicsLoaded:Bool;
	
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
	
	//For Atlases
	
	override public function loadGraphics()
	{
		if(graphicsLoaded)
			return;
		
		this.frames = new Array<BitmapData>();
		var numFrames = durations.length;
		
		if(numFrames > 0)
		{
			for(i in 0...numFrames)
			{
				frames.push
				(
					Assets.getBitmapData
					(
						"assets/graphics/" + Engine.IMG_BASE + "/background-" + ID + "-" + i + ".png",
						false
					)
				);
			}
		}
		
		else
		{
			frames.push
			(
				Assets.getBitmapData
				(
					"assets/graphics/" + Engine.IMG_BASE + "/background-" + ID + "-0.png",
					false
				)
			);
		}
		
		//---
		
		graphicsLoaded = true;
	}
	
	override public function unloadGraphics()
	{
		if(!graphicsLoaded)
			return;
		
		//Replace with a 1x1 px blank - graceful fallback
		var img = new BitmapData(1, 1);
		frames = [for(d in durations) img];
		
		//---
		
		var numFrames = durations.length;
		
		graphicsLoaded = false;
	}

	override public function reloadGraphics(subID:Int)
	{
		super.reloadGraphics(subID);
		for(layer in Engine.engine.backgroundLayers)
		{
			if(layer.model == this)
			{
				layer.reload(layer.resourceID);
			}
		}
	}
}
