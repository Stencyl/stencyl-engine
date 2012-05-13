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

import com.stencyl.models.scene.DeferredActor;
import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.Layer;
import com.stencyl.models.scene.TileLayer;
import com.stencyl.models.scene.ScrollingBitmap;

import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.background.ScrollingBackground;

import scripts.MyScripts;

import com.stencyl.utils.Utils;
import com.stencyl.utils.HashMap;
import com.stencyl.utils.SizedIntHash;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;

import box2D.dynamics.B2World;
import box2D.common.math.B2Vec2;
import box2D.dynamics.joints.B2Joint;
import box2D.dynamics.B2DebugDraw;
import box2D.collision.B2AABB;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;


class Engine 
{
	//*-----------------------------------------------
	//* Constants
	//*-----------------------------------------------
		
	public static var BACKGROUND:String = "b";
	public static var REGULAR_LAYER:String = "l";
	public static var DOODAD:String = "";
	
	
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
	
	public static var screenWidthHalf:Int;
	public static var screenHeightHalf:Int;
	
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
	//* Shaking
	//*-----------------------------------------------
	
	public var shakeTimer:Int;
	public var shakeIntensity:Float;
	public var isShaking:Bool;
	
		
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
	public var defaultGroup:Sprite; //The default layer (bottom-most)
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
	public var actorsToCreateInNextScene:Array<DeferredActor>;
	
	//TODO: Map<String, Layer>
	
	
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
	public var layersToDraw:SizedIntHash<Int>;
	public var layerOrders:SizedIntHash<Int>;		
	
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
	
	public var whenFocusChangedListeners:Array<Dynamic>;
	
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------

