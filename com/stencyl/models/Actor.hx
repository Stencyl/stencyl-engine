package com.stencyl.models;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.Assets;
import nme.display.Graphics;

import com.stencyl.Engine;

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
	//*-----------------------------------------------
	//* Globals
	//*-----------------------------------------------
	
	private var engine:Engine;
	

	//*-----------------------------------------------
	//* Properties
	//*-----------------------------------------------
	
	public var ID:Int;
	//public var name:String; //Already a prop
	public var groupID:Int;
	public var layerID:Int;
	public var typeID:Int;
	
	
	//*-----------------------------------------------
	//* States
	//*-----------------------------------------------

	public var recycled:Bool;
	public var paused:Bool;
	
	public var isRegion:Bool;
	public var isTerrainRegion:Bool;

	public var destroyed:Bool;	
	public var drawActor:Bool;	
	public var isHUD:Bool;
	public var alwaysSimulate:Bool;
	
	public var isCamera:Bool;
	public var killLeaveScreen:Bool;	
	public var isLightweight:Bool;
	public var autoScale:Bool;
	

	//*-----------------------------------------------
	//* Position / Motion
	//*-----------------------------------------------
	
	public var realX:Float;
	public var realY:Float;

	public var xSpeed:Float;
	public var ySpeed:Float;
	public var rSpeed:Float;
	
	//public var tweenLoc:Point;
	//public var tweenAngle:AngleHolder;
	
	
	//*-----------------------------------------------
	//* Sprite-Based Animation
	//*-----------------------------------------------
	
	public var currAnimation:DisplayObject;
	public var currAnimationName:String;
	public var animationMap:Hash<DisplayObject>;
	
	public var hasSprite:Bool; //???
	
	public var shapeMap:Hash<Dynamic>;
	public var originMap:Hash<Dynamic>;
	public var defaultAnim:String;
	
	/* 
	public var currOrigin:V2;
	public var currOffset:V2;
	*/
	
	
	//*-----------------------------------------------
	//* Behaviors
	//*-----------------------------------------------
	
	public var behaviors:BehaviorManager;
	
	
	//*-----------------------------------------------
	//* Actor Values
	//*-----------------------------------------------
	
	public var registry:Hash<Dynamic>;
	
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------	
	
	public var allListeners:HashMap<Dynamic,Dynamic>;
	public var allListenerReferences:Array<Dynamic>;
	
	public var whenCreatedListeners:Array<Dynamic>;
	public var whenUpdatedListeners:Array<Dynamic>;
	public var whenDrawingListeners:Array<Dynamic>;
	public var whenKilledListeners:Array<Dynamic>;		
	public var mouseOverListeners:Array<Dynamic>;
	public var positionListeners:Array<Dynamic>;
	public var collisionListeners:Array<Dynamic>;
	
	public var mouseState:Int;
	public var lastScreenState:Bool;
	public var lastSceneState:Bool;
	
	
	//*-----------------------------------------------
	//* Physics (Box2D)
	//*-----------------------------------------------
	
	//TODO
	/*
	public var body:b2Body;
	public var bodyDef:b2BodyDef;
	private var md:b2MassData;
	public var bodyScale:Point;
	public var contacts:Dictionary;
	public var regionContacts:Dictionary;
	public var collisions:Dictionary;
	*/


	//*-----------------------------------------------
	//* Collisions
	//*-----------------------------------------------
	
	public var handlesCollisions:Bool; //???
	public var lastCollided:Actor;
	
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------

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
		
		var r = 0;
		
		while(r < whenCreatedListeners.length)
		{
			try
			{
				var f:Array<Dynamic>->Void = whenCreatedListeners[r];			
				f(whenCreatedListeners);
				
				if(Utils.indexOf(whenCreatedListeners, f) == -1)
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
   	
   	
   	//*-----------------------------------------------
	//* Animation
	//*-----------------------------------------------
   	
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
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------
		
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
	//* Properties
	//*-----------------------------------------------
	
	public function getID():Int
	{
		return ID;
	}
	
	public function getName():String
	{
		return name;
	}
	
	public function getGroupID():Int
	{
		if(isLightweight)
		{
			return groupID;
		}
		
		else
		{
			return 0;
			//return body.groupID;
		}
	}
	
	public function getLayerID():Int
	{
		return layerID;
	}
	
	public function getLayerOrder():Int
	{
		return 0;
		//TODO
		//return engine.getOrderForLayerID(layerID) + 1;
	}
	
	public function getType():ActorType
	{
		if(typeID == -1)
		{
			return null;
		}
		
		return cast(Data.get().resources.get(typeID), ActorType);
	}
		
	//*-----------------------------------------------
	//* State
	//*-----------------------------------------------
		
	public function isPausable():Bool
	{
		return getType().pausable;
	}
	
	public function isPaused():Bool
	{
		return paused;
	}
	
	public function pause()
	{
		if(isPausable())
		{
			this.paused = true;
			
			/*if(!isLightweight)
			{
				this.body.SetPaused(true);
			}*/
		}
	}
	
	public function unpause()
	{
		if(isPausable())
		{
			this.paused = false;
			
			/*if(!isLightweight)
			{
				this.body.SetPaused(false);
			}*/
		}
	}
	
	//*-----------------------------------------------
	//* Type
	//*-----------------------------------------------
	
	public function getGroup():Sprite
	{
		try
		{
			//TODO
			//return engine.groups[getGroupID()];
		}
		
		//Dead
		catch(e:String)
		{
		}
		
		return null;
	}
	
	public function getIsRegion():Bool
	{
		return isRegion;
	}
	
	public function getIsTerrainRegion():Bool
	{
		return isTerrainRegion;
	}
	
	//*-----------------------------------------------
	//* Layering
	//*-----------------------------------------------
	
	public function moveToLayerOrder(layerOrder:Int)
	{
		//engine.moveToLayerOrder(this,layerOrder);
	}
	
	public function bringToFront()
	{
		//engine.bringToFront(this);
	}
	
	public function bringForward()
	{
		//engine.bringForward(this);
	}
	
	public function sendToBack()
	{
		//engine.sendToBack(this);
	}
	
	public function sendBackward()
	{
		//engine.sendBackward(this);
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
	//* Events PLumbing
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
