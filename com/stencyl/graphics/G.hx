package com.stencyl.graphics;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Shape;
import nme.display.BlendMode;
import nme.display.DisplayObject;
import nme.display.Tilesheet;

import nme.geom.Rectangle;
import nme.geom.Point;

import com.stencyl.models.Actor;
import com.stencyl.models.Font;

class G 
{
	private var defaultFont:Font;

	public var graphics:Graphics;
	public var canvas:Dynamic; //Sprite for cpp targets, BitmapData for flash
	
	public var x:Float;
	public var y:Float;
	public var scaleX:Float; //[1]
	public var scaleY:Float; //[1]
	public var alpha:Float; // [0,1]
	public var blendMode:BlendMode;
	public var strokeSize:Int;
	public var fillColor:Int;
	public var strokeColor:Int;
	public var font:Font;
	
	//Temp to avoid creating objects
	private var rect:Rectangle;
	private var point:Point;
	private var data:Array<Float>;
	
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
		blendMode = BlendMode.NORMAL;
		
		strokeSize = 0;
		
		fillColor = 0x000000;
		strokeColor = 0x000000;
		
		//
		
		rect = new Rectangle();
		point = new Point();
		data = [0.0, 0.0, 0];

		//
		
		drawPoly = false;
		pointCounter = 0;
		firstX = 0;
		firstY = 0;
		
		font = defaultFont = new Font(0, "", "", null, 0, 0, null); 
		defaultFont.font = new BitmapFont("assets/graphics/default-font.png", 16, 16, BitmapFont.TEXT_SET25, 55, 0, 0);
	}
	
	public inline function startGraphics()
	{
		graphics.lineStyle(strokeSize, strokeColor, alpha);
	}
	
	public inline function endGraphics()
	{
	}
	
	public inline function translate(x:Float, y:Float)
	{
		this.x += x * scaleX;
		this.y += y * scaleY;
	}
	
	public inline function moveTo(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}
	
	public inline function translateToScreen()
	{
		x = 0;
		y = 0;
	}
	
	public inline function translateToActor(a:Actor)
	{
		x = a.x;// - a.width * (a.scaleX - 1) / 2;
		y = a.y;// - a.height * (a.scaleY - 1) / 2;
	}
	
	public inline function drawString(s:String, x:Float, y:Float)
	{
		if(font == null)
		{
			resetFont();
		}
	
		font.font.text = s;
		drawImage(font.font.bitmapData, x, y); // this is kinda slow unless we only update when a repaint in requested?
	}
	
	public inline function drawLine(x1:Float, y1:Float, x2:Float, y2:Float)
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
	
	public inline function fillPixel(x:Float, y:Float)
	{
		fillRect(x, y, 1, 1);
	}
	
	public inline function drawRect(x:Float, y:Float, w:Float, h:Float)
	{
		x *= scaleX;
		y *= scaleY;
		w *= scaleX;
		h *= scaleY;
		
		startGraphics();
		 
     	graphics.drawRect(this.x + x, this.y + y, w, h);
     	
     	endGraphics();
	}
	
	public inline function fillRect(x:Float, y:Float, w:Float, h:Float)
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
	
	public inline function drawRoundRect(x:Float, y:Float, w:Float, h:Float, arc:Float)
	{
		x *= scaleX;
		y *= scaleY;
		w *= scaleX;
		h *= scaleY;
	
		startGraphics();
		 
     	graphics.drawRoundRect(this.x + x, this.y + y, w, h, arc, arc);
     	
     	endGraphics();
	}
	
	public inline function fillRoundRect(x:Float, y:Float, w:Float, h:Float, arc:Float)
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
	
	public inline function drawCircle(x:Float, y:Float, r:Float)
	{
		x *= scaleX;
		y *= scaleY;
		r *= scaleX;
		
		startGraphics();
		 
     	graphics.drawCircle(this.x + x, this.y + y, r);
     	
     	endGraphics();
	}
	
	public inline function fillCircle(x:Float, y:Float, r:Float)
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
	
	public inline function beginFillPolygon()
	{
		drawPoly = false;
		
		startGraphics();
		graphics.moveTo(this.x, this.y);
		pointCounter = 0;
	}
	
	public inline function endDrawingPolygon()
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
		
		endGraphics();
	}
	
	public inline function beginDrawPolygon()
	{
		drawPoly = true;
	
		startGraphics();
		graphics.moveTo(this.x, this.y);
		pointCounter = 0;
	}
	
	public inline function addPointToPolygon(x:Float, y:Float)
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
	
	public inline function drawImage(img:BitmapData, x:Float, y:Float)
	{
		x *= scaleX;
		y *= scaleY;
		
		rect.x = 0;
		rect.y = 0;
		rect.width = img.width;
		rect.height = img.height;
		
		//Why this has to be treated differently (add camera coords), I don't know...
		point.x = this.x + x + Engine.cameraX;
		point.y = this.y + y + Engine.cameraY;
		
		#if (flash || js)
		canvas.copyPixels(img, rect, point);
		#end
		
		#if cpp
		var sheet = new Tilesheet(img);
		sheet.addTileRect(rect, point);
		data[0] = 0;
		data[1] = 0;
		data[2] = 0;
  		sheet.drawTiles(canvas, data, true);
		#end
	}
	
	public inline function resetFont()
	{
		font = defaultFont;
	}
}
