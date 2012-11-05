package com.stencyl.models.scene;

import nme.display.Sprite;
import nme.display.Bitmap;
import com.stencyl.Engine;

class ScrollingBitmap extends Sprite
{
	public var image1:Bitmap; //Center
	public var image2:Bitmap; //W
	public var image3:Bitmap; //E
	public var image4:Bitmap; //NW
	public var image5:Bitmap; //N
	public var image6:Bitmap; //NE
	public var image7:Bitmap; //SW
	public var image8:Bitmap; //S
	public var image9:Bitmap; //SE
	
	public var speed:Float;
	public var curStep:Float;
	
	public var running:Bool;
	public var parallax:Bool;
	
	public var cacheWidth:Float;
	public var cacheHeight:Float;
	
	public var xP:Float;
	public var yP:Float;
	public var xPos:Float;
	public var yPos:Float;
	public var xVelocity:Float;
	public var yVelocity:Float;
	public var parallaxX:Float;
	public var parallaxY:Float;
	
	public function new(img:Dynamic, dx:Float, dy:Float, px:Float=0, py:Float=0) 
	{
		super();
		
		curStep = 0;
	
		running = true;
		
		image1 = new Bitmap(img);
		addChild(image1);
		
		cacheWidth = image1.width;
		cacheHeight = image1.height;
        
		image2 = new Bitmap(img);
        image2.x = image1.x-cacheWidth;
		addChild(image2);
        
        image3 = new Bitmap(img);
        image3.x = image1.x+cacheWidth;
		addChild(image3);
        
        //
        
        image4 = new Bitmap(img);
        image4.x = image1.x-cacheWidth;
        image4.y = image1.y-cacheHeight;
		addChild(image4);
        
        image5 = new Bitmap(img);
        image5.y = image1.y-cacheHeight;
		addChild(image5);
        
        image6 = new Bitmap(img);
        image6.x = image1.x+cacheWidth;
        image6.y = image1.y-cacheHeight;
		addChild(image6);
        
        //
        
        image7 = new Bitmap(img);
        image7.x = image1.x-cacheWidth;
        image7.y = image1.y+cacheHeight;
		addChild(image7);
        
        image8 = new Bitmap(img);
        image8.y = image1.y+cacheHeight;
		addChild(image8);
        
        image9 = new Bitmap(img);
        image9.x = image1.x+cacheWidth;
        image9.y = image1.y+cacheHeight;
		addChild(image9);
		
		xP = 0;
		yP = 0;
		
		xPos = 0;
        yPos = 0;
        
        xVelocity = dx;
        yVelocity = dy;
		
		parallax = false;
		parallaxX = px;
		parallaxY = py;
		
		if (dx == 0 && dy == 0)
		{
			parallax = true;
		}
	}
	
	public function updateAuto(elapsedTime:Float)
	{
		if(running)
		{
			var width = cacheWidth;
			var height = cacheHeight;
			
			xP += xVelocity / 10.0 * Engine.SCALE;
			yP += yVelocity / 10.0 * Engine.SCALE;
			
			if(xP < -width || xP > width)
	        {
	            xP = 0;
	        }
	        
	        if(yP < -height || yP > height)
	        {
	            yP = 0;
	        }
	        
	        xPos = Math.floor(xP);
	        yPos = Math.floor(yP);
	        
			curStep += 1;
			
			if(curStep < 1) 
			{
				return;
			}
		
			//TODO: Optimize?
	        resetPositions();
	        
			curStep -= Math.floor(curStep);
		}
	}
	
	public function updateParallax()
	{		
		xPos = Engine.cameraX * parallaxX;
		yPos = Engine.cameraY * parallaxY;
		
		if (xPos < -cacheWidth)
		{
			xPos = xPos % cacheWidth;
		}
		
		if (yPos < -cacheHeight)
		{
			yPos = yPos % cacheHeight;
		}	
		
		//TODO: Optimize?
		resetPositions();
	}
	
	public function resetPositions()
	{
		image1.x = xPos;
	    image1.y = yPos;
	        
	    image2.x = xPos - cacheWidth;
	    image2.y = yPos;
	        
		image3.x = xPos + cacheWidth;
		image3.y = yPos;
	        
		image4.x = xPos - cacheWidth;
		image4.y = yPos - cacheHeight;
	        
		image5.x = xPos;
		image5.y = yPos - cacheHeight;
	        
		image6.x = xPos + cacheWidth;
		image6.y = yPos - cacheHeight;
	        
		image7.x = xPos - cacheWidth;
		image7.y = yPos + cacheHeight;
	        
		image8.x = xPos;
		image8.y = yPos + cacheHeight;
	        
		image9.x = xPos + cacheWidth;
		image9.y = yPos + cacheHeight;
	}
	
	public function start()
	{
		running = true;
	}
	
	public function stop()
	{
		running = false;
	}
}
