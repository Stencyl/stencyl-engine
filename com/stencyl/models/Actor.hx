package com.stencyl.models;

import com.stencyl.behavior.TimedTask;

import com.stencyl.models.collision.CollisionInfo;
import com.stencyl.models.collision.Masklist;
import flash.geom.Transform;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.Assets;
import nme.display.Graphics;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

import com.stencyl.Input;
import com.stencyl.Engine;

import com.stencyl.graphics.G;
import com.stencyl.graphics.AbstractAnimation;
import com.stencyl.graphics.BitmapAnimation;
import com.stencyl.graphics.SheetAnimation;

import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.BehaviorManager;

import com.stencyl.models.actor.Group;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.CollisionPoint;
import com.stencyl.models.actor.AngleHolder;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.scene.ActorInstance;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.GameModel;

import com.stencyl.utils.Utils;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Back;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.easing.Expo;
import com.eclecticdesignstudio.motion.easing.Linear;
import com.eclecticdesignstudio.motion.easing.Quad;
import com.eclecticdesignstudio.motion.easing.Quart;
import com.eclecticdesignstudio.motion.easing.Quint;
import com.eclecticdesignstudio.motion.easing.Sine;
import com.eclecticdesignstudio.motion.actuators.GenericActuator;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2MassData;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Transform;
import box2D.collision.B2WorldManifold;

import com.stencyl.models.collision.Mask;
import com.stencyl.models.collision.Hitbox;

import nme.filters.BitmapFilter;

#if flash
import flash.filters.ColorMatrixFilter;
import com.stencyl.utils.ColorMatrix;
#end

#if js
import jeash.filters.ColorMatrixFilter;
#end


class Actor extends Sprite 
{	
	//*-----------------------------------------------
	//* Globals
	//*-----------------------------------------------
	
	private var engine:Engine;
	

	//*-----------------------------------------------
	//* Properties
	//*-----------------------------------------------
	
	//Used for recycled actors to tell them apart
	public var createTime:Float;
	
	public var ID:Int;
	public var groupID:Int;
	public var layerID:Int;
	public var typeID:Int;
	public var type:ActorType;
	
	private var groupsToCollideWith:Array<Int>; //cached value
	
	public static var GROUP_OFFSET:Int = 1000000; //for collision reporting
	
	
	//*-----------------------------------------------
	//* States
	//*-----------------------------------------------

	public var recycled:Bool;
	public var paused:Bool;
	
	public var isRegion:Bool;
	public var isTerrainRegion:Bool;
	public var isTerrain:Bool;

	public var destroyed:Bool;	
	public var drawActor:Bool;	
	public var isHUD:Bool;
	public var alwaysSimulate:Bool;
	
	public var isCamera:Bool;
	public var killLeaveScreen:Bool;	
	public var isLightweight:Bool;
	public var autoScale:Bool;
	
	public var dead:Bool; //gone from the game - don't touch
	public var dying:Bool; //in the process of dying but not yet removed
	
	public var fixedRotation:Bool;
	public var ignoreGravity:Bool;
	public var collidable:Bool;
	public var solid:Bool; //for non Box2D collisions
	public var resetOrigin:Bool; //fot HTML5 origin setting

	//*-----------------------------------------------
	//* Position / Motion
	//*-----------------------------------------------
	
	public var originX:Float;
	public var originY:Float;
	
	public var realX:Float;
	public var realY:Float;
	public var realAngle:Float;
	public var realScaleX:Float;
	public var realScaleY:Float;
	
	var lastX:Float;
	var lastY:Float;
	var lastAngle:Float;
	var lastScale:Point;
	
	public var colX:Float;
	public var colY:Float;

	public var xSpeed:Float;
	public var ySpeed:Float;
	public var rSpeed:Float;
	
	public var continuousCollision:Bool;
	
	public var tweenLoc:Point;
	public var tweenAngle:AngleHolder;
	public var activeAngleTweens:Int;
	public var activePositionTweens:Int;
	
	//Cache values
	public var cacheWidth:Float;
	public var cacheHeight:Float;	
	
	//*-----------------------------------------------
	//* Sprite-Based Animation
	//*-----------------------------------------------
	
	public var currAnimationAsAnim:AbstractAnimation;
	public var currAnimation:DisplayObject;
	public var currAnimationName:String;
	public var animationMap:Hash<DisplayObject>;
	
	public var sprite:com.stencyl.models.actor.Sprite;
	
	public var shapeMap:Hash<Dynamic>;
	public var originMap:Hash<B2Vec2>;
	public var defaultAnim:String;
	
	public var currOrigin:Point;
	public var currOffset:Point;
	
	public var transformObj:Transform;
	public var transformPoint:Point;
	public var transformMatrix:Matrix;
	public var updateMatrix:Bool;
	public var drawMatrix:Matrix; //For use when drawing actor image
	
	
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
	
	public var allListeners:IntHash<Dynamic>;
	public var allListenerReferences:Array<Dynamic>;
	
	public var whenCreatedListeners:Array<Dynamic>;
	public var whenUpdatedListeners:Array<Dynamic>;
	public var whenDrawingListeners:Array<Dynamic>;
	public var whenKilledListeners:Array<Dynamic>;		
	public var mouseOverListeners:Array<Dynamic>;
	public var positionListeners:Array<Dynamic>;
	public var collisionListeners:Array<Dynamic>;
	
	//Caching the array length since it was sapping 2-3 FPS a piece on iPod Touch 2 as a fn call
	public var positionListenerCount:Int;
	public var collisionListenerCount:Int;
	
	public var mouseState:Int;
	public var lastScreenState:Bool;
	public var lastSceneState:Bool;
	
	//Purely used by Engine.hx for caching. Don't rely on or use internally!
	public var isOnScreenCache:Bool;
	
	
	//*-----------------------------------------------
	//* Physics (Box2D)
	//*-----------------------------------------------
	
	public var body:B2Body;
	public var bodyDef:B2BodyDef;
	public var md:B2MassData;
	public var bodyScale:Point;
	
	public var handlesCollisions:Bool;
	public var contacts:IntHash<B2Contact>;
	public var regionContacts:IntHash<B2Contact>;
	public var collisions:IntHash<Collision>;
	
	public var dummy:B2Vec2;
	public var zero:B2Vec2;
	
	//*-----------------------------------------------
	//* Collisions
	//*-----------------------------------------------

	public static var lastCollided:Actor;

	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------

	public function new
	(
		engine:Engine, 
		ID:Int,
		groupID:Int,
		x:Float=0, 
		y:Float=0, 
		layerID:Int=0,
		width:Float=32, 
		height:Float=32,
		sprite:com.stencyl.models.actor.Sprite=null,
		behaviorValues:Hash<Dynamic>=null,
		actorType:ActorType=null,
		bodyDef:B2BodyDef=null,
		isSensor:Bool=false,
		isStationary:Bool=false,
		isKinematic:Bool=false,
		canRotate:Bool=false,
		shape:Dynamic=null, //B2Shape or Mask - Used only for terrain.
		typeID:Int = 0,
		isLightweight:Bool=false,
		autoScale:Bool = true,
		ignoreGravity:Bool = false		
	)
	{
		super();
		
		//---
		
		dummy = new B2Vec2();
		zero = new B2Vec2(0, 0);
		
		_point = Utils.point;
		_moveX = _moveY = 0;
		
		HITBOX = new Mask();		
		setShape(HITBOX);
		
		if(Std.is(this, Region) && Engine.NO_PHYSICS)
		{
			shape = HITBOX = new Hitbox(Std.int(width), Std.int(height), 0, 0, false);
			setShape(shape);
		}
		
		//---
		this.x = 0;
		this.y = 0;
		this.rotation = 0;		
		
		realX = 0;
		realY = 0;
		realAngle = 0;
		realScaleX = 1;
		realScaleY = 1;
		
		originX = 0;
		originY = 0;
		collidable = true;
		solid = !isSensor;
		updateMatrix = true;
		
		if(isLightweight)
		{
			this.x = x * Engine.physicsScale;
			this.y = y * Engine.physicsScale;
		}
		
		else
		{
			this.x = x;
			this.y = y;
		}

		realX = colX = x;
		realY = colY = y;

		activeAngleTweens = 0;
		activePositionTweens = 0;
		
		//---
		
		lastScale = new flash.geom.Point(1, 1);
		lastX = -1000;
		lastY = -1000;
		lastAngle = 0;		
		
		tweenLoc = new Point(0, 0);
		tweenAngle = new AngleHolder();
				
		transformPoint = new Point(0, 0);
		transformMatrix = new Matrix();
		drawMatrix = new Matrix();
		
		currOrigin = new Point(0, 0);
		currOffset = new Point(0, 0);			
		registry = new Hash<Dynamic>();
		
		this.isLightweight = isLightweight;
		this.autoScale = autoScale;
		xSpeed = 0;
		ySpeed = 0;
		rSpeed = 0;
		
		mouseState = 0;
		
		lastScreenState = false;
		lastSceneState = false;	
		isOnScreenCache = false;		
		
		isCamera = false;
		isRegion = false;
		isTerrainRegion = false;
		drawActor = true;
		
		killLeaveScreen = false;
		alwaysSimulate = false;
		isHUD = false;
		continuousCollision = false;

		fixedRotation = false;
		this.ignoreGravity = ignoreGravity;
		resetOrigin = true;
		
		//---
		
		allListeners = new IntHash<Dynamic>();
		allListenerReferences = new Array<Dynamic>();
		
		whenCreatedListeners = new Array<Dynamic>();
		whenUpdatedListeners = new Array<Dynamic>();
		whenDrawingListeners = new Array<Dynamic>();
		whenKilledListeners = new Array<Dynamic>();
		mouseOverListeners = new Array<Dynamic>();
		positionListeners = new Array<Dynamic>();
		collisionListeners = new Array<Dynamic>();
		
		//---
		
		this.recycled = false;
		this.paused = false;
		this.destroyed = false;
		
		this.name = "Unknown";
		this.ID = ID;
		this.groupID = groupID;
		this.layerID = layerID;
		this.typeID = typeID;
		this.engine = engine;
		
		groupsToCollideWith = GameModel.get().groupsCollidesWith.get(groupID);
		
		collisions = new IntHash<Collision>();
		simpleCollisions = new IntHash<CollisionInfo>();
		contacts = new IntHash<B2Contact>();
		regionContacts = new IntHash<B2Contact>();
		contactCount = 0;
		collisionsCount = 0;
		
		handlesCollisions = true;
		
		//---
		
		behaviors = new BehaviorManager();
		
		//---
		
		currAnimationName = "";
		animationMap = new Hash<DisplayObject>();
		shapeMap = new Hash<Dynamic>();
		originMap = new Hash<B2Vec2>();
		
		this.sprite = sprite;
		
		//---
		
		if(sprite != null)
		{
			var s:com.stencyl.models.actor.Sprite = cast(Data.get().resources.get(actorType.spriteID), com.stencyl.models.actor.Sprite);
			
			if(s != null)
			{
				this.type = cast(Data.get().resources.get(typeID), ActorType);
				
				var defaultAnim:String = "";
				
				for(a in s.animations)
				{
					addAnim
					(
						a.animID,
						a.animName, 
						a.imgData, 
						a.framesAcross, 
						Math.floor(a.imgWidth / a.framesAcross), 
						Math.floor(a.imgHeight / a.framesDown), 
						a.originX,
						a.originY,
						a.durations, 
						a.looping,
						isLightweight?a.simpleShapes:a.physicsShapes
					);
					
					if(a.animID == s.defaultAnimation)
					{
						defaultAnim = a.animName;
					}
				}
			}
		}
		
		//--
		
		addAnim(-1, "recyclingDefault", null, 1, 1, 1, 1, 1, [1000], false, null);

		if(bodyDef != null && !isLightweight)
		{
			if(bodyDef.bullet)
			{
				B2World.m_continuousPhysics = true;
			}
			
			bodyDef.groupID = groupID;

			initFromBody(bodyDef);	
			
			//XXX: Box2D seems to require this to be done, otherwise it will refuse to create any shapes in the future!
			var box = new B2PolygonShape();
			box.setAsBox(1, 1);
			body.createFixture2(box, 0.1);
			
			md = new B2MassData();
			md.mass = bodyDef.mass;
			md.I = bodyDef.aMass;
			md.center.x = 0;
			md.center.y = 0;
			
			body.setMassData(md);
			bodyScale = new Point(1, 1);
		}
		
		else
		{
			if(shape == null)
			{				
				shape = createBox(width, height);
			}
			
			if (bodyDef != null)
			{
				continuousCollision = bodyDef.bullet;
			}
			
			if(Std.is(this, Region))
			{
				isSensor = true;
				canRotate = false;
			}
			
			if(Std.is(this, Terrain))
			{
				canRotate = false;
			}
			
			if(shape != null && Std.is(shape, com.stencyl.models.collision.Mask))
			{
				setShape(shape);
				isTerrain = true;
			}
			
			else if(!isLightweight)
			{
				initBody(groupID, isSensor, isStationary, isKinematic, canRotate, shape);
			}
		}

		switchToDefaultAnimation();
		
		//Use set location to align actors
		if(sprite != null)
		{ 
			setLocation(Engine.toPixelUnits(x), Engine.toPixelUnits(y));
		}
		
		else
		{
			if(shape != null && Std.is(shape, com.stencyl.models.collision.Mask))
			{
				//TODO: Very inefficient for CPP/mobile - can we force width/height a different way?
				var dummy = new Bitmap(new BitmapData(1, 1, true, 0));
				dummy.x = width;
				dummy.y = height;
				addChild(dummy);
				cacheWidth = this.width = width;
				cacheHeight = this.height = height;
			}
			
			else if(!isLightweight)
			{
				body.setPosition(new B2Vec2(x, y));
			}
		}
		
		//No IC - Default to what the ActorType uses
		if(behaviorValues == null && actorType != null)
		{
			behaviorValues = actorType.behaviorValues;
		}

		Engine.initBehaviors(behaviors, behaviorValues, this, engine, false);
	}	
	
