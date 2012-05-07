package com.stencyl.models;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.Assets;
import nme.display.Graphics;
import nme.geom.Point;

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
	
	public var currOrigin:Point;
	public var currOffset:Point;
	
	
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
	
	private var dummy:V2 = new V2();
	private var zero:V2 = new V2(0, 0);
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
	
	public function updateAnimProperties(doAll:Bool)
	{
		if(currAnimation != null)
		{
			if(isLightweight)
			{
				currAnimation.x = getX();
				currAnimation.y = getY();
			}
			
			else
			{
				currAnimation.x = x;
				currAnimation.y = y;
			}
			
			currAnimation.rotation = rotation;
			
			if(doAll)
			{
				//TODO: 
				//currAnimation.updateAnimation();
			}
		}
	}
	
	function updateTweenProperties()
	{
		//Since we can't tween directly on the Box2D values and can't make direct function calls,
		//we have to reverse the normal flow of information from body -> Flixel to tween -> body
		/*var a:Boolean = Tweener.isTweening(tweenLoc);
		var b:Boolean = Tweener.isTweening(tweenAngle);
				
		if (autoScale && !isLightweight && body != null && bodyDef.type != b2Body.b2_staticBody && (bodyScale.x != currSprite.scale.x || bodyScale.y != currSprite.scale.y))
		{
			if (currSprite.scale.x > 0 && currSprite.scale.y > 0)
			{
				scaleBody(currSprite.scale.x, currSprite.scale.y);
			}
		}
		
		if(a && b)
		{
			x = tweenLoc.x;
			currSprite.x = tweenLoc.x;
			
			y = tweenLoc.y;
			currSprite.y = tweenLoc.y;
			
			angle = tweenAngle.angle;
			currSprite.angle = tweenAngle.angle;
			
			if (!isLightweight)
			{
				body.SetTransform(new V2(GameState.toPhysicalUnits(x), GameState.toPhysicalUnits(y)), Util.toRadians(angle));
			}
		}
		
		else
		{
			if(a)
			{
				x = tweenLoc.x;
				currSprite.x = tweenLoc.x;
				setX(tweenLoc.x);
				
				y = tweenLoc.y;
				currSprite.y = tweenLoc.y;
				setY(tweenLoc.y);
			}
			
			if(b)
			{
				angle = tweenAngle.angle;
				currSprite.angle = tweenAngle.angle;
				setAngle(tweenAngle.angle, false);
			}
		}*/		
	}
		
	public function scaleBody(width:Float, height:Float)
	{
		/*var fixtureList:Array = new Array;

		for(var fixture:b2Fixture = getBody().GetFixtureList(); fixture; fixture = fixture.GetNext())
		{
			fixtureList.push(fixture);
		}
			
		for each(var f:b2Fixture in fixtureList)
		{ 
			var poly:b2Shape = f.GetShape();
			var center:V2 = getBody().GetLocalCenter();
			if(poly instanceof b2CircleShape)
			{
				var factor:Number = (1 / bodyScale.x) * width;					
				
				var p:V2 = (poly as b2CircleShape).m_p.v2;
				var positionVector:V2 = V2.subtract(p, center);
				positionVector.x = positionVector.x * factor;
				positionVector.y = positionVector.y * factor;	
				
				(poly as b2CircleShape).m_p.v2 = V2.add(center, positionVector);
				poly.m_radius = poly.m_radius * factor;								
			}

			if(poly instanceof b2PolygonShape)
			{
  				var verts:Vector.<V2> = (poly as b2PolygonShape).m_vertices;
				var newVerts:Vector.<V2> = new Vector.<V2>();

				for each(var v:V2 in verts)
				{
					var positionVector:V2 = V2.subtract(v,center);
					positionVector.x = positionVector.x * (1 / bodyScale.x) * width;
					positionVector.y = positionVector.y * (1 / bodyScale.y) * height;	
					var newV2:V2 = V2.add(center, positionVector);

					newVerts.push(newV2);
				}

				(poly as b2PolygonShape).Set(newVerts);   					
			}
		}	
		
		bodyScale.x = width;
		bodyScale.y = height;*/
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
	//* Physics: Position
	//*-----------------------------------------------
	
	public function getX():Float
	{
		/*if(isRegion || isTerrainRegion)
		{
			return Math.round(GameState.toPixelUnits(body.GetPosition().x) - width/2);
		}
		
		else if (!isLightweight)
		{
			return Math.round(body.GetPosition().x * GameState.physicsScale - Math.floor(width / 2) - currOffset.x);
		}
		
		else 
		{
			return x - width/2 - currOffset.x;
		}*/
		
		return x;
	}
	
	public function getY():Float
	{
		/*if(isRegion || isTerrainRegion)
		{
			return Math.round(GameState.toPixelUnits(body.GetPosition().y) - height/2);
		}
			
		else if (!isLightweight)
		{
			return Math.round(body.GetPosition().y * GameState.physicsScale - Math.floor(height / 2) - currOffset.y);
		}
		
		else
		{
			return y - height/2 - currOffset.y;
		}*/
		
		return y;
	}
	
	public function getXCenter():Float
	{
		/*if(!isLightweight)
		{
			return Math.round(GameState.toPixelUnits(body.GetWorldCenter().x) - currOffset.x);
		}
		
		else
		{
			return x  - currOffset.x;
		}*/
		
		return x + width/2;
	}
	
	public function getYCenter():Float
	{
		/*if(!isLightweight)
		{
			return Math.round(GameState.toPixelUnits(body.GetWorldCenter().y) - currOffset.y);
		}
		
		else
		{
			return y - currOffset.y;
		}*/
		
		return y + height/2;
	}
	
	public function getScreenX():Float
	{
		if(isHUD)
		{
			return getX();
		}
		
		else
		{
			return getX() + Engine.cameraX;
		}
	}
	
	public function getScreenY():Float
	{
		if(isHUD)
		{
			return getY();
		}
			
		else
		{
			return getY() + Engine.cameraY;
		}
	}
	
	public function setX(x:Float, resetSpeed:Bool = false)
	{
		if(isLightweight)
		{
			this.x = x + width / 2 + currOffset.x;
			updateAnimProperties(false);
		}
		
		else
		{
			/*if(isRegion || isTerrainRegion)
			{
				dummy.x = GameState.toPhysicalUnits(x);
			}
				
			else
			{
				dummy.x = GameState.toPhysicalUnits(x + Math.floor(width/2) + currOffset.x);
			}			
			
			dummy.y = body.GetPosition().y;
			
			body.SetPosition(dummy);
			
			if(resetSpeed)
			{
				body.SetLinearVelocity(zero);
			}
			
			this.x = Math.round(dummy.x * GameState.physicsScale - Math.floor(width / 2) - currOffset.x);
			updateAnimProperties(false);*/
		}
	}
	
	public function setY(y:Float, resetSpeed:Bool = false)
	{
		if(isLightweight)
		{
			this.y = y + height / 2 + currOffset.y;
			updateAnimProperties(false);
		}
		
		else
		{	
			/*if(isRegion || isTerrainRegion)
			{
				dummy.y = GameState.toPhysicalUnits(y);
			}
				
			else
			{
				dummy.y = GameState.toPhysicalUnits(y + Math.floor(height/2) + currOffset.y);
			}
			
			dummy.x = body.GetPosition().x;
			
			body.SetPosition(dummy);		
			
			if(resetSpeed)
			{
				body.SetLinearVelocity(zero);
			}
			
			this.y = Math.round(dummy.y * GameState.physicsScale - Math.floor(height / 2) - currOffset.y);;
			updateAnimProperties(false);*/	
		}
	}
	
	public function follow(a:Actor)
	{
		if(isLightweight)
		{
			x = a.getXCenter();
			y = a.getYCenter();
			
			return;
		}
		
		//body.SetPosition(a.body.GetWorldCenter());
		
		//DEAD
		//x = a.x;
		//y = a.y;
	}
	
	public function followWithOffset(a:Actor, ox:Int, oy:Int)
	{
		if(isLightweight)
		{
			x = a.getXCenter() + ox;
			y = a.getYCenter() + oy;
			
			return;
		}
		
		/*var pt:V2 = a.body.GetWorldCenter();
		
		pt.x += GameState.toPhysicalUnits(ox);
		pt.y += GameState.toPhysicalUnits(oy);
		
		body.SetPosition(pt);*/
		
		//DEAD
		//x = a.x + ox;
		//y = a.y + oy;
	}
	
	public function setOriginPoint(x:Int, y:Int)
	{
		/*var resetPosition:V2;
		
		if (!isLightweight)
		{
			resetPosition = body.GetPosition();
		}
		
		else
		{
			resetPosition = new V2(GameState.toPhysicalUnits(this.x), GameState.toPhysicalUnits(this.y));
		}
		
		var offsetDiff:V2 = new V2(currOffset.x, currOffset.y);
		var radians:Number = getAngle();			
		
		var newOffX:int = x - (currSprite.width / 2);
		var newOffY:int = y - (currSprite.height / 2);
		
		if (currOrigin != null && (int(currOffset.x) != newOffX || int(currOffset.y) != newOffY) && angle != 0)
		{
			var oldAng:Number = radians + Math.atan2( -currOffset.y, -currOffset.x);
			var newAng:Number = radians + Math.atan2( -newOffY, -newOffX);
			var oldDist:Number = Math.sqrt(Math.pow(currOffset.x, 2) + Math.pow(currOffset.y, 2));
			var newDist:Number = Math.sqrt(Math.pow(newOffX, 2) + Math.pow(newOffY, 2));
							
			var oldFixCenterX:int = Math.round(currOrigin.x + Math.cos(oldAng) * oldDist);
			var oldFixCenterY:int = Math.round(currOrigin.y + Math.sin(oldAng) * oldDist);
			var newFixCenterX:int = Math.round(x + Math.cos(newAng) * newDist);
			var newFixCenterY:int = Math.round(y + Math.sin(newAng) * newDist);
						
			resetPosition.x += GameState.toPhysicalUnits(oldFixCenterX - newFixCenterX);
			resetPosition.y += GameState.toPhysicalUnits(oldFixCenterY - newFixCenterY);
		}
		
		currOrigin.x = x;
		currOrigin.y = y;
		currOffset.x = newOffX;
		currOffset.y = newOffY;		
					
		offsetDiff.x = currOffset.x - offsetDiff.x;
		offsetDiff.y = currOffset.y - offsetDiff.y;
		
		currSprite.origin.x = x;
		currSprite.origin.y = y;			
			
		resetPosition.x += GameState.toPhysicalUnits(offsetDiff.x);
		resetPosition.y += GameState.toPhysicalUnits(offsetDiff.y);
		
		if (!isLightweight)
		{
			body.SetPosition(resetPosition);
		}
		
		else
		{
			x = GameState.toPixelUnits(resetPosition.x);
			y = GameState.toPixelUnits(resetPosition.y);
		}*/
	}
	
	//*-----------------------------------------------
	//* Physics: Velocity
	//*-----------------------------------------------
	
	public function getXVelocity():Float
	{
		if(isLightweight)
		{
			return xSpeed;
		}
		
		return 0;
		//return body.GetLinearVelocity().x;
	}
	
	public function getYVelocity():Float
	{
		if(isLightweight)
		{
			return ySpeed;
		}
		
		return 0;
		//return body.GetLinearVelocity().y;
	}
	
	public function setXVelocity(dx:Float)
	{
		if(isLightweight)
		{
			xSpeed = dx;
			return;
		}
		
		/*var v:V2 = body.GetLinearVelocity();
		v.x = dx * Engine.PSCALE;
		body.SetLinearVelocity(v);
		body.SetAwake(true);*/
	}
	
	public function setYVelocity(dy:Float)
	{
		if(isLightweight)
		{
			ySpeed = dy;
			return;
		}
		
		/*var v:V2 = body.GetLinearVelocity();
		v.y = dy * GameState.PSCALE;
		body.SetLinearVelocity(v);
		body.SetAwake(true);*/
	}
	
	public function setVelocity(angle:Float, speed:Float)
	{
		setXVelocity(speed * Math.cos(Utils.RAD * angle));
		setYVelocity(speed * Math.sin(Utils.RAD * angle));
	}
	
	public function accelerateX(dx:Float)
	{
		setXVelocity(getXVelocity() + dx);
	}
	
	public function accelerateY(dy:Float)
	{
		setYVelocity(getYVelocity() + dy);
	}
	
	public function accelerate(angle:Float, speed:Float)
	{
		setXVelocity(getXVelocity() + speed * Math.cos(Utils.RAD * angle));
		setYVelocity(getYVelocity() + speed * Math.sin(Utils.RAD * angle));
	}
	
	//*-----------------------------------------------
	//* Physics: Angles and Angular Velocity
	//*-----------------------------------------------
	
	public function getAngle():Float
	{
		if(isLightweight)
		{
			return Utils.RAD * rotation;
		}
		
		return 0;
		//return body.GetAngle();
	}
	
	public function getAngleInDegrees():Float
	{
		if(isLightweight)
		{
			return rotation;
		}
		
		return 0;
		//return Util.toDegrees(body.GetAngle());
	}
	
	public function setAngle(angle:Float, inRadians:Bool = true)
	{
		if(inRadians)
		{
			if(isLightweight)
			{
				this.rotation = Utils.DEG * angle;
			}
			
			else
			{
				//body.SetAngle(angle);				
			}
		}
		
		else
		{
			if(isLightweight)
			{
				this.rotation = angle;
			}
			
			else
			{
				//body.SetAngle(Util.toRadians(angle));		
			}
		}
	}
	
	public function rotate(angle:Float, inRadians:Bool = true)
	{
		if(inRadians)
		{
			if(isLightweight)
			{
				this.rotation += Utils.DEG * angle;
			}
			
			else
			{
				//body.SetAngle(body.GetAngle() + angle);
			}
		}
			
		else
		{
			if(isLightweight)
			{
				this.rotation += angle;
			}
			
			else
			{
				//body.SetAngle(body.GetAngle() + Util.toRadians(angle));
			}	
		}
	}
	
	public function getAngularVelocity():Float
	{
		if(isLightweight)
		{
			return Utils.RAD * rotation;
		}
		
		return 0;
		//return body.GetAngularVelocity();
	}
	
	public function setAngularVelocity(omega:Float)
	{
		if(isLightweight)
		{
			rSpeed = Utils.DEG * omega;
		}
		
		else
		{
			//body.SetAngularVelocity(omega);	
			//body.SetAwake(true);
		}
	}
	
	public function changeAngularVelocity(omega:Float)
	{
		if(isLightweight)
		{
			rSpeed += Utils.DEG * omega;
		}
		
		else
		{
			//body.SetAngularVelocity(body.GetAngularVelocity() + omega);
			//body.SetAwake(true);
		}
	}
	
	//*-----------------------------------------------
	//* Physics: Forces
	//*-----------------------------------------------
	
	/*public function push(dirX:Number, dirY:Number, magnitude:Number)
	{
		if(isLightweight || (dirX == 0 && dirY == 0))
		{
			return;
		}
		
		dummy.x = dirX;
		dummy.y = dirY;
		dummy.normalize();
		
		if(magnitude > 0)
		{
			dummy.multiplyN(magnitude * GameState.PSCALE);
		}
		
		body.ApplyForce(dummy, body.GetWorldCenter());
	}
	
	//in degrees
	public function pushInDirection(angle:Number, speed:Number)
	{
		push
		(
			Math.cos(Util.toRadians(angle)),
			Math.sin(Util.toRadians(angle)),
			speed
		);
	}
	
	public function applyImpulse(dirX:Number, dirY:Number, magnitude:Number)
	{
		if(isLightweight || (dirX == 0 && dirY == 0))
		{
			return;
		}
		
		dummy.x = dirX;
		dummy.y = dirY;
		dummy.normalize();
		
		if(magnitude > 0)
		{
			dummy.multiplyN(magnitude * GameState.PSCALE);
		}
		
		body.ApplyImpulse(dummy, body.GetWorldCenter());
	}
	
	//in degrees
	public function applyImpulseInDirection(angle:Number, speed:Number)
	{
		applyImpulse
		(
			Math.cos(Util.toRadians(angle)),
			Math.sin(Util.toRadians(angle)),
			speed
		);
	}
	
	public function applyTorque(torque:Number)
	{
		if (!isLightweight)
		{
			body.ApplyTorque(torque * GameState.PSCALE);
			body.SetAwake(true);
		}
	}*/
	
	//*-----------------------------------------------
	//* Size
	//*-----------------------------------------------
	
	public function getWidth():Float
	{
		return width;
	}
	
	public function getHeight():Float
	{
		return height;
	}
	
	public function getPhysicsWidth():Float
	{
		return width / 10;
		//return Engine.toPhysicalUnits(getWidth());
	}
	
	public function getPhysicsHeight():Float
	{
		return height / 10;
		//return Engine.toPhysicalUnits(getHeight());
	}
	
	//*-----------------------------------------------
	//* Physics Flags
	//*-----------------------------------------------
	
	public function getBody():Dynamic
	{
		return null;
		//return body;
	}
	
	public function enableRotation()
	{
		if(!isLightweight)
		{
			//body.SetFixedRotation(false);
		}
	}
	
	public function disableRotation()
	{
		if(!isLightweight)
		{
			//body.SetFixedRotation(true);
		}
	}
	
	public function setIgnoreGravity(state:Bool)
	{
		if(!isLightweight)
		{
			//body.SetIgnoreGravity(state);
		}
	}
	
	public function ignoresGravity():Bool
	{
		if(isLightweight)
		{
			return true;
		}
		
		return false;
		//return body.IsIgnoringGravity();
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
