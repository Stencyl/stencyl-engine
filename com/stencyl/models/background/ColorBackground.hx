package com.stencyl.models.background;

import nme.display.Graphics;

class ColorBackground extends Resource, implements Background 
{	
	public var bgColor:Int;

	public function new(bgColor:Int) 
	{	
		super(0, "Color Background");
		
		this.bgColor = bgColor;
	}		
	
	public function update()
	{
	}
	
	public function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int)
	{
		g.beginFill(bgColor);
		g.drawRect(0, 0, screenWidth, screenHeight);
		g.endFill();
	}
}
