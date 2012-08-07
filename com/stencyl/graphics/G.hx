package com.stencyl.graphics;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Shape;
import nme.display.BlendMode;
import nme.display.DisplayObject;
import nme.display.Tilesheet;

import nme.geom.Rectangle;
import nme.geom.Point;
import nme.geom.Matrix;

import com.stencyl.Engine;
import com.stencyl.models.Actor;
import com.stencyl.models.Font;
import com.stencyl.utils.Utils;

import com.stencyl.graphics.fonts.Label;
import com.stencyl.graphics.fonts.BitmapFont;
import com.stencyl.graphics.fonts.DefaultFontGenerator;

class G 
{
	private var defaultFont:Font;

	public var graphics:Graphics;
	public var canvas:Dynamic; //Sprite for cpp, flash targets, BitmapData for js
	
	public var x:Float;
	public var y:Float;
	public var scaleX:Float; //[1]
	public var scaleY:Float; //[1]
	public var alpha:Float; // [0,1]
	public var blendMode:Dynamic;
	public var strokeSize:Int;
	public var fillColor:Int;
	public var strokeColor:Int;
	public var font:Font;
	
	private var fontData:Array<BitmapData>;
	private var mtx:Matrix;

	//Temp to avoid creating objects
	private var rect:Rectangle;
	private var point:Point;
	private var point2:Point;
	private var data:Array<Float>;
	
	//Polygon Specific
	private var drawPoly:Bool;
	private var pointCounter:Int;
	private var firstX:Float;
	private var firstY:Float;
	
	private var drawActor:Bool;
	
	public function new() 
	{	
		drawActor = false;
	
		x = y = 0;
		scaleX = scaleY = Engine.SCALE;
		alpha = 1;
		blendMode = BlendMode.NORMAL;
		
		strokeSize = 0;
		
		fillColor = 0x000000;
		strokeColor = 0x000000;
		
		//
		
		rect = new Rectangle();
		point = new Point();
		point2 = new Point();
		data = [0.0, 0.0, 0];

		//
		
		drawPoly = false;
		pointCounter = 0;
		firstX = 0;
		firstY = 0;
		
		font = defaultFont = new Font(-1, "", true); 
		
		drawData = [];
		
		#if (flash || js)
		mtx = new Matrix();
		fontData = font.font.getPreparedGlyphs(font.fontScale, 0x000000, true);
		#end

		//defaultFont.font = new BitmapFont("assets/graphics/default-font.png", 16, 16, BitmapFont.TEXT_SET25, 55, 0, 0);
	}
	
	public inline function setFont(newFont:Font)
	{
		if(newFont != null && newFont != font)
		{
			font = newFont;
		
			#if (flash || js)
			if(font == defaultFont)
			{
				fontData = font.font.getPreparedGlyphs(font.fontScale, 0x000000, true);
			}
			
			else
			{
				fontData = font.font.getPreparedGlyphs(font.fontScale, 0x000000, false);
			}
			#end	
		}
	}
	
	public inline function startGraphics()
	{
		if(drawActor)
		{
			x += Engine.cameraX;
			y += Engine.cameraY;
		}
	
		graphics.lineStyle(strokeSize, strokeColor, alpha);
	}
	
	public inline function endGraphics()
	{
		if(drawActor)
		{
			x -= Engine.cameraX;
			y -= Engine.cameraY;
		}
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
		drawActor = false;
	
		x = 0;
		y = 0;
	}
	
	public inline function translateToActor(a:Actor)
	{
		drawActor = true;
	
		if(Engine.NO_PHYSICS)
		{
			x = a.realX;
			y = a.realY;
		}
		
		else
		{
			x = a.realX - a.width / 2;
			y = a.realY - a.height / 2;
		}
	}
	
	private var drawData:Array<Float>;
	
	public inline function drawString(s:String, x:Float, y:Float)
	{
		if(font == null)
		{
			resetFont();
		}

		var drawX = this.x + x * scaleX + Engine.cameraX;
		var drawY = this.y + y * scaleY + Engine.cameraY;
		
		#if(cpp)
		drawData.splice(0, drawData.length);
		font.font.render(drawData, s, 0x000000, alpha, Std.int(drawX), Std.int(drawY), 0, font.fontScale, 0, false);
		font.font.drawText(graphics, drawData);
		#end
		
		#if(flash || js)
		mtx.identity();
 	 	mtx.translate(drawX, drawY);
 	 	
 	 	var w = font.font.getTextWidth(s, 0, font.fontScale);
 	 	var h = Std.int(font.font.getFontHeight() * font.fontScale);
 	 	
		var bitmapData = new BitmapData(w, h, true, 0);
		font.font.render(bitmapData, fontData, s, 0x000000, 0, 0, 0, 0);
		
		graphics.beginBitmapFill(bitmapData, mtx);
		graphics.drawRect(drawX, drawY, w, h);
 	 	graphics.endFill();
		#end
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
		
		#if (js)
		canvas.copyPixels(img, rect, point);
		#end
		
		//TODO: Very wasteful!
		#if (cpp || flash)
		var sheet = new Tilesheet(img);
		sheet.addTileRect(rect, point2);
		data[0] = point.x;
		data[1] = point.y;
		data[2] = 0;
  		sheet.drawTiles(canvas.graphics, data, true);
		#end
	}
	
	public inline function resetFont()
	{
		font = defaultFont;
	}
}
