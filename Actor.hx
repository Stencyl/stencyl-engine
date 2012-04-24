package ;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.Tilesheet;
import nme.display.DisplayObject;
import nme.Assets;
import nme.display.Graphics;

import graphics.AbstractAnimation;
import graphics.BitmapAnimation;
import graphics.SheetAnimation;

class Actor extends Sprite 
{	
	public var xSpeed:Float;
	public var ySpeed:Float;
	public var rSpeed:Float;
	
	//Sprite-Based Animation
	public var currAnimation:DisplayObject;
	public var currAnimationName:String;
	public var animationMap:Hash<DisplayObject>;

	public function new(x:Int = 0, y:Int = 0) 
	{
		super();	
		
		this.x = x;
		this.y = y;
		
		xSpeed = 0;
		ySpeed = 0;
		rSpeed = 0;
		
		animationMap = new Hash<DisplayObject>();
	}	
	
	public function tileTest()
   	{
   		#if !js
   		var bmp = Assets.getBitmapData("assets/graphics/animation.png");
		var tilesheet = new Tilesheet(bmp);
		tilesheet.addTileRect(new nme.geom.Rectangle(0, 0, 48, 32));
		tilesheet.addTileRect(new nme.geom.Rectangle(48, 0, 48, 32)); 	
		currAnimation = new SheetAnimation(tilesheet, [1000, 1000]);
		#end
		
		/*var img1 = Assets.getBitmapData("assets/graphics/anim1.png");
		var img2 = Assets.getBitmapData("assets/graphics/anim2.png");
		anim = new BitmapAnimation([img1, img2],[1000, 1000]);*/
		
		addChild(currAnimation);
   	}
   	
   	public function updateAnimation(elapsedTime:Float)
   	{
   		if(currAnimation != null)
   		{
   			cast(currAnimation, AbstractAnimation).update(elapsedTime);
   		}
   	}
	
	public function addAnimation(name:String, loc:String, numFrames:Int = 1)
	{
		var sprite = new Bitmap(Assets.getBitmapData(loc));
		sprite.smoothing = true;
		sprite.x = -sprite.width/2;
		sprite.y = -sprite.height/2;
		
		animationMap.set(name, sprite);
	}
	
	public function switchAnimation(name:String)
	{
		if(name != currAnimationName)
		{
			var newAnimation = animationMap.get(name);
			
			if(newAnimation == null)
			{
				return;
			}
			
			if(currAnimation != null)
			{
				removeChild(currAnimation);
			}
			
			currAnimationName = name;
			currAnimation = newAnimation;
				
			addChild(newAnimation);
		}
	}
	
	public function update(elapsedTime:Float)
	{
		this.x += elapsedTime * xSpeed;
		this.y += elapsedTime * ySpeed;
		this.rotation += elapsedTime * rSpeed;
	}	
	
	//Behavior = Attributes + Event Collection
	public function attachBehavior()
	{
	}
}