	public function destroy()
	{
		if(destroyed)
		{
			return;
		}
		
		destroyed = true;
		
		for(anim in animationMap)
		{
			anim.visible = false;
		}
		
		Utils.removeAllChildren(this);

		if(body != null && !isLightweight)
		{
			var contact:B2ContactEdge = body.getContactList();
			
			while(contact != null)
			{	
				Engine.engine.world.m_contactManager.m_contactListener.endContact(contact.contact);
				contact = contact.next;
			}
			
			Engine.engine.world.destroyBody(body);
		}			
		
		cancelTweens();
		
		lastCollided = null;
		
		shapeMap = null;
		originMap = null;
		defaultAnim = null;
		animationMap = null;
		currAnimationAsAnim = null;
		currAnimation = null;
		currOffset = null;
		currOrigin = null;
		body = null;
		sprite = null;
		contacts = null;
		regionContacts = null;
		contactCount = 0;
		collisionsCount = 0;
		
		transformPoint = null;
		transformMatrix = null;
		
		whenCreatedListeners = null;
		whenUpdatedListeners = null;
		whenDrawingListeners = null;
		whenKilledListeners = null;
		mouseOverListeners = null;
		positionListeners = null;
		collisionListeners = null;
		allListeners = null;
		allListenerReferences = null;
		
		positionListenerCount = 0;
		collisionListenerCount = 0;
		
		registry = null;
		
		collisions = null;
		simpleCollisions = null;		
		
		if (bodyDef != null)
		{
			bodyDef.userData = null;
			bodyDef = null;
		}
		
		//do for all?
		#if (cpp || neko)
		nmeTarget = null;
		#end
		
		behaviors.destroy();
	}
	
	public function resetListeners()
	{		
		for (key in allListeners)
		{
			allListeners.remove(key);
		}
		
		while (allListenerReferences.length > 0)
		{
			allListenerReferences.pop();
		}
		
		while (whenUpdatedListeners.length > 0)
		{
			whenUpdatedListeners.pop();
		}
		
		while (whenDrawingListeners.length > 0)
		{
			whenDrawingListeners.pop();
		}
		
		while (whenKilledListeners.length > 0)
		{
			whenKilledListeners.pop();
		}
		
		while (mouseOverListeners.length > 0)
		{
			mouseOverListeners.pop();
		}
		
		while (positionListeners.length > 0)
		{
			positionListeners.pop();
		}
		
		while (collisionListeners.length > 0)
		{
			collisionListeners.pop();
		}
		
		positionListenerCount = 0;
		collisionListenerCount = 0;
	}
	
	public function addAnim
	(
		animID:Int,
		name:String, 
		imgData:BitmapData, 
		frameCount:Int=1, 
		frameWidth:Int=0, 
		frameHeight:Int = 0, 
		originX:Float = 0,
		originY:Float = 0,
		durations:Array<Int>=null, 
		looping:Bool=true, 
		shapes:IntHash<Dynamic>=null
	)
	{
		if(shapes != null)
		{
			var arr = new Array<Dynamic>();
			
			if (isLightweight)
			{
				for(s in shapes)
				{				
					if (Std.is(s, Hitbox) && isLightweight)
					{		
						s = cast(s, Hitbox).clone();
						s.assignTo(this);
					}
				
					arr.push(s);
				}
			}
			
			else
			{
				for(s in shapes)
				{				
					arr.push(s);
				}
			}
			
			if (isLightweight)
			{
				shapeMap.set(name, new Masklist(arr));
			}
			
			else
			{
				shapeMap.set(name, arr);
			}
		}
	
		if(imgData == null || imgData.width <= 0 || imgData.height <= 0)
		{
			//animationMap.set(name, new Sprite());
			
			//XXX: Did some work on cases where image dta is missing. It's still an error but won't crash anymore.
			animationMap.set(name, new BitmapAnimation(new BitmapData(16, 16), 1, [1000000], false, null));
			originMap.set(name, new B2Vec2(originX, originY));
			return;
		}
	
		#if cpp
		var tilesheet = new Tilesheet(imgData);
				
		frameWidth = Std.int(imgData.width/frameCount);
				
		for(i in 0...frameCount)
		{			
			tilesheet.addTileRect(new nme.geom.Rectangle(frameWidth * i, 0, frameWidth, frameHeight * Engine.SCALE)); 	
		}
		 	
		var sprite = new SheetAnimation
		(
			tilesheet, 
			durations, 
			Std.int(frameWidth), 
			Std.int(frameHeight * Engine.SCALE),
			looping,
			this.sprite.animations.get(animID).sync ? this.sprite.animations.get(animID) : null
		);
		
		animationMap.set(name, sprite);
		#end
		
		#if (flash || js)
		var sprite = new BitmapAnimation
		(
			imgData, 
			frameCount, 
			durations, 
			looping, 
			this.sprite.animations.get(animID).sync ? this.sprite.animations.get(animID) : null
		);
		animationMap.set(name, sprite);
		#end	
				
		originMap.set(name, new B2Vec2(originX, originY));
	}
	
