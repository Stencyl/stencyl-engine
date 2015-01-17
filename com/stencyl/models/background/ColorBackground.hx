package com.stencyl.models.background;

import openfl.display.Graphics;

class ColorBackground extends Resource implements Background 
{	
	public var bgColor:Int;
	
	public static var WHITE:Int = -1;
	public static var TRANSPARENT:Int = -2;

	public function new(bgColor:Int) 
	{	
		super(0, "Color Background", -1);
		
		this.bgColor = bgColor;
		
		//XXX: White gets turned into transparent?!
		//Ref: http://community.stencyl.com/index.php/topic,14480.0.html
		if(bgColor == WHITE)
		{
			this.bgColor = 0xffffff;
		}
	}		
	
	public function update()
	{
	}
	
	public function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int)
	{
		if(bgColor != TRANSPARENT)
		{
			g.clear();
			g.beginFill(bgColor);
			g.drawRect(0, 0, screenWidth, screenHeight);
			g.endFill();			
		}
	}
}
