package com.stencyl.models.scene;

import nme.display.Sprite;
import nme.display.Bitmap;

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
	
	public var xP:Float;
	public var yP:Float;
	public var xPos:Float;
	public var yPos:Float;
	public var xVelocity:Float;
	public var yVelocity:Float;
	
	public function new(img:Dynamic, dx:Float, dy:Float) 
	{
		super();
		
		curStep = 0;
	
		running = true;
		
		image1 = new Bitmap(img);
		addChild(image1);
        
		image2 = new Bitmap(img);
        image2.x = image1.x-image1.width;
		addChild(image2);
        
        image3 = new Bitmap(img);
        image3.x = image1.x+image1.width;
		addChild(image3);
        
        //
        
        image4 = new Bitmap(img);
        image4.x = image1.x-image1.width;
        image4.y = image1.y-image1.height;
		addChild(image4);
        
        image5 = new Bitmap(img);
        image5.y = image1.y-image1.height;
		addChild(image5);
        
        image6 = new Bitmap(img);
        image6.x = image1.x+image1.width;
        image6.y = image1.y-image1.height;
		addChild(image6);
        
        //
        
        image7 = new Bitmap(img);
        image7.x = image1.x-image1.width;
        image7.y = image1.y+image1.height;
		addChild(image7);
        
        image8 = new Bitmap(img);
        image8.y = image1.y+image1.height;
		addChild(image8);
        
        image9 = new Bitmap(img);
        image9.x = image1.x+image1.width;
        image9.y = image1.y+image1.height;
		addChild(image9);
		
		xP = 0;
		yP = 0;
		
		xPos = 0;
        yPos = 0;
        
        xVelocity = dx;
        yVelocity = dy;
	}
	
	public function update(elapsedTime:Float)
	{
		if(running)
		{
			var width = image1.width;
			var height = image1.height;
			
			xP += xVelocity / 10.0;
			yP += yVelocity / 10.0;
			
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
		
	        image1.x = xPos;
	        image1.y = yPos;
	        
	        image2.x = xPos - width;
	        image2.y = yPos;
	        
	        image3.x = xPos + width;
	        image3.y = yPos;
	        
	        image4.x = xPos - width;
	        image4.y = yPos - height;
	        
	        image5.x = xPos;
	        image5.y = yPos - height;
	        
	        image6.x = xPos + width;
	        image6.y = yPos - height;
	        
	        image7.x = xPos - width;
	        image7.y = yPos + height;
	        
	        image8.x = xPos;
	        image8.y = yPos + height;
	        
	        image9.x = xPos + width;
	        image9.y = yPos + height;
	        
			curStep -= Math.floor(curStep);
		}
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