	public function initScripts()
	{		
		handlesCollisions = true;
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
	
	static public function createBox(width:Float, height:Float):B2PolygonShape
	{
		var boxShape:B2PolygonShape = new B2PolygonShape();
		boxShape.setAsBox(Engine.toPhysicalUnits(width/2), Engine.toPhysicalUnits(height/2));
		return boxShape;
	}
	
	private function initFromBody(bodyDef:B2BodyDef)
	{	
		bodyDef.allowSleep = false;
		bodyDef.userData = this;
		this.bodyDef = bodyDef;
		body = Engine.engine.world.createBody(bodyDef);
	}

	private function initBody(groupID:Int, isSensor:Bool, isStationary:Bool, isKinematic:Bool, canRotate:Bool, shape:Dynamic)
	{			
		var bodyDef:B2BodyDef = new B2BodyDef();
		
		bodyDef.groupID = groupID;
		bodyDef.position.x = Engine.toPhysicalUnits(x);
		bodyDef.position.y = Engine.toPhysicalUnits(y);
			
		bodyDef.angle = 0;
		bodyDef.fixedRotation = !canRotate;
		bodyDef.allowSleep = false;

		if(isStationary)
		{
			bodyDef.type = B2Body.b2_staticBody;
		}
		
		else if(isKinematic)
		{
			bodyDef.type = B2Body.b2_kinematicBody;
		}
		
		else
		{
			bodyDef.type = B2Body.b2_dynamicBody;
		}
		
		if(Std.is(shape, Array))
		{
			bodyDef.userData = this;
			body = Engine.engine.world.createBody(bodyDef);			
				
			var arr:Array<Dynamic> = cast(shape, Array<Dynamic>);
		
			for(item in arr)
			{
				var fixtureDef:B2FixtureDef = new B2FixtureDef();
				fixtureDef.shape = item;
				fixtureDef.friction = 1.0;
				fixtureDef.density = 0.1;
				fixtureDef.restitution = 0;
				fixtureDef.isSensor = false;
				fixtureDef.groupID = GameModel.TERRAIN_ID;
				fixtureDef.userData = this;
							
				body.createFixture(fixtureDef);
			}
		}

		else
		{
			var fixtureDef:B2FixtureDef = new B2FixtureDef();
			fixtureDef.shape = shape;
			fixtureDef.friction = 1.0;
			fixtureDef.density = 0.1;
			fixtureDef.restitution = 0;
			fixtureDef.isSensor = isSensor;
			fixtureDef.groupID = GameModel.INHERIT_ID;
			fixtureDef.userData = this;
						
			bodyDef.userData = this;
			body = Engine.engine.world.createBody(bodyDef);			
			body.createFixture(fixtureDef);
		}

		this.bodyDef = bodyDef;
	}   	
   	
   	//*-----------------------------------------------
	//* Animation
	//*-----------------------------------------------
   	
	public function addAnimation(name:String, sprite:DisplayObject)
	{
		animationMap.set(name, sprite);
	}
	
	public function getAnimation():String
	{
		return currAnimationName;
	}
	
	public function setAnimation(name:String)
	{
		switchAnimation(name);
	}
	
	public function switchToDefaultAnimation()
	{
		if(sprite != null && sprite.animations.size > 0)
		{
			var anim = sprite.animations.get(sprite.defaultAnimation);
		
			//In case the animation ID is bogus...
			if(anim == null)
			{
				for(a in sprite.animations)
				{
					anim = a;
					break;
				}
			}
			
			defaultAnim = cast(anim, Animation).animName;
			switchAnimation(defaultAnim);
			setCurrentFrame(0);
		}
	}
	
	public function isAnimationPlaying():Bool
	{
		if(Std.is(currAnimation, AbstractAnimation))
		{
			return !cast(currAnimation, AbstractAnimation).isFinished();
		}
		
		else
		{
			return true;
		}
	}
	
	public function getCurrentFrame():Int
	{
		if(Std.is(currAnimation, AbstractAnimation))
		{
			return cast(currAnimation, AbstractAnimation).getCurrentFrame();
		}
		
		else
		{
			return 0;
		}
	}
	
	public function setCurrentFrame(frame:Int)
	{
		if(Std.is(currAnimation, AbstractAnimation))
		{
			cast(currAnimation, AbstractAnimation).setFrame(frame);
		}
	}
	
	public function getNumFrames():Int
	{
		if(Std.is(currAnimation, AbstractAnimation))
		{
			return cast(currAnimation, AbstractAnimation).getNumFrames();
		}
		
		else
		{
			return 0;
		}
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
			
			//---
			
			var isDifferentShape = false;
			
			//XXX: Only switch the animation shape if it's different from before.
			//http://community.stencyl.com/index.php/topic,16464.0.html
			if(body != null && !isLightweight)
			{
				var arrOld = shapeMap.get(currAnimationName);
				var arrNew = shapeMap.get(name);
				
				if(arrOld == null || arrNew == null)
				{
					isDifferentShape = true;
				}
			
				else
				{
					if(arrOld.length != arrNew.length || arrOld.length > 1)
					{
						isDifferentShape = true;
					}
					
					else
					{
						var oldDef:B2FixtureDef = arrOld[0];
						var newDef:B2FixtureDef = arrNew[0];
						
						if(oldDef == null || newDef == null)
						{
							isDifferentShape = true;
						}
					
						else
						{
							var oldShape = oldDef.shape;
							var newShape = newDef.shape;
							
							if(oldDef.isSensor != newDef.isSensor)
							{
								isDifferentShape = true;
							}
							
							else if(oldDef.groupID != newDef.groupID)
							{
								isDifferentShape = true;
							}
							
							else if(Type.getClass(oldShape) == Type.getClass(newShape))
							{
								if(Type.getClass(oldShape) == B2PolygonShape)
								{
									var polyOld = cast(oldShape, B2PolygonShape);
									var polyNew = cast(newShape, B2PolygonShape);
									
									if(polyOld.m_vertexCount != polyNew.m_vertexCount)
									{
										isDifferentShape = true;
									}
									
									else
									{
										for(i in 0...polyOld.m_vertexCount)
										{
											if(polyOld.m_vertices[i].x != polyNew.m_vertices[i].x)
											{
												isDifferentShape = true;
												break;
											}
											
											else if(polyOld.m_vertices[i].y != polyNew.m_vertices[i].y)
											{
												isDifferentShape = true;
												break;
											}
										}
									}
								}
								
								else if(Type.getClass(oldShape) == B2CircleShape)
								{
									var circleOld = cast(oldShape, B2CircleShape);
									var circleNew = cast(newShape, B2CircleShape);
									
									if(circleOld.m_radius != circleNew.m_radius || 
									   circleOld.m_p.x != circleNew.m_p.x || 
									   circleOld.m_p.y != circleNew.m_p.y)
									{
										isDifferentShape = true;
									}
								}
							}
							
							else
							{
								isDifferentShape = true;
							}
						}
					}
				}
			}
			
			//---
			
			currAnimationName = name;
			currAnimation = newAnimation;
			
			currAnimationAsAnim = cast(currAnimation, AbstractAnimation);
							
			addChild(newAnimation);			
			
			//----------------
			
			var animOrigin:B2Vec2 = originMap.get(name);		
			
			if(!isLightweight)
			{
				updateTweenProperties();
			}
						
			var centerx = (currAnimation.width / Engine.SCALE / 2) - animOrigin.x;
			var centery = (currAnimation.height / Engine.SCALE / 2) - animOrigin.y;
			
			if(body != null && isDifferentShape && !isLightweight)
			{
				//Remember regions
				var regions = new Array<Region>();
			
				//BEGIN EXPLICIT ENDCONTACT HACK
				//SECRET/showthread.php?tid=9564
				var contact = body.getContactList();
				
				while(contact != null)
				{
					if(Std.is(contact.other.getUserData(), Region) && contact.contact.isTouching())
					{
						regions.push(contact.other.getUserData());
					}
					
					Engine.engine.world.m_contactManager.m_contactListener.endContact(contact.contact);
					contact = contact.next;
				}
				
				//Catch any residual contacts.
				//SECRET/showthread.php?tid=9773&page=3
				for(k in collisions.keys()) 
				{
					collisions.remove(k);
				}
				
				collisions = new IntHash<Collision>();
				simpleCollisions = new IntHash<CollisionInfo>();
				contacts = new IntHash<B2Contact>();
				regionContacts = new IntHash<B2Contact>();
				contactCount = 0;
				collisionsCount = 0;
				
				//END HACK

				while(body.m_fixtureCount > 0)
				{			
					body.DestroyFixture(body.getFixtureList());
				}
				
				for(f in cast(shapeMap.get(name), Array<Dynamic>))
				{
					var originFixDef = new B2FixtureDef();
					
					if(bodyDef.friction < Utils.NUMBER_MAX_VALUE)
					{
						originFixDef.friction = bodyDef.friction;
						originFixDef.restitution = bodyDef.bounciness;							
						
						if(bodyDef.mass > 0)
						{
							originFixDef.density = 0.1;//bodyDef.mass;
						}
					}
					
					originFixDef.density = f.density;						
					originFixDef.isSensor = f.isSensor;
					originFixDef.groupID = f.groupID;
					originFixDef.shape = f.shape;

					//TODO: Origin point junk goes here
					if (animOrigin != null)
					{
						body.origin.x = Engine.toPhysicalUnits(-animOrigin.x);
						body.origin.y = Engine.toPhysicalUnits(-animOrigin.y);
						
						if (Std.is(f.shape, B2PolygonShape))
						{
							var xf:B2Transform = new B2Transform();
							var oldBox:B2PolygonShape = cast(f.shape, B2PolygonShape);
							var newBox:B2PolygonShape = new B2PolygonShape();
								
							newBox.setAsArray(oldBox.m_vertices, oldBox.m_vertices.length);
								
							var vertices:Array<B2Vec2> = newBox.m_vertices;
							var normals:Array<B2Vec2> = newBox.m_normals;										
												
							xf.position.set(Engine.toPhysicalUnits(centerx), Engine.toPhysicalUnits(centery));
							xf.R.setAngle(0);
							
							for (i in 0...newBox.m_vertexCount) 
							{								
								vertices[i] = xf.multiply(vertices[i]);
								normals[i] = xf.R.multiplyV(normals[i]);															
							}
							
							newBox.setAsArray(vertices, vertices.length);							
							newBox.m_normals = normals;
							
							originFixDef.shape = newBox;
						}
						
						else if (Std.is(f.shape, B2CircleShape))
						{
							var oldCircle:B2CircleShape = cast(f.shape, B2CircleShape);
							var newCircle:B2CircleShape = new B2CircleShape();
								
							newCircle.setRadius(oldCircle.getRadius());
							newCircle.m_p.x = oldCircle.m_p.x + Engine.toPhysicalUnits(centerx);
							newCircle.m_p.y = oldCircle.m_p.y + Engine.toPhysicalUnits(centery);
							
							originFixDef.shape = newCircle;
						}
					}
					
					var fix = body.createFixture(originFixDef);
					fix.SetUserData(this);	
				}
				
				if(body.getFixtureList() != null)
				{
					bodyScale.x = 1;
					bodyScale.y = 1;
			
					for(r in regions)
					{
						var mine = body.getFixtureList().m_aabb;
						var other = r.getBody().getFixtureList().m_aabb;
						
						if(other.testOverlap(mine))
						{
							r.addActor(this);
						}
					}
				}
				
				if(md != null)
				{
					body.setMassData(md);
				}
			}	
						
			else if(shapeMap.get(name) != null && isLightweight)
			{				
				//Get hitbox list for Simple Physics
				setShape(shapeMap.get(name));
				HITBOX = _mask;
				
				//TODO: Compare hitboxes
				isDifferentShape = true;
			}
			
			cacheWidth = currAnimation.width / Engine.SCALE;
			cacheHeight = currAnimation.height / Engine.SCALE;			
			
			if(body != null)
			{
				body.size.x = Engine.toPhysicalUnits(cacheWidth);
				body.size.y = Engine.toPhysicalUnits(cacheHeight);
			}
			
			if(!isLightweight)
			{
				realX = getX(false);
				realY = getY(false);
			}
			
			if(animOrigin != null)
			{					
				setOriginPoint(Std.int(animOrigin.x), Std.int(animOrigin.y));				
			}
			
			if (isLightweight)
			{
				
			}
			
			updateMatrix = true;
			
			//----------------
			
			if(Std.is(currAnimation, AbstractAnimation))
			{
				cast(currAnimation, AbstractAnimation).reset();
			}				
		}
	}
	
	//*-----------------------------------------------
	//* Events - Update
	//*-----------------------------------------------
	
	public function update(elapsedTime:Float)
	{
		innerUpdate(elapsedTime, true);
	}
	
	//mouse/col/screen checks kill 5 FPS (is it even active?)
	//actor update kills 20-25 FPS (!!)
	//internal update kills 5 FPS
	public function innerUpdate(elapsedTime:Float, hudCheck:Bool)
	{
		//HUD / always simulate actors are updated separately to prevent double updates.
		if(paused || isCamera || dying || dead || destroyed || hudCheck && (isHUD || alwaysSimulate))
		{
			return;
		}
		
		if(mouseOverListeners.length > 0)
		{
			//Previously was checkMouseState() - inlined for performance. See Region:innerUpdate for other instance
			var mouseOver:Bool = isMouseOver();
				
			if(mouseState <= 0 && mouseOver)
			{
				//Just Entered
				mouseState = 1;
			}
			
			#if !mobile	
			else if(mouseState >= 1 && mouseOver)
			#end
			
			//in the context of single touches, this does not exist on mobile
			#if mobile
			if(mouseOver)
			#end
			{
				//Over
				mouseState = 2;
						
				if(Input.mousePressed)
				{
					//Clicked On
					mouseState = 3;
				}
						
				else if(Input.mouseDown)
				{
					//Dragged
					mouseState = 4;
				}
						
				if(Input.mouseReleased)
				{
					//Released
					mouseState = 5;
				}
			}
			
			else if(mouseState > 0 && !mouseOver)
			{
				//Just Exited
				mouseState = -1;
			}
				
			else if(mouseState == -1 && !mouseOver)
			{
				mouseState = 0;
			}	
			
			Engine.invokeListeners2(mouseOverListeners, mouseState);
		}
		
		var checkType = type.ID;
		var groupType = GROUP_OFFSET + groupID;
		
		var ec = engine.collisionListeners;
		var ep = engine.typeGroupPositionListeners;
				
		if(!isLightweight)
		{
			if(collisionListenerCount > 0 || 
			   ec.get(checkType) != null || 
			   ec.get(groupType) != null) 
			{
				//TODO: This needs to be optimized a lot.
				handleCollisions();		
			}
		}

		internalUpdate(elapsedTime, true);
		Engine.invokeListeners2(whenUpdatedListeners, elapsedTime);		

		if(positionListenerCount > 0 || 
		   ep.get(checkType) != null || 
		   ep.get(groupType) != null)
		{
			checkScreenState();
		}
	}
	
