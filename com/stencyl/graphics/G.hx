package com.stencyl.graphics;

import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;

import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.geom.Matrix;

import com.stencyl.Config;
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
	private var rect2:Rectangle;
	private var point:Point;
	private var point2:Point;
	private var data:Array<Float>;
	
	//Polygon Specific
	private var drawPoly:Bool;
	private var pointCounter:Int;
	private var firstX:Float;
	private var firstY:Float;
	
	public var drawActor:Bool;
	private var actor:Actor;
	
	//Cache for speed
	public static var fontCache:Map<Int,Array<BitmapData>> = null;
	
	public static function resetStatics():Void
	{
		fontCache = null;
	}

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
		rect2 = new Rectangle();
		point = new Point();
		point2 = new Point();
		data = [0.0, 0.0, 0];

		//
		
		drawPoly = false;
		pointCounter = 0;
		firstX = 0;
		firstY = 0;
		
		font = defaultFont = new Font(-1, 0, "", true); 
		
		mtx = new Matrix();
		
		#if (flash || js)
		if(fontCache == null)
		{
			fontCache = new Map<Int,Array<BitmapData>>();
		}
		
		var temp = fontCache.get(-1);
		
		if(temp == null)
		{
			temp = font.font.getPreparedGlyphs(font.fontScale, 0x000000, true);
			fontCache.set(-1, temp);
		}
		
		fontData = temp;
		#end
		
		//defaultFont.font = new BitmapFont("assets/graphics/default-font.png", 16, 16, BitmapFont.TEXT_SET25, 55, 0, 0);
	}
	
	 public inline function resetGraphicsSettings():Void
     {
     	alpha = 1;
     	strokeSize = 0;
		fillColor = 0x000000;
		strokeColor = 0x000000;
		font = defaultFont;
     }
	
	public inline function setFont(newFont:Font)
	{
		if(newFont != null && newFont != font)
		{
			font = newFont;
		
			#if (flash || js)
			if(font == defaultFont)
			{
				fontData = fontCache.get(-1);
			
				if(fontData == null)
				{
					fontData = font.font.getPreparedGlyphs(font.fontScale, 0x000000, true);
					fontCache.set(-1, fontData);
				}
			}
			
			else
			{
				fontData = fontCache.get(font.ID);
				
				if(fontData == null)
				{
					fontData = font.font.getPreparedGlyphs(font.fontScale, 0x000000, false);
					fontCache.set(font.ID, fontData);
				}
			}
			#end	
		}
	}
	
	public inline function startGraphics()
	{
		if(drawActor)
		{
			if(actor != null && actor.isHUD)
			{
			}
			
			else
			{
				x += Engine.cameraX;
				y += Engine.cameraY;
			}
		}
	
		if(strokeSize == 0)
		{
			graphics.lineStyle();
		}
		
		else
		{
			graphics.lineStyle(strokeSize, strokeColor, alpha);
		}
	}
	
	public inline function endGraphics()
	{
		if(drawActor && !actor.isHUD)
		{
			x -= Engine.cameraX;
			y -= Engine.cameraY;
		}
		
		graphics.lineStyle();
	}
	
	public inline function translate(x:Float, y:Float)
	{
		this.x += x * scaleX;
		this.y += y * scaleY;
	}
	
	public inline function moveTo(x:Float, y:Float)
	{
		if(drawActor)
		{
			if(actor != null)
			{
				translateToActor(actor);
			}
			
			this.x += x * scaleX;
			this.y += y * scaleY;
		}
		
		else
		{
			this.x = x * scaleX;
			this.y = y * scaleY;
		}
	}
	
	public inline function translateToScreen()
	{
		drawActor = false;
		actor = null;
	
		x = 0;
		y = 0;
	}
	
	public inline function translateToActor(a:Actor)
	{
		drawActor = true;
		actor = a;
	
		if (a.smoothMove)
		{
			var drawX:Float = a.drawX - Math.floor(a.cacheWidth / 2) - a.currOffset.x;
			var drawY:Float = a.drawY - Math.floor(a.cacheHeight / 2) - a.currOffset.y;
		
			if(Engine.NO_PHYSICS)
			{
				x = drawX * scaleX;
				y = drawY * scaleY;
			}
			
			else
			{
				x = drawX * scaleX;
				y = drawY * scaleY;
			}
		}
		else
		{
			if(Engine.NO_PHYSICS)
			{
				x = a.colX * scaleX;
				y = a.colY * scaleY;
			}
			
			else
			{
				x = a.colX * scaleX;
				y = a.colY * scaleY;
			}
		}
	}

	private static var drawnStringCache = new Map<String, TemporaryImage>();

	private inline function getCacheKey(string:String, font:Font, alpha:Float):String
	{
		return string + ":" + font.ID + ":" + alpha;
	}
	
	public inline function drawString(s:String, x:Float, y:Float)
	{
		if(font == null)
		{
			resetFont();
		}
		
		var drawX:Float;
		var drawY:Float;
		
		if(drawActor)
		{
			if(actor != null && actor.isHUD)
			{
				drawX = this.x + x * scaleX;
				drawY = this.y + y * scaleY;
			}
			
			else
			{
				drawX = this.x + x * scaleX + Engine.cameraX;
				drawY = this.y + y * scaleY + Engine.cameraY;
			}
		}
		
		else
		{
			drawX = this.x + x * scaleX;
			drawY = this.y + y * scaleY;
		}
		
		mtx.identity();
		mtx.translate(drawX, drawY);

		var toDraw:BitmapData = null;
		
		var cacheKey = getCacheKey(s, font, alpha);
		if(drawnStringCache.exists(cacheKey))
		{
			var temp = drawnStringCache.get(cacheKey);
			temp.lifetime = 5;
			toDraw = temp.img;
		}
		else
		{
			var w = font.font.getTextWidth(s, font.letterSpacing, font.fontScale);
			var h = Std.int(font.font.getFontHeight() * font.fontScale);
			
			if(w > 0 && h > 0)
			{
				toDraw = new BitmapData(w, h, true, 0);
				
				#if (flash || js)
				font.font.render(toDraw, fontData, s, 0x000000, alpha, 0, 0, font.letterSpacing, font.fontScale, 0);
				#else
				font.font.renderToImg(toDraw, s, 0x000000, alpha, 0, 0, font.letterSpacing, font.fontScale, 0, false); //0, false
				#end
				
				var temp = new TemporaryImage();
				temp.img = toDraw;
				temp.lifetime = 5;

				drawnStringCache.set(cacheKey, temp);
				//trace("Added drawString image to cache: " + cacheKey);
			}
		}

		if(toDraw != null)
		{
			graphics.beginBitmapFill(toDraw, mtx);
			graphics.drawRect(drawX, drawY, toDraw.width, toDraw.height);
			graphics.endFill();
		}
	}

	public static function visitStringCache():Void
	{
		for(key in drawnStringCache.keys())
		{
			var temp = drawnStringCache.get(key);
			--temp.lifetime;
			if(temp.lifetime == 0)
			{
				temp.img.dispose();
				drawnStringCache.remove(key);
				//trace("Removed drawString image from cache: " + key);
			}
		}
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
		startGraphics();
		
		graphics.lineStyle();
		graphics.beginFill(fillColor, alpha);
		graphics.drawRect
		(
			this.x + Std.int(x * Engine.SCALE), 
			this.y + Std.int(y * Engine.SCALE), 
			Std.int(Engine.SCALE), 
			Std.int(Engine.SCALE)
		);
		graphics.endFill();
		
		endGraphics();
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
		if(pointCounter >= 2)
		{
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
		
	public inline function drawImage(img:BitmapData, x:Float, y:Float, angle:Float=0, matrix:Matrix = null)
	{
		x *= scaleX;
		y *= scaleY;
		
		rect.x = 0;
		rect.y = 0;
		rect.width = img.width;
		rect.height = img.height;
		
		//Why this has to be treated differently (add camera coords), I don't know...
		if(drawActor)
		{
			if(actor != null && actor.isHUD)
			{
				point.x = this.x + x;
				point.y = this.y + y;	
			}
			
			else
			{
				point.x = this.x + x + Engine.cameraX;
				point.y = this.y + y + Engine.cameraY;	
			}
		}
		
		else
		{
			point.x = this.x + x;
			point.y = this.y + y;	
		}
		
		var newImg:BitmapData = null;
		var imgSize = 0;
		mtx.identity();
		mtx.rotate(angle);
		mtx.translate(point.x, point.y);
		
		if (angle == 0)
		{
			if (alpha == 1)
			{
				//TODO: This is pretty wasteful but some weird caching bug if we don't do it.
				//http://community.stencyl.com/index.php/topic,13870.new.html#new
				graphics.beginBitmapFill(img.clone(), mtx);
			}
			else // actor is transparent
			{
				point2.x = 0;
				point2.y = 0;
				rect2.width = img.width;
				rect2.height = img.height;
			
				//TODO: Can we avoid making a new one each time?
				var temp = new BitmapData(img.width, img.height, true, toARGB(0x000000, Std.int(alpha * 255)));
				var temp2 = new BitmapData(img.width, img.height, true, 0);
				
				temp2.copyPixels(img, rect2, point2, temp, null, true);
				img = temp2;
				
				graphics.beginBitmapFill(img, mtx);
			}
			
			graphics.drawRect(point.x, point.y, img.width, img.height);
		}
		else // actor is rotated
		{
			if (alpha != 1)
			{
				point2.x = 0;
				point2.y = 0;
				rect2.width = img.width;
				rect2.height = img.height;
			
				//TODO: Can we avoid making a new one each time?
				var temp = new BitmapData(img.width, img.height, true, toARGB(0x000000, Std.int(alpha * 255)));
				var temp2 = new BitmapData(img.width, img.height, true, 0);
				
				temp2.copyPixels(img, rect2, point2, temp, null, true);
				img = temp2;
			}
			
			newImg = new BitmapData(img.width + 2, img.height + 2, true, 0x00000000);
			imgSize = Std.int(Math.sqrt(Math.pow(newImg.width, 2) + Math.pow(newImg.height, 2)));
			var srcRect = new Rectangle(0, 0, img.width, img.height);
			var destPt = new Point(1,1);
			newImg.copyPixels(img, srcRect, destPt);
			
			graphics.beginBitmapFill(newImg, mtx, false, Config.antialias);
			var rectX = ((imgSize - img.width) / 2);
			var rectY = ((imgSize - img.height) / 2);
			graphics.drawRect(this.x - rectX, this.y - rectY, imgSize, imgSize);
		}
		
		graphics.endFill();
	}
	
	private function toARGB(rgb:Int, newAlpha:Int):Int
	{
		var argb = 0; 
		argb = (rgb); 
		argb += (newAlpha << 24); 
		
		return argb; 
	}
	
	public inline function resetFont()
	{
		font = defaultFont;
	}
}

private class TemporaryImage
{
	public var lifetime:Int;
	public var img:BitmapData;

	public function new() {}
}