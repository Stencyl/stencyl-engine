package com.stencyl;

import com.stencyl.behavior.Attribute;
import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.TimedTask;
import com.stencyl.behavior.BehaviorManager;
import com.stencyl.behavior.BehaviorInstance;
import com.stencyl.behavior.Script;


import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.Shape;
import nme.display.Graphics;
import nme.text.TextField;
import nme.display.DisplayObjectContainer;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.Assets;
import nme.Lib;
import nme.ui.Keyboard;

import com.stencyl.graphics.transitions.Transition;
import com.stencyl.graphics.transitions.FadeInTransition;
import com.stencyl.graphics.BitmapFont;

import com.stencyl.models.Actor;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.scene.ActorInstance;
import com.stencyl.models.GameModel;
import com.stencyl.models.Scene;
import com.stencyl.models.SoundChannel;
import com.stencyl.models.Region;
import com.stencyl.models.Terrain;

import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.Layer;
import com.stencyl.models.scene.TileLayer;


import scripts.MyScripts;

import com.stencyl.utils.Utils;
import com.stencyl.utils.HashMap;

#if cpp
import nme.ui.Accelerometer;
#end

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;

import box2D.dynamics.B2World;
import box2D.common.math.B2Vec2;
import box2D.dynamics.joints.B2Joint;
import box2D.dynamics.B2DebugDraw;
import box2D.collision.B2AABB;
import box2D.collision.shapes.B2Shape;


class Engine 
{
	//*-----------------------------------------------
	//* Constants
	//*-----------------------------------------------
		
	//None?
	
	
	//*-----------------------------------------------
	//* Important Values
	//*-----------------------------------------------
	
	public static var engine:Engine = null;
	
	public static var cameraX:Float;
	public static var cameraY:Float;
	
	public static var screenWidth:Int;
	public static var screenHeight:Int;
	
	public static var sceneWidth:Int;
	public static var sceneHeight:Int;
	
	public static var paused:Bool = false;
	public static var started:Bool = false;


	//*-----------------------------------------------
	//* Physics
	//*-----------------------------------------------
	
	public var world:B2World;
	
	private var physicalWidth:Float;
	private var physicalHeight:Float;
	
	public static var ITERATIONS:Int = 3;
	public static var physicsScale:Float = 10.0;
		
	public static var paddingLeft:Int = 0;
	public static var paddingRight:Int = 0;
	public static var paddingTop:Int = 0;
	public static var paddingBottom:Int = 0;
	
	
	//*-----------------------------------------------
	//* Online / API Values
	//*-----------------------------------------------
	
	public static var mochiID:String;
	public static var ngID:String;
	public static var ngKey:String;
	//public static var medalPopup:MedalPopup;
		
	
	//*-----------------------------------------------
	//* Transitioning
	//*-----------------------------------------------
	
	private var leave:Transition;
	private var enter:Transition;
	private var sceneToEnter:Int;	
	
	public var enterTimer:Int;
	public var leaveTimer:Int;
	
		
	//*-----------------------------------------------
	//* Model
	//*-----------------------------------------------
	
	public var scene:Scene;
	public var camera:Actor;
	
	public var channels:Array<SoundChannel>;
	public var tasks:Array<TimedTask>;
	
	//Scene-Specific
	public var regions:IntHash<Region>;
	public var terrainRegions:IntHash<Terrain>;
	public var joints:IntHash<B2Joint>;
	
	public static var stage:Stage;
	public var root:Sprite; //The absolute root
	public var master:Sprite; // the root of the main node
	public var transitionLayer:Sprite; //Shows above everything else
	
	
	//*-----------------------------------------------
	//* Model - Actors & Groups
	//*-----------------------------------------------
	
	public var groups:IntHash<DisplayObjectContainer>;
	public var allActors:IntHash<Actor>;
	public var nextID:Int;
	
	//Used to be called actorsToRender
	public var actorsPerLayer:IntHash<DisplayObjectContainer>;
	
	public var hudActors:HashMap<Actor, Actor>;
	
	//HashMap<Integer, HashSet<Actor>>
	public var actorsOfType:IntHash<Array<Actor>>;
	
	//HashMap<Integer, HashSet<Actor>>
	public var recycledActorsOfType:IntHash<Array<Actor>>;
	
	//List<DeferredActor>
	public var actorsToCreateInNextScene:Array<Actor>;
	
	
	//*-----------------------------------------------
	//* Model - Layers / Terrain
	//*-----------------------------------------------
	
	//My feeling is that we don't need anything except a way to map from layerID to Layer, which in turn
	//can tell us the order and which layers are above, below. And what layer is on top/bottom.
	//A Layer = Sprite/Container.
	
	public var layers:IntHash<Layer>;
	public var tileLayers:IntHash<TileLayer>;
	public var dynamicTiles:Hash<Actor>;
	public var animatedTiles:Array<Tile>;
	
	public var topLayer:Int;
	public var bottomLayer:Int;
	public var middleLayer:Int;
	
	//int[]
	//index -> order
	//value -> layerID
	public var layersToDraw:IntHash<Int>;
	public var layerOrders:IntHash<Int>;		
	
	//public var parallax:ParallaxArea;
	//public var playfield:Area;
	
	
	//*-----------------------------------------------
	//* Model - ?????
	//*-----------------------------------------------
	
	public var actors:Array<Actor>;
	
	
	//*-----------------------------------------------
	//* Model - Behaviors & Game Attributes
	//*-----------------------------------------------
	
	public var gameAttributes:Hash<Dynamic>;
	public var behaviors:BehaviorManager;
	
	
	//*-----------------------------------------------
	//* Timing
	//*-----------------------------------------------
	
	public static var STEP_SIZE:Float = 0.01;
	public static var MS_PER_SEC:Int = 1000;
	
	public static var elapsedTime:Float = 0;
	public static var timeScale:Float = 1;
	
	private var lastTime:Float;
	private var acc:Float;
	
	private var framerate:Int;
	private var framerateCounter:Float;
	
	
	//*-----------------------------------------------
	//* Debug
	//*-----------------------------------------------
	
	public static var debug:Bool = false;
	public static var debugDraw:Bool = false;
	public static var debugDrawer:B2DebugDraw;
	
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------
	
	private var mx:Float;
	private var my:Float;
	
	private var collisionPairs:HashMap<Dynamic, Dynamic>;
	
	public var whenKeyPressedListeners:HashMap<Dynamic, Dynamic>;
	public var whenTypeGroupCreatedListeners:HashMap<Dynamic, Dynamic>;
	public var whenTypeGroupDiesListeners:HashMap<Dynamic, Dynamic>;
	public var typeGroupPositionListeners:HashMap<Dynamic, Dynamic>;
	public var collisionListeners:HashMap<Dynamic, Dynamic>;
	public var soundListeners:HashMap<Dynamic, Dynamic>;		
			
	public var whenUpdatedListeners:Array<Dynamic>;
	public var whenDrawingListeners:Array<Dynamic>;
	public var whenMousePressedListeners:Array<Dynamic>;
	public var whenMouseReleasedListeners:Array<Dynamic>;
	public var whenMouseMovedListeners:Array<Dynamic>;
	public var whenMouseDraggedListeners:Array<Dynamic>;		
	public var whenPausedListeners:Array<Dynamic>;		
	
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------

	public function new(root:Sprite) 
	{		
		Engine.engine = this;
		this.root = root;
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);
		begin(0);
	