	//doAll prevents super.update from being called, which can often muck with
	//animations happening if they are updated before play() is called.
	public function internalUpdate(elapsedTime:Float, doAll:Bool)
	{
		if(paused)
		{
			return;
		}
					
		if(isLightweight)
		{		
			if (!ignoreGravity && !isHUD)
			{
				//TODO: Adjust?
				xSpeed += elapsedTime * engine.gravityX * 0.001;
				ySpeed += elapsedTime * engine.gravityY * 0.001;
			}
			
			if(xSpeed != 0 || ySpeed != 0)
			{
				resetReal(realX, realY);			
				
				moveActorBy(elapsedTime * xSpeed * 0.01, elapsedTime * ySpeed * 0.01, groupsToCollideWith);						
			}			
						
			if(rSpeed != 0)
			{
				realAngle += elapsedTime * rSpeed * 0.001;				
			}
			
			if(fixedRotation)
			{
				realAngle = 0;
				this.rSpeed = 0;
			}			
		}
		
		else
		{			
			var p = body.getPosition();		
						
			#if js			
			realX = jeashX = p.x * Engine.physicsScale;
			realY = jeashY = p.y * Engine.physicsScale;				
			#end
			
			#if !js							
			realX = p.x * Engine.physicsScale;
			realY = p.y * Engine.physicsScale;				
			#end
			
			resetReal(realX, realY);
			
			realAngle = body.getAngle() * Utils.DEG;				
		}
		
		if (lastX != realX || lastY != realY || lastAngle != realAngle || lastScale.x != realScaleX || lastScale.y != realScaleY)
		{
			updateMatrix = true;
		}
		
		lastX = realX;
		lastY = realY;
		lastAngle = realAngle;
		lastScale.x = realScaleX;
		lastScale.y = realScaleY;
		
		if(doAll && currAnimationAsAnim != null)
		{
   			//This may be a slowdown on iOS by 3-5 FPS due to clear and redraw?
   			currAnimationAsAnim.update(elapsedTime);
		}
			
		updateTweenProperties();		
	}	
	
	public function updateDrawingMatrix()
	{
		if(paused)
		{
			return;
		}
		
		var drawX:Float = realX;
		var drawY:Float = realY;
		
		if (!isLightweight)
		{
			var p = body.getPosition();
			
			drawX = p.x * Engine.physicsScale;
			drawY = p.y * Engine.physicsScale;
		}
		
		var trueScaleX:Float = Engine.SCALE * realScaleX;
		var trueScaleY:Float = Engine.SCALE * realScaleY;
		
		transformPoint.x = currOrigin.x - (cacheWidth*Engine.SCALE) / 2;
		transformPoint.y = currOrigin.y - (cacheHeight*Engine.SCALE) / 2;

		transformMatrix.identity();
		transformMatrix.translate( -transformPoint.x * Engine.SCALE, -transformPoint.y * Engine.SCALE);
		transformMatrix.scale(realScaleX, realScaleY);
		
		if (realAngle != 0)
		{
			transformMatrix.rotate(realAngle * Utils.RAD);
		}
		
		transformMatrix.translate(drawX * Engine.SCALE, drawY * Engine.SCALE);
		
						
		if (transformObj == null)
		{
			transformObj = transform;
		}
		
		transformObj.matrix = transformMatrix;		
		
		//Temp until jeash handles on their end?
		#if js
		currAnimation.jeashInvalidateMatrix();
		#end
	}
	
	private function updateTweenProperties()
	{		
	
		//Since we can't tween directly on the Box2D values and can't make direct function calls,
		//we have to reverse the normal flow of information from body -> NME to tween -> body
		var a:Bool = activePositionTweens > 0;
		var b:Bool = activeAngleTweens > 0;
				
		if(autoScale && !isLightweight && body != null && bodyDef.type != B2Body.b2_staticBody && (bodyScale.x != realScaleX || bodyScale.y != realScaleY))
		{			
			if (realScaleX != 0 && realScaleY != 0)
			{
				scaleBody(realScaleX, realScaleY);
			}
		}
		
		if(a && b)
		{					
			if (!isLightweight)
			{
				realX = tweenLoc.x;
				realY = tweenLoc.y;
				realAngle = tweenAngle.angle;
				
				dummy.x = Engine.toPhysicalUnits(realX + Math.floor(cacheWidth/2) + currOffset.x);
				dummy.y = Engine.toPhysicalUnits(realY + Math.floor(cacheHeight/2) + currOffset.y);
			
				body.setPositionAndAngle
				(
					dummy,
					Utils.RAD * realAngle
				);
			}
			
			else
			{
				moveActorBy(tweenLoc.x - getX(false), tweenLoc.y - getY(false), groupsToCollideWith);
				setAngle(tweenAngle.angle, false);
			}

			updateMatrix = true;
		}
		
		else
		{
			if(a)
			{
				if (!isLightweight)
				{
					setX(tweenLoc.x);
					setY(tweenLoc.y);
				}
				
				else
				{
					moveActorBy(tweenLoc.x - getX(false), tweenLoc.y - getY(false), groupsToCollideWith);
					updateMatrix = true;
				}				
			}
			
			if(b)
			{
				setAngle(tweenAngle.angle, false);
			}
		}
	}
		
	//*-----------------------------------------------
	//* Events - Other
	//*-----------------------------------------------
	
	//Make more efficient?
	public function scaleBody(width:Float, height:Float)
	{
		var fixtureList:Array<B2Fixture> = new Array<B2Fixture>();
		var fixture:B2Fixture = body.getFixtureList();

		while (fixture != null)
		{
			fixtureList.push(fixture);
			fixture = fixture.getNext();
		}		
			
		for (f in fixtureList)
		{ 
			var poly:B2Shape = f.getShape();
			var center:B2Vec2 = body.getLocalCenter();
			if(Std.is(poly, B2CircleShape))
			{
				var factorX:Float = (1 / bodyScale.x) * width;					
				var factorY:Float = (1 / bodyScale.y) * height;
				
				var p:B2Vec2 = cast(poly, B2CircleShape).m_p;
				p.subtract(center);
				p.x = p.x * factorX;
				p.y = p.y * factorY;	
								
				cast(poly, B2CircleShape).m_p = center.copy();
				cast(poly, B2CircleShape).m_p.add(p);
				poly.m_radius = poly.m_radius * Math.abs(factorX);								
			}

			else if(Std.is(poly, B2PolygonShape))
			{
  				var verts:Array<B2Vec2> = cast(poly, B2PolygonShape).m_vertices;
				var newVerts:Array<B2Vec2> = new Array<B2Vec2>();

				for (v in verts)
				{
					v.subtract(center);
					v.x = v.x * (1 / Math.abs(bodyScale.x)) * Math.abs(width);
					v.y = v.y * (1 / Math.abs(bodyScale.y)) * Math.abs(height);	
					
					if ((bodyScale.x > 0 && width < 0) || (bodyScale.x < 0 && width > 0))
					{
						v.x = -v.x;
					}
					
					if ((bodyScale.y > 0 && height < 0) || (bodyScale.y < 0 && height > 0))
					{
						v.y = -v.y;
					}
					
					var newVert:B2Vec2 = center.copy();
					newVert.add(v);

					newVerts.push(newVert);
				}
				
				if ((bodyScale.x > 0 && width < 0) || (bodyScale.x < 0 && width > 0) || (bodyScale.y > 0 && height < 0) || (bodyScale.y < 0 && height > 0))
				{
					newVerts.reverse();
				}

				cast(poly, B2PolygonShape).setAsArray(newVerts, newVerts.length);   				
			}
		}	
		
		bodyScale.x = width;
		bodyScale.y = height;
	}
	
	private function checkScreenState()
	{
		var onScreen:Bool = isOnScreen();
		var inScene:Bool = onScreen || isInScene();
		
		var enteredScreen:Bool = !lastScreenState && onScreen;
		var enteredScene:Bool = !lastSceneState && inScene;
		var exitedScreen:Bool = lastScreenState && !onScreen;
		var exitedScene:Bool = lastSceneState && !inScene;
		
		Engine.invokeListeners5(positionListeners, enteredScreen, exitedScreen, enteredScene, exitedScene);
			
		var typeListeners = engine.typeGroupPositionListeners.get(groupID + Actor.GROUP_OFFSET);
		var groupListeners = engine.typeGroupPositionListeners.get(typeID);
		
		if(typeListeners != null)
		{
			Engine.invokeListeners6(typeListeners, this, enteredScreen, exitedScreen, enteredScene, exitedScene);
		}
		
		if(groupListeners != null)
		{
			Engine.invokeListeners6(groupListeners, this, enteredScreen, exitedScreen, enteredScene, exitedScene);
		}
		
		lastScreenState = onScreen;
		lastSceneState = inScene;
	}
		
	//*-----------------------------------------------
	//* Collision
	//*-----------------------------------------------
	
	private static var manifold = new B2WorldManifold();
	private var contactCount:Int;
	private var collisionsCount:Int;
	
