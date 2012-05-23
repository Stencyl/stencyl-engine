package com.stencyl.graphics;

import nme.display.Graphics;
import nme.display.Shape;

class G 
{
	public var graphics:Graphics;
	
	public var x:Float;
	public var y:Float;
	public var scaleX:Float; //[1]
	public var scaleY:Float; //[1]
	
	public var alpha:Float; // [0,1]
	
	public var strokeSize:Int;
	
	public var fillColor:Int;
	public var strokeColor:Int;
	
	//Polygon Specific
	private var drawPoly:Bool;
	private var pointCounter:Int;
	private var firstX:Float;
	private var firstY:Float;
	
	public function new() 
	{	
		x = y = 0;
		scaleX = scaleY = 1;
		alpha = 1;
		
		strokeSize = 1;
		
		fillColor = 0x000000;
		strokeColor = 0x000000;
		
		//
		
		drawPoly = false;
		pointCounter = 0;
		firstX = 0;
		firstY = 0;
	}
	
	public inline function startGraphics()
	{
		graphics.lineStyle(strokeSize, strokeColor, alpha);
	}
	
	public inline function endGraphics()
	{
	}
	
	public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float)
	{
		x1 *= scaleX;
		y1 *= scaleY;
		x2 *= scaleX;
		y2 *= scaleY;
		
		startGraphics();
		 
     	graphics.moveTo(this.x + x1, this.y + y1);
     	graphics.lineTo(this.x + x2, this.y + y2);
     	
     	endGraphics();
	}
	
	public function fillPixel(x:Float, y:Float)
	{
		fillRect(x, y, 1, 1);
	}
	
	public function drawRect(x:Float, y:Float, w:Float, h:Float)
	{
		x *= scaleX;
		y *= scaleY;
		w *= scaleX;
		h *= scaleY;
		
		startGraphics();
		 
     	graphics.drawRect(this.x + x, this.y + y, w, h);
     	
     	endGraphics();
	}
	
	public function fillRect(x:Float, y:Float, w:Float, h:Float)
	{
		x *= scaleX;
		y *= scaleY;
		w *= scaleX;
		h *= scaleY;
		
		startGraphics();
	
		graphics.beginFill(fillColor, alpha);
     	graphics.drawRect(this.x + x, this.y + y, w, h);
     	graphics.endFill();
     	
     	endGraphics();
	}
	
	public function drawRoundRect(x:Float, y:Float, w:Float, h:Float, arc:Float)
	{
		x *= scaleX;
		y *= scaleY;
		w *= scaleX;
		h *= scaleY;
	
		startGraphics();
		 
     	graphics.drawRoundRect(this.x + x, this.y + y, w, h, arc, arc);
     	
     	endGraphics();
	}
	
	public function fillRoundRect(x:Float, y:Float, w:Float, h:Float, arc:Float)
	{
		x *= scaleX;
		y *= scaleY;
		w *= scaleX;
		h *= scaleY;
		
		startGraphics();
	
		graphics.beginFill(fillColor, alpha);
     	graphics.drawRoundRect(this.x + x, this.y + y, w, h, arc, arc);
     	graphics.endFill();
     	
     	endGraphics();
	}
	
	public function drawCircle(x:Float, y:Float, r:Float)
	{
		x *= scaleX;
		y *= scaleY;
		r *= scaleX;
		
		startGraphics();
		 
     	graphics.drawCircle(this.x + x, this.y + y, r);
     	
     	endGraphics();
	}
	
	public function fillCircle(x:Float, y:Float, r:Float)
	{
		x *= scaleX;
		y *= scaleY;
		r *= scaleX;
	
		startGraphics();
	
		graphics.beginFill(fillColor, alpha);
     	graphics.drawCircle(this.x + x, this.y + y, r);
     	graphics.endFill();
     	
     	endGraphics();
	}
	
	public function beginFillPolygon()
	{
		drawPoly = false;
		
		startGraphics();
		graphics.moveTo(this.x, this.y);
		pointCounter = 0;
	}
	
	public function endDrawingPolygon()
	{
		if(pointCounter < 2)
		{
			return;	
		}
		
		if(drawPoly)
		{
			graphics.lineTo(this.x + firstX, this.y + firstY);
		}
			
		else
		{
			graphics.lineTo(this.x + firstX, this.y + firstY);
			graphics.endFill();
		}
	}
	
	public function beginDrawPolygon()
	{
		drawPoly = true;
	
		startGraphics();
		graphics.moveTo(this.x, this.y);
		pointCounter = 0;
	}
	
	public function addPointToPolygon(x:Float, y:Float)
	{
		x *= scaleX;
		y *= scaleY;
		
		if(pointCounter == 0)
		{
			firstX = x;
			firstY = y;
			
			graphics.moveTo(this.x + x, this.y + y);
			
			if(!drawPoly)
			{
				graphics.beginFill(fillColor, alpha);	
			}
		}
		
		pointCounter++;
		
		graphics.lineTo(this.x + x, this.y + y);
	}
}
