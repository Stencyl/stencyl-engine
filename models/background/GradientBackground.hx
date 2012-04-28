package models;

import nme.display.Graphics;

class GradientBackground extends Resource, implements Background 
{	
	private var topColor:Int;
	private var bottomColor:Int;

	public function new(topColor:Int, bottomColor:Int) 
	{	
		super(0, "Gradient Background");
		
		this.topColor = topColor;
		this.bottomColor = bottomColor;
	}		
	
	public function update()
	{
	}
	
	public function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int)
	{
		//beginFill(bgColor);
		//drawRect(0, 0, screenWidth, screenHeight);
		//endFill();
	}	
}