		/*Input.enable();
		
		Data.get();
		GameModel.get();
		
		//---
		
		gameAttributes = new Hash<Dynamic>();
		
		cameraX = 0;
		cameraY = 0;

		acc = 0;
		framerateCounter = 0;
		
		sceneToEnter =  0;
		
		//---
		
		layers = new Array<Sprite>();
		
		//---
		
		tasks = new Array<TimedTask>();
		this.root = root;

		//---
	
		sceneWidth = 640;
		sceneHeight = 640;
		
		screenWidth = Std.int(stage.stageWidth);
		screenHeight = Std.int(stage.stageHeight);
		
		//---
	
		lastTime = Lib.getTimer() / MS_PER_SEC;
		
		master = new Sprite();
		root.addChild(master);*/
		
		
		
		
		
		
		
		//---
		
		//Add Layers - First the tile layer, then the actor layer
		
		/*for(i in 0...3)
		{
			var tileLayer = new Sprite();
			addChild(tileLayer);
			
			var layer = new Sprite();
			layers.push(layer);
			addChild(layer);
		}*/
		
		//---
					
		//TEST
		/*for(i in 0...10)
		{
			var sprite = new Bitmap(Assets.getBitmapData("assets/graphics/tile.png"));
			sprite.smoothing = true;
			sprite.x = -sprite.width/2;
			sprite.y = -sprite.height/2;
		
			var actor = new Actor(this, null, i * 32 + 16, 96 + 16);
			master.addChild(actor);
			actor.addAnimation("d", sprite);
			actor.switchAnimation("d");
		}
		
		for(i in 0...10)
		{
			var sprite = new Bitmap(Assets.getBitmapData("assets/graphics/tile.png"));
			sprite.smoothing = true;
			sprite.x = -sprite.width/2;
			sprite.y = -sprite.height/2;
		
			var actor = new Actor(this, null, 96 + 16, i * 32 + 16);
			master.addChild(actor);
			actor.addAnimation("d", sprite);
			actor.switchAnimation("d");
		}
	
		//pronger = new Actor(this, null, 16, 32);
		//master.addChild(pronger);
		//pronger.addAnimation("anim1", "assets/graphics/anim1.png");
		//pronger.addAnimation("anim2", "assets/graphics/anim2.png");
		//pronger.switchAnimation("anim1");
		//pronger.tileTest();
		
		var font:BitmapFont = new BitmapFont("assets/graphics/font.png", 32, 32, BitmapFont.TEXT_SET11 + "#", 9, 1, 1);
		font.text = "Stencyl 2.5";
		font.x = 10;
		font.y = 10;
		master.addChild(font);
		
		//---
		
		//var sound = Assets.getSound("assets/music/sample.ogg");
		//var soundChannel = sound.play();
		*/

		//randomMotion();
		
		//var thing = Type.createInstance(Type.this("behavior.Motion"), [pronger, this]);
		/*var behavior = new Behavior(pronger, engine, 0, "Pronger", "scripts.Motion", true, false, null);
		pronger.behaviors.add(behavior);
		pronger.initScripts();*/
		
