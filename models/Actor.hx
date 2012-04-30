package models;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.DisplayObject;
import nme.Assets;
import nme.display.Graphics;

import graphics.AbstractAnimation;
import graphics.BitmapAnimation;
import graphics.SheetAnimation;

import behavior.BehaviorManager;

import models.actor.ActorType;
import models.scene.ActorInstance;

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
	
	public var behaviors:BehaviorManager;

	public function new(engine:Engine, inst:ActorInstance, x:Int = 0, y:Int = 0, behaviorValues:Hash<Dynamic> = null) 
	{
		super();
		
		var actorType:ActorType = null;	
		
		if(inst == null)
		{
			this.x = x;
			this.y = y;
		}
		
		else
		{
			this.x = inst.x;
			this.y = inst.y;
			
			actorType = inst.actorType;
		}
		
		xSpeed = 0;
		ySpeed = 0;
		rSpeed = 0;
		
		hasSprite = false;
		
		animationMap = new Hash<DisplayObject>();
		behaviors = new BehaviorManager();
		
		if(actorType != null)
		{
			var s:models.actor.Sprite = cast(Data.get().resources.get("" + actorType.spriteID), models.actor.Sprite);
			
			if(s != null)
			{
				var defaultAnim:String = "";
				
				for(a in s.animations)
				{
					addAnim
					(
						a.animName, 
						a.imgData, 
						a.framesAcross, 
						Math.floor(a.imgWidth / a.framesAcross), 
						Math.floor(a.imgHeight / a.framesDown), 
						a.originX,
						a.originY,
						a.durations, 
						a.looping,
						a.shapes
					);
					
					if(a.animID == s.defaultAnimation)
					{
						defaultAnim = a.animName;
					}
				}
				
				switchAnimation(defaultAnim);
			}
		}
		
		//---
		
		if(behaviorValues == null && actorType != null)
		{
			behaviorValues = actorType.behaviorValues;
		}

		Engine.initBehaviors(behaviors, behaviorValues, this, engine, false);
	}	
	
	public function addAnim
	(
		name:String, 
		imgData:BitmapData, 
		frameCount:Int=1, 
		frameWidth:Int=0, 
		frameHeight:Int = 0, 
		originX:Float = 0,
		originY:Float = 0,
		durations:Array<Int>=null, 
		looping:Bool=true, 
		shapes:Array<Dynamic>=null
	)
	{
		/*if(shapes != null)
		{
			var arr:Array = new Array();
			
			for each(var s:b2FixtureDef in shapes)
			{
				arr.push(s);
			}
			
			shapeMap[name] = arr;
		}*/
	
		var sprite = new BitmapAnimation(imgData, frameCount, [1000, 1000]);
		animationMap.set(name, sprite);
		hasSprite = true;		
	}
	
	public function initScripts()
	{		
		//handlesCollisions = true;
		
		behaviors.initScripts();
		
		/*for (var r:int = 0; r < whenCreatedListeners.length; r++)
		{
			try
			{
				var f:Function = whenCreatedListeners[r] as Function;
				f(whenCreatedListeners);
				
				if (whenCreatedListeners.indexOf(f) == -1)
				{
					r--;
				}
			}
			catch (e:Error)
			{
				FlxG.log(e.getStackTrace());
			}
		}*/
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
		
		behaviors.update(elapsedTime);
	}	
}
