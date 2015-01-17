package com.stencyl.models.background;

import openfl.display.Graphics;
import openfl.geom.Matrix;
import openfl.display.GradientType;
import openfl.display.SpreadMethod;

class GradientBackground extends Resource implements Background 
{	
	private var topColor:UInt;
	private var bottomColor:UInt;

	public function new(topColor:UInt, bottomColor:UInt) 
	{
		super(0, "Gradient Background", -1);
		
		this.topColor = topColor;
		this.bottomColor = bottomColor;
	}		
	
	public function update()
	{
	}
	
	public function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int)
	{
		var colors = [topColor, bottomColor];
		var alphas = [100, 100];
		var ratios = [0, 0xFF];
		var matr = new Matrix();
		matr.createGradientBox(screenWidth, screenHeight, Math.PI/2, 0, 0);
		var sprMethod = SpreadMethod.PAD;
	
		g.clear();
		g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr, sprMethod);
		g.drawRect(0, 0, screenWidth, screenHeight);
		g.endFill();
	}	
}
