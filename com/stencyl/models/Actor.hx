package com.stencyl.models;

import de.polygonal.ds.IntHashTable;

import com.stencyl.behavior.TimedTask;

import com.stencyl.models.collision.CollisionInfo;
import com.stencyl.models.collision.Masklist;
import flash.geom.Transform;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Tilesheet;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.Assets;
import openfl.display.Graphics;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

#if (flash || cpp || neko)
import openfl.Memory;
#end

import com.stencyl.Input;
import com.stencyl.Engine;

import com.stencyl.graphics.G;
import com.stencyl.graphics.AbstractAnimation;
import com.stencyl.graphics.BitmapAnimation;
import com.stencyl.graphics.BitmapWrapper;
import com.stencyl.graphics.SheetAnimation;
import com.stencyl.graphics.fonts.Label;

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

import motion.Actuate;
import motion.easing.Back;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;
import motion.actuators.GenericActuator;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2MassData;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Transform;
import box2D.collision.B2WorldManifold;

import com.stencyl.models.collision.Mask;
import com.stencyl.models.collision.Hitbox;
import com.stencyl.models.collision.Grid;

import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import com.stencyl.utils.ColorMatrix;

//#if flash
//import flash.filters.ColorMatrixFilter;
//import com.stencyl.utils.ColorMatrix;
//#end

#if js
//import jeash.filters.ColorMatrixFilter;
#end