	inline private function handleCollisions()
	{		
		var otherActor:Actor;
		var otherShape:B2Fixture;
		var thisShape:B2Fixture;
		
		//Even iteration over blank maps can impact low-end devices. Guard against it.
		if(contactCount > 0)
		{		
			for(p in contacts)
			{
				var key = p.key;
				
				if(collisions.get(key) != null)
				{
					continue;
				}
				
				var a1 = cast(p.getFixtureA().getUserData(), Actor);
				var a2 = cast(p.getFixtureB().getUserData(), Actor);
					
				if(a1 == this)
				{
					otherActor = a2;
					otherShape = p.getFixtureB();
					thisShape = p.getFixtureA();
				}
				
				else
				{
					otherActor = a1;
					otherShape = p.getFixtureA();
					thisShape = p.getFixtureB();
				}
	
				//TODO: We can pool this if it helps.
				var d:Collision = new Collision();
				d.otherActor = otherActor;
				d.otherShape = otherShape;
				d.thisActor = this;
				d.thisShape = thisShape;
				d.actorA = a1;
				d.actorB = a2;

				//TODO: No longer need to remake. Use a shared instance.
				//var manifold = new B2WorldManifold();
				p.getWorldManifold(manifold);
				
				var pt = manifold.getPoint();
				var cp:CollisionPoint;
				
				//trace(manifold.getPoint().x + " - " + manifold.getPoint().y);
				
				if(pt == null)
				{
					cp = new CollisionPoint
					(
						-9999, 
						-9999, 
						manifold.m_normal.x,
						manifold.m_normal.y
					);
				}
				
				else
				{
					//XXX: Workaround for this bug
					//http://community.stencyl.com/index.php/topic,14925.0.html
					if(Std.is(thisShape.getShape(), B2CircleShape))
					{
						cp = new CollisionPoint
						(
							manifold.getPoint().x * 2, 
							manifold.getPoint().y * 2, 
							manifold.m_normal.x,
							manifold.m_normal.y
						);
					}
				
					else
					{
						cp = new CollisionPoint
						(
							manifold.getPoint().x, 
							manifold.getPoint().y, 
							manifold.m_normal.x,
							manifold.m_normal.y
						);
					}				
				} 
	
				collisions.set(key, d);
				collisionsCount++;
				
				if(cp.x != -9999 && cp.y != -9999)
				{
					d.points.push(cp);
					
					var thisActor:Actor = this;
					var body = thisActor.getBody();	
					var otherBody = otherActor.getBody();	
					var body1 = p.getFixtureA().getBody();
					var body2 = p.getFixtureB().getBody();
			
					d.thisFromBottom = false;
					d.thisFromTop = false;
					d.thisFromLeft = false;
					d.thisFromRight = false;
			
					//collidedFromBottom
					if(body1 == body)
					{
						d.thisFromBottom = cp.normalY > 0;
					}
					
					else if(body2 == body)
					{
						d.thisFromBottom = cp.normalY < 0;
					}
			
					//collidedFromTop
					if(body1 == body)
					{
						d.thisFromTop = cp.normalY < 0;
					}
					
					else if(body2 == body)
					{
						d.thisFromTop = cp.normalY > 0;
					}
					
					//collidedFromLeft
					if(body1 == body)
					{
						d.thisFromLeft = cp.normalX < 0;
					}
					
					else if(body2 == body)
					{
						d.thisFromLeft = cp.normalX > 0;
					}
					
					//collidedFromRight
					if(body1 == body)
					{
						d.thisFromRight = cp.normalX > 0;
					}
					
					else if(body2 == body)
					{
						d.thisFromRight = cp.normalX < 0;
					}
					
					//---
					
					d.otherFromBottom = false;
					d.otherFromTop = false;
					d.otherFromLeft = false;
					d.otherFromRight = false;
					
					//collidedFromBottom
					if(body1 == otherBody)
					{
						d.otherFromBottom = cp.normalY > 0;
					}
					
					else if(body2 == otherBody)
					{
						d.otherFromBottom = cp.normalY < 0;
					}
					
					//collidedFromTop
					if(body1 == otherBody)
					{
						d.otherFromTop = cp.normalY < 0;
					}
					
					else if(body2 == otherBody)
					{
						d.otherFromTop = cp.normalY > 0;
					}
					
					//collidedFromLeft
					if(body1 == otherBody)
					{
						d.otherFromLeft = cp.normalX < 0;
					}
					
					else if(body2 == otherBody)
					{
						d.otherFromLeft = cp.normalX > 0;
					}
					
					//collidedFromRight
					if(body1 == otherBody)
					{
						d.otherFromRight = cp.normalX > 0;
					}
					
					else if(body2 == otherBody)
					{
						d.otherFromRight = cp.normalX < 0;
					}
				}
			
				//---
				
				d.thisCollidedWithActor = false;					
				d.thisCollidedWithTerrain = false;			
				d.thisCollidedWithTile = false;
				d.thisCollidedWithSensor = false;
				
				d.otherCollidedWithActor = false;			
				d.otherCollidedWithTerrain = false;	
				d.otherCollidedWithTile = false;
				d.otherCollidedWithSensor = false;
				
				//---
				
				if(otherActor != null)
				{
					d.thisCollidedWithActor = otherActor.groupID != 1 && otherActor.groupID != -2 && !otherActor.isTerrainRegion;					
					d.thisCollidedWithTerrain = otherActor.isTerrainRegion;			
					d.thisCollidedWithTile = otherActor.groupID == 1;
				}
				
				d.otherCollidedWithActor = this.groupID != 1 && this.groupID != -2 && !this.isTerrainRegion;					
				d.otherCollidedWithTerrain = this.isTerrainRegion;			
				d.otherCollidedWithTile = this.groupID == 1;
				
				d.thisCollidedWithSensor = otherShape.isSensor();
				d.otherCollidedWithSensor = thisShape.isSensor();		
			}
		}
		
		//Even iteration over blank maps can impact low-end devices. Guard against it.
		if(collisionsCount > 0)
		{
			for(collision in collisions)
			{
				//trace(this + " vs " + collision.otherActor);
				
				if
				(
				   collision == null || collision.thisActor == null || collision.otherActor == null ||
				   !collision.thisActor.handlesCollisions || 
				   !collision.otherActor.handlesCollisions)
				{
					continue;
				}
				
				lastCollided = collision.otherActor;
				Engine.invokeListeners2(collisionListeners, collision);
				
				engine.handleCollision(this, collision);	
			}
		}
		
		//TODO: Can we avoid remaking this? Yes, just don't clear out and let system naturally
		//remove contacts and ignore ones we've already processed.
		//10 FPS drop
		//contacts = new IntHash<B2Contact>();
	}
	
	public inline function addContact(point:B2Contact)
	{
		if(contacts != null)
		{
			contacts.set(point.key, point);
			contactCount++;
			
			if(collisions.remove(point.key))
			{
				collisionsCount--;
			}
		}
	}
	
	public inline function removeContact(point:B2Contact)
	{
		if(collisions != null)
		{
			if(collisions.remove(point.key))
			{
				collisionsCount--;
			}
		}
		
		if(contacts != null)
		{
			if(contacts.remove(point.key))
			{
				contactCount--;
			}
		}
	}
	
	public inline function addRegionContact(point:B2Contact)
	{
		if(regionContacts != null)
		{
			regionContacts.set(point.key, point);
		}			
	}
	
