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

import com.stencyl.Input;
import com.stencyl.Engine;

import com.stencyl.graphics.AbstractAnimation;
import com.stencyl.graphics.BitmapAnimation;
import com.stencyl.graphics.SheetAnimation;

import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.BehaviorManager;

import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.AngleHolder;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.scene.ActorInstance;
import com.stencyl.models.actor.Animation;

import com.stencyl.utils.Utils;
import com.stencyl.utils.HashMap;

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

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2MassData;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Transform;


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
	public var type:ActorType;
	
	
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
	
	public var dead:Bool; //gone from the game - don't touch
	public var dying:Bool; //in the process of dying but not yet removed
	

	//*-----------------------------------------------
	//* Position / Motion
	//*-----------------------------------------------
	
	public var realX:Float;
	public var realY:Float;

	public var xSpeed:Float;
	public var ySpeed:Float;
	public var rSpeed:Float;
	
	public var tweenLoc:Point;
	public var tweenAngle:AngleHolder;
	public var activeAngleTweens:Int;
	public var activePositionTweens:Int;
	
	
	//*-----------------------------------------------
	//* Sprite-Based Animation
	//*-----------------------------------------------
	
	public var currAnimation:DisplayObject;
	public var currAnimationName:String;
	public var animationMap:Hash<DisplayObject>;
	
	public var sprite:com.stencyl.models.actor.Sprite;
	
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
	
	public var body:B2Body;
	public var bodyDef:B2BodyDef;
	public var md:B2MassData;
	public var bodyScale:Point;
	
	public var contacts:Hash<B2Contact>;
	public var regionContacts:Hash<B2Contact>;
	public var collisions:Hash<Collision>;
	
	private var dummy:B2Vec2;
	private var zero:B2Vec2;
	

	//*-----------------------------------------------
	//* Collisions
	//*-----------------------------------------------
	
	public var handlesCollisions:Bool; //???
	public var lastCollided:Actor;
	
	
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
		width:Int=32, 
		height:Int=32,
		sprite:com.stencyl.models.actor.Sprite=null,
		behaviorValues:Hash<Dynamic>=null,
		actorType:ActorType=null,
		bodyDef:B2BodyDef=null,
		isSensor:Bool=false,
		isStationary:Bool=false,
		isKinematic:Bool=false,
		canRotate:Bool=false,
		shape:B2Shape=null, //Used only for terrain.
		typeID:Int = 0,
		isLightweight:Bool=false,
		autoScale:Bool=true
	)
	{
		super();
		
		//---
		
		dummy = new B2Vec2();
		zero = new B2Vec2(0, 0);
		
		x = 0;
		y = 0;
		
		realX = 0;
		realY = 0;

		activeAngleTweens = 0;
		activePositionTweens = 0;
		
		//---
		
		tweenLoc = new Point(0, 0);
		tweenAngle = new AngleHolder();
		
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
		
		isCamera = false;
		isRegion = false;
		isTerrainRegion = false;
		drawActor = true;
		
		killLeaveScreen = false;
		alwaysSimulate = false;
		isHUD = false;
		
		handlesCollisions = true;
		lastCollided = null;
		
		//---
		
		resetListeners();
		
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

		//---
		
		behaviors = new BehaviorManager();
		
		//---
		
		currAnimationName = "";
		animationMap = new Hash<DisplayObject>();
		shapeMap = new Hash<Dynamic>();
		originMap = new Hash<Dynamic>();
		
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
		
		//--
		
		addAnim("recyclingDefault", null, 1, 1, 1, 1, 1, [1000], false, []);
			
		if(bodyDef != null && !isLightweight)
		{
			if(bodyDef.bullet)
			{
				B2World.m_continuousPhysics = true;
			}
			
			//Not done yet
			//bodyDef.groupID = groupID;

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
			
			if(Std.is(this, Region))
			{
				isSensor = true;
				canRotate = false;
			}
			
			if(Std.is(this, Terrain))
			{
				canRotate = false;
			}
			
			if(!isLightweight)
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
			if(!isLightweight)
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
		
		whenCreatedListeners = null;
		whenUpdatedListeners = null;
		whenDrawingListeners = null;
		whenKilledListeners = null;
		mouseOverListeners = null;
		positionListeners = null;
		
		registry = null;
		
		collisions = null;
		
		behaviors.destroy();
	}
	
	private function resetListeners()
	{
		allListeners = new HashMap<Dynamic, Dynamic>();
		allListenerReferences = new Array<Dynamic>();
		
		whenCreatedListeners = new Array<Dynamic>();
		whenUpdatedListeners = new Array<Dynamic>();
		whenDrawingListeners = new Array<Dynamic>();
		whenKilledListeners = new Array<Dynamic>();
		mouseOverListeners = new Array<Dynamic>();
		positionListeners = new Array<Dynamic>();
		collisionListeners = new Array<Dynamic>();
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
		if(shapes != null)
		{
			var arr = new Array<B2FixtureDef>();
			
			for(s in shapes)
			{
				arr.push(s);
			}
			
			shapeMap.set(name, arr);
		}
	
		if(imgData == null)
		{
			animationMap.set(name, new Sprite());
			return;
		}
	
		#if cpp
		var tilesheet = new Tilesheet(imgData);
		
		for(i in 0...frameCount)
		{
			tilesheet.addTileRect(new nme.geom.Rectangle(frameWidth * i, 0, frameWidth, frameHeight)); 	
		}
		 	
		var sprite = new SheetAnimation(tilesheet, durations, frameWidth, frameHeight);
		animationMap.set(name, sprite);
		#end
		
		#if (flash || js)
		var sprite = new BitmapAnimation(imgData, frameCount, durations);
		animationMap.set(name, sprite);
		#end	
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

	private function initBody(groupID:Int, isSensor:Bool, isStationary:Bool, isKinematic:Bool, canRotate:Bool, shape:B2Shape)
	{			
		var bodyDef:B2BodyDef = new B2BodyDef();
		
		//bodyDef.groupID = groupID;
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

		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = shape;
		fixtureDef.friction = 1.0;
		fixtureDef.density = 0.1;
		fixtureDef.restitution = 0;
		fixtureDef.isSensor = isSensor;
		//fixtureDef.groupID = -1000;
		fixtureDef.userData = this;
					
		bodyDef.userData = this;
		body = Engine.engine.world.createBody(bodyDef);			
		body.createFixture(fixtureDef);

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
			defaultAnim = cast(sprite.animations.get(sprite.defaultAnimation), Animation).animName;
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
			
			currAnimationName = name;
			currAnimation = newAnimation;
			
			addChild(newAnimation);
			
			this.x = realX + Math.floor(newAnimation.width/2);
			this.y = realY + Math.floor(newAnimation.height/2);
		}
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
			checkMouseState();
		}
				
		/*if(collisionListeners.length > 0 || 
		  engine.collisionListeners[type] != null || 
		  engine.collisionListeners[getGroup()] != null) 
		{
			handleCollisions();		
		}*/

		internalUpdate(elapsedTime, true);
		
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

		/*if(positionListeners.length > 0 || 
		   engine.typeGroupPositionListeners[type] != null || 
		   engine.typeGroupPositionListeners[getGroup()] != null)
		{
			checkScreenState();
		}*/
		
		updateAnimProperties(elapsedTime, true);
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
			/*x += xSpeed / Engine.physicsScale;
			y += ySpeed / Engine.physicsScale;
			rotation += rSpeed / Engine.physicsScale / Engine.physicsScale;*/
			
			this.x += elapsedTime * xSpeed;
			this.y += elapsedTime * ySpeed;
			this.rotation += elapsedTime * rSpeed;
		}
		
		else
		{
			var p = body.getPosition();
					
			x = Math.round(p.x * Engine.physicsScale - Math.floor(width / 2) - currOffset.x);
			y = Math.round(p.y * Engine.physicsScale - Math.floor(height / 2) - currOffset.y);		
			rotation = body.getAngle() * Utils.DEG;
		}
		
		if(doAll)
		{
			if(Std.is(currAnimation, AbstractAnimation))
	   		{
	   			cast(currAnimation, AbstractAnimation).update(elapsedTime);
	   		}
		}
		
		updateTweenProperties();
	}	
	
	public function updateAnimProperties(elapsedTime:Float, doAll:Bool)
	{
		if(doAll && currAnimation != null)
		{
			if(Std.is(currAnimation, AbstractAnimation))
		   	{
		   		cast(currAnimation, AbstractAnimation).update(elapsedTime);
		   	}
		}
	}
	
	function updateTweenProperties()
	{
		//In lightweight mode, none of this junk has to happen - it just works like it should!
		if(isLightweight)
		{
			return;
		}
	
		//Since we can't tween directly on the Box2D values and can't make direct function calls,
		//we have to reverse the normal flow of information from body -> NME to tween -> body
		var a:Bool = activePositionTweens > 0;
		var b:Bool = activeAngleTweens > 0;
				
		/*if(autoScale && !isLightweight && body != null && bodyDef.type != b2Body.b2_staticBody && (bodyScale.x != currSprite.scale.x || bodyScale.y != currSprite.scale.y))
		{
			if(currSprite.scale.x > 0 && currSprite.scale.y > 0)
			{
				scaleBody(currSprite.scale.x, currSprite.scale.y);
			}
		}*/
		
		if(a && b)
		{
			x = tweenLoc.x;
			currAnimation.x = tweenLoc.x;
			
			y = tweenLoc.y;
			currAnimation.y = tweenLoc.y;
			
			rotation = tweenAngle.angle;
			currAnimation.rotation = tweenAngle.angle;
			
			if(!isLightweight)
			{
				body.setPositionAndAngle
				(
					new B2Vec2(Engine.toPhysicalUnits(x), Engine.toPhysicalUnits(y)),
					Utils.RAD * rotation
				);
			}
		}
		
		else
		{
			if(a)
			{
				x = tweenLoc.x;
				currAnimation.x = tweenLoc.x;
				setX(tweenLoc.x);
				
				y = tweenLoc.y;
				currAnimation.y = tweenLoc.y;
				setY(tweenLoc.y);
			}
			
			if(b)
			{
				rotation = tweenAngle.angle;
				currAnimation.rotation = tweenAngle.angle;
				setAngle(tweenAngle.angle, false);
			}
		}
	}
		
	//*-----------------------------------------------
	//* Events - Other
	//*-----------------------------------------------
	
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
	
	private function checkScreenState()
	{
		/*var onScreen:Boolean = isOnScreen();
		var inScene:Boolean = onScreen || isInScene();
		
		var enteredScreen:Boolean = !lastScreenState && onScreen;
		var enteredScene:Boolean = !lastSceneState && inScene;
		var exitedScreen:Boolean = lastScreenState && !onScreen;
		var exitedScene:Boolean = lastSceneState && !inScene;
		
		for (var r:int = 0; r < positionListeners.length; r++)
		{
			try
			{
				var f:Function = positionListeners[r] as Function;				
				f(positionListeners, enteredScreen, exitedScreen, enteredScene, exitedScene);
				
				if (positionListeners.indexOf(f) == -1)
				{
					r--;
				}
			}
			catch (e:Error)
			{
				FlxG.log(e.getStackTrace());
			}
		}
		
		var typeListeners:Array = game.typeGroupPositionListeners[getGroup()] as Array;
		var groupListeners:Array = game.typeGroupPositionListeners[getType()] as Array;
		
		//Move to scene level?
		if (typeListeners != null)
		{
			for (var r:int = 0; r < typeListeners.length; r++)
			{
				try
				{
					var f:Function = typeListeners[r] as Function;				
					f(typeListeners, this, enteredScreen, exitedScreen, enteredScene, exitedScene);
					
					if (typeListeners.indexOf(f) == -1)
					{
						r--;
					}
				}
				catch (e:Error)
				{
					FlxG.log(e.getStackTrace());
				}
			}
		}
		
		if (groupListeners != null)
		{
			for (var r:int = 0; r < groupListeners.length; r++)
			{
				try
				{
					var f:Function = groupListeners[r] as Function;				
					f(groupListeners, this, enteredScreen, exitedScreen, enteredScene, exitedScene);
					
					if (groupListeners.indexOf(f) == -1)
					{
						r--;
					}						
				}
				catch (e:Error)
				{
					FlxG.log(e.getStackTrace());
				}
			}
		}
		
		lastScreenState = onScreen;
		lastSceneState = inScene;*/
	}
		
	//*-----------------------------------------------
	//* Collision
	//*-----------------------------------------------
	
	
	private function handleCollisions()
	{			
		/*for each(var p:b2Contact in contacts)
		{
			var a1:Actor = p.GetFixtureA().GetUserData() as Actor;
			var a2:Actor = p.GetFixtureB().GetUserData() as Actor;
											
			var otherActor:Actor;
			var otherShape:b2Fixture;
			var thisShape:b2Fixture;
			
			var key:String = String(p._ptr);
				
			if(a1 == this)
			{
				otherActor = a2;
				otherShape = p.GetFixtureB();
				thisShape = p.GetFixtureA();
			}
			
			else
			{
				otherActor = a1;
				otherShape = p.GetFixtureA();
				thisShape = p.GetFixtureB();
			}
							
			if(collisions[key] != null)
			{
				continue;
			}
			
			var d:Collision = new Collision();
			d.otherActor = otherActor;
			d.otherShape = otherShape;
			d.thisActor = this;
			d.thisShape = thisShape;
			d.actorA = a1;
			d.actorB = a2;
			
			var manifold:b2WorldManifold = new b2WorldManifold();
			p.GetWorldManifold(manifold);
			
			var cp:CollisionPoint = new CollisionPoint();
			cp.point = manifold.GetPoint();
			cp.normal = manifold.normal;
			
			collisions[key] = d;
			
			if(cp.point != null)
			{
				d.points.push(cp);
				
				d.thisFromBottom = collidedFromBottom(p, cp.normal);					
				d.thisFromTop = collidedFromTop(p, cp.normal);						
				d.thisFromLeft = collidedFromLeft(p, cp.normal);					
				d.thisFromRight = collidedFromRight(p, cp.normal);		
				
				d.otherFromBottom = otherActor.collidedFromBottom(p, cp.normal);					
				d.otherFromTop = otherActor.collidedFromTop(p, cp.normal);						
				d.otherFromLeft = otherActor.collidedFromLeft(p, cp.normal);					
				d.otherFromRight = otherActor.collidedFromRight(p, cp.normal);
			}
			
			//Can use logical OR assignment shortcut if we switch back to multipoint collisions
			d.thisCollidedWithActor = collidedWithActor(otherActor);						
			d.thisCollidedWithTerrain = collidedWithTerrain(otherActor);				
			d.thisCollidedWithTile = collidedWithTile(otherActor);
			d.thisCollidedWithSensor = otherShape.IsSensor();		
			
			d.otherCollidedWithActor = collidedWithActor(this);						
			d.otherCollidedWithTerrain = collidedWithTerrain(this);				
			d.otherCollidedWithTile = collidedWithTile(this);
			d.otherCollidedWithSensor = thisShape.IsSensor();		
		}
		
		for each(var collision:Collision in collisions)
		{
			if (!collision.thisActor.handlesCollisions || !collision.otherActor.handlesCollisions)
			{
				continue;
			}
			
			lastCollided = collision.otherActor;
			handleCollision(collision);
		}
		
		contacts = new Dictionary();*/
	}
	
	/*public function collidedFromBottom(c:b2Contact, normal:V2):Boolean
	{
		var thisActor:Actor = this;
		var body:b2Body = thisActor.getBody();
		
		var body1:b2Body = c.GetFixtureA().GetBody();
		var body2:b2Body = c.GetFixtureB().GetBody();

		if(body1 == body)
		{
			return normal.y > 0;
		}
		
		if(body2 == body)
		{
			return normal.y < 0;
		}

		return false;
	}
	
	public function collidedFromTop(c:b2Contact, normal:V2):Boolean
	{
		var thisActor:Actor = this;
		var body:b2Body = thisActor.getBody();
		
		var body1:b2Body = c.GetFixtureA().GetBody();
		var body2:b2Body = c.GetFixtureB().GetBody();
		
		if(body1 == body)
		{
			return normal.y < 0;
		}
		
		if(body2 == body)
		{
			return normal.y > 0;
		}
		
		return false;
	}
	
	public function collidedFromLeft(c:b2Contact, normal:V2):Boolean
	{
		var thisActor:Actor = this;
		var body:b2Body = thisActor.getBody();
		
		var body1:b2Body = c.GetFixtureA().GetBody();
		var body2:b2Body = c.GetFixtureB().GetBody();
		
		if(body1 == body)
		{
			return normal.x < 0;
		}
		
		if(body2 == body)
		{
			return normal.x > 0;
		}
		
		return false;
	}
	
	public function collidedFromRight(c:b2Contact, normal:V2):Boolean
	{
		var thisActor:Actor = this;
		var body:b2Body = thisActor.getBody();
		
		var body1:b2Body = c.GetFixtureA().GetBody();
		var body2:b2Body = c.GetFixtureB().GetBody();
		
		if(body1 == body)
		{
			return normal.x > 0;
		}
		
		if(body2 == body)
		{
			return normal.x < 0;
		}
		
		return false;
	}
	
	private function collidedWithActor(a:Actor):Boolean
	{
		if(a != null)
		{
			return a.getGroupID() != 1 && a.getGroupID() != -2 && !a.isTerrainRegion; //not tile, region, or terrain
		}
		
		return false;
	}
	
	private function collidedWithTerrain(a:Actor):Boolean
	{
		if(a != null)
		{
			return a.isTerrainRegion;   //Terrain Region?
		}
		
		return false;
	}
	
	private function collidedWithTile(a:Actor):Boolean
	{
		if(a != null)
		{
			return a.getGroupID() == 1; //Game.TILE_GROUP_ID;
		}
		
		return false;
	}
	
	public function addContact(point:b2Contact):void
	{
		if(contacts != null)
		{
			var key:String = String(point._ptr);	
			contacts[key] = point;
			delete collisions[key];
		}			
	}
	
	public function removeContact(point:b2Contact):void
	{
		var key:String = String(point._ptr);

		if(collisions != null)
		{
			delete collisions[key];
		}
		
		if(contacts != null)
		{
			delete contacts[key];
		}
	}
	
	public function addRegionContact(point:b2Contact):void
	{
		if(regionContacts != null)
		{
			var key:String = String(point._ptr);	
			regionContacts[key] = point;
		}			
	}
	
	public function removeRegionContact(point:b2Contact):void
	{
		var key:String = String(point._ptr);
		
		if(regionContacts != null)
		{
			delete regionContacts[key];
		}
	}
	
	public function handleCollision(event:Collision):void
	{
		//Move to GameState level with type?
		for (var r:int = 0; r < collisionListeners.length; r++)
		{
			try
			{					
				var f:Function = collisionListeners[r] as Function;
				f(collisionListeners, event);
									
				if (collisionListeners.indexOf(f) == -1)
				{
					r--;
				}									
			}
			catch (e:Error)
			{
				FlxG.log(e.getStackTrace());
			}
		}
		
		game.handleCollision(this, event);			
	}
	
	*/
	
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
	
	public function getGroup():DisplayObjectContainer
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
	
	public function moveToLayerOrder(layerOrder:Int)
	{
		engine.moveToLayerOrder(this,layerOrder);
	}
	
	public function bringToFront()
	{
		engine.bringToFront(this);
	}
	
	public function bringForward()
	{
		engine.bringForward(this);
	}
	
	public function sendToBack()
	{
		engine.sendToBack(this);
	}
	
	public function sendBackward()
	{
		engine.sendBackward(this);
	}
	
	//*-----------------------------------------------
	//* Physics: Position
	//*-----------------------------------------------
	
	public function getX():Float
	{
		if(isRegion || isTerrainRegion)
		{
			return Math.round(Engine.toPixelUnits(body.getPosition().x) - width/2);
		}
		
		else if (!isLightweight)
		{
			return Math.round(body.getPosition().x * Engine.physicsScale - Math.floor(width / 2) - currOffset.x);
		}
		
		else 
		{
			return x - currOffset.x;
		}
	}
	
	public function getY():Float
	{
		if(isRegion || isTerrainRegion)
		{
			return Math.round(Engine.toPixelUnits(body.getPosition().y) - height/2);
		}
			
		else if (!isLightweight)
		{
			return Math.round(body.getPosition().y * Engine.physicsScale - Math.floor(height / 2) - currOffset.y);
		}
		
		else
		{
			return y - currOffset.y;
		}
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
			return x + width/2 - currOffset.x;
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
			return y + height/2 - currOffset.y;
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
			updateAnimProperties(0, false);
		}
		
		else
		{
			if(isRegion || isTerrainRegion)
			{
				dummy.x = Engine.toPhysicalUnits(x);
			}
				
			else
			{
				dummy.x = Engine.toPhysicalUnits(x + Math.floor(width/2) + currOffset.x);
			}			
			
			dummy.y = body.getPosition().y;
			
			body.setPosition(dummy);
			
			if(resetSpeed)
			{
				body.setLinearVelocity(zero);
			}
			
			this.x = Math.round(dummy.x * Engine.physicsScale - Math.floor(width / 2) - currOffset.x);
			updateAnimProperties(0, false);
		}
	}
	
	public function setY(y:Float, resetSpeed:Bool = false)
	{
		if(isLightweight)
		{
			this.y = y + height / 2 + currOffset.y;
			updateAnimProperties(0, false);
		}
		
		else
		{	
			if(isRegion || isTerrainRegion)
			{
				dummy.y = Engine.toPhysicalUnits(y);
			}
				
			else
			{
				dummy.y = Engine.toPhysicalUnits(y + Math.floor(height/2) + currOffset.y);
			}
			
			dummy.x = body.getPosition().x;
			
			body.setPosition(dummy);		
			
			if(resetSpeed)
			{
				body.setLinearVelocity(zero);
			}
			
			this.y = Math.round(dummy.y * Engine.physicsScale - Math.floor(height / 2) - currOffset.y);
			updateAnimProperties(0, false);
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
		
		body.setPosition(a.body.getWorldCenter());
	}
	
	public function followWithOffset(a:Actor, ox:Int, oy:Int)
	{
		if(isLightweight)
		{
			x = a.getXCenter() + ox;
			y = a.getYCenter() + oy;
			
			return;
		}
		
		var pt:B2Vec2 = a.body.getWorldCenter();
		
		pt.x += Engine.toPhysicalUnits(ox);
		pt.y += Engine.toPhysicalUnits(oy);
		
		body.setPosition(pt);
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
			return Utils.RAD * rotation;
		}
		
		return body.getAngle();
	}
	
	public function getAngleInDegrees():Float
	{
		if(isLightweight)
		{
			return rotation;
		}
		
		return Utils.DEG * body.getAngle();
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
				body.setAngle(angle);				
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
				body.setAngle(Utils.RAD * angle);		
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
				body.setAngle(body.getAngle() + angle);
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
				body.setAngle(body.getAngle() + (Utils.RAD * angle));
			}	
		}
	}
	
	public function getAngularVelocity():Float
	{
		if(isLightweight)
		{
			return Utils.RAD * rotation;
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
		if(isLightweight || (dirX == 0 && dirY == 0))
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
		if(isLightweight || (dirX == 0 && dirY == 0))
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
		if(!isLightweight)
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
		return width;
	}
	
	public function getHeight():Float
	{
		return height;
	}
	
	public function getPhysicsWidth():Float
	{
		return width / Engine.physicsScale;
	}
	
	public function getPhysicsHeight():Float
	{
		return height / Engine.physicsScale;
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
	//* Mouse Convenience
	//*-----------------------------------------------
	
	public function isMouseOver():Bool
	{
		//This may need to be in global x/y???
		var mx:Int = Input.mouseX;
		var my:Int = Input.mouseY;
		
		var xPos:Float = this.x;
		var yPos:Float = this.y;
		
		if(isLightweight)
		{
			xPos = getX();
			yPos = getY();
		}
		
		if(isHUD)
		{
			//This said screen x/y???
			mx = Input.mouseX;
			my = Input.mouseY;
			
			xPos = getScreenX();
			yPos = getScreenY();
		}
		
		return (mx >= xPos && 
		   		my >= yPos && 
		   		mx < xPos + width && 
		   		my < yPos + height);
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
	
	public function checkMouseState()
	{
		var mouseOver:Bool = isMouseOver();
				
		if(mouseState <= 0 && mouseOver)
		{
			//Just Entered
			mouseState = 1;
		}
				
		else if(mouseState >= 1 && mouseOver)
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
		
		var r = 0;
		
		while(r < mouseOverListeners.length)
		{
			try
			{
				var f:Int->Array<Dynamic>->Void = mouseOverListeners[r];			
				f(mouseState, mouseOverListeners);
				
				if(Utils.indexOf(mouseOverListeners, f) == -1)
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
	
	//*-----------------------------------------------
	//* Tween Convenience
	//*-----------------------------------------------
	
	public function cancelTweens()
	{
		for(s in animationMap)
		{
			Actuate.stop(s);
		}
	}
	
	public function fadeTo(value:Float, duration:Float = 1, easing:Dynamic = null, delay:Int = 0)
	{	
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		for(s in animationMap)
		{
			Actuate.tween(s, duration, {alpha:value}).ease(easing).delay(delay);
		}
	}
	
	public function growTo(scaleX:Float = 1, scaleY:Float = 1, duration:Float = 1, easing:Dynamic = null, delay:Int = 0)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		for(s in animationMap)
		{
			Actuate.tween(this, duration, {x:scaleX, y:scaleY}).ease(easing).delay(delay);
		}
	}
	
	//In degrees
	public function spinTo(angle:Float, duration:Float = 1, easing:Dynamic = null, delay:Int = 0)
	{
		tweenAngle.angle = this.rotation;

		if(easing == null)
		{
			easing = Linear.easeNone;
		}
		
		activeAngleTweens++;
	
		Actuate.tween(tweenAngle, duration, {rotation:angle}).ease(easing).delay(delay).onComplete(onTweenAngleComplete);
	}
	
	public function moveTo(x:Float, y:Float, duration:Float = 1, easing:Dynamic = null, delay:Int = 0)
	{
		tweenLoc.x = getX();
		tweenLoc.y = getY();
		
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
		
		activePositionTweens++;
		
		Actuate.tween(tweenLoc, duration, {x:x, y:y}).ease(easing).delay(delay).onComplete(onTweenPositionComplete);
	}
	
	//In degrees
	public function spinBy(angle:Float, duration:Float = 1, easing:Dynamic = null, delay:Int = 0)
	{
		spinTo(this.rotation + angle, duration, easing, delay);
	}
	
	public function moveBy(x:Float, y:Float, duration:Float = 1, easing:Dynamic = null, delay:Int = 0)
	{
		moveTo(getX() + x, getY() + y, duration, easing, delay);
	}
	
	public function onTweenAngleComplete()
	{
		activeAngleTweens--;
	}
	
	public function onTweenPositionComplete()
	{
		activePositionTweens--;
	}
	
	
	//*-----------------------------------------------
	//* Drawing
	//*-----------------------------------------------
	
	public function enableActorDrawing()
	{
		drawActor = true;
		
		if(currAnimation != null)
		{
			currAnimation.visible = true;
		}
	}
	
	public function disableActorDrawing()
	{
		drawActor = false;
		
		if(currAnimation != null)
		{
			currAnimation.visible = false;
		}
	}
	
	public function drawsImage():Bool
	{
		return drawActor;
	}
	
	//*-----------------------------------------------
	//* Filters
	//*-----------------------------------------------
	
	public function setFilter(filter:Dynamic)
	{
		/*if(currAnimation != null)
		{
			currAnimation.setFilter(filter);
		}*/
	}
	
	//Pulpcore-like filter addon
	/*public var filter:*;
	

	public function setFilter(filter:*):void
	{			
		//sent in null (remove all), or no filters currently applied (apply all)
		if(filter == null || this.filter == null)
		{
			this.filter = filter;
			calcFrame();
			return;
		}
		
		this.filter = [this.filter].concat(filter);
		
		calcFrame();
	}

	public function applyFilter(filter:*):void
	{
		if(filter != null)
		{
			_flashRect.x = _flashRect.y = 0;
			
			_flashRect.width = _framePixels.width;
			_flashRect.height = _framePixels.height;

			_flashPointZero.x = 0;
			_flashPointZero.y = 0;
						
			//var rect:Rectangle = _framePixels.generateFilterRect(_flashRect, filter);
			
			if(filter is Array)
			{
				for each(var o:Object in filter)
				{
					applyFilter(o);
				}
			}
			else if(filter is BitmapFilter)
			{
				_framePixels.applyFilter(_framePixels, _flashRect, _flashPointZero, filter as BitmapFilter);
			}
		}
	}
	*/
	
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
	//* Events Plumbing
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
	
	//*-----------------------------------------------
	//* Misc
	//*-----------------------------------------------	
	
	public function anchorToScreen()
	{
		if(!isLightweight)
		{
			//body.SetAlwaysActive(true);
		}
		
		isHUD = true;			
		engine.addHUDActor(this);
		
		for(anim in animationMap)
		{
			//anim.scrollFactor.x = 0;
			//anim.scrollFactor.y = 0;
		}
	}
	
	public function unanchorFromScreen()
	{
		if(!isLightweight)
		{
			//body.SetAlwaysActive(alwaysSimulate || false);
		}
		
		isHUD = false;			
		engine.removeHUDActor(this);
		
		for(anim in animationMap)
		{
			//anim.scrollFactor.x = 1;
			//anim.scrollFactor.y = 1;
		}
	}
	
	public function isAnchoredToScreen():Bool
	{
		return isHUD;
	}
	
	public function makeAlwaysSimulate()
	{
		if(!isLightweight)
		{
			//body.SetAlwaysActive(true);
		}
		
		alwaysSimulate = true;			
		engine.addAlwaysOnActor(this);
	}
	
	public function makeSometimesSimulate()
	{
		if(!isLightweight)
		{
			//body.SetAlwaysActive(false);
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
	
		/*kill();
		
		for (var r:int = 0; r < whenKilledListeners.length; r++)
		{
			var f:Function = whenKilledListeners[r] as Function;	
			
			try
			{
				f(whenKilledListeners);
				
				if (whenKilledListeners.indexOf(f) == -1)
				{
					r--;
				}
			}
			catch(e:Error)
			{
				FlxG.log("Error in die listener function");
				FlxG.log(e.getStackTrace());
			}
		}
		
		//Move to GameState level?
		if (game.whenTypeGroupDiesListeners[getType()] != null)
		{
			var listeners:Array = game.whenTypeGroupDiesListeners[getType()] as Array;
			
			for (var r:int = 0; r < listeners.length; r++)
			{
				try
				{
					var f:Function = listeners[r] as Function;
					f(listeners, this);
					
					if (listeners.indexOf(f) == -1)
					{
						r--;
					}
				}
				catch (e:Error)
				{
					FlxG.log(e.getStackTrace());
				}
			}
		}
		
		if (game.whenTypeGroupDiesListeners[getGroup()] != null)
		{
			var listeners:Array = game.whenTypeGroupDiesListeners[getGroup()] as Array;
			
			for (var r:int = 0; r < listeners.length; r++)
			{
				try
				{
					var f:Function = listeners[r] as Function;
					f(listeners, this);
					
					if (listeners.indexOf(f) == -1)
					{
						r--;
					}
				}
				catch (e:Error)
				{
					FlxG.log(e.getStackTrace());
				}
			}
		}
		
		removeAllListeners();*/
	}
		
	public function isDying():Bool
	{
		return dying;
	}
	
	public function isAlive():Bool
	{
		return !(dead || dying);
	}
	
	public function isOnScreen():Bool
	{
		var cameraX = Engine.cameraX;
		var cameraY = Engine.cameraY;
		
		var left = Engine.paddingLeft;
		var top = Engine.paddingTop;
		var right = Engine.paddingRight;
		var bottom = Engine.paddingBottom;
	
		return (isLightweight || body.isActive()) && 
			   getX() >= cameraX - left && 
			   getY() >= cameraY - top &&
			   getX() < cameraX + Engine.screenWidth + right &&
			   getY() < cameraY + Engine.screenHeight + bottom;
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
		return lastCollided;
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
		
		return name;
	}
	
	//*-----------------------------------------------
	//* Camera-Only
	//*-----------------------------------------------
	
	public function setLocation(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
		
		setX(x);
		setY(y);
	}
}