#if (cpp || neko)
typedef ActorAnimation = SheetAnimation;
#else
typedef ActorAnimation = BitmapAnimation;
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
	public var physicsMode:Int;
	public var autoScale:Bool;
	
	public var dead:Bool; //gone from the game - don't touch
	public var dying:Bool; //in the process of dying but not yet removed
	
	public var fixedRotation:Bool;
	public var ignoreGravity:Bool;
	public var defaultGravity:Bool;
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
	
	public var currAnimation:ActorAnimation;
	public var currAnimationName:String;
	public var animationMap:Map<String,ActorAnimation>;

	#if (cpp || neko || js)
	public var backupAnimationMap:Map<String,BitmapData>;
	public var animsBackedUp:Bool = false;
	public var tint:Bool = false;
	#end

	public var sprite:com.stencyl.models.actor.Sprite;
	
	public var shapeMap:Map<String,Dynamic>;
	public var originMap:Map<String,B2Vec2>;
	public var defaultAnim:String;
	
	public var currOrigin:Point;
	public var currOffset:Point;
	
	public var transformObj:Transform;
	public var transformPoint:Point;
	public var transformMatrix:Matrix;
	public var updateMatrix:Bool;
	public var drawMatrix:Matrix; //For use when drawing actor image
	
	public var label:Label;

	public var attachedImages:Array<BitmapWrapper> = null;
	
	// These are for the smooth movement option.
	public var smoothMove:Bool = false;
	public var firstMove:Bool = false;
	public var snapOnSet:Bool = false;
	public var drawX:Float = 0;
	public var drawY:Float = 0;
	public var moveMultiplier:Float = 0.33;
	public var moveXDistance:Float = 0;
	public var moveYDistance:Float = 0;
	public var minMove:Float = 3;
	public var maxMove:Float = 99999;
	
	//*-----------------------------------------------
	//* Behaviors
	//*-----------------------------------------------
	
	public var behaviors:BehaviorManager;
	
	
	//*-----------------------------------------------
	//* Actor Values
	//*-----------------------------------------------
	
	public var registry:Map<String,Dynamic>;

	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------	
	
	public var allListeners:Map<Int,Dynamic>;
	public var allListenerReferences:Array<Dynamic>;
	
	public var whenCreatedListeners:Array<Dynamic>;
	public var whenUpdatedListeners:Array<Dynamic>;
	public var whenDrawingListeners:Array<Dynamic>;
	public var whenKilledListeners:Array<Dynamic>;		
	public var mouseOverListeners:Array<Dynamic>;
	public var positionListeners:Array<Dynamic>;
	public var collisionListeners:Array<Dynamic>;
	
	public var positionListenerCount:Int;
	//Fixed for html5
	public var collisionListenerCount:Int = 0;
	
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
	public var contacts:IntHashTable<B2Contact>;
	public var regionContacts:IntHashTable<B2Contact>;
	public var collisions:IntHashTable<Collision>;
	
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
		behaviorValues:Map<String,Dynamic>=null,
		actorType:ActorType=null,
		bodyDef:B2BodyDef=null,
		isSensor:Bool=false,
		isStationary:Bool=false,
		isKinematic:Bool=false,
		canRotate:Bool=false,
		shape:Dynamic=null, //B2Shape or Mask - Used only for terrain.
		typeID:Int = 0,
		autoScale:Bool = true,
		ignoreGravity:Bool = false,
		physicsMode:Int = 0
	)
	{
		super();
		
		if(Engine.NO_PHYSICS && physicsMode == 0)
		{
			physicsMode = 1;
			this.physicsMode = 1;
		}
		
		//---
		
		dummy = new B2Vec2();
		zero = new B2Vec2(0, 0);
		
		_point = Utils.point;
		_moveX = _moveY = 0;
		
		HITBOX = new Mask();		
		set_shape(HITBOX);
		
		if(Std.is(this, Region) && Engine.NO_PHYSICS)
		{
			shape = HITBOX = new Hitbox(Std.int(width), Std.int(height), 0, 0, false, -2);
			set_shape(shape);
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
		
		if(physicsMode > 0)
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
		registry = new Map<String,Dynamic>();
		
		attachedImages = new Array<BitmapWrapper>();
		
		this.physicsMode = physicsMode;
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
		defaultGravity = ignoreGravity;
		resetOrigin = true;
		
		//---
		
		allListeners = new Map<Int,Dynamic>();
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
		
		collidedList = new Array<Actor>();
		
		collisions = new IntHashTable<Collision>(16);
		simpleCollisions = new IntHashTable<Collision>(16);
		contacts = new IntHashTable<B2Contact>(16);
		regionContacts = new IntHashTable<B2Contact>(16);
		
		collisions.reuseIterator = true;
		simpleCollisions.reuseIterator = true;
		contacts.reuseIterator = true;
		regionContacts.reuseIterator = true;
		
		contactCount = 0;
		collisionsCount = 0;
		
		handlesCollisions = true;
		
		//---
		
		behaviors = new BehaviorManager();
		
		//---
		
		currAnimationName = "";
		animationMap = new Map<String,ActorAnimation>();
		shapeMap = new Map<String,Dynamic>();
		originMap = new Map<String,B2Vec2>();
		
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
						a.frameCount, 
						Math.floor(a.imgWidth / a.framesAcross), 
						Math.floor(a.imgHeight / a.framesDown), 
						a.framesAcross,
						a.framesDown,
						a.originX,
						a.originY,
						a.durations, 
						a.looping,
						physicsMode > 0 ? a.simpleShapes : a.physicsShapes
					);
					
					if(a.animID == s.defaultAnimation)
					{
						defaultAnim = a.animName;
					}
				}
			}
		}
		
		//--
		
		addAnim(-1, "recyclingDefault", null, 1, 1, 1, 1, 1, 1, 1, [1000], false, null);

		if(bodyDef != null && physicsMode == 0)
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
			if(shape == null || Type.typeof(shape) == TFloat)
			{				
				shape = createBox(width, height);
			}
			
			if(bodyDef != null)
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
				set_shape(shape);
				isTerrain = true;
			}
			
			else if(physicsMode == 0)
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
			
			else if(physicsMode == 0)
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
		
		#if js
		clearFilters();
		#end
		
		destroyed = true;
		
		for(anim in animationMap)
		{
			anim.visible = false;
		}
		
		Utils.removeAllChildren(this);

		if(body != null && physicsMode == 0)
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
		
		if(bodyDef != null)
		{
			bodyDef.userData = null;
			bodyDef = null;
		}
		
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
		framesAcross:Int = 1,
		framesDown:Int = 1,
		originX:Float = 0,
		originY:Float = 0,
		durations:Array<Int>=null, 
		looping:Bool=true, 
		shapes:Map<Int,Dynamic>=null
	)
	{
		if(shapes != null)
		{
			var arr = new Array<Dynamic>();
			
			if(physicsMode == 1)
			{
				for(s in shapes)
				{				
					if(Std.is(s, Hitbox) && physicsMode > 0)
					{		
						s = cast(s, Hitbox).clone();
						s.assignTo(this);
					}
				
					arr.push(s);
				}
			}
			
			else if(physicsMode == 2)
			{
				//no shapes at all
			}
			
			else
			{
				for(s in shapes)
				{				
					arr.push(s);
				}
			}
			
			if(physicsMode > 0)
			{
				shapeMap.set(name, new Masklist(arr, this));
				
			}
			
			else
			{
				shapeMap.set(name, arr);
			}
		}
	
		if(imgData == null || imgData.width <= 0 || imgData.height <= 0)
		{
			//animationMap.set(name, new Sprite());
			
			//XXX: Did some work on cases where image data is missing. It's still an error but won't crash anymore.
			//XXX: This ends up being the case for the recyclingDefault animation.
			#if (cpp || neko)

			var tilesheet = new Tilesheet(new BitmapData(16, 16));
			tilesheet.addTileRect(new openfl.geom.Rectangle(0, 0, 16, 16));
			var tempSprite = new SheetAnimation(tilesheet, [1000000], 16, 16, false, null);
			tempSprite.framesAcross = 1;
			animationMap.set(name, tempSprite);
			
			#elseif flash
			
			animationMap.set(name, new BitmapAnimation(new BitmapData(16, 16), 1, 1, 1, [1000000], false, null));
			
			#end
			
			originMap.set(name, new B2Vec2(originX, originY));
			
			return;
		}
	
		#if (cpp || neko)
		var tilesheet = new Tilesheet(imgData);
				
		frameWidth = Std.int(imgData.width/framesAcross);
		frameHeight = Std.int(imgData.height/framesDown);
				
		for(i in 0...frameCount)
		{			
			tilesheet.addTileRect(new openfl.geom.Rectangle(frameWidth * (i % framesAcross), Math.floor(i / framesAcross) * frameHeight, frameWidth, frameHeight));
			// trace("x: " + (frameWidth * (i % framesAcross)) + " y: " + (Math.floor(i / framesAcross) * frameHeight) + " w: " + (frameWidth) + " h: " + (frameHeight));
		}
		 	
		var sprite = new SheetAnimation
		(
			tilesheet, 
			durations, 
			frameWidth, 
			frameHeight,
			looping,
			this.sprite.animations.get(animID).sync ? this.sprite.animations.get(animID) : null
		);
		
		sprite.framesAcross = framesAcross;
		
		animationMap.set(name, sprite);
		#end
		
		#if (flash || js)
		var sprite = new BitmapAnimation
		(
			imgData, 
			frameCount, 
			framesAcross,
			framesDown,
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
		if(physicsMode == 2)
		{
			handlesCollisions = false;
			return;
		}
	
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
   	
	public function addAnimation(name:String, sprite:ActorAnimation)
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
		//TODO: PERF - We lost SizedMap - this operation is O(n)
		if(sprite != null && Lambda.count(sprite.animations) > 0)
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
			if(body != null && physicsMode == 0)
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
							
			addChild(newAnimation);			
			
			//----------------
			
			var animOrigin:B2Vec2 = originMap.get(name);		
			
			if(physicsMode == 0)
			{
				updateTweenProperties();
			}
						
			var centerx = (currAnimation.width / Engine.SCALE / 2) - animOrigin.x;
			var centery = (currAnimation.height / Engine.SCALE / 2) - animOrigin.y;
			
			if(body != null && isDifferentShape && physicsMode == 0)
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
					collisions.clr(k);
				}
				
				collisions = new IntHashTable<Collision>(16);
				simpleCollisions = new IntHashTable<Collision>(16);
				contacts = new IntHashTable<B2Contact>(16);
				regionContacts = new IntHashTable<B2Contact>(16);
				
				collisions.reuseIterator = true;
				simpleCollisions.reuseIterator = true;
				contacts.reuseIterator = true;
				regionContacts.reuseIterator = true;
				
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
						
			else if(shapeMap.get(name) != null && physicsMode == 1)
			{				
				//Get hitbox list for Simple Physics
				set_shape(shapeMap.get(name));
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
			
			if(physicsMode == 0)
			{
				realX = getX(false);
				realY = getY(false);
			}
			
			if(animOrigin != null)
			{					
				setOriginPoint(Std.int(animOrigin.x), Std.int(animOrigin.y));				
			}
			
			updateMatrix = true;
			
			//----------------
			
			if(Std.is(currAnimation, AbstractAnimation))
			{
				cast(currAnimation, AbstractAnimation).reset();
			}				
		}
	}

	public function removeAttachedImages()
	{
		for(b in attachedImages)
			removeChild(b);
		attachedImages = new Array<BitmapWrapper>();
	}
	
	//*-----------------------------------------------
	//* Events - Update
	//*-----------------------------------------------
	
	public function update(elapsedTime:Float)
	{
		innerUpdate(elapsedTime, true);
	}
	
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
				
		if(physicsMode == 0)
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
		
		if (physicsMode == 1)
		{
			if(collisionListenerCount > 0 || 
			   ec.get(checkType) != null || 
			   ec.get(groupType) != null) 
			{
				handleCollisionsSimple();
			}
		}
		
		if(physicsMode < 2)
		{
			Engine.invokeListeners2(whenUpdatedListeners, elapsedTime);		
		}
		
		if(positionListenerCount > 0 || 
		   ep.get(checkType) != null || 
		   ep.get(groupType) != null)
		{
			checkScreenState();
		}
		
		//If this actor has a label, set the label's alpha to match the actor's alpha.
		if(label != null)
		{
			label.setAlpha(alpha);
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
					
		if(physicsMode > 0)
		{		
			if(physicsMode == 1 && !ignoreGravity && !isHUD)
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
						
			realX = p.x * Engine.physicsScale;
			realY = p.y * Engine.physicsScale;				
			
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
		
		if(doAll && currAnimation != null)
		{
   			//This may be a slowdown on iOS by 3-5 FPS due to clear and redraw?
   			currAnimation.update(elapsedTime);
		}
			
		updateTweenProperties();		
	}	
	
	public function updateDrawingMatrix()
	{
		if(paused)
		{
			return;
		}
		
		if(smoothMove)
		{
			if(!firstMove)
			{
				drawX = realX;
				drawY = realY;
				firstMove = true;
			}
			
			moveXDistance = realX - drawX;
			moveYDistance = realY - drawY;
			
			//Check x distance
			if(moveXDistance > minMove)
			{
				if(moveXDistance * moveMultiplier > minMove)
				{
					if(moveXDistance > maxMove)
					{
						drawX = realX;
					}
					
					else
					{
						drawX += moveXDistance * moveMultiplier;
					}
				}
				
				else
				{
					drawX += minMove;
				}
			}
			
			else if(moveXDistance < minMove * -1)
			{
				if(moveXDistance * moveMultiplier < minMove * -1)
				{
					if(moveXDistance < maxMove * -1)
					{
						drawX = realX;
					}
					
					else
					{
						drawX += moveXDistance * moveMultiplier;
					}
				}
				
				else
				{
					drawX -= minMove;
				}
			}
			
			else
			{
				drawX = realX;
			}
				
			//Check y distance
			if(moveYDistance > minMove)
			{
				if(moveYDistance * moveMultiplier > minMove)
				{
					if(moveYDistance > maxMove)
					{
						drawY = realY;
					}
					
					else
					{
						drawY += moveYDistance * moveMultiplier;
					}
				}
				
				else
				{
					drawY += minMove;
				}
			}
			
			else if(moveYDistance < minMove * -1)
			{
				if(moveYDistance * moveMultiplier < minMove * -1)
				{
					if(moveYDistance < maxMove * -1)
					{
						drawY = realY;
					}
					
					else
					{
						drawY += moveYDistance * moveMultiplier;
					}
				}
				
				else
				{
					drawY -= minMove;
				}
			}
			
			else
			{
				drawY = realY;
			}
		}
		
		//Normal Movement
		else
		{
			if(physicsMode > 0)
			{
				drawX = realX;
				drawY = realY;
			}
			
			else
			{
				var p = body.getPosition();
				
				drawX = p.x * Engine.physicsScale;
				drawY = p.y * Engine.physicsScale;
			}
		}
		
		var trueScaleX:Float = Engine.SCALE * realScaleX;
		var trueScaleY:Float = Engine.SCALE * realScaleY;
		
		transformPoint.x = currOrigin.x - (cacheWidth*Engine.SCALE) / 2;
		transformPoint.y = currOrigin.y - (cacheHeight*Engine.SCALE) / 2;

		transformMatrix.identity();
		transformMatrix.translate( -transformPoint.x * Engine.SCALE, -transformPoint.y * Engine.SCALE);
		transformMatrix.scale(realScaleX, realScaleY);
		
		if(realAngle != 0)
		{
			transformMatrix.rotate(realAngle * Utils.RAD);
		}
		
		if (scripts.MyAssets.pixelsnap)
		{
			transformMatrix.translate(Math.round(drawX) * Engine.SCALE, Math.round(drawY) * Engine.SCALE);
		}
		
		else
		{
			transformMatrix.translate(drawX * Engine.SCALE, drawY * Engine.SCALE);
		}
		
						
		if(transformObj == null)
		{
			transformObj = transform;
		}
		
		transformObj.matrix = transformMatrix;		
		
		//Temp until jeash handles on their end?
		//#if js
		//currAnimation.__invalidateMatrix();
		//#end
	}
	
	private function updateTweenProperties()
	{		
		//Since we can't tween directly on the Box2D values and can't make direct function calls,
		//we have to reverse the normal flow of information from body -> NME to tween -> body
		var a:Bool = activePositionTweens > 0;
		var b:Bool = activeAngleTweens > 0;
				
		if(autoScale && physicsMode == 0 && body != null && bodyDef.type != B2Body.b2_staticBody && (bodyScale.x != realScaleX || bodyScale.y != realScaleY))
		{			
			if(realScaleX != 0 && realScaleY != 0)
			{
				scaleBody(realScaleX, realScaleY);
			}
		}
		
		if(a && b)
		{					
			if(physicsMode == 0)
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
				if(physicsMode == 0)
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

				var horiChange:Bool = (bodyScale.x > 0 && width < 0) || (bodyScale.x < 0 && width > 0);
				var vertChange:Bool = (bodyScale.y > 0 && height < 0) || (bodyScale.y < 0 && height > 0);
				
				for (v in verts)
				{
					v.subtract(center);
					v.x = v.x * (1 / Math.abs(bodyScale.x)) * Math.abs(width);
					v.y = v.y * (1 / Math.abs(bodyScale.y)) * Math.abs(height);	
					
					if (horiChange)
					{
						v.x = -v.x;
					}
					
					if (vertChange)
					{
						v.y = -v.y;
					}
					
					var newVert:B2Vec2 = center.copy();
					newVert.add(v);

					newVerts.push(newVert);
				}
				
				if (!(horiChange && vertChange) && (horiChange || vertChange))
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
					//need to update points for pre-existing contacts.

					var d:Collision = collisions.get(key);
					d.points = [];
					
					p.getWorldManifold(manifold);

					for (point in manifold.m_points)
					{
						if (point.x != 0 && point.y != 0)
						{
							d.points.push(new CollisionPoint
							(
								point.x, 
								point.y, 
								manifold.m_normal.x,
								manifold.m_normal.y
							));
						}
					}

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
				
				var pt = null;
				var cp:CollisionPoint;

				collisions.set(key, d);
				collisionsCount++;
				
				var thisActor:Actor = this;
				var body = thisActor.getBody();	
				var otherBody = otherActor.getBody();	
				var body1 = p.getFixtureA().getBody();
				var body2 = p.getFixtureB().getBody();

				//loop over all points in manifold.m_points
				for (point in manifold.m_points)
				{
					//ignore the point if it is (0,0)
					if (point.x != 0 && point.y != 0)
					{
						pt = point;

						cp = new CollisionPoint
						(
							pt.x, 
							pt.y, 
							manifold.m_normal.x,
							manifold.m_normal.y
						);				

						d.points.push(cp);
						
						if(body1 == body)
						{
							d.thisFromBottom = d.thisFromBottom || cp.normalY > 0;
							d.thisFromTop = d.thisFromTop || cp.normalY < 0;
							d.thisFromLeft = d.thisFromLeft || cp.normalX < 0;
							d.thisFromRight = d.thisFromRight || cp.normalX > 0;
						}
						
						else if(body2 == body)
						{
							d.thisFromBottom = d.thisFromBottom || cp.normalY < 0;
							d.thisFromTop = d.thisFromTop || cp.normalY > 0;
							d.thisFromLeft = d.thisFromLeft || cp.normalX > 0;
							d.thisFromRight = d.thisFromRight || cp.normalX < 0;
						}
				
						//---
						
						if(body1 == otherBody)
						{
							d.otherFromBottom = d.otherFromBottom || cp.normalY > 0;
							d.otherFromTop = d.otherFromTop || cp.normalY < 0;
							d.otherFromLeft = d.otherFromLeft || cp.normalX < 0;
							d.otherFromRight = d.otherFromRight || cp.normalX > 0;
						}
						
						else if(body2 == otherBody)
						{
							d.otherFromBottom = d.otherFromBottom || cp.normalY < 0;
							d.otherFromTop = d.otherFromTop || cp.normalY > 0;
							d.otherFromLeft = d.otherFromLeft || cp.normalX > 0;
							d.otherFromRight = d.otherFromRight || cp.normalX < 0;
						}
				
						//---
						
						if(otherActor != null)
						{
							d.thisCollidedWithActor = d.thisCollidedWithActor || (otherActor.groupID != 1 && otherActor.groupID != -2 && !otherActor.isTerrainRegion);					
							d.thisCollidedWithTerrain = d.thisCollidedWithTerrain || otherActor.isTerrainRegion;			
							d.thisCollidedWithTile = d.thisCollidedWithTile || otherActor.groupID == 1;
						}
						
						d.otherCollidedWithActor = d.otherCollidedWithActor || (this.groupID != 1 && this.groupID != -2 && !this.isTerrainRegion);					
						d.otherCollidedWithTerrain = d.otherCollidedWithTerrain || this.isTerrainRegion;			
						d.otherCollidedWithTile = d.otherCollidedWithTile || this.groupID == 1;
						
						d.thisCollidedWithSensor = d.thisCollidedWithSensor || otherShape.isSensor();
						d.otherCollidedWithSensor = d.otherCollidedWithSensor || thisShape.isSensor();		
					}
				}
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
			
			if(collisions.clr(point.key))
			{
				collisionsCount--;
			}
		}
	}
	
	public inline function removeContact(point:B2Contact)
	{
		if(collisions != null)
		{
			if(collisions.clr(point.key))
			{
				collisionsCount--;
			}
		}
		
		if(contacts != null)
		{
			if(contacts.clr(point.key))
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
			regionContacts.clr(point.key);
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
		if(physicsMode > 0)
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
		return engine.layers.get(layerID).order;
		//getOrderForLayerID(layerID) + 1; WHY plus one??
	}
	
	public function getType():ActorType
	{
		if(typeID == -1)
		{
			return null;
		}
		
		var result = Data.get().resources.get(typeID);
		
		if(Std.is(result, ActorType))
		{
			return cast(result, ActorType);
		}
		
		return null;
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
			
			if(physicsMode == 0)
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
			
			if(physicsMode == 0)
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
	
	public function moveToLayer(layerRefType:Int, layerRef:String)
	{
		if(!isHUD)
		{
			engine.moveToLayer(this, layerRefType, layerRef);
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
	
	public function moveToBottom()
	{
		this.parent.setChildIndex(this, 0);
	}
	
	public function moveToTop()
	{
		this.parent.setChildIndex(this, this.parent.numChildren-1);
	}
	
	public function moveDown()
	{
		var index:Int = this.parent.getChildIndex(this);
		if (index > 0)
		{
			this.parent.setChildIndex(this, index-1);
		}
	}
	
	public function moveUp()
	{
		var index:Int = this.parent.getChildIndex(this);
		var max:Int = this.parent.numChildren-1;
		if (index < max)
		{
			this.parent.setChildIndex(this, index+1);
		}
	}
	
	public function getZIndex():Int
	{
		return this.parent.getChildIndex(this);
	}
	
	public function setZIndex(zindex:Int)
	{
		var max:Int = this.parent.numChildren-1;
		if (zindex > max)
		{
			zindex = max;
		}
		if (zindex < 0)
		{
			zindex = 0;
		}
		this.parent.setChildIndex(this, zindex);
	}
	
	//*-----------------------------------------------
	//* Physics: Position
	//*-----------------------------------------------
	
	public function enableSmoothMotion()
	{
		smoothMove = true;
	}
	
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
			
			else if(physicsMode == 0)
			{
				toReturn = body.getPosition().x * Engine.physicsScale - Math.floor(cacheWidth / 2) - currOffset.x;
			}
		}
		
		if (Engine.NO_PHYSICS || physicsMode > 0)
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
			
			else if(physicsMode == 0)
			{
				toReturn = body.getPosition().y * Engine.physicsScale - Math.floor(cacheHeight / 2) - currOffset.y;
			}
		}
		
		if (Engine.NO_PHYSICS || physicsMode > 0)
		{
			toReturn = realY - Math.floor(cacheHeight / 2) - currOffset.y;
		}
		
		return round ? Math.round(toReturn) : toReturn;
	}
	
	//TODO: Eliminate?
	public function getXCenter():Float
	{
		if(physicsMode == 0)
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
		if(physicsMode == 0)
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
			return getX(true);
		}
		
		else
		{
			return getX(true) + Engine.cameraX / Engine.SCALE;
		}
	}
	
	public function getScreenY():Float
	{
		if(isHUD)
		{
			return getY(true);
		}
			
		else
		{
			return getY(true) + Engine.cameraY / Engine.SCALE;
		}
	}
	
	public function setX(x:Float, resetSpeed:Bool = false, noCollision:Bool = false)
	{	
		if(physicsMode == 1)
		{
			moveActorTo(x + Math.floor(cacheWidth/2) + currOffset.x, realY, !noCollision && continuousCollision ? groupsToCollideWith: null);
		}
		
		else if(physicsMode == 2)
		{
			resetReal(x + Math.floor(cacheWidth/2) + currOffset.x, realY);
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
		
		if (snapOnSet)
		{
			drawX = realX;
			drawY = realY;
		}
		
		updateMatrix = true;
	}
	
	public function setY(y:Float, resetSpeed:Bool = false, noCollision:Bool = false)
	{		
		if(physicsMode == 1)
		{
			moveActorTo(realX, y + Math.floor(cacheHeight/2) + currOffset.y, !noCollision && continuousCollision ? groupsToCollideWith : null);
		}
		
		else if(physicsMode == 2)
		{
			resetReal(realX, y + Math.floor(cacheHeight/2) + currOffset.y);
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
		
		if (snapOnSet)
		{
			drawX = realX;
			drawY = realY;
		}
		
		updateMatrix = true;
	}
	
	public function follow(a:Actor)
	{
		if(a == null)
		{
			return;
		}
	
		if(physicsMode > 0)
		{
			moveActorTo(a.getXCenter(), a.getYCenter());	
			return;
		}
		
		body.setPosition(a.body.getWorldCenter());
	}
	
	public function followWithOffset(a:Actor, ox:Int, oy:Int)
	{
		if(physicsMode > 0)
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
		
		if (physicsMode == 0)
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
		
		if(physicsMode == 0)
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
		if(physicsMode > 0)
		{
			return xSpeed;
		}
		
		return body.getLinearVelocity().x;
	}
	
	public function getYVelocity():Float
	{
		if(physicsMode > 0)
		{
			return ySpeed;
		}
		
		return body.getLinearVelocity().y;
	}
	
	public function setXVelocity(dx:Float)
	{
		if(physicsMode > 0)
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
		if(physicsMode > 0)
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
		if(physicsMode > 0)
		{
			return Utils.RAD * realAngle;
		}
		
		return body.getAngle();
	}
	
	public function getAngleInDegrees():Float
	{
		if(physicsMode > 0)
		{
			return realAngle;
		}
		
		return Utils.DEG * body.getAngle();
	}
	
	public function setAngle(angle:Float, inRadians:Bool = true)
	{
		if(inRadians)
		{
			if(physicsMode > 0)
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
			if(physicsMode > 0)
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
			if(physicsMode > 0)
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
			if(physicsMode > 0)
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
		if(physicsMode > 0)
		{
			return Utils.RAD * rSpeed;
		}
		
		return body.getAngularVelocity();
	}
	
	public function setAngularVelocity(omega:Float)
	{
		if(physicsMode > 0)
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
		if(physicsMode > 0)
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
		if(physicsMode > 0)
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
		dummy.multiply(magnitude);
		
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
		if(physicsMode > 0)
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
		dummy.multiply(magnitude);
		
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
		if(physicsMode > 0)
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
	
	public function enableRotation()
	{
		if(physicsMode > 0)
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
		if(physicsMode > 0)
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
	
		if(physicsMode == 0)
		{
			body.setIgnoreGravity(state);
		}
	}
	
	public function ignoresGravity():Bool
	{
		if(physicsMode > 0)
		{
			return ignoreGravity;
		}
		
		return body.isIgnoringGravity();
	}
	
	public function getFriction():Float
	{
		if (physicsMode == 0 && body.m_fixtureList != null)
		{
			return body.m_fixtureList.m_friction;
		}
		
		return 0;
	}
	
	public function getBounciness():Float
	{
		if (physicsMode == 0 && body.m_fixtureList != null)
		{
			return body.m_fixtureList.m_restitution;
		}
		
		return 0;
	}
	
	public function getMass():Float
	{
		if (physicsMode == 0)
		{
			return md.mass;
		}
		
		return 0;
	}
	
	public function getAngularMass():Float
	{
		if (physicsMode == 0)
		{
			return md.I;
		}
		
		return 0;
	}
	
	public function getLinearDamping():Float
	{
		if (physicsMode == 0)
		{
			return body.getLinearDamping();
		}
		
		return 0;
	}
	
	public function getAngularDamping():Float
	{
		if (physicsMode == 0)
		{
			return body.getAngularDamping();
		}
		
		return 0;
	}
	
	public function setFriction(value:Float)
	{
		if(physicsMode == 0)
		{
			body.setFriction(value);
		}
	}
	
	public function setBounciness(value:Float)
	{
		if(physicsMode == 0)
		{
			body.setBounciness(value);
		}
	}
	
	public function setMass(newMass:Float)
	{
		if (physicsMode == 0)
		{
			md.mass = newMass;
			body.setMassData(this.md);
		}
	}
	
	public function setAngularMass(newAMass:Float)
	{
		if (physicsMode == 0)
		{
			md.I = newAMass;
			body.setMassData(this.md);
		}
	}
	
	public function setLinearDamping(newDamping:Float)
	{
		if (physicsMode == 0)
		{
			body.setLinearDamping(newDamping);
		}
	}
	
	public function setAngularDamping(newDamping:Float)
	{
		if (physicsMode == 0)
		{
			body.setAngularDamping(newDamping);
		}
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
			mx = Input.mouseX / Engine.SCALE;
		 	my = Input.mouseY / Engine.SCALE;
		}
		
		else
		{
			mx = (Input.mouseX - Engine.cameraX) / Engine.SCALE;
		 	my = (Input.mouseY - Engine.cameraY) / Engine.SCALE;
		}
		
		//TODO: Mike - Make this work with arbitrary origin points
		//The problem was that mouse detect was off for higher scales
		//and would only work within the centered, original bounds.
		var offsetX = (scaleX - 1) * Math.floor(cacheWidth/2);
		var offsetY = (scaleY - 1) * Math.floor(cacheHeight/2);
		
		var xPos = colX - offsetX;
		var yPos = colY - offsetY;

		if(rotation != 0)
		{
			// Imagine a circle with the actor's origin point as the center and the mouse position somewhere on the circle.
			// If the circle is rotated by the actor's direction, then the mouse's new position can be compared with the actor's original bounding box.
			var actorOriginX:Float = xPos + currOrigin.x;
			var actorOriginY:Float = yPos + currOrigin.y;
			var xFromOrigin:Float = mx - actorOriginX;
			var yFromOrigin:Float = my - actorOriginY;
			var rotationRadians:Float = Utils.RAD * rotation;
			var mxNew:Float = actorOriginX + (xFromOrigin * Math.cos(rotationRadians)) + (yFromOrigin * Math.sin(rotationRadians));
			var myNew:Float = actorOriginY - (xFromOrigin * Math.sin(rotationRadians)) + (yFromOrigin * Math.cos(rotationRadians));
			mx = mxNew;
			my = myNew;
		}

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
		Actuate.stop(this, ["alpha", "realScaleX", "realScaleY"], false, false);		

		Actuate.stop(tweenAngle, null, false, false);
		Actuate.stop(tweenLoc, null, false, false);
		
		activePositionTweens = 0;
		activeAngleTweens = 0;
		
		Actuate.unloadForTarget(this);
		Actuate.unloadForTarget(tweenAngle);
		Actuate.unloadForTarget(tweenLoc);
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
		updateTweenProperties();
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
			
			#if (cpp || neko)
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
			
			cast(currAnimation, AbstractAnimation).draw(g, x, y, realAngle * Utils.RAD, g.alpha);
		}
	}
	
	public function getCurrentImage()
	{
		return cast(currAnimation, AbstractAnimation).getCurrentImage();
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

	#if (flash)
	public function setFilter(filter:Array<BitmapFilter>)
	{			
		filters = filters.concat(filter);
	}
	#end
	
	#if js
	public function setFilter(filter:Array<ColorMatrixFilter>)
	{
		var matrix:Array<Float> = cast(filter[0].matrix);
		
		if (!animsBackedUp)
		{
			backupAnimationMap = new Map<String,BitmapData>();
		
			for (key in animationMap.keys())
			{
				var anim = animationMap.get(key);
				backupAnimationMap.set(key, anim.sheet.clone());
			}
			animsBackedUp = true;
		}
			
		for (key in animationMap.keys())
		{
			var anim = animationMap.get(key);
			var bd:BitmapData = anim.sheet.clone();
			
			bd.applyFilter(
				bd,
				bd.rect,
				new Point(0, 0),
				new ColorMatrixFilter(matrix)
			);
			anim.sheet = bd.clone();
			anim.updateBitmap();
		}
	}
	#end
	
	
	#if (cpp || neko)
	public function setFilter(filter:Array<Array<Dynamic>>)
	{	
		var filterName:String;
		var i:Int;
		var srcA:Int;
		var srcR:Int;
		var srcG:Int;
		var srcB:Int;
		var redResult:Float;
		var greenResult:Float;
		var blueResult:Float;
		
		// Stencyl adds the result of the filter blocks into an array, so for cpp targets it must be taken out.
		var defaultMatrix:Array<Dynamic> = filter[0];
		
		filterName = defaultMatrix[0];
		
		if (filterName != "TintFilter")
		{
			// Backup the default animations so the filters can be undone later.
			if (!animsBackedUp)
			{
				backupAnimationMap = new Map<String,BitmapData>();
			
				for (key in animationMap.keys())
				{
					var anim = animationMap.get(key);
					
					if (Type.getClass(anim) == SheetAnimation)
					{
						backupAnimationMap.set(key, anim.getBitmap().clone());
						
						var frameWidth = anim.frameWidth;
						var frameHeight = anim.frameHeight;
						var tempData:BitmapData = anim.getBitmap().clone();
						var tempTilesheet = new Tilesheet(tempData);
						
						var i = 0;
						
						while (i < anim.numFrames)
						{
							tempTilesheet.addTileRect(new openfl.geom.Rectangle(frameWidth * (i % anim.framesAcross), Math.floor(i / anim.framesAcross) * frameHeight, frameWidth, frameHeight));
							i++;
						}
						
						anim.tilesheet = tempTilesheet;
						anim.updateBitmap();
					}
				}
				animsBackedUp = true;
			}
		}
		
		if (filterName == "NegativeFilter")
		{
			for (anim in animationMap)
			{
				if (Type.getClass(anim) == SheetAnimation)
				{
					var imageData:BitmapData = anim.getBitmap();
					var byteArray:ByteArray = imageData.getPixels(imageData.rect);
					var len:Int = byteArray.length;
					// Using the Memory class with a ByteArray slightly increases performance.
					Memory.select(byteArray);

					i = 0;
					while (i < len)
					{
						srcA = Memory.getByte(i);
						if (srcA == 0)
						{
							// Ignore pixels with full transparency.
							i = i + 4;
							continue;
						}

						srcR = Memory.getByte(i + 1);
						srcG = Memory.getByte(i + 2);
						srcB = Memory.getByte(i + 3);
					
						Memory.setByte((i + 1), (255 - srcR));
						Memory.setByte((i + 2), (255 - srcG));
						Memory.setByte((i + 3), (255 - srcB));

						i = i + 4;
					}

					// Not setting the ByteArray position back to 0 will result in an end-of-file error.
					byteArray.position = 0;
				
					imageData.setPixels(imageData.rect, byteArray);
				}

			}
		}
		else if (filterName == "TintFilter")
		{
			tint = true;
			
			for (anim in animationMap)
			{
				if (Type.getClass(anim) == SheetAnimation)
				{
					// The tint filter uses drawTiles for much better performance.
					anim.tint = true;
					var tintAmount:Float = 1 - defaultMatrix[4];
					anim.redValue   = Math.min((defaultMatrix[1] + tintAmount), 1);
					anim.greenValue = Math.min((defaultMatrix[2] + tintAmount), 1);
					anim.blueValue  = Math.min((defaultMatrix[3] + tintAmount), 1);
					anim.updateBitmap();
				}
			}
		}
		else if (filterName == "GrayscaleFilter")
		{
			for (anim in animationMap)
			{
				if (Type.getClass(anim) == SheetAnimation)
				{
					var imageData:BitmapData = anim.getBitmap();
					var byteArray:ByteArray = imageData.getPixels(imageData.rect);
					var len:Int = byteArray.length;
					var greyResult:Int;
					// Using the Memory class with a ByteArray slightly increases performance.
					Memory.select(byteArray);

					i = 0;
					while (i < len)
					{
						srcA = Memory.getByte(i);
						if (srcA == 0)
						{
							// Ignore pixels with full transparency.
							i = i + 4;
							continue;
						}

						srcR = Memory.getByte(i + 1);
						srcG = Memory.getByte(i + 2);
						srcB = Memory.getByte(i + 3);
						
						// All color values are the same in greyscale, so just calculate one.
						greyResult = Std.int((srcR * 0.5) + (srcG * 0.5) + (srcB * 0.5));

						if (greyResult > 254)
						{
							greyResult = 255;
						}
						else if (greyResult < 1)
						{
							greyResult = 0;
						}

						Memory.setByte((i + 1), greyResult);
						Memory.setByte((i + 2), greyResult);
						Memory.setByte((i + 3), greyResult);
						
						i = i + 4;
					}

					// Not setting the ByteArray position back to 0 will result in an end-of-file error.
					byteArray.position = 0;
				
					imageData.setPixels(imageData.rect, byteArray);
				}
			}
		}
		else
		{
			// Take 12 values from the original array, ignoring alpha since no Stencyl filters change it.
			var matrix = new Array<Float>();
			matrix[0]  = defaultMatrix[1];
			matrix[1]  = defaultMatrix[2];
			matrix[2]  = defaultMatrix[3];
			matrix[3]  = defaultMatrix[5];
			matrix[4]  = defaultMatrix[6];
			matrix[5]  = defaultMatrix[7];
			matrix[6]  = defaultMatrix[8];
			matrix[7]  = defaultMatrix[10];
			matrix[8]  = defaultMatrix[11];
			matrix[9]  = defaultMatrix[12];
			matrix[10] = defaultMatrix[13];
			matrix[11] = defaultMatrix[15];
			
			for (anim in animationMap)
			{
				if (Type.getClass(anim) == SheetAnimation)
				{
					var imageData:BitmapData = anim.getBitmap();
					var byteArray:ByteArray = imageData.getPixels(imageData.rect);
					var len:Int = byteArray.length;
					
					// Using the Memory class with a ByteArray slightly increases performance.
					Memory.select(byteArray);

					i = 0;
					while (i < len)
					{
						srcA = Memory.getByte(i);
						if (srcA == 0)
						{
							// Ignore pixels with full transparency.
							i = i + 4;
							continue;
						}

						srcR = Memory.getByte(i + 1);
						srcG = Memory.getByte(i + 2);
						srcB = Memory.getByte(i + 3);

						redResult = ((matrix[0] * srcR) + (matrix[1] * srcG) + (matrix[2]  * srcB) + matrix[3]);
						if (redResult > 254)
						{
							Memory.setByte((i + 1), 255);
						}
						else if (redResult < 1)
						{
							Memory.setByte((i + 1), 0);
						}
						else
						{
							Memory.setByte((i + 1), Std.int(redResult));
						}
					
						greenResult = ((matrix[4] * srcR) + (matrix[5] * srcG) + (matrix[6]  * srcB) + matrix[7]);
						if (greenResult > 254)
						{
							Memory.setByte((i + 2), 255);
						}
						else if (greenResult < 1)
						{
							Memory.setByte((i + 2), 0);
						}
						else
						{
							Memory.setByte((i + 2), Std.int(greenResult));
						}
					
						blueResult = ((matrix[8] * srcR) + (matrix[9] * srcG) + (matrix[10] * srcB) + matrix[11]);
						if (blueResult > 254)
						{
							Memory.setByte((i + 3), 255);
						}
						else if (blueResult < 1)
						{
							Memory.setByte((i + 3), 0);
						}
						else
						{
							Memory.setByte((i + 3), Std.int(blueResult));
						}
					
						i = i + 4;
					}

					// Not setting the ByteArray position back to 0 will result in an end-of-file error.
					byteArray.position = 0;
				
					imageData.setPixels(imageData.rect, byteArray);
				}
			}
		}
	}
	#end
	
	public function clearFilters()
	{
		#if (flash)
		filters = [];
		#end
		
		#if js
		if (animsBackedUp)
		{
			//var pt:Point = new Point(0,0);
			
			for (key in backupAnimationMap.keys())
			{
				var imageData = backupAnimationMap.get(key);
				var sheetValue = animationMap.get(key);
				sheetValue.sheet = imageData.clone();
				//sheetValue.tint = false;
				sheetValue.updateBitmap();
			}	
			animsBackedUp = false;
		}
		#end
		
		#if (cpp || neko)
		if (animsBackedUp)
		{
			var pt:Point = new Point(0,0);
			
			for (key in backupAnimationMap.keys())
			{
				var imageData = backupAnimationMap.get(key);
				var sheetValue = animationMap.get(key);
				sheetValue.getBitmap().copyPixels(imageData, imageData.rect, pt);
				sheetValue.tint = false;
				sheetValue.updateBitmap();
			}	
		}
		else if (tint)
		{
			for (anim in animationMap)
			{
				if (Type.getClass(anim) == SheetAnimation)
				{
					anim.tint = false;
					anim.updateBitmap();
				}
			}
		}
		#end
		
		#if js
			// clearFilters() is not implemented for HTML5.
		#end
	}
	
	public function setBlendMode(blendName:Dynamic)
	{
		#if (cpp || neko)
		for (anim in animationMap)
		{
			if (Type.getClass(anim) == SheetAnimation)
			{
				anim.blendName = blendName;
				anim.updateBitmap();
			}
		}
		#else
		blendMode = blendName;
		#end
	}
	
	public function resetBlendMode()
	{
		#if (cpp || neko)
		for (anim in animationMap)
		{
			if (Type.getClass(anim) == SheetAnimation)
			{
				anim.blendName = "NORMAL";
				anim.updateBitmap();
			}
		}
		#end
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
		if(physicsMode == 0)
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
		if(physicsMode == 0)
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
		if (!alwaysSimulate)
		{
			if(physicsMode == 0 && alterBody)
			{
				body.setAlwaysActive(true);
			}
			
			alwaysSimulate = true;			
			engine.addHUDActor(this);
		}
	}
	
	public function makeSometimesSimulate(alterBody:Bool = true)
	{
		if (alwaysSimulate)
		{
			if(physicsMode == 0 && alterBody)
			{
				body.setAlwaysActive(false);
			}
			
			alwaysSimulate = false;			
			engine.removeHUDActor(this);
		}
	}
	
	public function alwaysSimulates():Bool
	{
		return alwaysSimulate;
	}
	
	public function die()
	{
		dying = true;
		
		var a = engine.whenTypeGroupDiesListeners.get(getType());
		var b = engine.whenTypeGroupDiesListeners.get(getGroup());
	
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
	
		return (physicsMode > 0 || body.isActive()) && 
			   getX(true) >= -cameraX - left && 
			   getY(true) >= -cameraY - top &&
			   getX(true) < -cameraX + Engine.screenWidth + right &&
			   getY(true) < -cameraY + Engine.screenHeight + bottom;
	}
	
	public function isInScene():Bool
	{
		return (physicsMode > 0 || body.isActive()) && 
			   getX(true) >= 0 && 
			   getY(true) >= 0 &&
			   getX(true) < Engine.sceneWidth &&
			   getY(true) < Engine.sceneHeight;
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
	
	public static function scaleShape(shape:B2Shape, center:B2Vec2, factor:Float)
	{
		if(Std.is(shape, B2CircleShape))
		{
			var circle:B2CircleShape = cast(shape, B2CircleShape);
			
			circle.m_radius *= factor;
		}
		
		else if(Std.is(shape, B2PolygonShape))
		{
			var polygon:B2PolygonShape = cast(shape, B2PolygonShape);
			var vertices:Array<B2Vec2> = polygon.m_vertices;
			var newVertices:Array<B2Vec2> = new Array<B2Vec2>();
			
			for (v in vertices)
			{
				v.subtract(center);
				v.multiply(factor);
				v.add(center);
				newVertices.push(v);
			}
			
			polygon.setAsArray(newVertices);
		}
	}
	
	public function addRectangularShape(x:Float, y:Float, w:Float, h:Float)
	{
		if (physicsMode == 0)
		{
			var polygon:B2PolygonShape = new B2PolygonShape();
			var vertices:Array<B2Vec2> = new Array<B2Vec2>();
			x = Engine.toPhysicalUnits(x - Math.floor(cacheWidth / 2) - currOffset.x);
			y = Engine.toPhysicalUnits(y - Math.floor(cacheHeight / 2) - currOffset.y);
			w = Engine.toPhysicalUnits(w);
			h = Engine.toPhysicalUnits(h);
			vertices.push(new B2Vec2(x, y));
			vertices.push(new B2Vec2(x + w, y));
			vertices.push(new B2Vec2(x + w, y + h));
			vertices.push(new B2Vec2(x, y + h));
			polygon.setAsVector(vertices);
			var fixture:B2Fixture = this.getBody().createFixture2(polygon, 1);
			fixture.SetUserData(this);
		}
	}
	
	public function addCircularShape(x:Float, y:Float, r:Float)
	{
		if (physicsMode == 0)
		{
			var circle:B2CircleShape = new B2CircleShape();
			circle.m_radius = Engine.toPhysicalUnits(r);
			circle.m_p.x = Engine.toPhysicalUnits(x);
			circle.m_p.y = Engine.toPhysicalUnits(y);
			var fixture:B2Fixture = this.getBody().createFixture2(circle, 1);
			fixture.SetUserData(this);
		}
	}
	
	public function addVertex(vertices:Array<B2Vec2>, x:Float, y:Float)
	{
		x = Engine.toPhysicalUnits(x - Math.floor(cacheWidth / 2) - currOffset.x);
		y = Engine.toPhysicalUnits(y - Math.floor(cacheHeight / 2) - currOffset.y);
		vertices.push(new B2Vec2(x, y));
	}
	
	public function addPolygonalShape(vertices:Array<B2Vec2>)
	{
		if (physicsMode == 0)
		{
			var polygon:B2PolygonShape = new B2PolygonShape();
			/*var newVertices:Array<B2Vec2> = new Array<B2Vec2>();
			for (v in vertices)
			{
				v.subtract(new B2Vec2(getPhysicsWidth()/2, getPhysicsHeight()/2));
				newVertices.push(v);
			}
			polygon.setAsArray(newVertices);*/
			polygon.setAsArray(vertices);
			var fixture:B2Fixture = this.getBody().createFixture2(polygon, 1);
			fixture.SetUserData(this);
		}
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
	public var shape(get_shape, set_shape):Mask;
	private inline function get_shape():Mask { return _mask; }
	private function set_shape(value:Mask):Mask
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
						colMask = e._mask;
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
					colMask = (e._mask != null ? e._mask : e.HITBOX);
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
		var cc:Int = collidedList.length;
		
		//Mike: Do we need this?
		if (Std.is(types, String))
		{
			collideInto(types, x, y, collidedList);
			
			if (collidedList.length > cc)
			{
				return collidedList[collidedList.length - 1];
			}
		}
		else
		{			
			var a:Array<Int> = HITBOX.collideTypes;
			if (a != null)
			{
				var e:Actor;
				var type:Int;
				for (type in a)
				{
					if (type == GameModel.REGION_ID) continue;
					
					collideInto(type, x, y, collidedList);
				}
				
				if (collidedList.length > cc)
				{					
					return collidedList[collidedList.length - 1];
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
					if (e._mask == null || e._mask.collide(HITBOX)) 
					{
						if (!Utils.contains(array, e))
						{
							array[n++] = e;
						}
					}
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
				if (_mask.collide(e._mask != null ? e._mask : e.HITBOX)) 
				{
					if (!Utils.contains(array, e))
					{
						array[n++] = e;
					}
				}
			};
		}
		resetReal(_x, _y);
		return;
	}
	
	public function clearCollisionInfoList()
	{
		if (collisionsCount > 0)
		{
			for(info in simpleCollisions) 
			{
				info.remove = true;		
				
				if (info.linkedCollision != null)
				{
					info.linkedCollision.remove = true;
				}
			}
		}	
	}
	
	private function clearCollidedList()
	{
		while (collidedList.length > 0)
		{
			collidedList.pop();
		}
		
		listChecked = 0;
	}
	
	public function addCollision(info:Collision):Collision
	{
		var check:Int;
		
		if ((check = alreadyCollided(info.maskA, info.maskB)) != -1) {			
			var oldInfo:Collision = simpleCollisions.get(check);
			
			info.switchData(oldInfo.linkedCollision);
			info.linkedCollision.remove = false;
			info.remove = false;
			
			Collision.recycle(oldInfo);
			
			simpleCollisions.clr(check);
			simpleCollisions.set(check, info);
			
			return info;
		}
		
		simpleCollisions.clr(collisionsCount);
		simpleCollisions.set(collisionsCount, info);
		collisionsCount++;		
		
		return info;
	}
	
	public function alreadyCollided(maskA:Mask, maskB:Mask):Int
	{
		for (key in simpleCollisions.keys())
		{
			var info:Collision = simpleCollisions.get(key);
			
			if (info != null && ((info.maskA == maskA && info.maskB == maskB) || (info.maskA == maskB && info.maskB == maskA)))			
			{
				return key;
			}
		}
		
		return -1;
	}
	
	public function resetReal(x:Float, y:Float)
	{
		realX = x; realY = y;
		colX = realX - Math.floor(cacheWidth/2) - currOffset.x;
		colY = realY - Math.floor(cacheHeight / 2) - currOffset.y;
	}
	
	private function adjustByWidth(posDir:Bool):Float
	{
		if (_mask != null && _mask.lastCheckedMask != null)
		{
			if (Std.is(_mask.lastCheckedMask, Hitbox))
			{
				var box:Hitbox = cast(_mask.lastCheckedMask, Hitbox);
				
				if (posDir)
				{
					return (cacheWidth / 2) - (cacheWidth - (box._x + box._width));
				}
				
				return (cacheWidth / 2) - box._x;
			}
		}
		
		return cacheWidth / 2;
	}
	
	private function adjustByHeight(posDir:Bool):Float
	{
		if (_mask != null && _mask.lastCheckedMask != null)
		{
			if (Std.is(_mask.lastCheckedMask, Hitbox))
			{
				var box:Hitbox = cast(_mask.lastCheckedMask, Hitbox);
				
				if (posDir)
				{
					return (cacheHeight / 2) - (cacheHeight - (box._y + box._height));
				}
				
				return (cacheHeight / 2) - box._y;
			}
		}
		
		return cacheHeight/ 2;
	}
	
	private function getAllCollisionInfo(xDir:Float, yDir:Float):Collision
	{		
		var solidCollision:Collision = null;
		
		while (listChecked < collidedList.length)
		{
			var lastCollisionInfo:Collision = Collision.get();
			
			colMask = collidedList[listChecked]._mask;			
			
			fillCollisionInfo(lastCollisionInfo, collidedList[listChecked], xDir, yDir);
			addCollision(lastCollisionInfo);
							
			if (lastCollisionInfo.linkedCollision == null)
			{
				var linked:Collision = Collision.get();
								
				lastCollisionInfo.switchData(linked);
				collidedList[listChecked].addCollision(linked);
			}
			
			if (lastCollisionInfo.solidCollision)
			{
				solidCollision = lastCollisionInfo;
			}
			
			listChecked++;
		}	
		
		return solidCollision;			
	}

	public function moveActorBy(x:Float, y:Float, solidType:Dynamic = null, sweep:Bool = false)
	{
		if (x == 0 && y == 0)
		{
			return;
		}		
		
		clearCollisionInfoList();		
		clearCollidedList();
		
		if (solidType != null)
		{
			var sign:Float, signIncr:Float, next:Float, e:Actor;			
			
			if (x != 0)
			{
				next = x > 0 ? Math.ceil(realX + x) : Math.floor(realX + x);
				
				if (collidable && (sweep || collideTypes(solidType, next, realY) != null))
				{
					clearCollidedList();
					
					while (x != 0)
					{
						signIncr = (x >= 1 || x <= -1) ? 1 : Math.abs(x);
						sign = x > 0 ? signIncr : -signIncr;						
						next = sign > 0 ? Math.ceil(realX + sign) : Math.floor(realX + sign);
						
						//Check regions first
						if ((e = collide(GameModel.REGION_ID, next, realY)) != null)
						{
							cast(e, Region).addActor(this);
						}
						
						if ((e = collideTypes(solidType, next, realY)) != null)
						{							
							var solidCollision:Collision = getAllCollisionInfo(sign, 0);
							
							if (solidCollision != null)
							{
								xSpeed = 0;
								
								if (solidCollision.useBounds)
								{
									if (sign > 0)
									{
										realX = solidCollision.bounds.x - Math.ceil(adjustByWidth(true));
									}
									
									else
									{
										realX = solidCollision.bounds.x + solidCollision.bounds.width + Math.floor(adjustByWidth(false));
									}
								}
								
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
				next = y > 0 ? Math.ceil(realY + y) : Math.floor(realY + y);
				
				clearCollidedList();
				
				if (collidable && (sweep || collideTypes(solidType, realX, next) != null))
				{
					clearCollidedList();
					while (y != 0)
					{
						signIncr = (y >= 1 || y <= -1) ? 1 : Math.abs(y);
						sign = y > 0 ? signIncr : -signIncr;
						next = sign > 0 ? Math.ceil(realY + sign) : Math.floor(realY + sign);
						
						//Check regions first
						if ((e = collide(GameModel.REGION_ID, realX, next)) != null)
						{
							cast(e, Region).addActor(this);
						}
						
						if ((e = collideTypes(solidType, realX, next)) != null)
						{		
							var solidCollision:Collision = getAllCollisionInfo(0, sign);
							
							if (solidCollision != null)
							{
								ySpeed = 0;
								
								
								if (solidCollision.useBounds)
								{
									if (sign > 0)
									{
										realY = solidCollision.bounds.y - Math.ceil(adjustByHeight(true));
									}
									
									else
									{
										realY = solidCollision.bounds.y + solidCollision.bounds.height + Math.floor(adjustByHeight(false));
									}
								}
								
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
	public function moveCollideX(info:Collision, sign:Float)
	{		
	}

	/**
	 * When you collide with an Entity on the y-axis with moveTo() or moveBy().
	 * @param	e		The Entity you collided with.
	 */
	public function moveCollideY(info:Collision, sign:Float)
	{
	}
	
	private function fillCollisionInfo(info:Collision, a:Actor, xDir:Float, yDir:Float)
	{
		if(Std.is(a, Region))
		{
			var region = cast(a, Region);
			region.addActor(this);
			return;
		}
	
		info.thisActor = info.actorA = this;
		info.otherActor = info.actorB = a;
		
		info.maskA = _mask;
		info.maskB = colMask;
		info.solidCollision = _mask.solid && colMask.solid;
		
		info.groupA = _mask.lastCheckedMask.groupID;
		info.groupB = _mask.lastCheckedMask.lastColID;	
		 
		var responseMap:Map<Int, String> = Collision.collisionResponses.get(getGroupID());
		var overrideSensor:Bool = false;
		var overridePhysical:Bool = false;
		
		if (responseMap != null && responseMap.get(a.getGroupID()) != null)
		{
			if (responseMap.get(a.getGroupID()) == "sensor")
			{
				info.solidCollision = false;
				overrideSensor = true;
			}
			
			else 
			{
				info.solidCollision = true;
				overridePhysical = true;
			}
		}
		
		if (colMask != null)
		{			
			info.useBounds = true;
			info.bounds.x = colMask.lastBounds.x;
			info.bounds.y = colMask.lastBounds.y;
			info.bounds.width = colMask.lastBounds.width;
			info.bounds.height = colMask.lastBounds.height;
		}
					
		if(xDir != 0)
		{
			//If tile, have to use travel direction
			if (a.ID == Utils.INTEGER_MAX)
			{
				info.thisFromLeft = xDir < 0;
				info.thisFromRight = xDir > 0;
			}
			else
			{			
				info.thisFromLeft = a.colX < colX;
				info.thisFromRight = a.colX > colX;
			}
			
			info.otherFromLeft = !info.thisFromLeft;
			info.otherFromRight = !info.thisFromRight;
		
			info.thisFromTop = info.otherFromTop = false;
			info.thisFromBottom = info.otherFromBottom = false;
		}
		
		if(yDir != 0)
		{
			//If tile, have to use travel direction
			if (a.ID == Utils.INTEGER_MAX)
			{
				info.thisFromTop = yDir < 0;
				info.thisFromBottom = yDir > 0;
			}
			else
			{			
				info.thisFromTop = a.colY < colY;
				info.thisFromBottom = a.colY > colY;
			}
		
			info.otherFromTop = !info.thisFromTop;
			info.otherFromBottom = !info.thisFromBottom;
		
			info.thisFromLeft = info.otherFromLeft = false;
			info.thisFromRight = info.otherFromRight = false;
		}
		
		//TODO
		info.thisCollidedWithActor = true;
		info.thisCollidedWithTile = a.ID == Utils.INTEGER_MAX;
		
		if(info != null)
		{
			info.thisCollidedWithSensor = overrideSensor || !overridePhysical && !info.maskB.solid;
		}
		
		else
		{
			info.thisCollidedWithSensor = false;
		}
		
		info.thisCollidedWithTerrain = false;
		
		info.otherCollidedWithActor = true;
		info.otherCollidedWithTile = a.ID == Utils.INTEGER_MAX;
		
		if(info != null)
		{
			info.otherCollidedWithSensor = !info.maskA.solid;
		}
		
		else
		{
			info.otherCollidedWithSensor = false;
		}
		
		info.otherCollidedWithTerrain = false;
	}
	
	public function handleCollisionsSimple()
	{
		if (collisionsCount > 0)
		{
			for (info in simpleCollisions)
			{
				if (info == null || info.remove == true) continue;
				
				lastCollided = info.otherActor;
				Engine.invokeListeners2(collisionListeners, info);
				engine.handleCollision(this, info);								
			}
		}
	}
	
	private var HITBOX:Mask;
	private var _mask:Mask;
	private var colMask:Mask;
	private var _x:Float;
	private var _y:Float;
	private var _moveX:Float;
	private var _moveY:Float;
	private var _point:Point;
	private var simpleCollisions:IntHashTable<Collision>;
	private var collidedList:Array<Actor>;
	private var listChecked:Int;
}
