package com.stencyl.models.background;

import nme.display.Graphics;

class ColorBackground extends Resource, implements Background 
{	
	public var bgColor:Int;

	public function new(bgColor:Int) 
	{	
		super(0, "Color Background");
		
		this.bgColor = bgColor;
		
		//XXX: White gets turned into transparent?!
		//Ref: http://community.stencyl.com/index.php/topic,14480.0.html
		if(bgColor == -1)
		{
			this.bgColor = 0xffffff;
		}
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