	public function new(root:Sprite) 
	{		
		Engine.engine = this;
		this.root = root;
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);
		begin(0);
	}
	
	public function begin(initSceneID:Int)
	{		
		Input.enable();
		Data.get();
		GameModel.get();
			
		//---
			
		started = true;
		
		//---
		
		shakeTimer = 0;
		shakeIntensity = 0.01;
		isShaking = false;
	
		//---
		
		leave = null;
		enter = null;
		
		cameraX = 0;
		cameraY = 0;

		acc = 0;
		lastTime = Lib.getTimer() / MS_PER_SEC;

		//Constants
		Engine.sceneWidth = 640; //Overriden once scene loads
		Engine.sceneHeight = 480; //Overriden once scene loads
		Engine.screenWidth = Std.int(stage.stageWidth);
		Engine.screenHeight = Std.int(stage.stageHeight);
		Engine.screenWidthHalf = Std.int(stage.stageWidth/2);
		Engine.screenHeightHalf = Std.int(stage.stageHeight/2);
			
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
		setOffscreenTolerance(0, 0, 0, 0);
		
		tasks = new Array<TimedTask>();
		
		scene = GameModel.get().scenes.get(sceneID);
		
		if(sceneID == -1 || scene == null)
		{
			scene = GameModel.get().scenes.get(GameModel.get().defaultSceneID);
		}
		
		Engine.sceneWidth = scene.sceneWidth;
		Engine.sceneHeight = scene.sceneHeight;
		
		behaviors = new BehaviorManager();
		
		groups = new IntHash<DisplayObjectContainer>();
		
		for(grp in GameModel.get().groups)
		{
			var g = new Sprite();
			groups.set(grp.ID, g);
			g.name = grp.name;
		}
		
		actorsOfType = new IntHash<Array<Actor>>();
		recycledActorsOfType = new IntHash<Array<Actor>>();
		
		regions = new IntHash<Region>();
		terrainRegions = new IntHash<Terrain>();
		joints = new IntHash<B2Joint>();
		layers = new IntHash<Layer>();
		tileLayers = new IntHash<TileLayer>();
		dynamicTiles = new Hash<Actor>();
		animatedTiles = new Array<Tile>();
		hudActors = new HashMap<Actor,Actor>();
		allActors = new IntHash<Actor>();
		actorsPerLayer = new IntHash<DisplayObjectContainer>();
		nextID = 0;
		
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
		whenFocusChangedListeners = new Array();
											
		initPhysics();
		loadBackgrounds();
		loadTerrain();
		loadRegions();
		loadTerrainRegions();
		loadActors();			
		loadCamera();
		loadJoints();
		
		loadDeferredActors();
		//actorsOnScreen = cacheActors();		
		initBehaviors(behaviors, scene.behaviorValues, this, this, true);			
		initActorScripts();
	}
		
	private function loadBackgrounds()
	{
		var bg = new Shape();
		scene.colorBackground.draw(bg.graphics, 0, 0, screenWidth, screenHeight);
		master.addChild(bg);
		
		for(backgroundID in scene.bgs)
		{
			var background = cast(Data.get().resources.get(backgroundID), ImageBackground);
			
			if(background == null || background.img == null)
			{
				trace("Warning: Could not load a background. Ignoring...");
	            continue;
			}
			
			if(Std.is(background, ScrollingBackground))
			{
				var scroller = cast(background, ScrollingBackground);
				var img = new ScrollingBitmap(background.img, scroller.xVelocity, scroller.yVelocity);
				img.name = BACKGROUND;
				master.addChild(img);
			}
			
			else
			{
				if(background.repeats)
				{
					var img = new Bitmap();
					background.drawRepeated(img, screenWidth, screenHeight);
					
					img.name = BACKGROUND;
					master.addChild(img);
				}
				
				else
				{
					var img = new Bitmap(background.img);
					img.name = BACKGROUND;
					master.addChild(img);
				}
			}
		}
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
		
		debugDrawer = new B2DebugDraw();
		debugDrawer.setSprite(new Sprite());
		world.setDebugDraw(debugDrawer);
		master.addChild(debugDrawer.m_sprite);
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
			Script.lastCreatedActor = createActorOfType(a.type, a.x, a.y, a.layer);
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
		camera = new Actor(this, -1, GameModel.DOODAD_ID, 0, 0, getTopLayer(), 2, 2, null, null, null, null, true, false, true, false, null, 0, true, false);
		camera.name = "Camera";
		camera.isCamera = true;
		
		//TODO?
		//FlxG.followBounds(0, 0, scene.sceneWidth, scene.sceneHeight);
	}
	
	private function loadRegions()
	{					
		regions = new IntHash<Region>();

		for(r in scene.regions)
		{
			var region:Region = new Region(this, r.x, r.y, r.shapes);
			region.name = r.name;
			
			region.setX(Engine.toPixelUnits(r.x) + (region.width / 2));
			region.setY(Engine.toPixelUnits(r.y) + (region.height / 2));
			
			region.ID = r.ID;
			
			addRegion(region);
			regions.set(r.ID, region);
		}
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
		initLayers();
		
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
	
	//This is mainly to establish mappings and figure out top, middle, bottom
	private function initLayers()
	{
		var layers = new SizedIntHash<Int>();
		var orders = new SizedIntHash<Int>();
		var exists = new SizedIntHash<Int>();
		
		tileLayers = scene.terrain;
		animatedTiles = scene.animatedTiles;
		
		if(animatedTiles != null)
		{
			for(tile in animatedTiles)
			{
				tile.currFrame = 0;
				tile.currTime = 0;
			}
		}
		
		if(scene.terrain != null)
		{
			for(l in scene.terrain)
			{
				layers.set(l.zOrder, l.layerID);
				orders.set(l.layerID, l.zOrder);
				exists.set(l.zOrder, l.zOrder);
			}
		}
		
		for(i in 0...layers.size)
		{
			if(!exists.exists(i))
			{
				layers.set(i, -1);
			}
		}
		
		layersToDraw = layers;
		layerOrders = orders;
		
		var foundTop:Bool = false;
		var foundMiddle:Bool = false;
		var realNumLayers:Int = 0;
		
		//Figure out how many there actually are
		for(i in 0...layers.size)
		{
			var layerID:Int = layersToDraw.get(i);
			
			if(layerID != -1)
			{
				realNumLayers++;
			}
		}
		
		var numLayersProcessed:Int = 0;
		
		for(i in 0...layers.size)
		{
			var layerID:Int = layersToDraw.get(i);
			
			if(layerID == -1)
			{
				continue;
			}
			
			var list = new Sprite();
			var terrain = null;
			
			if(scene.terrain != null)
			{
				terrain = new Layer(layerID, i, scene.terrain.get(layerID));
			}
			
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

			if(terrain != null)
			{
				terrain.name = REGULAR_LAYER;
				master.addChild(terrain);
				this.layers.set(layerID, terrain);
			}
				
			list.name = REGULAR_LAYER;
			master.addChild(list);
			
			actorsPerLayer.set(layerID, list);
			
			//Eventually, this will become the correct value
			bottomLayer = i;
			defaultGroup = list;
			
			numLayersProcessed++;
		}
		
		//For scenes with no scene data
		if(defaultGroup == null)
		{
			defaultGroup = new Sprite();
			defaultGroup.name = REGULAR_LAYER;
			master.addChild(defaultGroup);
		}
	}

	//*-----------------------------------------------
	//* Scene Switching
	//*-----------------------------------------------
	
	public function cleanup()
	{
		debugDrawer.m_sprite.graphics.clear();
		
		Utils.removeAllChildren(master);
		Utils.removeAllChildren(transitionLayer);
					
		behaviors.destroy();
	
		for(group in actorsPerLayer)
		{
			Utils.removeAllChildren(group);
		}
		
		//--
		
		camera.destroy();
		camera = null;
		
		//--
		
		//Kill the remaining ones
		var worldbody = world.getBodyList();
		var j = world.getJointList();
		
		while(worldbody != null)
		{
			world.destroyBody(worldbody);
			worldbody = worldbody.getNext();
		}
		
		while(j != null)
		{
			world.destroyJoint(j);
			j.getNext();
		}
		
		for(set in actorsOfType)
		{
			Utils.clear(set);
		}
		
		for(set in recycledActorsOfType)
		{
			Utils.clear(set);
		}
		
		actorsOfType = null;
		recycledActorsOfType = null;
		
		hudActors = null;
		layers = null;
		actorsPerLayer = null;
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
		
		//Reset
		Input.update();
		
		world = null;
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
		var s:com.stencyl.models.actor.Sprite = cast(Data.get().resources.get(ai.actorType.spriteID), com.stencyl.models.actor.Sprite);
	
		var a:Actor = new Actor
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
			null, //TODO: ai.actorType.bodyDef,
			false,
			false,
			false,
			false,
			null,
			ai.actorType.ID,
			true, //TODO: ai.actorType.isLightweight,
			ai.actorType.autoScale
		);

		if(ai.angle != 0)
		{
			a.setAngle(ai.angle + 180, false);
		}	
		
		if(ai.scaleX != 1 || ai.scaleY != 1)
		{
			a.growTo(ai.scaleX, ai.scaleY, 0);
		}
		
		a.name = ai.actorType.name;
		
		moveActorToLayer(a, ai.layerID);
		
		//---
		
		var group = groups.get(ai.groupID);
		
		if(group != null)
		{
			group.addChild(a);
		}
		
		//---

		//Use the next available ID
		if(ai.elementID == Utils.NUMBER_MAX_VALUE)
		{
			nextID++;
			a.ID = nextID;
			allActors.set(a.ID, a);
		}
		
		else
		{
			allActors.set(a.ID, a);
			nextID = Std.int(Math.max(a.ID, nextID));
		}

		a.internalUpdate(0, false);
		
		//---
			
		//Add to type cache
		if(ai.actorType != null)
		{
			var cache = actorsOfType.get(ai.actorType.ID);
			
			if(cache == null)
			{
				cache = new Array<Actor>();
				actorsOfType.set(ai.actorType.ID, cache);
			}
			
			if(cache != null)
			{
				cache.push(a);
			}
		}
		
		//---
			
		master.addChild(a);
		
		return a;
	}
	
	public function removeActor(a:Actor)
	{
		allActors.remove(a.ID);

		//Remove from the layer group
		removeActorFromLayer(a, a.layerID);
		
		//Remove from normal group
		groups.get(a.getGroupID()).removeChild(a);
		
		if(a.isHUD || a.alwaysSimulate)
		{
			hudActors.delete(a);
		}
		
		a.destroy();
		
		//---
		
		var typeID:ActorType = cast(Data.get().resources.get(a.typeID), ActorType);
		
		if(typeID != null)
		{
			var cache = actorsOfType.get(typeID.ID);
			
			if(cache != null)
			{
				cache.remove(a);
			}
		}
	}
	
	private function removeActorFromLayer(a:Actor, layerID:Int)
	{
		var layer = actorsPerLayer.get(layerID);
		
		if(layer == null)
		{
			trace("Assuming default group");
			layer = defaultGroup;
		}
		
		layer.removeChild(a);
	}
	
	private function moveActorToLayer(a:Actor, layerID:Int)
	{
		var layer = actorsPerLayer.get(layerID);
		
		if(layer == null)
		{
			trace("Putting actor inside default group");
			layer = defaultGroup;
		}

		//To ensure that it draws after.
		layer.addChild(a);
	}
	
	public function recycleActor(a:Actor)
	{
		a.setX(1000000);
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
			var contact:B2ContactEdge = a.body.getContactList();
			
			while(contact != null)
			{	
				Engine.engine.world.m_contactManager.m_contactListener.endContact(contact.contact);
				contact = contact.next;
			}
		}
		
		a.removeAllListeners();
		a.resetListeners();
		
		removeActorFromLayer(a, a.layerID);
		
		if(!a.isLightweight)
		{
			a.body.setAwake(false);
		}
	}
	
	public function getRecycledActorOfType(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		var a:Actor = null;
		
		if(recycledActorsOfType.get(type.ID) == null)
		{
			//This ought to be a HashSet instead
			recycledActorsOfType.set(type.ID, new Array<Actor>());
		}

		var cache = recycledActorsOfType.get(type.ID);
		
		if(cache != null)
		{
			//Check for next available one O(1)
			//In practice, this doesn't exceed 10-20.
			for(actor in cache)
			{
				if(actor != null && actor.recycled)
				{
					actor.recycled = false;
					actor.switchToDefaultAnimation();						
					actor.enableAllBehaviors();
					
					if(!actor.isLightweight)
					{
						actor.body.setAwake(true);
					}
					
					actor.enableActorDrawing();
					actor.setX(x);
					actor.setY(y);
					actor.setAngle(0, false);
					actor.alpha = 1;
					actor.scaleX = 1;
					actor.scaleY = 1;
					actor.setFilter(null);
					actor.initScripts();
					
					//move to specified layer
					var layerID = 0;
					
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
			cache.push(a);
		}
		
		return a;
	}
	
	public function createActorOfType(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		if(type == null)
		{
			trace("Tried to create actor with null or invalid type.");
			return null;
		}
		
		var layerID = 0;
		
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
			-1,
			Std.int(x),
			Std.int(y),
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
		
		var f1 = whenTypeGroupCreatedListeners.get(type);
		var f2 = whenTypeGroupCreatedListeners.get(a.getGroup());
		
		if(f1 != null)
		{
			invokeListeners2(f1, a);
		}
		
		if(f2 != null)
		{
			invokeListeners2(f2, a);
		}
		
		return a;
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
				
	/*if(Input.multiTouchEnabled)
	{
		for(elem in Input.multiTouchPoints)
		{
			trace(elem.eventPhase + "," + elem.stageX + "," + elem.stageY);
		}
	}*/
	
	public function update(elapsedTime:Float)
	{
		if(scene == null)
		{
			trace("Scene is null");
			return;
		}
		
		//TODO: This is inefficient to recalculate each frame.
		/*var aabb:AABB = world.GetScreenBounds();
		aabb.lowerBound.x = (Math.abs(FlxG.scroll.x) - left) / physicsScale;
		aabb.lowerBound.y = (Math.abs(FlxG.scroll.y) - top) / physicsScale;
		aabb.upperBound.x = aabb.lowerBound.x + ((FlxG.width + right + left) / physicsScale);
		aabb.upperBound.y = aabb.lowerBound.y + ((FlxG.height + bottom + top) / physicsScale);
		world.SetScreenBounds(aabb);*/
		
				
		if(Input.mousePressed)
		{
			Script.mpx = Input.mouseX;
			Script.mpy = Input.mouseY;
			invokeListeners(whenMousePressedListeners);
		}
		
		if(Input.mouseReleased)
		{
			Script.mrx = Input.mouseX;
			Script.mry = Input.mouseY;
			invokeListeners(whenMouseReleasedListeners);
		}
		
		if(mx != Input.mouseX || my != Input.mouseY)
		{
			mx = Input.mouseX;
			my = Input.mouseY;
			
			invokeListeners(whenMouseMovedListeners);
			
			if(Input.mouseDown)
			{
				invokeListeners(whenMouseDraggedListeners);
			}
		}				
		
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
		
		//Poll Keyboard Inputs
		/*for (var key:String in whenKeyPressedListeners)
		{
			var k:String = Game.get().controller["_" + key];
			
			if (k == null)
			{
				continue;
			}
			
			var listeners:Array = whenKeyPressedListeners[key] as Array;
			
			var pressed:Boolean = FlxG.keys.justPressed(k);
			var released:Boolean = FlxG.keys.justReleased(k);
			
			if (pressed || released)
			{
				for (var i:int = 0; i < listeners.length; i++)
				{
					try
					{
						var f:Function = listeners[i] as Function;					
						f(listeners, pressed, released);
						
						if (listeners.indexOf(f) == -1)
						{
							i--;
						}
					}
					catch (e:Error)
					{
						FlxG.log(e.getStackTrace);
					}
					
				}
			}				
		}*/
		
		invokeListeners2(whenUpdatedListeners, elapsedTime);
		

		//world.Step(STEP_SIZE, 3, 8);

		/*for each(var r:Region in regions)
		{
			if(r == null) continue;
			r.innerUpdate(true);
		}*/
		
		//collisionPairs = new Dictionary();
		var disableCollisionList = new Array<Actor>();

		//TODO:
		//for(a in actorsOnScreen)
		for(a in actors)
		{		
			if(a != null && !a.dead && !a.recycled) 
			{
				if(!a.isLightweight && a.body != null)
				{
					if(a.killLeaveScreen && !a.isOnScreen())
					{							
						a.die();
					}
					
					else if(a.body.isActive())
					{		
						a.innerUpdate(elapsedTime, true);							
					}
				}
				
				else if(a.isLightweight)
				{
					if(a.killLeaveScreen && !a.isOnScreen())
					{
						a.die();
					}
					
					else if(a.isAlive())
					{		
						a.innerUpdate(elapsedTime, true);
					}
				}
				
				if(a.dead)
				{
					disableCollisionList.push(a);
				}
			}
		}
					
		for(a2 in hudActors)
		{
			if(a2 != null && (a2.isLightweight || (a2.body != null && a2.body.isActive())) && !a2.dead && !a2.recycled)
			{
				a2.innerUpdate(elapsedTime, false);
			}
		}
		
		for(a in disableCollisionList)
		{
			if(a != null)
			{
				a.handlesCollisions = false;
			}
		}
		
		for(tile in animatedTiles)
		{
			tile.update(elapsedTime);
		}
		
		if(leave != null && leave.isActive())
		{
			leave.update(elapsedTime);
		}
			
		else if(enter != null && enter.isActive())
		{
			enter.update(elapsedTime);
		} 

		//---
		
		//Camera Control
		cameraX = -Math.abs(camera.x) + screenWidthHalf;
		cameraY = -Math.abs(camera.y) + screenHeightHalf;
		
		//Position Limiter - Never go past 0 (which would be fully to the right/bottom)
		var maxCamX = -Engine.sceneWidth + screenWidthHalf;
		var maxCamY = -Engine.sceneHeight + screenHeightHalf;
		
		if(cameraX < maxCamX)
		{
			cameraX = maxCamX;
		} 
		
		if(cameraY < maxCamY)
		{
			cameraY = maxCamY;
		}
		
		//Position Limiter - Never go past 0 (which would be fully to the right/bottom)
		cameraX = Math.min(screenWidthHalf, cameraX);
		cameraY = Math.min(screenHeightHalf, cameraY);
		
		for(i in 0...master.numChildren)
		{
			var child = master.getChildAt(i);
			
			//Background
			if(child.name == BACKGROUND)
			{
				if(Std.is(child, ScrollingBitmap))
				{
					var bg = cast(child, ScrollingBitmap);
					bg.update(elapsedTime);
				}
				
				else
				{
					var endX = -Math.abs(child.width - Engine.screenWidth);
					var endY = -Math.abs(child.height - Engine.screenHeight);
					
					child.x = endX * -(cameraX - screenWidthHalf) / Engine.sceneWidth;
					child.y = endY * -(cameraY - screenHeightHalf) / Engine.sceneHeight;
				}
			}
			
			//Regular Layer
			else if(child.name == REGULAR_LAYER)
			{
				child.x = cameraX;
				child.y = cameraY;
			}
			
			//Something that doesn't scroll
			else
			{
				continue;
			}
		}
		
		//Shaking
		if(isShaking)
		{
			shakeTimer -= 10;
        
	        if(shakeTimer <= 0)
	        {
	        	stopShakingScreen();
	            return;
	        }
	        
	        var randX = (-shakeIntensity * Engine.screenWidth + Math.random() * (2 * shakeIntensity * Engine.screenWidth));
	        var randY = (-shakeIntensity * Engine.screenHeight + Math.random() * (2 * shakeIntensity * Engine.screenHeight));
	        
	        master.x = randX;
	        master.y = randY;
		}
		
		//TODO: Should we do it here or outside?
		//Input.update();
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
			update(STEP_SIZE * MS_PER_SEC);
			acc -= STEP_SIZE;
			
			Input.update();
		}	
		
		lastTime = currTime;
			
		//On screen flag reset
		for(a in allActors)
		{
			if(a == null || (!a.isLightweight && a.body == null))
			{
				continue;
			}
			
			if(a.dead || a.dying)
			{
				removeActor(a);
				continue;
			}
			
			if(a.body == null)
			{
				continue;
			}
		}
	}
	
	//*-----------------------------------------------
	//* Events Finished
	//*-----------------------------------------------
	
	//???
	
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
	//* Effects
	//*-----------------------------------------------
	
	public function shakeScreen(intensity:Float, duration:Float)
	{
		shakeTimer = Std.int(1000 * duration);
	    isShaking = true;
	    shakeIntensity = intensity;
	}
	
	public function stopShakingScreen()
	{
		shakeTimer = 0;
	    isShaking = false;
	    
	    master.x = 0;
	    master.y = 0;
	}
	
	//*-----------------------------------------------
	//* Camera
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
		
		invokeListeners2(whenPausedListeners, true);
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
		
		invokeListeners2(whenPausedListeners, false);
	}
	
	public function isPaused():Bool
	{
		return paused;
	}

	//*-----------------------------------------------
	//* Custom Drawing
	//*-----------------------------------------------
	
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
      
     //The display tree does almost everything now. We only need to invoke the behavior drawers.
     public function render()
     {
     	//TODO:
     	
     	//Clear each of the layer surfaces
     	
     	//Walk through each of the drawing events
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
		hudActors.delete(a);
	}
	
	//*-----------------------------------------------
	//* Actors - Layering
	//*-----------------------------------------------
	
	public function moveToLayerOrder(a:Actor, layerOrder:Int)
	{
		var lID = layerOrder - 1;

		if(lID < 0 || lID > layersToDraw.size - 1) 
		{
			return;
		}
			
		if(a.layerID == layersToDraw.get(lID)) 
		{
			return;
		}
		
		lID = layersToDraw.get(lID);

		removeActorFromLayer(a, a.layerID);
		a.layerID = lID;
		moveActorToLayer(a,lID);
	}
	
	public function sendToBack(a:Actor)
	{
		removeActorFromLayer(a, a.layerID);
		a.layerID = getBottomLayer();
		moveActorToLayer(a, a.layerID);
	}
	
	public function sendBackward(a:Actor)
	{
		removeActorFromLayer(a, a.layerID);
		
		var order:Int = getOrderForLayerID(a.layerID);
		
		if(order < layersToDraw.size - 1)
		{
			a.layerID = layersToDraw.get(order + 1);	
		}
		
		moveActorToLayer(a, a.layerID);
	}
	
	public function bringToFront(a:Actor)
	{
		removeActorFromLayer(a, a.layerID);
		a.layerID = getTopLayer();
		moveActorToLayer(a, a.layerID);
	}
	
	public function bringForward(a:Actor)
	{
		removeActorFromLayer(a, a.layerID);
		
		var order:Int = getOrderForLayerID(a.layerID);
		
		if(order > 0)
		{
			a.layerID = layersToDraw.get(order - 1);	
		}
		
		moveActorToLayer(a, a.layerID);
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
	
	public function getGroup(ID:Int, a:Actor = null):DisplayObjectContainer
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
	
	private function createRegion(x:Float, y:Float, shape:B2Shape, offset:Bool=false):Region
	{
		var shapeList = new Array<B2Shape>();
		shapeList.push(shape);
		var region = new Region(this, x, y, shapeList);
		
		if(offset)
		{
			region.setX(Engine.toPixelUnits(x) + region.width / 2);
			region.setY(Engine.toPixelUnits(y) + region.height / 2);
		}
		
		addRegion(region);
		return region;
	}
	
	public function createBoxRegion(x:Float, y:Float, w:Float, h:Float):Region
	{
		x = Engine.toPhysicalUnits(x);
		y = Engine.toPhysicalUnits(y);
		w = Engine.toPhysicalUnits(w);
		h = Engine.toPhysicalUnits(h);
	
		var p = new B2PolygonShape();
		p.setAsBox(w/2, h/2);
		
		return createRegion(x, y, p, true);
	}
	
	public function createCircularRegion(x:Float, y:Float, r:Float):Region
	{
		x = Engine.toPhysicalUnits(x);
		y = Engine.toPhysicalUnits(y);
		r = Engine.toPhysicalUnits(r);
		
		var cShape = new B2CircleShape();
		cShape.m_radius = r;
		
		return createRegion(x, y, cShape, true);
	}
	
	public function addRegion(r:Region)
	{
		var nextID = nextRegionID();
		r.ID = nextID;
		regions.set(nextID, r);
	}
	
	public function removeRegion(ID:Int)
	{
		var r = getRegion(ID);	
		regions.remove(r.ID);
		r.destroy();
	}
	
	public function getRegion(ID:Int):Region
	{
		return regions.get(ID);
	}
	
	public function getRegions():IntHash<Region>
	{
		return regions;
	}
	
	public function nextRegionID():Int
	{
		var ID = -1;
		
		for(r in regions)
		{
			if(r == null) 
			{
				continue;
			}
				
			ID = Std.int(Math.max(ID, r.ID));
		}
		
		return ID + 1;
	}
	
	public function isInRegion(a:Actor, r:Region):Bool
	{			
		if(r != null && regions.get(r.getID()) != null)
		{
			return r.containsActor(a);
		}
			
		else
		{
			trace("Region does not exist.");
			return false;
		}
	}
	
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
	
	public function setOffscreenTolerance(top:Int, left:Int, bottom:Int, right:Int)
	{
		Engine.paddingTop = top;
		Engine.paddingLeft = left;
		Engine.paddingBottom = bottom;
		Engine.paddingRight = right;
	}
	
	/*
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
	}*/
	
	//*-----------------------------------------------
	//* Utils
	//*-----------------------------------------------
	
	//0 args
	public static function invokeListeners(listeners:Array<Dynamic>)
	{
		var r = 0;
		
		while(r < listeners.length)
		{
			try
			{
				var f:Array<Dynamic>->Void = listeners[r];			
				f(listeners);
				
				if(Utils.indexOf(listeners, f) == -1)
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
	
	//1 args
	public static function invokeListeners2(listeners:Array<Dynamic>, value:Dynamic)
	{
		var r = 0;
		
		while(r < listeners.length)
		{
			try
			{
				var f:Dynamic->Array<Dynamic>->Void = listeners[r];			
				f(value, listeners);
				
				if(Utils.indexOf(listeners, f) == -1)
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
	
	//2 args
	public static function invokeListeners3(listeners:Array<Dynamic>, value:Dynamic, value2:Dynamic)
	{
		var r = 0;
		
		while(r < listeners.length)
		{
			try
			{
				var f:Dynamic->Dynamic->Array<Dynamic>->Void = listeners[r];			
				f(value, value2, listeners);
				
				if(Utils.indexOf(listeners, f) == -1)
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
}
