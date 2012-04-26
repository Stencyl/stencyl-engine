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
	
	private var hasSprite:Bool;

	public function new(x:Int = 0, y:Int = 0) 
	{
		super();	
		
		this.x = x;
		this.y = y;
		
		xSpeed = 0;
		ySpeed = 0;
		rSpeed = 0;
		
		hasSprite = false;
		
		animationMap = new Hash<DisplayObject>();
	}	
	
	public function tileTest()
   	{
   		var bmp = Assets.getBitmapData("assets/graphics/animation.png");

   		#if !js
		/*var tilesheet = new Tilesheet(bmp);
		tilesheet.addTileRect(new nme.geom.Rectangle(0, 0, 48, 32));
		tilesheet.addTileRect(new nme.geom.Rectangle(48, 0, 48, 32)); 	
		currAnimation = new SheetAnimation(tilesheet, [1000, 1000], 48, 32);*/
		#end
				
		currAnimation = new BitmapAnimation(bmp, 2, [1000, 1000]);
		
		addChild(currAnimation);
		
		hasSprite = true;
   	}
   	
	public function addAnimation(name:String, sprite:DisplayObject)
	{
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
		if(hasSprite)
   		{
   			cast(currAnimation, AbstractAnimation).update(elapsedTime);
   		}
   		
		this.x += elapsedTime * xSpeed;
		this.y += elapsedTime * ySpeed;
		this.rotation += elapsedTime * rSpeed;
	}	
	
	//Behavior = Attributes + Event Collection
	public function attachBehavior()
	{
	}
}