		/*//TODO: Key to toggle this, does not work on HTML5
		#if !js
		var stats = new com.nmefermmmtools.debug.Stats();
		stage.addChild(stats);
		//stats.visible = false;
		#end
		
		//enter = new FadeInTransition(500);
		//enter.start();
		//sceneToEnter = initSceneID;
			
		loadScene(sceneToEnter);
		
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);
		
		begin();*/
	}
	
	public function begin(initSceneID:Int)
	{		
		Input.enable();
		Data.get();
		GameModel.get();
			
		//---
			
		started = true;
		
		//---
		
		leave = null;
		enter = null;
		
		cameraX = 0;
		cameraY = 0;

		acc = 0;
		framerateCounter = 0;
		lastTime = Lib.getTimer() / MS_PER_SEC;

		//Constants
		Engine.sceneWidth = 640;
		Engine.sceneHeight = 640;
		Engine.screenWidth = Std.int(stage.stageWidth);
		Engine.screenHeight = Std.int(stage.stageHeight);
			
		//Display List
		master = new Sprite();
		root.addChild(master);
		
		transitionLayer = new Sprite();
		root.addChild(transitionLayer);
		
		//Initialize things	
		actorsToCreateInNextScene = new Array();			
		gameAttributes = new Hash<Dynamic>();
		
		//Profiler
		#if !js
		var stats = new com.nmefermmmtools.debug.Stats();
		stage.addChild(stats);
		//stats.visible = false;
		#end
		
		//GA's
		for(key in GameModel.get().gameAttributes)
		{
			setGameAttribute(key, GameModel.get().gameAttributes.get(key));
		}
		
		//Sound
		channels = new Array<SoundChannel>();
		
		for(index in 0...Script.CHANNELS)
		{
			channels.push(new SoundChannel(this, index)); 				
		}
		
		//Now, let's start
		enter = new FadeInTransition(0.5);
		enter.start();
		sceneToEnter = initSceneID;
		
		loadScene(initSceneID);
	}	
	
	public function loadScene(sceneID:Int)
	{
		//trace("Loading Scene: " + sceneID);
		
		tasks = new Array<TimedTask>();
		
		scene = GameModel.get().scenes.get(sceneID);
		
		if(sceneID == -1 || scene == null)
		{
			scene = GameModel.get().scenes.get(GameModel.get().defaultSceneID);
		}
		
		behaviors = new BehaviorManager();
		
		//Events
		whenKeyPressedListeners = new HashMap<Dynamic, Dynamic>();
		whenTypeGroupCreatedListeners = new HashMap<Dynamic, Dynamic>();
		whenTypeGroupDiesListeners = new HashMap<Dynamic, Dynamic>();
		typeGroupPositionListeners = new HashMap<Dynamic, Dynamic>();
		collisionListeners = new HashMap<Dynamic, Dynamic>();
		soundListeners = new HashMap<Dynamic, Dynamic>();
		
		whenUpdatedListeners = new Array<Dynamic>();
		whenDrawingListeners = new Array<Dynamic>();
		whenMousePressedListeners = new Array<Dynamic>();
		whenMouseReleasedListeners = new Array<Dynamic>();
		whenMouseMovedListeners = new Array<Dynamic>();
		whenMouseDraggedListeners = new Array<Dynamic>();
		whenPausedListeners = new Array<Dynamic>();
		
		//Stuff
		loadBackgrounds();	
		loadActors();
		
		initBehaviors(behaviors, scene.behaviorValues, this, this, true);			
		initActorScripts();
		
		/*setOffscreenTolerance(0, 0, 0, 0);
		
		tasks = new Array();
		
		accumulator = 0;
		
		scene = Game.get().scenes[sceneID];
		
		if(sceneID == -1 || scene == null)
		{
			scene = Game.get().scenes[Game.get().defaultSceneID];
		}
		
		FlxG.log(scene.name);
		
		behaviors = new BehaviorManager();
		
		groups = new Array();
		
		for each(var grp:GroupDef in Game.get().groups)
		{
			var g:FlxGroup = new FlxGroup();
			groups[grp.ID] = g;
			g.name = grp.name;
		}
		
		actorsOfType = new Array();
		recycledActorsOfType = new Array();
		
		regions = new Array();
		terrainRegions = new Array();
		joints = new Array();
		layers = new Array();
		tileLayers = new Array();
		dynamicTiles = new Dictionary();
		animatedTiles = new Array();
		hudActors = new HashSet();
		allActors = new Array();
		actorsToRender = new Array();
		nextID = 0;
		
		whenKeyPressedListeners = new Dictionary();
		whenTypeGroupCreatedListeners = new Dictionary();
		whenTypeGroupDiesListeners = new Dictionary();
		typeGroupPositionListeners = new Dictionary();
		collisionListeners = new Dictionary();
		soundListeners = new Dictionary();
		
		whenUpdatedListeners = new Array();
		whenDrawingListeners = new Array();
		whenMousePressedListeners = new Array();
		whenMouseReleasedListeners = new Array();
		whenMouseMovedListeners = new Array();
		whenMouseDraggedListeners = new Array();
		whenPausedListeners = new Array();
		
		whenFocusChangedListeners = new Array();
											
		initPhysics();
		loadBackgrounds();
		
		loadTerrain();
			
		rootPanel = new Panel(0, 0, FlxG.width, FlxG.height);
		rootPanel.game = this;
		rootPanelLayer = getTopLayer();
		
		loadRegions();
		loadTerrainRegions();
		loadActors();			
		loadCamera();
		loadJoints();
		
		loadDeferredActors();
		actorsOnScreen = cacheActors();		
					
		trace("Init Scene Behaviors");
		
		initBehaviors(behaviors, scene.behaviorValues, this, this, true);			
		initActorScripts();*/
	}
		
	private function loadBackgrounds()
	{
		var bg = new Shape();
		scene.colorBackground.draw(bg.graphics, 0, 0, screenWidth, screenHeight);
		master.addChild(bg);
		
		//add in the backgrounds as sprites, not as the funny stuff from before
	}
	
	public static function initBehaviors
	(
		manager:BehaviorManager, 
		behaviorValues:Hash<Dynamic>, 
		parent:Dynamic, 
		game:Engine,
		initialize:Bool
	)
	{
		if(behaviorValues == null)
		{
			return;
		}
		
		for(behaviorInstance in behaviorValues)
		{
			var bi:BehaviorInstance = behaviorInstance;
		
			if(bi == null || !bi.enabled)
			{
				continue;
			}
			
			var template:Behavior = Data.get().behaviors.get(bi.behaviorID);
			var attributes:Hash<Attribute> = new Hash<Attribute>();
			
			for(key in bi.values.keys())
			{
				var value:Dynamic = bi.values.get(key);
				
				if(template == null)
				{
					trace("Non-Existent Behavior ID (Init): " + bi.behaviorID);
					continue;
				}
				
				var attribute:Attribute = cast(template.attributes.get(key), Attribute);

				if(attribute == null)
				{
					continue;
				}
				
				var type:String = attribute.type;
				var ID:Int = attribute.ID;
				
				attributes.set(key, new Attribute(ID, attribute.fieldName, attribute.fullName, value, type, null));
			}
			
			if(template == null)
			{
				trace("Non-Existent Behavior ID (Init): " + bi.behaviorID);
				continue;
			}
			
			var b:Behavior = new Behavior
			(
				parent, 
				game, 
				template.ID, 
				template.name, 
				template.classname, 
				true, 
				false,  
				attributes,
				template.type
			);
			
			manager.add(b);
		}
		
		if(initialize)
		{
			manager.initScripts();
		}
	}
	
	//*-----------------------------------------------
	//* Init - Physics
	//*-----------------------------------------------
	
	public function initPhysics()
	{
		var gravity:B2Vec2 = new B2Vec2(scene.gravityX, scene.gravityY);
		world = new B2World(gravity, false);
		
		B2World.m_continuousPhysics = false;
		B2World.m_warmStarting = true;
		
		//Cusotmization TODO
		/*var aabb:B2AABB = new B2AABB();
		aabb.lowerBound.x = 0;
		aabb.lowerBound.y = 0;
		aabb.upperBound.x = Engine.screenWidth / physicsScale;
		aabb.upperBound.y = Engine.screenHeight / physicsScale;
		world.SetScreenBounds(aabb);*/
		
		initDebugDraw();
	}
	
	//*-----------------------------------------------
	//* Init - Actors / Regions / Joints / Terrain
	//*-----------------------------------------------
	
	private function loadActors()
	{
		actors = new Array<Actor>();
		
		for(instance in scene.actors)
		{
			actors.push(createActor(instance, true));
		}
	}
	
	private function loadDeferredActors()
	{
		for(a in actorsToCreateInNextScene)
		{
			//TODO
			//Script.lastCreatedActor = createActorOfType(a.type, a.x, a.y, a.layer);
		}
		
		actorsToCreateInNextScene = [];
	}
	
	private function initActorScripts()
	{
		for(a in actors)
		{
			a.initScripts();
		}
		
		//???
		//actors = null;
	}
	
	private function loadCamera()
	{
		/*camera = new Actor(this, int.MAX_VALUE, Game.DOODAD_ID, 0, 0, getTopLayer(), 2, 2, null, new Array(), null, null, true, false, true);
		camera.name = name;
		camera.body.SetIgnoreGravity(true);
		camera.isCamera = true;
		
		FlxG.followBounds(0, 0, scene.sceneWidth, scene.sceneHeight);*/
	}
	
	private function loadRegions()
	{					
		regions = new IntHash<Region>();

		/*for each(var r:RegionDef in scene.regions)
		{
			var region:Region = new Region(this, r.x, r.y, r.shapes);
			region.name = r.name;
			
			region.setX(GameState.toPixelUnits(r.x) + (region.width / 2));
			region.setY(GameState.toPixelUnits(r.y) + (region.height / 2));
			
			region.ID = r.ID;
			
			add(region);
			regions[r.ID] = region;
		}*/
	}
	
	private function loadTerrainRegions()
	{						
		terrainRegions = new IntHash<Terrain>();
		
		/*for each(var t:TerrainRegionDef in scene.terrainRegions)
		{
			var terrainRegion:TerrainRegion = new TerrainRegion(this, t.x, t.y, t.shapes, t.groupID,t.fillColor);
			terrainRegion.name = t.name;
			
			terrainRegion.setX(GameState.toPixelUnits(t.x) + (terrainRegion.width / 2));
			terrainRegion.setY(GameState.toPixelUnits(t.y) + (terrainRegion.height / 2));
			
			terrainRegion.ID = t.ID;
			
			add(terrainRegion);
			terrainRegions[t.ID] = terrainRegion;
		}*/
	}
			
	private function loadJoints()
	{
		/*for each(var jd:b2JointDef in scene.joints)
		{
			var a1:int = jd.actor1;
			var a2:int = jd.actor2;
			var collide:Boolean = jd.collideConnected;
			
			var one:b2Body = null;
			var two:b2Body = null;
			
			var pt:V2 = null;
			
			//Types are defined in b2Joint.h
			
			//STICK
			if(jd.type == 3)
			{
				joints[jd.ID] = createStickJoint(getActor(a1).body, getActor(a2).body, jd.ID, collide);
			}
			
			//HINGE
			else if(jd.type == 1)
			{
				var r:b2RevoluteJointDef = jd as b2RevoluteJointDef;
				pt = getActor(a1).body.GetLocalCenter().clone();
				
				pt.x = GameState.toPixelUnits(pt.x);
				pt.y = GameState.toPixelUnits(pt.y);
				
				one = getActor(a1).body;
				two = null;
				
				if(a2 == -1)
				{
					two = world.m_groundBody;
				}
				
				else
				{
					two = getActor(a2).body;
				}
				
				joints[jd.ID] = createHingeJoint
				(
					one, 
					two, 
					pt, 
					jd.ID, 
					collide, 
					r.enableLimit, 
					r.enableMotor, 
					r.lowerAngle, 
					r.upperAngle, 
					r.maxMotorTorque, 
					-r.motorSpeed
				);
			}
			
			//SLIDING
			else if(jd.type == 2 || jd.type == 7)
			{
				var s:b2LineJointDef = jd as b2LineJointDef;
				pt = getActor(a1).body.GetLocalCenter().clone();
				
				pt.x = GameState.toPixelUnits(pt.x);
				pt.y = GameState.toPixelUnits(pt.y);
				
				one = getActor(a1).body;
				two = null;
				
				if(a2 == -1)
				{
					two = world.m_groundBody;
				}
					
				else
				{
					two = getActor(a2).body;
				}
				
				joints[jd.ID] = createSlidingJoint
				(
					one,
					two,
					s.localAxisA.v2,
					jd.ID,
					collide,
					s.enableLimit,
					s.enableMotor,
					s.lowerTranslation,
					s.upperTranslation,
					s.maxMotorForce,
					s.motorSpeed
				);
			}
		}*/
	}
	
	public function loadTerrain()
	{				
		//initLayers();
		
		/*for each(var item:* in scene.wireframes)
		{
			var wireframe:Wireframe = item as Wireframe;
			
			FlxG.log("Num vertices: " + (wireframe.shape as b2LoopShape).m_count);
			
			var a:Actor = new Actor
			(
				this, 
				int.MAX_VALUE,
				Game.TERRAIN_ID,
				x, 
				y, 
				getTopLayer(),
				wireframe.width, 
				wireframe.height, 
				null, 
				new Array(),
				null,
				null, 
				false, 
				true, 
				false,
				false, 
				wireframe.shape, 
				true
			);
			
			a.name = "Terrain";
			a.typeID = -1;
			a.visible = false;
			add(a);
		}*/		
	}
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------	

	private function update(elapsedTime:Float)
	{
		#if cpp
		/*if(nme.sensors.Accelerometer.isSupported)
		{
			var data = Accelerometer.get();
			
			//pronger.x += data.x;
			//pronger.y -= data.y;
		}*/
		#end
		
		//---
		
		//cameraX = pronger.x - screenWidth/2;
		//cameraY = pronger.y - screenHeight/2;
		
		//Camera Control
		if(cameraX < 0)
		{
			cameraX = 0;
		}
		
		if(cameraY < 0)
		{
			cameraY = 0;
		}
		
		if(cameraX > sceneWidth - screenWidth)
		{
			cameraX = sceneWidth - screenWidth;
		}
		
		if(cameraY > sceneHeight - screenHeight)
		{
			cameraY = sceneHeight - screenHeight;
		}

		master.x = -cameraX;
		master.y = -cameraY;
		
		//---		
		
		/*if(Input.multiTouchEnabled)
		{
			for(elem in Input.multiTouchPoints)
			{
				trace(elem.eventPhase + "," + elem.stageX + "," + elem.stageY);
			}
		}*/
		
		for(a in actors)
		{
			//cameraX = a.x - screenWidth/2;
			//cameraY = a.y - screenHeight/2;
			
			a.update(elapsedTime);
		}

		//---
		
		//Update Timed Tasks
		var i = 0;
		
		while(i < tasks.length)
		{
			var t:TimedTask = tasks[i];
			
			t.update(10);
			
			if(t.done)
			{
				tasks.remove(t);	
				i--;
			}
			
			i++;
		}
		
		//Update Behaviors
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
	}
	
	//Game Loop
	private function onUpdate(event:Event):Void 
	{
		var currTime:Float = Lib.getTimer() / MS_PER_SEC;
		var elapsedTime:Float = (currTime - lastTime);
		acc += elapsedTime;
		
		Engine.elapsedTime = elapsedTime;
		
		while(acc > STEP_SIZE)
		{
			update(STEP_SIZE * 1000);
			acc -= STEP_SIZE;
			
			Input.update();
		}	
		
		lastTime = currTime;
			
		/*framerate = Std.int(1 / elapsedTime);
		framerateCounter += elapsedTime;
		
		if(framerateCounter > 1)
		{
			framerateCounter -= 1;
			fpsLabel.text = Std.string(framerate);
		}*/
	}
	
	//*-----------------------------------------------
	//* Scene Switching
	//*-----------------------------------------------
	
	public function cleanup()
	{
		/*debugDrawer.graphics.clear();
		defaultGroup.destroy();
					
		behaviors.destroy();
	
		for each(var group:FlxGroup in actorsToRender)
		{
			group.destroy();
		}
		
		//--
		
		camera.destroy();
		camera = null;
		
		rootPanel.destroy();
		rootPanel = null;
		
		//--
		
		//Kill the remaining ones
		for(var worldbody:b2Body = world.GetBodyList(); worldbody; worldbody = worldbody.GetNext()) 
		{
			world.DestroyBody(worldbody);
		}
		
		for(var j:b2Joint = world.GetJointList(); j; j = j.GetNext()) 
		{
			world.DestroyJoint(j);
		}
		
		for each(var set:HashSet in actorsOfType)
		{
			set.clear();
		}
		
		for each(var set:HashSet in recycledActorsOfType)
		{
			set.clear();
		}
		
		actorsOfType = null;
		recycledActorsOfType = null;
		
		hudActors = null;
		layers = null;
		actorsOnScreen = null;
		actorsToRender = null;
		layersToDraw = null;
		layerOrders = null;
		dynamicTiles = null;
		animatedTiles = null;
		
		regions = null;
		terrainRegions = null;
		joints = null;
		groups = null;
		allActors = null;
		scene = null;
		tasks = null;
		
		whenKeyPressedListeners = null;		
		whenTypeGroupCreatedListeners = null;
		whenTypeGroupDiesListeners = null;
		typeGroupPositionListeners = null;
		collisionListeners = null;
		soundListeners = null;
					
		whenUpdatedListeners = null;
		whenDrawingListeners = null;
		whenMousePressedListeners = null;
		whenMouseReleasedListeners = null;
		whenMouseMovedListeners = null;
		whenMouseDraggedListeners = null;		
		whenPausedListeners = null;
		
		whenFocusChangedListeners = null;
		
		FlxG.resetInput();
		
		world.destroy();*/
	}
	
	public function switchScene(sceneID:Int, leave:Transition=null, enter:Transition=null)
	{
		trace("Request to switch to Scene " + sceneID);

		if(isTransitioning())
		{
			trace("Warning: Switching Scene while already switching. Ignoring.");
			return;
		}
		
		if(leave != null && leave.isComplete())
		{
			leave.reset();
		}
		
		if(leave == null)
		{
			leave = new Transition(0);
		}
		
		if(enter == null || enter.duration == 0)
		{
			enter = new Transition(0);
		}
		
		this.leave = leave;
		this.enter = enter;
		
		leaveTimer = 0;
		
		if(!this.leave.isComplete())
		{
			this.leave.start();
		}
		
		sceneToEnter = sceneID;
	}
	
	public function enterScene()
	{
		enterTimer = 0;
		
		if(!enter.isComplete())
		{
			enter.start();
		}
		
		trace("Entering Scene " + sceneToEnter);
		
		cleanup();
		loadScene(sceneToEnter);
	}
	
	public function isTransitioning():Bool
	{			
		if(enter != null && enter.isActive())
		{
			return true;
		}
			
		else if(leave != null && leave.isActive())
		{
			return true;
		}
		
		return false;
	}
	
	//*-----------------------------------------------
	//* Actor Creation
	//*-----------------------------------------------
	
	public function createActor(ai:ActorInstance, offset:Bool = false):Actor
	{
		//trace(ai.actorType);
		var a:Actor = new Actor(this, ai);
		
		//TODO: Mount grpahic and add
		/*var a:Actor = new Actor
		(
			this, 
			ai.elementID,
			ai.groupID,
			ai.x / physicsScale, 
			ai.y / physicsScale, 
			ai.layerID,
			s.width, 
			s.height, 
			s,
			ai.behaviorValues,
			ai.actorType,
			ai.actorType.bodyDef,
			false,
			false,
			false,
			false,
			null,
			false,
			ai.actorType.ID,
			ai.actorType.isLightweight,
			ai.actorType.autoScale
		);*/

		/*if(ai.angle != 0)
		{
			a.setAngle(ai.angle + 180, false);
		}	
		
		if(ai.scaleX != 1 || ai.scaleY != 1)
		{
			a.growTo(ai.scaleX, ai.scaleY, 0);
		}*/
		
		/*moveActorToLayer(a, ai.layerID);
		
		//---
		
		var group:FlxGroup = groups[ai.groupID] as FlxGroup;
		
		if(group != null)
		{
			group.add(a);
		}*/
		
		//---

		//Use the next available ID
		/*if(ai.elementID == Int.MAX_VALUE)
		{
			nextID++;
			a.ID = nextID;
			allActors[a.ID] = a;
		}
		
		else
		{
			allActors[a.ID] = a;
			nextID = Math.max(a.ID, nextID);
		}*/

		//a.internalUpdate(false);
		
		master.addChild(a);
		
		return a;
	}
	
	public function removeActor(a:Actor)
	{
		/*var i:Int = allActors.indexOf(a);
		
		if(i != -1)
		{
			allActors[i] = null;
		}

		//Remove from the layer group
		removeActorFromLayer(a, a.layerID);
		
		//Remove from normal group
		if (!a.isLightweight)
		{
			(groups[a.getGroupID()] as FlxGroup).remove(a, true);
		}
		
		if(a.isHUD || a.alwaysSimulate)
		{
			hudActors.remove(a);
		}
		
		a.destroy();
		
		//---
		
		var typeID:ActorType = Assets.get().resources[a.typeID] as ActorType;
		
		if(typeID != null)
		{
			var cache:HashSet = actorsOfType[typeID.ID];
			
			if(cache != null)
			{
				cache.remove(a);
			}
		}*/
	}
	
	private function removeActorFromLayer(a:Actor, layerID:Int)
	{
		/*var layer:FlxGroup = actorsToRender[layerID] as FlxGroup;
		
		if(layer == null)
		{
			trace("Assuming default group");
			layer = defaultGroup;
		}
		
		layer.remove(a, true);
		
		for each(var anim:FlxSprite in a.anims)
		{
			layer.remove(anim, true);	
		}*/
	}
	
	private function moveActorToLayer(a:Actor, layerID:Int)
	{
		/*var layer:FlxGroup = actorsToRender[layerID] as FlxGroup;
		
		if(layer == null)
		{
			trace("Putting actor inside default group");
			layer = defaultGroup;
		}
		
		for each(var anim:FlxSprite in a.anims)
		{
			layer.add(anim);	
		}
		
		//To ensure that it draws after.
		layer.add(a);*/
	}
	
	public function recycleActor(a:Actor)
	{
		/*a.setX(1000000);
		a.setY(1000000);
		a.recycled = true;
		a.setFilter(null);
		a.disableActorDrawing();
		a.cancelTweens();
		a.moveTo(1000000, 1000000, 0);
		a.growTo(1, 1, 0);
		a.spinTo(0, 0);
		a.fadeTo(1, 0);
		a.switchToDefaultAnimation();
		
		//Kill previous contacts
		if(!a.isLightweight && a.body != null)
		{
			var contact:b2ContactEdge = a.body.GetContactList();

			while(contact != null)
			{
				world.m_contactListener.EndContact(contact.contact);
				contact = contact.next;
			}
		}
		
		a.removeAllListeners();
		a.resetListeners();
		
		removeActorFromLayer(a, a.layerID);
		
		if (!a.isLightweight)
		{
			a.body.SetAwake(false);
		}*/
	}
	
	public function getRecycledActorOfType(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		/*var a:Actor = null;
		
		if(recycledActorsOfType[type.ID] == null)
		{
			recycledActorsOfType[type.ID] = new HashSet();
		}

		var cache:HashSet = recycledActorsOfType[type.ID];
		
		if(cache != null)
		{
			//Check for next available one O(1)
			//In practice, this doesn't exceed 10-20.
			for each(var actor:Actor in cache)
			{
				if(actor != null && actor.recycled)
				{
					//cache.remove(actor);
					
					actor.recycled = false;
					//actor.body.SetActive(true);
					
					actor.switchToDefaultAnimation();
											
					actor.enableAllBehaviors();
					
					if (!actor.isLightweight)
					{
						actor.body.SetAwake(true);
					}
					
					actor.enableActorDrawing();
					actor.setX(x);
					actor.setY(y);
					actor.setAngle(0, false);
					actor.alpha = 1;
					actor.scale.x = 1;
					actor.scale.y = 1;
					actor.setFilter(null);
					actor.initScripts();
					
					//move to specified layer
					var layerID:int = 0;
					
					if(layerConst == Script.FRONT)
					{
						layerID = getTopLayer();
					}
						
					else if(layerConst == Script.BACK)
					{
						layerID = getBottomLayer();
					}
						
					else
					{
						layerID = getMiddleLayer();
					}
					
					moveActorToLayer(actor, layerID);

					return actor;
				}
			}
			
			//Otherwise make a new one
			a = createActorOfType(type, x, y, layerConst);
			cache.add(a);
		}
		
		return a;*/
		
		return null;
	}
	
	public function createActorOfType(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		/*if(type == null)
		{
			FlxG.log("Tried to create actor with null or invalid type.");
			return null;
		}
		
		var layerID:int = 0;
		
		if(layerConst == Script.FRONT)
		{
			layerID = getTopLayer();
		}
			
		else if(layerConst == Script.BACK)
		{
			layerID = getBottomLayer();
		}
			
		else
		{
			layerID = getMiddleLayer();
		}
		
		var ai:ActorInstance = new ActorInstance
		(
			int.MAX_VALUE,
			x,
			y,
			1,
			1,
			layerID,
			0,
			type.groupID,
			type.ID,
			null,
			false
		);
		
		var a:Actor = createActor(ai, true);
		a.initScripts();
		
		if (whenTypeGroupCreatedListeners[type] != null)
		{
			var listeners:Array = whenTypeGroupCreatedListeners[type] as Array;
			
			for (var r:int = 0; r < listeners.length; r++)
			{
				try
				{
					var f:Function = listeners[r] as Function;
					f(listeners, a);
					
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
		
		if (whenTypeGroupCreatedListeners[a.getGroup()] != null)
		{
			var listeners:Array = whenTypeGroupCreatedListeners[a.getGroup()] as Array;
			
			for (var r:int = 0; r < listeners.length; r++)
			{
				try
				{
					var f:Function = listeners[r] as Function;
					f(listeners, a);
					
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
		
		return a;*/
		
		return null;
	}
	
	//*-----------------------------------------------
	//* Terrain Creation
	//*-----------------------------------------------
	
	public function createDynamicTile(shape:B2Shape, x:Float, y:Float, layerID:Int, width:Float, height:Float)
	{
		/*var a:Actor = new Actor
		(
			this, 
			int.MAX_VALUE,
			Game.TERRAIN_ID,
			x, 
			y, 
			layerID,
			width,
			height, 
			null, 
			new Array(),
			null,
			null, 
			false, 
			true, 
			false,
			false, 
			shape, 
			true
		);
		
		a.name = "Terrain";
		a.visible = false;
		add(a);
		;
		var key:String = "ID"
		key = key.concat("-",toPixelUnits(x).toString(),"-",toPixelUnits(y),"-", layerID.toString());

		dynamicTiles[key] = a;     //keep reference to Tile actor based on position and layer*/
	}
		
	public function getTopLayer():Int
	{
		return layersToDraw.get(topLayer);
	}
	
	public function getBottomLayer():Int
	{
		return layersToDraw.get(bottomLayer);
	}
	
	public function getMiddleLayer():Int
	{
		return layersToDraw.get(middleLayer);
	}
		
		
	//*-----------------------------------------------
	//* Update Loop
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Events Finished
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Timed Tasks
	//*-----------------------------------------------
	
	public function addTask(task:TimedTask)
	{
		tasks.push(task);
	}
	
	public function removeTask(taskToRemove:TimedTask)
	{
		tasks.remove(taskToRemove);
	}	
	
	//*-----------------------------------------------
	//* Pausing
	//*-----------------------------------------------
	
	public function cameraFollow(actor:Actor, lockX:Bool=true, lockY:Bool=true)
	{	
		if(lockX)
		{
			camera.x = Math.round(actor.x + actor.width / 2);
		}
		
		if(lockY)
		{
			camera.y = Math.round(actor.y + actor.height / 2);
		}
	}
	
	//*-----------------------------------------------
	//* Pausing
	//*-----------------------------------------------
	
	public function pause()
	{
		if(isTransitioning())
		{
			return;
		}
		
		paused = true;
		
		for(a in allActors)
		{
			if (a != null)
			{
				a.pause();
			}									
		}
		
		/*for(var r:int = 0; r < whenPausedListeners.length; r++ )
		{
			try
			{
				var f:Function = whenPausedListeners[r] as Function;
				f(whenPausedListeners, true);
			
				if(whenPausedListeners.indexOf(f) == -1)
				{
					r--;
				}
			}
			
			catch(e:Error)
			{
				FlxG.log(e.getStackTrace());
			}
		}*/
	}
	
	public function unpause()
	{
		paused = false;
		
		for(a in allActors)
		{
			if(a != null)
			{
				a.unpause();
			}								
		}
		
		/*for(var r:int = 0; r < whenPausedListeners.length; r++ )
		{
			try
			{
				var f:Function = whenPausedListeners[r] as Function;
				f(whenPausedListeners, false);
			
				if(whenPausedListeners.indexOf(f) == -1)
				{
					r--;
				}
			}
			
			catch(e:Error)
			{
				FlxG.log(e.getStackTrace());
			}
		}*/
	}
	
	public function isPaused():Bool
	{
		return paused;
	}

	//*-----------------------------------------------
	//* Custom Drawing
	//*-----------------------------------------------
	
	//TODO
	
	/**
     * Renders the game.
     * Elements are rendered in the following order:
     * - Background Color
     * - Backgrounds
     * + For each layer:
     * -- The layer itself
     * -- The actors on that layer
     * -- Actor custom drawing
     * -- The User Interface
     * -- Scene custom drawing (Layer)
     * - Foregrounds
     * - Scene custom drawing
     * - Debug drawing
	 * - Transition drawing
         */
	
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
	
	public function say(behaviorName:String, msg:String, args:Array<Dynamic>):Dynamic
	{
		return behaviors.call2(behaviorName, msg, args);
	}
	
	public function shout(msg:String, args:Array<Dynamic>):Dynamic
	{
		return behaviors.call(msg, args);
	}
	
	//*-----------------------------------------------
	//* Actors
	//*-----------------------------------------------
	
	public function getActor(ID:Int):Actor
	{
		return allActors.get(ID);
	}
	
	public function getActorsOfType(type:ActorType):Array<Actor>
	{
		return actorsOfType.get(type.ID);
	}
	
	public function getRecycledActorsOfType(type:ActorType):Array<Actor>
	{
		return recycledActorsOfType.get(type.ID);
	}
	
	public function addAlwaysOnActor(a:Actor)
	{
		addHUDActor(a);
	}
	
	public function addHUDActor(a:Actor)
	{
		hudActors.set(a, a);
	}
	
	public function removeHUDActor(a:Actor)
	{
		hudActors.remove(a);
	}
	
	//*-----------------------------------------------
	//* Actors - Layering
	//*-----------------------------------------------
	
	public function moveToLayerOrder(a:Actor, layerOrder:Int)
	{
		/*var lID:Int;
		lID = layerOrder - 1;

		if(lID < 0 || lID > layersToDraw.length-1) return;
		if(a.layerID == layersToDraw[lID]) return;
		
		lID = layersToDraw[lID];

		removeActorFromLayer(a, a.layerID);
		a.layerID = lID;
		moveActorToLayer(a,lID);*/
	}
	
	public function sendToBack(a:Actor)
	{
		/*removeActorFromLayer(a, a.layerID);
		a.layerID = getBottomLayer();
		moveActorToLayer(a, a.layerID);
	}
	
	public function sendBackward(a:Actor)
	{
		/*removeActorFromLayer(a, a.layerID);
		
		var order:Int = getOrderForLayerID(a.layerID);
		
		if(order < layersToDraw.length - 1)
		{
			a.layerID = layersToDraw[order + 1];	
		}
		
		moveActorToLayer(a, a.layerID);*/
	}
	
	public function bringToFront(a:Actor)
	{
		/*removeActorFromLayer(a, a.layerID);
		a.layerID = getTopLayer();
		moveActorToLayer(a, a.layerID);*/
	}
	
	public function bringForward(a:Actor)
	{
		/*removeActorFromLayer(a, a.layerID);
		
		var order:Int = getOrderForLayerID(a.layerID);
		
		if(order > 0)
		{
			a.layerID = layersToDraw[order - 1];	
		}
		
		moveActorToLayer(a, a.layerID);*/
	}
	
	public function getOrderForLayerID(layerID:Int):Int
	{
		return layerOrders.get(layerID);
	}
	
	public function getIDFromLayerOrder(layerOrder:Int):Int
	{
		return layersToDraw.get(layerOrder - 1);
	}
	
	//*-----------------------------------------------
	//* Physics
	//*-----------------------------------------------
	
	public function getPhysicalWidth():Float
	{
		return physicalWidth;
	}
	
	public function getPhysicalHeight():Float
	{
		return physicalHeight;
	}
	
	static public function toPhysicalUnits(value:Float):Float
	{
		value /= physicsScale;
		
		return value;
	}
	
	static public function toPixelUnits(value:Float):Float
	{
		value *= physicsScale;
		
		return value;
	}
	
	static public function vToPhysicalUnits(v:B2Vec2):B2Vec2
	{
		v.x = toPhysicalUnits(v.x);
		v.y = toPhysicalUnits(v.y);
		
		return v;
	}
	
	static public function vToPixelUnits(v:B2Vec2):B2Vec2
	{
		v.x = toPixelUnits(v.x);
		v.y = toPixelUnits(v.y);
		
		return v;
	}
	
	private function initDebugDraw() 
	{
		/*debugDrawer = new b2DebugDraw();
		debugDrawer.world = world;
		debugDrawer.scale = physicsScale;
		
		addChild(debugDrawer);*/
	}
	
	public function enableGlobalSleeping()
	{
		world.m_allowSleep = true;
	}
	
	public function disableGlobalSleeping()
	{
		world.m_allowSleep = false;
	}
	
	//*-----------------------------------------------
	//* Groups
	//*-----------------------------------------------
	
	public function getGroup(ID:Int, a:Actor = null):Dynamic
	{
		if(ID == -1000 && a != null)
		{
			return groups.get(a.getGroupID());
		}
		
		return groups.get(ID);
	}
	
	//*-----------------------------------------------
	//* Joints
	//*-----------------------------------------------
	
	/*public function nextJointID():int
	{
		var ID:int = -1;

		for each(var j:b2Joint in joints)
		{
			if(j == null) continue;
			ID = Math.max(ID, j.ID);
		}
		
		return ID + 1;
	}
	
	public function addJoint(j:b2Joint):void
	{
		var nextID:int = nextJointID();
		j.ID = nextID;
		joints[nextID] = j;
	}
	
	public function getJoint(ID:int):b2Joint
	{
		return joints[ID];
	}
	
	public function destroyJoint(j:b2Joint):void
	{
		//joints.splice(j.ID,1);
		joints[j.ID] = null;
		world.DestroyJoint(j as b2Joint);
	}
	
	//---
	
	public function createStickJoint
	(
		one:b2Body, 
		two:b2Body, 
		jointID:int = -1, 
		collide:Boolean = false, 
		damping:Number = 0, 
		frequencyHz:Number = 0
	):b2DistanceJoint
	{
		var v1:V2 = one.GetLocalCenter()
		var v2:V2 = two.GetLocalCenter();
		
		if(one.GetType() == 0)
		{
			v1.x = (one.GetUserData() as Actor).getPhysicsWidth() / 2;
			v1.y = (one.GetUserData() as Actor).getPhysicsHeight() / 2;
		}
		
		if(two.GetType() == 0)
		{
			v2.x = (two.GetUserData() as Actor).getPhysicsWidth() / 2;
			v2.y = (two.GetUserData() as Actor).getPhysicsHeight() / 2;
		}
		
		v1 = one.GetWorldPoint(v1);
		v2 = two.GetWorldPoint(v2);
		
		var jd:b2DistanceJointDef = new b2DistanceJointDef();
		jd.Initialize(one, two, v1, v2);
		jd.collideConnected = collide;
		jd.dampingRatio = damping;
		jd.frequencyHz = frequencyHz;
		
		var toReturn:b2Joint = world.CreateJoint(jd);
		
		if(jointID == -1)
		{
			addJoint(toReturn);
		}
			
		else
		{
			joints[jointID] = toReturn;
			toReturn.ID = jointID;
		}
		
		return toReturn as b2DistanceJoint;
	}
	
	public function createCustomStickJoint
	(
		one:b2Body,
		x1:Number, 
		y1:Number, 
		two:b2Body, 
		x2:Number, 
		y2:Number
	):b2DistanceJoint
	{
		var v1:V2 = new V2(x1, y1);
		var v2:V2 = new V2(x2, y2);
		
		v1.x = GameState.toPhysicalUnits(v1.x);
		v1.y = GameState.toPhysicalUnits(v1.y);
		v2.x = GameState.toPhysicalUnits(v2.x);
		v2.y = GameState.toPhysicalUnits(v2.y);
		
		v1 = one.GetWorldPoint(v1);
		v2 = two.GetWorldPoint(v2);
		
		var jd:b2DistanceJointDef = new b2DistanceJointDef();
		jd.Initialize(one, two, v1, v2);
		
		var toReturn:b2Joint = world.CreateJoint(jd);
		addJoint(toReturn);
		
		return toReturn as b2DistanceJoint;
	}
	
	//---
	
	public function createHingeJoint
	(
		one:b2Body, 
		two:b2Body = null, 
		pt:V2 = null, 
		jointID:int = -1,
		collide:Boolean = false, 
		limit:Boolean = false, 
		motor:Boolean = false, 
		lower:Number = 0, 
		upper:Number = 0, 
		torque:Number = 0, 
		speed:Number = 0
	):b2RevoluteJoint
	{
		if(two == null)
		{
			two = world.m_groundBody;
		}
		
		if(pt == null)
		{
			pt = one.GetLocalCenter();
		}
	
		var jd:b2RevoluteJointDef = new b2RevoluteJointDef();
		
		jd.bodyA = one;
		jd.bodyB = two;
		
		pt.x = GameState.toPhysicalUnits(pt.x);
		pt.y = GameState.toPhysicalUnits(pt.y);
		
		jd.localAnchorA.v2 = pt;
		jd.localAnchorB.v2 = two.GetLocalPoint(one.GetWorldPoint(pt));
		jd.collideConnected = collide;
		jd.enableLimit = limit;
		jd.enableMotor = motor;
		jd.lowerAngle = lower;
		jd.upperAngle = upper;
		jd.maxMotorTorque = torque;
		jd.motorSpeed = speed;
		
		var toReturn:b2Joint = world.CreateJoint(jd);
		
		if(jointID == -1)
		{
			addJoint(toReturn);
		}
			
		else
		{
			joints[jointID] = toReturn;
			toReturn.ID = jointID;
		}
		
		return toReturn as b2RevoluteJoint;
	}
	
	//---
											
	public function createSlidingJoint
	(
		one:b2Body, 
		two:b2Body = null, 
		dir:V2 = null, 
		jointID:int = -1,
		collide:Boolean = false, 
		limit:Boolean = false, 
		motor:Boolean = false, 
		lower:Number = 0, 
		upper:Number = 0, 
		force:Number = 0, 
		speed:Number = 0
	):b2LineJoint
	{
		if(two == null)
		{
			two = world.m_groundBody;
		}
		
		if(dir == null)
		{
			dir = new V2(1, 0);
		}
	
		dir.normalize();
		
		var pt1:V2 = one.GetWorldCenter();
		var pt2:V2 = two.GetWorldCenter();
		
		//Static body
		if(one.GetType() == 0)
		{
			if((one.GetUserData() as Actor) != null)
			{
				pt1.x = (one.GetUserData() as Actor).getPhysicsWidth() / 2;
				pt1.y = (one.GetUserData() as Actor).getPhysicsHeight() / 2;
				pt1 = one.GetWorldPoint(pt1);	
			}
		}
		
		if(two.GetType() == 0)
		{
			if((two.GetUserData() as Actor) != null)
			{
				pt2.x = (two.GetUserData() as Actor).getPhysicsWidth() / 2;
				pt2.y = (two.GetUserData() as Actor).getPhysicsHeight() / 2;
				pt2 = two.GetWorldPoint(pt2);	
			}
		}
		
		var pjd:b2LineJointDef = new b2LineJointDef();
		pjd.Initialize(one, two, pt1, dir);

		pjd.collideConnected = collide;
		pjd.enableLimit = limit;
		pjd.enableMotor = motor;
		pjd.lowerTranslation = toPhysicalUnits(lower);
		pjd.upperTranslation = toPhysicalUnits(upper);
		pjd.maxMotorForce = force;
		pjd.motorSpeed = toPhysicalUnits(speed);
		
		var toReturn:b2Joint = world.CreateJoint(pjd);
		
		if(jointID == -1)
		{
			addJoint(toReturn);
		}
			
		else
		{
			joints[jointID] = toReturn;
			toReturn.ID = jointID;
		}
		
		return toReturn as b2LineJoint;
	}*/
			
	//*-----------------------------------------------
	//* Regions
	//*-----------------------------------------------
	
	/*private function createRegion(x:Number, y:Number, shape:b2Shape, offset:Boolean=false):Region
	{
		var shapeList:Array = new Array(shape);
		var region:Region = new Region(this, x, y, shapeList);
		
		if(offset)
		{
			region.setX(GameState.toPixelUnits(x) + region.width / 2);
			region.setY(GameState.toPixelUnits(y) + region.height / 2);
		}
		
		addRegion(region);
		return region;
	}
	
	public function createBoxRegion(x:Number, y:Number, w:Number, h:Number):Region
	{
		x = GameState.toPhysicalUnits(x);
		y = GameState.toPhysicalUnits(y);
		w = GameState.toPhysicalUnits(w);
		h = GameState.toPhysicalUnits(h);
	
		var p:b2PolygonShape = new b2PolygonShape();
		p.SetAsBox(w/2, h/2);
		
		return createRegion(x, y, p, true);
	}
	
	public function createCircularRegion(x:Number, y:Number, r:Number):Region
	{
		x = GameState.toPhysicalUnits(x);
		y = GameState.toPhysicalUnits(y);
		r = GameState.toPhysicalUnits(r);
		
		var cShape:b2CircleShape = new b2CircleShape();
		cShape.m_radius = r;
		
		return createRegion(x, y, cShape, true);
	}
	
	public function addRegion(r:Region):void
	{
		var nextID:int = nextRegionID();
		r.ID = nextID;
		regions[nextID] = r;
	}
	
	public function removeRegion(ID:int):void
	{
		var r:Region = getRegion(ID);	
		//regions.splice(r.ID, 1);
		regions[r.ID] = null;
		r.destroy();
	}
	
	public function getRegion(ID:int):Region
	{
		return regions[ID];
	}
	
	public function getRegions(ID:int):Array
	{
		return regions;
	}
	
	public function nextRegionID():int
	{
		var ID:int = -1;
		
		for each(var r:Region in regions)
		{
			if(r == null) continue;
			ID = Math.max(ID, r.ID);
		}
		
		return ID + 1;
	}
	
	public function isInRegion(a:Actor, r:Region):Boolean
	{			
		if(r != null && regions[r.getID()] != null)
		{
			return ((r as Region).containsActor(a))
		}
			
		else
		{
			FlxG.log("Region does not exist.");
			return false;
		}
	}*/
	
	//*-----------------------------------------------
	//* Terrain Regions
	//*-----------------------------------------------
	
	/*private function createTerrainRegion(x:Number, y:Number, shape:b2Shape, offset:Boolean=false, groupID:int = 1):TerrainRegion
	{
		var shapeList:Array = new Array(shape);
		var terrainRegion:TerrainRegion = new TerrainRegion(this, x, y, shapeList, groupID);
		
		if(offset)
		{
			terrainRegion.setX(GameState.toPixelUnits(x) + terrainRegion.width / 2);
			terrainRegion.setY(GameState.toPixelUnits(y) + terrainRegion.height / 2);
		}
		
		addTerrainRegion(terrainRegion);
		return terrainRegion;
	}
	
	public function createBoxTerrainRegion(x:Number, y:Number, w:Number, h:Number, groupID:int=1):TerrainRegion
	{
		x = GameState.toPhysicalUnits(x);
		y = GameState.toPhysicalUnits(y);
		w = GameState.toPhysicalUnits(w);
		h = GameState.toPhysicalUnits(h);
	
		var p:b2PolygonShape = new b2PolygonShape();
		p.SetAsBox(w/2, h/2);
		
		return createTerrainRegion(x, y, p, true, groupID);
	}
	
	public function createCircularTerrainRegion(x:Number, y:Number, r:Number, groupID:int = 1):TerrainRegion
	{
		x = GameState.toPhysicalUnits(x);
		y = GameState.toPhysicalUnits(y);
		r = GameState.toPhysicalUnits(r);
		
		var cShape:b2CircleShape = new b2CircleShape();
		cShape.m_radius = r;
		
		return createTerrainRegion(x, y, cShape, true, groupID);
	}
	
	public function addTerrainRegion(r:TerrainRegion):void
	{
		var nextID:int = nextTerrainRegionID();
		r.ID = nextID;
		terrainRegions[nextID] = new Array(r);
	}
	
	public function removeTerrainRegion(ID:int):void
	{
		var t:TerrainRegion = getTerrainRegion(ID);
		
		terrainRegions[ID] = null;
		
		t.destroy();
	}
	
	public function getTerrainRegion(ID:int):TerrainRegion
	{
		return terrainRegions[ID];
	}
	
	public function getTerrainRegions(ID:int):Array
	{
		return terrainRegions;
	}
	
	public function nextTerrainRegionID():int
	{
		var ID:int = -1;
		
		for each(var r:TerrainRegion in terrainRegions)
		{
			if(r == null) continue;
			ID = Math.max(ID, r.ID);
		}
		
		return ID + 1;
	}*/
	
	//*-----------------------------------------------
	//* Game Attributes
	//*-----------------------------------------------
	
	public function setGameAttribute(name:String, value:Dynamic)
	{
		gameAttributes.set(name, value);
	}
	
	public function getGameAttribute(name:String):Dynamic
	{
		return gameAttributes.get(name);
	}
	
	//*-----------------------------------------------
	//* On/Off Screen
	//*-----------------------------------------------
	
	/*
	
	public function setOffscreenTolerance(top:int, left:int, bottom:int, right:int):void
	{
		this.top = top;
		this.left = left;
		this.bottom = bottom;
		this.right = right;
	}
	
	private function fetchActorsToRender():int
	{
		actorsOnScreen = cacheActors();
		
		for each(var curr:Actor in actorsOnScreen)
		{
			if(curr != null && curr.body != null && curr.currSprite != null)
			{
				curr.currSprite.exists = (curr.body.IsActive() || curr.paused) && !curr.recycled;
			}
		}
		
		return 0;
	}
	
	public function cacheActors():Array
	{
		for each(var a:Actor in hudActors)
		{
			if(a == null || a.dead)
			{
				hudActors.remove(a);
			}
		}
		
		return allActors;
	}
	
	private function initLayers():void
	{
		var layers:Array = new Array();
		var orders:Array = new Array();
		var exists:HashSet = new HashSet();
		tileLayers = scene.terrain;
		animatedTiles = scene.animatedTiles;
		
		for each (var tile:Tile in animatedTiles)
		{
			tile.currFrame = 0;
			tile.currTime = 0;
		}
		
		for each(var l:TileLayer in scene.terrain)
		{
			layers[l.zOrder] = l.layerID;
			orders[l.layerID] = l.zOrder;
			exists.add(l.zOrder);
		}
		
		for(var i:int = 0; i < layers.length; i++)
		{
			if(!exists.has(i))
			{
				layers[i] = -1;
			}
		}
		
		layersToDraw = layers;
		layerOrders = orders;
		
		var foundTop:Boolean = false;
		var foundMiddle:Boolean = false;
		
		var realNumLayers:int = 0;
		
		//Figure out how many there actually are
		for(i = 0; i < layers.length; i++)
		{
			var layerID:int = layersToDraw[i];
			
			if(layerID != -1)
			{
				realNumLayers++;
			}
		}
		
		var numLayersProcessed:int = 0;
		
		for(i = 0; i < layers.length; i++)
		{
			var layerID:int = layersToDraw[i];
			
			if(layerID == -1)
			{
				continue;
			}
			
			var list:FlxGroup = new FlxGroup();
			var terrain:FlxGroup = new Layer(layerID, i, scene.terrain[layerID]);
			
			if(!foundTop)
			{
				foundTop = true;
				topLayer = i;
			}
			
			if(!foundMiddle && numLayersProcessed == Math.floor(realNumLayers / 2))
			{
				foundMiddle = true;
				middleLayer = i;
			}

			add(terrain);
			
			//FlxG.log("layerID: " + layerID +  " === order: " + i);
			
			this.layers[layerID] = terrain;
			actorsToRender[layerID] = list;
			
			//Eventually, this will become the correct value
			bottomLayer = i;
			
			numLayersProcessed++;
		}
	}
	
	*/
}
