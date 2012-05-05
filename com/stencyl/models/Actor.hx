package com.stencyl.models;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.DisplayObject;
import nme.Assets;
import nme.display.Graphics;

import com.stencyl.graphics.AbstractAnimation;
import com.stencyl.graphics.BitmapAnimation;
import com.stencyl.graphics.SheetAnimation;

import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.BehaviorManager;

import com.stencyl.models.actor.ActorType;
import com.stencyl.models.scene.ActorInstance;

import com.stencyl.utils.Utils;
import com.stencyl.utils.HashMap;

class Actor extends Sprite 
{	
	public var realX:Float;
	public var realY:Float;

	public var xSpeed:Float;
	public var ySpeed:Float;
	public var rSpeed:Float;
	
	//Sprite-Based Animation
	public var currAnimation:DisplayObject;
	public var currAnimationName:String;
	public var animationMap:Hash<DisplayObject>;
	
	private var hasSprite:Bool;
	
	public var behaviors:BehaviorManager;
	public var registry:Hash<Dynamic>;
	
	//Events	
	public var allListeners:HashMap<Dynamic,Dynamic>;
	public var allListenerReferences:Array<Dynamic>;
	
	public var whenCreatedListeners:Array<Dynamic>;
	public var whenUpdatedListeners:Array<Dynamic>;
	public var whenDrawingListeners:Array<Dynamic>;
	public var whenKilledListeners:Array<Dynamic>;		
	public var mouseOverListeners:Array<Dynamic>;
	public var positionListeners:Array<Dynamic>;
	public var collisionListeners:Array<Dynamic>;

	public function new(engine:Engine, inst:ActorInstance, x:Int = 0, y:Int = 0, behaviorValues:Hash<Dynamic> = null) 
	{
		super();
		
		registry = new Hash<Dynamic>();
		
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
		
		realX = this.x;
		realY = this.y;
		
		xSpeed = 0;
		ySpeed = 0;
		rSpeed = 0;
		
		hasSprite = false;
		
		//---
		
		animationMap = new Hash<DisplayObject>();
		behaviors = new BehaviorManager();
		
		allListeners = new HashMap<Dynamic, Dynamic>();
		allListenerReferences = new Array<Dynamic>();
		
		whenCreatedListeners = new Array<Dynamic>();
		whenUpdatedListeners = new Array<Dynamic>();
		whenDrawingListeners = new Array<Dynamic>();
		whenKilledListeners = new Array<Dynamic>();
		mouseOverListeners = new Array<Dynamic>();
		positionListeners = new Array<Dynamic>();
		collisionListeners = new Array<Dynamic>();
		
		//---
		
		if(actorType != null)
		{
			var s:com.stencyl.models.actor.Sprite = cast(Data.get().resources.get(actorType.spriteID), com.stencyl.models.actor.Sprite);
			
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
	
	public function destroy()
	{
		//TODO:
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
			
			this.x = realX + Math.floor(newAnimation.width/2);
			this.y = realY + Math.floor(newAnimation.height/2);
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
		
		var r = 0;
		
		while(r < whenUpdatedListeners.length)
		{
			try
			{
				var f:Float->Array<Dynamic>->Void = whenUpdatedListeners[r];			
				f(elapsedTime, whenUpdatedListeners);
				
				if(Utils.indexOf(whenUpdatedListeners, f) == -1)
				{
					r--;
				}
			}
			
			catch(e:String)
			{
				trace(e);
			}
			
			r++;
		}			
			
		//behaviors.update(elapsedTime);
	}	
	
	//*-----------------------------------------------
	//* Behaviors
	//*-----------------------------------------------
	
	public function addBehavior(b:Behavior)
	{
		if(behaviors != null)
		{
			behaviors.add(b);
		}
	}
	
	public function hasBehavior(name:String):Bool
	{
		if(behaviors != null)
		{
			return behaviors.hasBehavior(name);
		}
		
		return false;
	}
	
	public function enableBehavior(name:String)
	{
		if(behaviors != null)
		{
			behaviors.enableBehavior(name);
		}
	}
	
	public function disableBehavior(name:String)
	{
		if(behaviors != null)
		{
			behaviors.disableBehavior(name);
		}
	}
	
	public function isBehaviorEnabled(name:String):Bool
	{
		if(behaviors != null)
		{
			return behaviors.isBehaviorEnabled(name);
		}
		
		return false;
	}
	
	public function enableAllBehaviors()
	{
		if(behaviors != null)
		{
			for(b in behaviors.behaviors)
			{
				b.enabled = true;
			}
		}
	}
		
	//*-----------------------------------------------
	//* Messaging
	//*-----------------------------------------------
	
	public function getValue(behaviorName:String, attributeName:String):Dynamic
	{
		return behaviors.getAttribute(behaviorName, attributeName);
	}
	
	public function setValue(behaviorName:String, attributeName:String, value:Dynamic)
	{
		behaviors.setAttribute(behaviorName, attributeName, value);
	}
	
	public function shout(msg:String, args:Array<Dynamic>):Dynamic
	{
		return behaviors.call(msg, args);
	}
	
	public function say(behaviorName:String, msg:String, args:Array<Dynamic>):Dynamic
	{
		return behaviors.call2(behaviorName, msg, args);
	}
	
	//*-----------------------------------------------
	//* Actor-Level Attributes
	//*-----------------------------------------------
	
	public function setActorValue(name:String, value:Dynamic)
	{
		if(registry != null)
		{
			registry.set(name, value);
		}
	}
	
	public function getActorValue(name:String):Dynamic
	{
		if(registry == null)
		{
			return null;
		}
		
		else
		{
			return registry.get(name);
		}
	}
	
	public function hasActorValue(name:String):Dynamic
	{
		if(registry == null)
		{
			return null;
		}
		
		return registry.get(name) != null;
	}
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------
	
	public function registerListener(type:Array<Dynamic>, listener:Dynamic)
	{
		var listenerList:Array<Dynamic> = allListeners.get(type);
		
		if(listenerList == null)
		{
			listenerList = new Array<Dynamic>();
			allListeners.set(type, listenerList);
		}
		
		listenerList.push(listener);
	}
	
	public function removeAllListeners()
	{			
		for(k in allListeners.keys())
		{
			var listener = cast(k, Array<Dynamic>);
			
			if(listener != null)
			{
				var list:Array<Dynamic> = cast(allListeners.get(listener), Array<Dynamic>);
				
				if(list != null)
				{
					for(r in 0...list.length)
					{
						Utils.removeValueFromArray(listener, list[r]);
					}
				}
			}
		}
		
		//Not Needed?
		for(dict in allListenerReferences)
		{
			dict.delete(this);
		}
		
		Utils.clear(allListenerReferences);
	}		
}