	public inline function removeRegionContact(point:B2Contact)
	{
		if(regionContacts != null)
		{
			regionContacts.remove(point.key);
		}
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
			return body.groupID;
		}
	}
	
	public function getLayerID():Int
	{
		return layerID;
	}
	
	public function getLayerOrder():Int
	{
		return engine.getOrderForLayerID(layerID) + 1;
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
			
			if(!isLightweight)
			{
				this.body.setPaused(true);
			}
		}
	}
	
	public function unpause()
	{
		if(isPausable())
		{
			this.paused = false;
			
			if(!isLightweight)
			{
				this.body.setPaused(false);
			}
		}
	}
	
	//*-----------------------------------------------
	//* Type
	//*-----------------------------------------------
	
	public function getGroup():Group
	{
		return engine.groups.get(getGroupID());
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
	
	public function moveToLayer(layerID:Float)
	{
		if(!isHUD)
		{
			engine.moveToLayer(this, Std.int(layerID));
		}
	}
	
	public function bringToFront()
	{
		if(!isHUD)
		{
			engine.bringToFront(this);
		}
	}
	
	public function bringForward()
	{
		if(!isHUD)
		{
			engine.bringForward(this);
		}
	}
	
	public function sendToBack()
	{
		if(!isHUD)
		{
			engine.sendToBack(this);
		}
	}
	
	public function sendBackward()
	{
		if(!isHUD)
		{
			engine.sendBackward(this);
		}
	}
	
	//*-----------------------------------------------
	//* Physics: Position
	//*-----------------------------------------------
	
	//Big Change: Returns relative to the origin point as (0,0). Meaning if the origin = center, the center is now (0,0)!
	
	public function getX(round:Bool = true):Float
	{
		var toReturn:Float = -1;
		
		if(!Engine.NO_PHYSICS)
		{
			if(isRegion || isTerrainRegion)
			{
				toReturn = Engine.toPixelUnits(body.getPosition().x) - cacheWidth/2;
			}
			
			else if(!isLightweight)
			{
				toReturn = body.getPosition().x * Engine.physicsScale - Math.floor(cacheWidth / 2) - currOffset.x;
			}
		}
		
		if (Engine.NO_PHYSICS || isLightweight)
		{
			toReturn = realX - Math.floor(cacheWidth/2) - currOffset.x;
		}
		
		return round ? Math.round(toReturn) : toReturn;
	}
	
	public function getY(round:Bool = true):Float
	{
		var toReturn:Float = -1;
		
		if(!Engine.NO_PHYSICS)
		{
			if(isRegion || isTerrainRegion)
			{				
				toReturn = Engine.toPixelUnits(body.getPosition().y) - cacheHeight/2;
			}
			
			else if(!isLightweight)
			{
				toReturn = body.getPosition().y * Engine.physicsScale - Math.floor(cacheHeight / 2) - currOffset.y;
			}
		}
		
		if (Engine.NO_PHYSICS || isLightweight)
		{
			toReturn = realY - Math.floor(cacheHeight / 2) - currOffset.y;
		}
		
		return round ? Math.round(toReturn) : toReturn;
	}
	
	//TODO: Eliminate?
	public function getXCenter():Float
	{
		if(!isLightweight)
		{
			return Math.round(Engine.toPixelUnits(body.getWorldCenter().x) - currOffset.x);
		}
		
		else
		{
			return realX - currOffset.x;
		}
	}
	
	//TODO: Eliminate?
	public function getYCenter():Float
	{
		if(!isLightweight)
		{
			return Math.round(Engine.toPixelUnits(body.getWorldCenter().y) - currOffset.y);
		}
		
		else
		{
			return realY - currOffset.y;
		}
	}
	
	public function getScreenX():Float
	{
		if(isHUD)
		{
			return getX();
		}
		
		else
		{
			return getX() + Engine.cameraX / Engine.SCALE;
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
			return getY() + Engine.cameraY / Engine.SCALE;
		}
	}
	
	public function setX(x:Float, resetSpeed:Bool = false, noCollision:Bool = false)
	{	
		if(isLightweight)
		{
			moveActorTo(x + Math.floor(cacheWidth/2) + currOffset.x, realY, !noCollision && continuousCollision ? groupsToCollideWith: null);
		}
		
		else
		{
			if(isRegion || isTerrainRegion)
			{
				dummy.x = Engine.toPhysicalUnits(x);
			}
				
			else
			{
				dummy.x = Engine.toPhysicalUnits(x + Math.floor(cacheWidth/2) + currOffset.x);
			}			
			
			dummy.y = body.getPosition().y;
			
			body.setPosition(dummy);
			
			if(resetSpeed)
			{
				body.setLinearVelocity(zero);
			}
		}
		
		updateMatrix = true;
	}
	
	public function setY(y:Float, resetSpeed:Bool = false, noCollision:Bool = false)
	{		
		if(isLightweight)
		{
			moveActorTo(realX, y + Math.floor(cacheHeight/2) + currOffset.y, !noCollision && continuousCollision ? groupsToCollideWith : null);
		}
		
		else
		{	
			if(isRegion || isTerrainRegion)
			{
				dummy.y = Engine.toPhysicalUnits(y);
			}
				
			else
			{
				dummy.y = Engine.toPhysicalUnits(y + Math.floor(cacheHeight/2) + currOffset.y);
			}
			
			dummy.x = body.getPosition().x;
			
			body.setPosition(dummy);		
			
			if(resetSpeed)
			{
				body.setLinearVelocity(zero);
			}
		}
		
		updateMatrix = true;
	}
	
	public function follow(a:Actor)
	{
		if(a == null)
		{
			return;
		}
	
		if(isLightweight)
		{
			moveActorTo(a.getXCenter(), a.getYCenter());	
			return;
		}
		
		body.setPosition(a.body.getWorldCenter());
	}
	
	public function followWithOffset(a:Actor, ox:Int, oy:Int)
	{
		if(isLightweight)
		{
			moveActorTo(a.getXCenter() + ox, a.getYCenter() + oy);
			return;
		}
		
		var pt:B2Vec2 = a.body.getWorldCenter();
		
		pt.x += Engine.toPhysicalUnits(ox);
		pt.y += Engine.toPhysicalUnits(oy);
		
		body.setPosition(pt);
	}
	
	public function setOriginPoint(x:Int, y:Int)
	{
		var resetPosition:B2Vec2 = null;
		
		if (!isLightweight)
		{
			resetPosition = body.getPosition();
		}
		
		else
		{
			resetPosition = new B2Vec2(Engine.toPhysicalUnits(realX), Engine.toPhysicalUnits(realY));
		}
		
		var offsetDiff:B2Vec2 = new B2Vec2(currOffset.x, currOffset.y);
		var radians:Float = getAngle();
			
		var rotated:Bool = Std.int(radians * Utils.DEG) != 0;	
		
		var w:Float = cacheWidth;
		var h:Float = cacheHeight;
		
		var newOffX:Int = Std.int(x - (w / 2));
		var newOffY:Int = Std.int(y - (h / 2));
				
		if (currOrigin != null && (Std.int(currOffset.x) != newOffX || Std.int(currOffset.y) != newOffY) && rotated)
		{
			var oldAng:Float = radians + Math.atan2( -currOffset.y, -currOffset.x);
			var newAng:Float = radians + Math.atan2( -newOffY, -newOffX);			
			var oldDist:Float = Math.sqrt(Math.pow(currOffset.x, 2) + Math.pow(currOffset.y, 2));
			var newDist:Float = Math.sqrt(Math.pow(newOffX, 2) + Math.pow(newOffY, 2));
							
			var oldFixCenterX:Int = Math.round(currOrigin.x + Math.cos(oldAng) * oldDist);
			var oldFixCenterY:Int = Math.round(currOrigin.y + Math.sin(oldAng) * oldDist);
			var newFixCenterX:Int = Math.round(x + Math.cos(newAng) * newDist);
			var newFixCenterY:Int = Math.round(y + Math.sin(newAng) * newDist);
					
			resetPosition.x += Engine.toPhysicalUnits(oldFixCenterX - newFixCenterX);
			resetPosition.y += Engine.toPhysicalUnits(oldFixCenterY - newFixCenterY);
		}
		
		currOrigin.x = x;
		currOrigin.y = y;
		originX = currOffset.x = newOffX;
		originY = currOffset.y = newOffY;
							
		offsetDiff.x = currOffset.x - offsetDiff.x;
		offsetDiff.y = currOffset.y - offsetDiff.y;		
					
		resetPosition.x += Engine.toPhysicalUnits(offsetDiff.x);
		resetPosition.y += Engine.toPhysicalUnits(offsetDiff.y);
		
		if (!isLightweight)
		{
			body.setPosition(resetPosition);
		}
		
		else
		{
			realX = Engine.toPixelUnits(resetPosition.x);
			realY = Engine.toPixelUnits(resetPosition.y);
		}
		
		resetOrigin = true;
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
		
		return body.getLinearVelocity().x;
	}
	
	public function getYVelocity():Float
	{
		if(isLightweight)
		{
			return ySpeed;
		}
		
		return body.getLinearVelocity().y;
	}
	
	public function setXVelocity(dx:Float)
	{
		if(isLightweight)
		{
			xSpeed = dx;
			return;
		}
		
		var v = body.getLinearVelocity();
		v.x = dx;
		body.setLinearVelocity(v);
		body.setAwake(true);
	}
	
	public function setYVelocity(dy:Float)
	{
		if(isLightweight)
		{
			ySpeed = dy;
			return;
		}
		
		var v = body.getLinearVelocity();
		v.y = dy;
		body.setLinearVelocity(v);
		body.setAwake(true);
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
			return Utils.RAD * realAngle;
		}
		
		return body.getAngle();
	}
	
	public function getAngleInDegrees():Float
	{
		if(isLightweight)
		{
			return realAngle;
		}
		
		return Utils.DEG * body.getAngle();
	}
	
	public function setAngle(angle:Float, inRadians:Bool = true)
	{
		if(inRadians)
		{
			if(isLightweight)
			{
				realAngle = Utils.DEG * angle;
			}
			
			else
			{
				body.setAngle(angle);				
			}
		}
		
		else
		{
			if(isLightweight)
			{
				realAngle = angle;
			}
			
			else
			{
				body.setAngle(Utils.RAD * angle);		
			}
		}
		
		updateMatrix = true;
	}
	
	public function rotate(angle:Float, inRadians:Bool = true)
	{
		if(inRadians)
		{
			if(isLightweight)
			{
				realAngle += Utils.DEG * angle;
			}
			
			else
			{
				body.setAngle(body.getAngle() + angle);
			}
		}
			
		else
		{
			if(isLightweight)
			{
				realAngle += angle;
			}
			
			else
			{
				body.setAngle(body.getAngle() + (Utils.RAD * angle));
			}	
		}
	}
	
	public function getAngularVelocity():Float
	{
		if(isLightweight)
		{
			return Utils.RAD * rSpeed;
		}
		
		return body.getAngularVelocity();
	}
	
	public function setAngularVelocity(omega:Float)
	{
		if(isLightweight)
		{
			rSpeed = Utils.DEG * omega;
		}
		
		else
		{
			body.setAngularVelocity(omega);	
			body.setAwake(true);
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
			body.setAngularVelocity(body.getAngularVelocity() + omega);
			body.setAwake(true);
		}
	}
	
	//*-----------------------------------------------
	//* Physics: Forces
	//*-----------------------------------------------
	
	public function push(dirX:Float, dirY:Float, magnitude:Float)
	{
		if(isLightweight)
		{
			dummy.x = dirX;
			dummy.y = dirY;
			dummy.normalize();
		
			accelerateX(dummy.x * magnitude * 0.01);
			accelerateY(dummy.y * magnitude * 0.01);
			return;
		}
		
		if(dirX == 0 && dirY == 0)
		{
			return;
		}
		
		dummy.x = dirX;
		dummy.y = dirY;
		dummy.normalize();
		
		if(magnitude > 0)
		{
			dummy.multiply(magnitude);
		}
		
		body.applyForce(dummy, body.getWorldCenter());
	}
	
	//in degrees
	public function pushInDirection(angle:Float, speed:Float)
	{
		push
		(
			Math.cos(Utils.RAD * angle),
			Math.sin(Utils.RAD * angle),
			speed
		);
	}
	
	public function applyImpulse(dirX:Float, dirY:Float, magnitude:Float)
	{
		if(isLightweight)
		{
			dummy.x = dirX;
			dummy.y = dirY;
			dummy.normalize();
		
			//TODO: Figure out how to match Box2D
			accelerateX(dummy.x * magnitude);
			accelerateY(dummy.y * magnitude);
			//accelerateX(dummy.x * magnitude * 8);
			//accelerateY(dummy.y * magnitude * 8);
			return;
		}
		
		if(dirX == 0 && dirY == 0)
		{
			return;
		}
		
		dummy.x = dirX;
		dummy.y = dirY;
		dummy.normalize();
		
		if(magnitude > 0)
		{
			dummy.multiply(magnitude);
		}
		
		body.applyImpulse(dummy, body.getWorldCenter());
	}
	
	//in degrees
	public function applyImpulseInDirection(angle:Float, speed:Float)
	{
		applyImpulse
		(
			Math.cos(Utils.RAD * angle),
			Math.sin(Utils.RAD * angle),
			speed
		);
	}
	
	public function applyTorque(torque:Float)
	{
		if(isLightweight)
		{
			if(!fixedRotation)
			{
				rSpeed -= torque;
			}
		}
		
		else
		{
			body.applyTorque(torque);
			body.setAwake(true);
		}
	}
	
	//*-----------------------------------------------
	//* Size
	//*-----------------------------------------------
	
	public function getWidth():Float
	{
		return cacheWidth;
	}
	
	public function getHeight():Float
	{
		return cacheHeight;
	}
	
	public function getPhysicsWidth():Float
	{
		return cacheWidth / Engine.physicsScale;
	}
	
	public function getPhysicsHeight():Float
	{
		return cacheHeight / Engine.physicsScale;
	}
	
	//*-----------------------------------------------
	//* Physics Flags
	//*-----------------------------------------------
	
	public function getBody():B2Body
	{
		return body;
	}
	
	public function setFriction(value:Float)
	{
		if(!isLightweight)
		{
			body.setFriction(value);
		}
	}
	
	public function setBounciness(value:Float)
	{
		if(!isLightweight)
		{
			body.setBounciness(value);
		}
	}
	
	public function enableRotation()
	{
		if(isLightweight)
		{
			fixedRotation = false;
		}
		
		else
		{
			body.setFixedRotation(false);
		}
	}
	
	public function disableRotation()
	{
		if(isLightweight)
		{
			fixedRotation = true;
		}
		
		else
		{
			body.setFixedRotation(true);
		}
	}
	
	public function setIgnoreGravity(state:Bool)
	{
		ignoreGravity = state;
	
		if(!isLightweight)
		{
			body.setIgnoreGravity(state);
		}
	}
	
	public function ignoresGravity():Bool
	{
		if(isLightweight)
		{
			return ignoreGravity;
		}
		
		return body.isIgnoringGravity();
	}
	
	//*-----------------------------------------------
	//* Mouse Convenience
	//*-----------------------------------------------
	
	public function isMouseOver():Bool
	{
		var mx:Float;
		var my:Float;
		
		if(isHUD)
		{
			//on flash/desktop adjust for full screen mode
			#if(!js && !mobile)
			mx = (Input.mouseX / Engine.SCALE - Engine.engine.root.x) / Engine.engine.root.scaleX;
		 	my = (Input.mouseY / Engine.SCALE - Engine.engine.root.y) / Engine.engine.root.scaleY;
		 	#else
		 	mx = Input.mouseX / Engine.SCALE;
		 	my = Input.mouseY / Engine.SCALE;
		 	#end
		}
		
		else
		{
			//on flash/desktop adjust for full screen mode
			#if(!js && !mobile)
			mx = (Input.mouseX / Engine.SCALE - Engine.engine.root.x) / Engine.engine.root.scaleX - Engine.cameraX / Engine.SCALE;
		 	my = (Input.mouseY / Engine.SCALE - Engine.engine.root.y) / Engine.engine.root.scaleY - Engine.cameraY / Engine.SCALE;
		 	#else
		 	mx = (Input.mouseX - Engine.cameraX) / Engine.SCALE;
		 	my = (Input.mouseY - Engine.cameraY) / Engine.SCALE;
		 	#end
		}
		
		//TODO: Mike - Make this work with arbitrary origin points
		//The problem was that mouse detect was off for higher scales
		//and would only work within the centered, original bounds.
		var offsetX = (scaleX - 1) * Math.floor(cacheWidth/2);
		var offsetY = (scaleY - 1) * Math.floor(cacheHeight/2);
		
		var xPos = colX - offsetX;
		var yPos = colY - offsetY;

		return (mx >= xPos && 
		   		my >= yPos && 
		   		mx < xPos + cacheWidth + offsetX * 2 && 
		   		my < yPos + cacheHeight + offsetY * 2);
	}
	
	public function isMouseHover():Bool
	{
		return isMouseOver() && Input.mouseUp;
	}
	
	public function isMouseDown():Bool
	{
		return isMouseOver() && Input.mouseDown;
	}
	
	public function isMousePressed():Bool
	{
		return isMouseOver() && Input.mousePressed;
	}
	
	public function isMouseReleased():Bool
	{
		return isMouseOver() && Input.mouseReleased;
	}
	
	//*-----------------------------------------------
	//* Tween Convenience
	//*-----------------------------------------------
	
	public function cancelTweens()
	{
		/*trace("Before");
		for(item in Actuate.getLibrary(this))
		{
			trace(item.duration);
		}*/
		
		Actuate.stop(this, ["alpha", "realScaleX", "realScaleY"], false, false);		
		
		Actuate.stop(tweenAngle, null, false, false);
		Actuate.stop(tweenLoc, null, false, false);		
		
		activePositionTweens = 0;
		activeAngleTweens = 0;
		
		/*trace("After");
		for(item in Actuate.getLibrary(this))
		{
			trace(item.duration);
		}*/
	}
	
	public function fadeTo(value:Float, duration:Float = 1, easing:Dynamic = null)
	{	
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		Actuate.tween(this, duration, {alpha:value}).ease(easing);
	}
	
	public function growTo(scaleX:Float = 1, scaleY:Float = 1, duration:Float = 1, easing:Dynamic = null)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		Actuate.tween(this, duration, {realScaleX:scaleX, realScaleY:scaleY}).ease(easing);
	}
	
	//In degrees
	public function spinTo(angle:Float, duration:Float = 1, easing:Dynamic = null)
	{
		tweenAngle.angle = realAngle;

		if(easing == null)
		{
			easing = Linear.easeNone;
		}
		
		activeAngleTweens++;		
		
		Actuate.tween(tweenAngle, duration, {angle:angle}).ease(easing).onComplete(onTweenAngleComplete);		
		
		//Taken out because people said it's buggy.
		//Lock to final value to make up for lack of full syncing
		/*var toExecute = function(timeTask:TimedTask):Void
		{
			if(isLightweight)
			{
				Actuate.stop(this, "realAngle", true, true);
			}
			
			else
			{
				Actuate.stop(tweenAngle, "angle", true, true);
			}
			
			setAngle(Utils.RAD * angle);
		};
		
		var t:TimedTask = new TimedTask(toExecute, Std.int(duration * 1000) - 1, false, this);
		engine.addTask(t);*/
	}
	
	public function moveTo(x:Float, y:Float, duration:Float = 1, easing:Dynamic = null)
	{
		tweenLoc.x = getX(false);
		tweenLoc.y = getY(false);
		
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
		
		activePositionTweens++;		
		
		Actuate.tween(tweenLoc, duration, {x:x, y:y}).ease(easing).onComplete(onTweenPositionComplete);		
		
		//Taken out because people said it's buggy.
		//Lock to final value to make up for lack of full syncing
		/*var toExecute = function(timeTask:TimedTask):Void
		{
			if(isLightweight)
			{
				Actuate.stop(this, ["realX", "realY"], true, true);
			}
			
			else
			{
				Actuate.stop(tweenLoc, ["x", "y"], true, true);
			}
			
			setX(x);
			setY(y);
			
			colX = realX - Math.floor(cacheWidth/2) - currOffset.x;
			colY = realY - Math.floor(cacheHeight/2) - currOffset.y;
		};
		
		var t:TimedTask = new TimedTask(toExecute, Std.int(duration * 1000) - 1, false, this);
		engine.addTask(t);*/
	}
	
	//In degrees
	public function spinBy(angle:Float, duration:Float = 1, easing:Dynamic = null)
	{
		spinTo(realAngle + angle, duration, easing);
	}
	
	public function moveBy(x:Float, y:Float, duration:Float = 1, easing:Dynamic = null)
	{		
		moveTo(getX(false) + x, getY(false) + y, duration, easing);	
	}
	
	public function onTweenAngleComplete()
	{
		activeAngleTweens--;
	}
	
	public function onTweenPositionComplete()
	{
		updateTweenProperties();
		activePositionTweens--;
		
		if (currOffset != null)
		{
			resetReal(realX, realY);
		}
	}
	
	
	//*-----------------------------------------------
	//* Drawing
	//*-----------------------------------------------
	
	public function drawImage(g:G)
	{
		if(currAnimation != null)
		{
			var x:Float = 0;
			var y:Float = 0;
			
			#if cpp
			if(g.drawActor)
			{
				x = g.x + Engine.cameraX;
				y = g.y + Engine.cameraY;
			}
			
			else
			{
				x = g.x;
				y = g.y;
			}
			#end		
			
			//TODO: See if I can make more efficient
			if (realAngle > 0)
			{
				drawMatrix.identity();
				transformPoint.x = 0 - (cacheWidth*Engine.SCALE) / 2;
				transformPoint.y = 0 - (cacheHeight*Engine.SCALE) / 2;

				drawMatrix.translate( -transformPoint.x * Engine.SCALE, -transformPoint.y * Engine.SCALE);
				drawMatrix.scale(realScaleX, realScaleY);		
				drawMatrix.rotate(realAngle * Utils.RAD);		
		
				drawMatrix.translate(colX * Engine.SCALE, colY * Engine.SCALE);
				
				x += transformMatrix.tx - drawMatrix.tx;
				y += transformMatrix.ty - drawMatrix.ty;
			}
			
			cast(currAnimation, AbstractAnimation).draw(g, x, y, -realAngle * Utils.RAD, g.alpha);
		}
	}
	
	public function enableActorDrawing()
	{
		drawActor = true;
		
		if(currAnimation != null)
		{
			currAnimation.visible = true;
		}
		
		for(anim in animationMap)
		{
			if(anim != null)
			{
				anim.visible = true;
			}
		}
	}
	
	public function disableActorDrawing()
	{
		drawActor = false;
		
		if(currAnimation != null)
		{
			currAnimation.visible = false;
		}
		
		for(anim in animationMap)
		{
			if(anim != null)
			{
				anim.visible = false;
			}
		}
	}
	
	public function drawsImage():Bool
	{
		return drawActor;
	}
	
	//*-----------------------------------------------
	//* Filters
	//*-----------------------------------------------

	public function setFilter(filter:Array<BitmapFilter>)
	{			
		#if !cpp
		filters = filters.concat(filter);
		#end
	}
	
	public function clearFilters()
	{
		filters = [];
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
	
	public function shout(msg:String, args:Array<Dynamic> = null):Dynamic
	{
		return behaviors.call(msg, args);
	}
	
	public function say(behaviorName:String, msg:String, args:Array<Dynamic> = null):Dynamic
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
	//* Events Plumbing
	//*-----------------------------------------------
	
	public function registerListener(type:Array<Dynamic>, listener:Dynamic)
	{
		var ePos:Int = Utils.indexOf(allListenerReferences, type);
		
		var listenerList:Array<Dynamic> = null; 
		
		if (ePos != -1)
		{
			listenerList = allListeners.get(ePos);
		}
		
		else
		{
			allListenerReferences.push(type);
			ePos = allListenerReferences.length - 1;
			
			listenerList = new Array<Dynamic>();
			allListeners.set(ePos, listenerList);
		}
		
		listenerList.push(listener);
	}
	
	public function removeAllListeners()
	{			
		for(k in 0...allListenerReferences.length)
		{
			var listener = allListenerReferences[k];
			
			if(listener != null)
			{
				var list:Array<Dynamic> = cast(allListeners.get(k), Array<Dynamic>);
				
				if(list != null)
				{
					for(r in 0...list.length)
					{
						Utils.removeValueFromArray(listener, list[r]);
					}
				}
			}
		}
		
		Utils.clear(allListenerReferences);
	}	
	
	//*-----------------------------------------------
	//* Misc
	//*-----------------------------------------------	
	
	public function anchorToScreen()
	{
		if(!isLightweight)
		{
			body.setAlwaysActive(true);
		}
		
		isHUD = true;	
		engine.removeActorFromLayer(this, layerID);
		engine.addHUDActor(this);		
		engine.hudLayer.addChild(this);
		
		updateMatrix = true;
	}
	
	public function unanchorFromScreen()
	{
		if(!isLightweight)
		{
			body.setAlwaysActive(alwaysSimulate);
		}
		
		isHUD = false;			
		engine.removeHUDActor(this);
		engine.hudLayer.removeChild(this);
		engine.moveActorToLayer(this, layerID);		
		
		updateMatrix = true;
	}
	
	public function isAnchoredToScreen():Bool
	{
		return isHUD;
	}
	
	public function makeAlwaysSimulate(alterBody:Bool = true)
	{
		if(!isLightweight && alterBody)
		{
			body.setAlwaysActive(true);
		}
		
		alwaysSimulate = true;			
		engine.addHUDActor(this);
	}
	
	public function makeSometimesSimulate(alterBody:Bool = true)
	{
		if(!isLightweight && alterBody)
		{
			body.setAlwaysActive(false);
		}
		
		alwaysSimulate = false;			
		engine.removeHUDActor(this);
	}
	
	public function alwaysSimulates():Bool
	{
		return alwaysSimulate;
	}
	
	public function die()
	{
		dying = true;
		
		var a = engine.whenTypeGroupDiesListeners.get(getType().sID);
		var b = engine.whenTypeGroupDiesListeners.get(getGroup().sID);
	
		Engine.invokeListeners(whenKilledListeners);

		if(a != null)
		{
			Engine.invokeListeners2(a, this);
		}
		
		if(b != null)
		{
			Engine.invokeListeners2(b, this);
		}
		
		removeAllListeners();
	}
		
	public function isDying():Bool
	{
		return dying;
	}
	
	public function isAlive():Bool
	{
		return !(dead || dying || recycled);
	}

	//hand-inlined to engine to avoid overhead
	public function isOnScreen():Bool
	{
		var cameraX = Engine.cameraX / Engine.SCALE;
		var cameraY = Engine.cameraY / Engine.SCALE;
		
		var left = Engine.paddingLeft;
		var top = Engine.paddingTop;
		var right = Engine.paddingRight;
		var bottom = Engine.paddingBottom;
	
		return (isLightweight || body.isActive()) && 
			   getX() >= -cameraX - left && 
			   getY() >= -cameraY - top &&
			   getX() < -cameraX + Engine.screenWidth + right &&
			   getY() < -cameraY + Engine.screenHeight + bottom;
	}
	
	public function isInScene():Bool
	{
		return (isLightweight || body.isActive()) && 
			   getX() >= 0 && 
			   getY() >= 0 &&
			   getX() < Engine.sceneWidth &&
			   getY() < Engine.sceneHeight;
	}
	
	public function getLastCollidedActor():Actor
	{
		return Actor.lastCollided;
	}
	

	//Kills this actor after it leaves the screen
	public function killSelfAfterLeavingScreen()
	{
		killLeaveScreen = true;
	}
	
	override public function toString():String
	{
		if(name == null)
		{
			return "Unknown Actor " + ID;
		}
		
		return "[Actor " + ID + "," + name + "]";
	}
	
	//*-----------------------------------------------
	//* Camera-Only
	//*-----------------------------------------------
	
	public function setLocation(x:Float, y:Float)
	{			
		realX = x;
		realY = y;
		
		setX(x, false, true);
		setY(y, false, true);
	}
	
	//*-----------------------------------------------
	//* Simple Collision system (via FlashPunk)
	//*-----------------------------------------------

	/**
	 * An optional Mask component, used for specialized collision. If this is
	 * not assigned, collision checks will use the Entity's hitbox by default.
	 */
	public var shape(getShape, setShape):Mask;
	private inline function getShape():Mask { return _mask; }
	private function setShape(value:Mask):Mask
	{
		if (_mask == value) return value;
		if (_mask != null) _mask.assignTo(null);
		_mask = value;
		if (value != null) _mask.assignTo(this);
		return _mask;
	}
	
	/**
	 * Checks for a collision against an Entity type.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collide(groupID:Int, x:Float, y:Float):Actor
	{
		//Grab all actors from a group. For us, that means grabbing the group! (instead of a string type)
		var actorList = engine.getGroup(groupID);
		
		_x = realX; _y = realY;
		resetReal(x, y);

		if (_mask == null)
		{
			for(actor in actorList.list)
			{
				var e = actor;
				
				if (e.recycled)
				{
					continue;
				}
				
				if (colX + cacheWidth >= e.colX
				&& colY + cacheHeight >= e.colY
				&& colX <= e.colX + e.cacheWidth
				&& colY <= e.colY + e.cacheHeight
				&& e.collidable && e != this)
				{
					if (e._mask == null || e._mask.collide(HITBOX))
					{						
						resetReal(_x, _y);						
						
						return e;
					}
				}
			}
			
			resetReal(_x, _y);			
			return null;
		}

		for(actor in actorList.list)
		{
			var e = actor;
			
			if (e.recycled)
			{
				continue;
			}
	
			if (colX + cacheWidth >= e.colX
			&& colY + cacheHeight >= e.colY
			&& colX <= e.colX + e.cacheWidth
			&& colY <= e.colY + e.cacheHeight
			&& e.collidable && e != this)
			{				
				if (_mask.collide(e._mask != null ? e._mask : e.HITBOX))
				{					
					resetReal(_x, _y);										
					
					return e;
				}
			}
		}
		resetReal(_x, _y);
		return null;
	}

	/**
	 * Checks for collision against multiple Entity types.
	 * @param	types		An Array or Vector of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collideTypes(types:Dynamic, x:Float, y:Float):Actor
	{
		if (Std.is(types, String))
		{
			return collide(types, x, y);
		}
		else
		{
			var a:Array<Int> = cast types;
			if (a != null)
			{
				var e:Actor;
				var type:Int;
				for (type in a)
				{
					if (type == GameModel.REGION_ID) continue;
					
					e = collide(type, x, y);
					if (e != null) return e;
				}
			}
		}

		return null;
	}
	
	/**
	 * Checks if this Entity collides with a specific Entity.
	 * @param	e		The Entity to collide against.
	 * @param	x		Virtual x position to place this Entity.
	 * @param	y		Virtual y position to place this Entity.
	 * @return	The Entity if they overlap, or null if they don't.
	 */
	public function collideWith(e:Actor, x:Float, y:Float):Actor
	{
		_x = realX; _y = realY;
		resetReal(x, y);

		if (colX + cacheWidth >= e.colX
		&& colY + cacheHeight >= e.colY
		&& colX <= e.colX + e.cacheWidth
		&& colY <= e.colY + e.cacheHeight
		&& collidable && e.collidable)
		{
			if (_mask == null)
			{
				if (e._mask == null || e._mask.collide(HITBOX))
				{
					resetReal(_x, _y);
					return e;
				}
				resetReal(_x, _y);
				return null;
			}
			if (_mask.collide(e._mask != null ? e._mask : e.HITBOX))
			{
				resetReal(_x, _y);
				return e;
			}
		}
		resetReal(_x, _y);
		return null;
	}

	/**
	 * Populates an array with all collided Entities of a type.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 * @return	The array, populated with all collided Entities.
	 */
	public function collideInto(groupID:Int, x:Float, y:Float, array:Array<Actor>)
	{
		//Grab all actors from a group. For us, that means grabbing the group! (instead of a string type)
		var actorList = engine.getGroup(groupID);

		_x = realX; _y = realY;
		resetReal(x, y);
		var n:Int = array.length;

		if (_mask == null)
		{
			for(actor in actorList.list)
			{
				var e = actor;
				
				if (e.recycled)
				{
					continue;
				}
				
				if (colX + cacheWidth >= e.colX
				&& colY + cacheHeight >= e.colY
				&& colX <= e.colX + e.cacheWidth
				&& colY <= e.colY + e.cacheHeight
				&& e.collidable && e != this)
				{
					if (e._mask == null || e._mask.collide(HITBOX)) array[n++] = e;
				}
			}
			resetReal(_x, _y);
			return;
		}

		for(actor in actorList.list)
		{
			var e = actor;
			
			if (colX + cacheWidth >= e.colX
			&& colY + cacheHeight >= e.colY
			&& colX <= e.colX + e.cacheWidth
			&& colY <= e.colY + e.cacheHeight
			&& e.collidable && e != this)			
			{
				if (_mask.collide(e._mask != null ? e._mask : e.HITBOX)) array[n++] = e;
			};
		}
		resetReal(_x, _y);
		return;
	}

	/**
	 * Populates an array with all collided Entities of multiple types.
	 * @param	types		An array of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 * @return	The array, populated with all collided Entities.
	 */
	public function collideTypesInto(types:Array<Int>, x:Float, y:Float, array:Array<Actor>)
	{
		var type:String;
		for (type in types) collideInto(type, x, y, array);
	}
	
	public function clearCollisionList()
	{
		if (collisionsCount > 0)
		{
			for(k in simpleCollisions.keys()) 
			{
				simpleCollisions.remove(k);
			}
		}
		
		collisionsCount = 0;
	}
	
	public function addCollision(info:CollisionInfo)
	{
		if (!allowAdd) return;
		
		simpleCollisions.set(collisionsCount, info);
		collisionsCount++;
	}
	
	public function alreadyCollided(maskA:Mask, maskB:Mask):Bool
	{
		for (info in simpleCollisions)
		{
			if (info.maskA == maskA && info.maskB == maskB)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function resetReal(x:Float, y:Float)
	{
		realX = x; realY = y;
		colX = realX - Math.floor(cacheWidth/2) - currOffset.x;
		colY = realY - Math.floor(cacheHeight/2) - currOffset.y;
	}

	public function moveActorBy(x:Float, y:Float, solidType:Dynamic = null, sweep:Bool = false)
	{
		if (x == 0 && y == 0)
		{
			return;
		}
		
		clearCollisionList();		
				
		if (solidType != null)
		{
			var sign:Float, signIncr:Float, e:Actor, checkMove:Bool;
			
			if (x != 0)
			{
				allowAdd = false;
				
				if (collidable && (sweep || collideTypes(solidType, realX + x, realY) != null))
				{
					allowAdd = true;
					
					while (x != 0)
					{
						signIncr = (x >= 1 || x <= -1) ? 1 : x;
						sign = x > 0 ? signIncr : -signIncr;
						checkMove = Std.int(realX) != Std.int(realX + sign);						
						
						//Check regions first
						if (checkMove && (e = collide(GameModel.REGION_ID, realX + sign, realY)) != null)
						{
							cast(e, Region).addActor(this);
						}
						
						if (checkMove && (e = collideTypes(solidType, realX + sign, realY)) != null)
						{							
							moveCollideX(e, sign);
							
							if (simpleCollisions.get(collisionsCount -1) != null && simpleCollisions.get(collisionsCount -1).solidCollision)
							{
								xSpeed = 0;
								break;
							}							
						}
						
						realX += sign;
						x -= sign;						
					}
				}
				else realX += x;
			}						
			if (y != 0)
			{
				allowAdd = false;
				
				if (collidable && (sweep || collideTypes(solidType, realX, realY + y) != null))
				{
					allowAdd = true;
					
					while (y != 0)
					{
						signIncr = (y >= 1 || y <= -1) ? 1 : y;
						sign = y > 0 ? signIncr : -signIncr;
						checkMove = Std.int(realY) != Std.int(realY + sign);
						
						//Check regions first
						if (checkMove && (e = collide(GameModel.REGION_ID, realX, realY + sign)) != null)
						{
							cast(e, Region).addActor(this);
						}
						
						if (checkMove && (e = collideTypes(solidType, realX, realY + sign)) != null)
						{						
							moveCollideY(e, sign);
							
							if (simpleCollisions.get(collisionsCount -1) != null && simpleCollisions.get(collisionsCount -1).solidCollision)
							{
								ySpeed = 0;
								break;
							}
						}
						
						realY += sign;
						y -= sign;
						
					}
				}
				else realY += y;
			}
		}
		else
		{
			realX += x;
			realY += y;
		}
		
		resetReal(realX, realY);
	}
	
	/**
	 * Moves the Entity to the position, retaining integer values for its x and y.
	 * @param	x			X position.
	 * @param	y			Y position.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveActorTo(x:Float, y:Float, solidType:Dynamic = null, sweep:Bool = false)
	{
		moveActorBy(x - realX, y - realY, solidType, sweep);
	}

	/**
	 * Moves towards the target position, retaining integer values for its x and y.
	 * @param	x			X target.
	 * @param	y			Y target.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveActorTowards(x:Float, y:Float, amount:Float, solidType:Dynamic = null, sweep:Bool = false)
	{
		_point.x = x - realX;
		_point.y = y - realY;
		_point.normalize(amount);
		moveActorBy(_point.x, _point.y, solidType, sweep);
	}

	/**
	 * When you collide with an Entity on the x-axis with moveTo() or moveBy().
	 * @param	e		The Entity you collided with.
	 */
	public function moveCollideX(a:Actor, sign:Float)
	{
		handleCollisionsSimple(a, true, false, sign);
	}

	/**
	 * When you collide with an Entity on the y-axis with moveTo() or moveBy().
	 * @param	e		The Entity you collided with.
	 */
	public function moveCollideY(a:Actor, sign:Float)
	{
		handleCollisionsSimple(a, false, true, sign);
	}
	
	private function handleCollisionsSimple(a:Actor, fromX:Bool, fromY:Bool, sign:Float)
	{
		if(Std.is(a, Region))
		{
			var region = cast(a, Region);
			region.addActor(this);
			return;
		}
		
		var info:CollisionInfo = simpleCollisions.get(collisionsCount -1);
	
		Utils.collision.thisActor = Utils.collision.actorA = this;
		Utils.collision.otherActor = Utils.collision.actorB = a;
		
		if (a.isLightweight)
		{
			a.clearCollisionList();
		}
		
		if(fromX)
		{
			//If tile, have to use travel direction
			if (a.ID == Utils.INT_MAX)
			{
				Utils.collision.thisFromLeft = sign < 0;
				Utils.collision.thisFromRight = sign > 0;
			}
			else
			{			
				Utils.collision.thisFromLeft = a.colX < colX;
				Utils.collision.thisFromRight = a.colX > colX;
			}
			
			Utils.collision.otherFromLeft = !Utils.collision.thisFromLeft;
			Utils.collision.otherFromRight = !Utils.collision.thisFromRight;
		
			Utils.collision.thisFromTop = Utils.collision.otherFromTop = false;
			Utils.collision.thisFromBottom = Utils.collision.otherFromBottom = false;
		}
		
		if(fromY)
		{
			//If tile, have to use travel direction
			if (a.ID == Utils.INT_MAX)
			{
				Utils.collision.thisFromTop = sign < 0;
				Utils.collision.thisFromBottom = sign > 0;
			}
			else
			{			
				Utils.collision.thisFromTop = a.colY < colY;
				Utils.collision.thisFromBottom = a.colY > colY;
			}
		
			Utils.collision.otherFromTop = !Utils.collision.thisFromTop;
			Utils.collision.otherFromBottom = !Utils.collision.thisFromBottom;
		
			Utils.collision.thisFromLeft = Utils.collision.otherFromLeft = false;
			Utils.collision.thisFromRight = Utils.collision.otherFromRight = false;
		}
		
		//TODO
		Utils.collision.thisCollidedWithActor = true;
		Utils.collision.thisCollidedWithTile = a.ID == Utils.INT_MAX;
		
		if(info != null)
		{
			Utils.collision.thisCollidedWithSensor = !info.maskB.solid;
		}
		
		else
		{
			Utils.collision.thisCollidedWithSensor = false;
		}
		
		Utils.collision.thisCollidedWithTerrain = false;
		
		Utils.collision.otherCollidedWithActor = true;
		Utils.collision.otherCollidedWithTile = a.ID == Utils.INT_MAX;
		
		if(info != null)
		{
			Utils.collision.otherCollidedWithSensor = !info.maskA.solid;
		}
		
		else
		{
			Utils.collision.otherCollidedWithSensor = false;
		}
		
		Utils.collision.otherCollidedWithTerrain = false;

		lastCollided = a;
		Engine.invokeListeners2(collisionListeners, Utils.collision);
		engine.handleCollision(this, Utils.collision);
		
		lastCollided = this;
		Engine.invokeListeners2(a.collisionListeners, Utils.collision.switchData());
	}
	
	private var HITBOX:Mask;
	private var _mask:Mask;
	private var _x:Float;
	private var _y:Float;
	private var _moveX:Float;
	private var _moveY:Float;
	private var _point:Point;
	private var simpleCollisions:IntHash<CollisionInfo>;
	private var allowAdd:Bool;
}
