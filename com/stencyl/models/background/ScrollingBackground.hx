package com.stencyl.models.background;

import openfl.display.Graphics;
import openfl.display.BitmapData;

class ScrollingBackground extends ImageBackground implements Background 
{
	public var xVelocity:Float;
	public var yVelocity:Float;
		
	public function new
	(
		ID:Int,
		atlasID:Int,
		name:String,
		durations:Array<Int>,
		parallaxX:Float,
		parallaxY:Float,
		repeats:Bool,
		xVelocity:Float,
		yVelocity:Float
	)
	{	
		super(ID, atlasID, name, durations, parallaxX, parallaxY, repeats);
		
		this.xVelocity = xVelocity;
		this.yVelocity = yVelocity;		
	}	
	
	override public function update()
	{
	}
	
	override public function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int)
	{
	}
}
