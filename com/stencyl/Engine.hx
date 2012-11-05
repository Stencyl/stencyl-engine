package com.stencyl;

#if cpp
import cpp.vm.Gc;
#end

import com.stencyl.behavior.Attribute;
import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.TimedTask;
import com.stencyl.behavior.BehaviorManager;
import com.stencyl.behavior.BehaviorInstance;
import com.stencyl.behavior.Script;

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.Shape;
import nme.display.Graphics;
import nme.display.MovieClip;
import nme.display.StageDisplayState;
import nme.text.TextField;
import nme.display.DisplayObjectContainer;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.Assets;
import nme.Lib;
import nme.ObjectHash;
import nme.ui.Keyboard;

import com.stencyl.graphics.transitions.Transition;
import com.stencyl.graphics.transitions.FadeInTransition;
import com.stencyl.graphics.transitions.FadeOutTransition;
import com.stencyl.graphics.transitions.CircleTransition;
import com.stencyl.graphics.BitmapFont;
import com.stencyl.graphics.G;

import com.stencyl.models.scene.layers.BackgroundLayer;
import com.stencyl.models.scene.layers.RegularLayer;

import com.stencyl.models.Actor;
import com.stencyl.models.scene.DeferredActor;
import com.stencyl.models.actor.Group;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
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
import com.stencyl.models.collision.Mask;

import com.stencyl.utils.Utils;
import com.stencyl.utils.HashMap;
import com.stencyl.utils.SizedIntHash;

import com.stencyl.event.EventMaster;
import com.stencyl.event.NativeListener;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;

import box2D.dynamics.B2World;
import box2D.common.math.B2Vec2;
import box2D.dynamics.joints.B2Joint;
import box2D.dynamics.joints.B2DistanceJoint;
import box2D.dynamics.joints.B2DistanceJointDef;
import box2D.dynamics.joints.B2RevoluteJoint;
import box2D.dynamics.joints.B2RevoluteJointDef;
import box2D.dynamics.joints.B2LineJoint;
import box2D.dynamics.joints.B2LineJointDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2Body;
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
	public static var SCROLLING_BACKGROUND:String = "s";
	public static var REGULAR_LAYER:String = "l";
	public static var DOODAD:String = "";
	
	public static var INTERNAL_SHIFT:String = "iSHIFT";
	public static var INTERNAL_CTRL:String = "iCTRL";
	
	public static var NO_PHYSICS:Bool = false;
	public static var DEBUG_DRAW:Bool = false; //!NO_PHYSICS && true;
	
	public static var IMG_BASE:String = "";
	public static var SCALE:Float = 1;
	
	public static var isStandardIOS:Bool = false;
	public static var isExtendedIOS:Bool = false;
	public static var isTabletIOS:Bool = false;
	
	
	//*-----------------------------------------------
	//* Important Values
	//*-----------------------------------------------
	
	public static var engine:Engine = null;
	
	public static var landscape:Bool = false; //Only applies to mobile
	
	public static var cameraX:Float;
	public static var cameraY:Float;
	
	public static var screenScaleX:Float;
	public static var screenScaleY:Float;
	public static var screenOffsetX:Int;
	public static var screenOffsetY:Int;
	
	public static var screenWidth:Int;
	public static var screenHeight:Int;
	
	public static var sceneWidth:Int;
	public static var sceneHeight:Int;
	
	public static var screenWidthHalf:Int;
	public static var screenHeightHalf:Int;
	
	public static var paused:Bool = false;
	public static var started:Bool = false;
	
	public static var events:EventMaster = new EventMaster();
	

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
	
	public static var movieClip:MovieClip;
	public static var stage:Stage;
	public var defaultGroup:Sprite; //The default layer (bottom-most)
	public var root:Sprite; //The absolute root
	public var master:Sprite; // the root of the main node
	public var hudLayer:Sprite; //Shows above everything else
	public var transitionBitmapLayer:DisplayObject; //Shows above everything else
	public var transitionLayer:Sprite; //Shows above everything else
	public var debugLayer:Sprite;
	
	public var g:G;
	
	
	//*-----------------------------------------------
	//* Model - Actors & Groups
	//*-----------------------------------------------
	
	public var groups:IntHash<Group>;
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
		
	public var tileUpdated:Bool;
	public var cameraMoved:Bool;
	public var cameraOldX:Float;
	public var cameraOldY:Float;	
	
	public var atlasesToLoad:IntHash<Int>;
	public var atlasesToUnload:IntHash<Int>;
	
	
	//*-----------------------------------------------
	//* Model - ?????
	//*-----------------------------------------------
	
	public var actorsToCreate:Array<Actor>;
	
	
	//*-----------------------------------------------
	//* Model - Behaviors & Game Attributes
	//*-----------------------------------------------
	
	public var gameAttributes:Hash<Dynamic>;
	public var behaviors:BehaviorManager;
	
	
	//*-----------------------------------------------
	//* Timing
	//*-----------------------------------------------
	
	public static var STEP_SIZE:Int = 10;
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
	
	private var collisionPairs:HashMap<Dynamic, HashMap<Dynamic, Bool>>;
	
	public var whenKeyPressedListeners:Hash<Dynamic>;
	public var whenTypeGroupCreatedListeners:HashMap<Dynamic, Dynamic>;
	public var whenTypeGroupDiesListeners:HashMap<Dynamic, Dynamic>;
	public var typeGroupPositionListeners:IntHash<Dynamic>;
	public var collisionListeners:IntHash<Dynamic>;
	public var soundListeners:HashMap<Dynamic, Dynamic>;		
			
	public var whenUpdatedListeners:Array<Dynamic>;
	public var whenDrawingListeners:Array<Dynamic>;
	public var whenMousePressedListeners:Array<Dynamic>;
	public var whenMouseReleasedListeners:Array<Dynamic>;
	public var whenMouseMovedListeners:Array<Dynamic>;
	public var whenMouseDraggedListeners:Array<Dynamic>;	
	public var whenPausedListeners:Array<Dynamic>;
	
	public var whenSwipedListeners:Array<Dynamic>;
	public var whenMTStartListeners:Array<Dynamic>;
	public var whenMTDragListeners:Array<Dynamic>;
	public var whenMTEndListeners:Array<Dynamic>;
	
	public var whenFocusChangedListeners:Array<Dynamic>;
	public var nativeListeners:Array<NativeListener>;
	
	
	//*-----------------------------------------------
	//* Full Screen
	//*-----------------------------------------------
	
	private var isFullScreen:Bool = false;
	private var stats:com.nmefermmmtools.debug.Stats;
	
	#if(!js && !mobile)
	private function onKeyDown(e:KeyboardEvent = null)
	{
		if(e.keyCode == Key.ESCAPE)
		{
			toggleFullscreen(true);
		}
	}
	
	public function toggleFullscreen(forceOff:Bool = false):Void
	{
		if(forceOff)
		{
			isFullScreen = true;
		}
	
		if(isFullScreen)
		{
			isFullScreen = false;
			Lib.current.stage.displayState = StageDisplayState.NORMAL;
			
			root.scaleX = 1.0;
			root.scaleY = 1.0;
			root.x = 0.0;
			root.y = 0.0;
			
			
			if(stats != null)
			{
				stats.x = Lib.current.stage.stageWidth - stats.width;
				stats.y = 0;
			}
			
			Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		} 
		
		else 
		{
			isFullScreen = true;
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			var xScaleFresh:Int = Math.floor(cast(Lib.current.stage.stageWidth, Float) / cast(scripts.MyAssets.stageWidth, Float));
			var yScaleFresh:Int = Math.floor(cast(Lib.current.stage.stageHeight, Float) / cast(scripts.MyAssets.stageHeight, Float));
			
			if(xScaleFresh < yScaleFresh)
			{
				root.scaleX = cast(xScaleFresh, Float);
				root.scaleY = cast(xScaleFresh, Float);
			}
			
			else if(yScaleFresh < xScaleFresh)
			{
				root.scaleX = cast(yScaleFresh, Float);
				root.scaleY = cast(yScaleFresh, Float);
			} 
			
			else
			{
				root.scaleX = cast(xScaleFresh, Float);
				root.scaleY = cast(yScaleFresh, Float);
			}
			
			root.x = (cast(Lib.current.stage.stageWidth, Float) / 2.0) - (cast(scripts.MyAssets.stageWidth*root.scaleX,Float) / 2.0);
			root.y = (cast(Lib.current.stage.stageHeight, Float) / 2.0) - (cast(scripts.MyAssets.stageHeight*root.scaleY,Float) / 2.0);
			
			var r = new nme.geom.Rectangle(0, 0, scripts.MyAssets.stageWidth, scripts.MyAssets.stageHeight);
			root.scrollRect = r;
			
			if(stats != null)
			{
				stats.x = Lib.current.stage.stageWidth - stats.width;
				stats.y = 0;
			}
			
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 2);
		}
	}
	#end
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------

	public function new(root:Sprite) 
	{		
		root.mouseChildren = false;
		root.mouseEnabled = false;
		//root.stage.mouseChildren = false;

		if(!scripts.MyAssets.releaseMode && scripts.MyAssets.debugDraw)
		{
			DEBUG_DRAW = true;
		}
		
		Engine.engine = this;
		this.root = root;
		
		Engine.screenScaleX = root.scaleX;
		Engine.screenScaleY = root.scaleY;
		Engine.screenOffsetX = Std.int(root.x);
		Engine.screenOffsetY = Std.int(root.y);
		
		NO_PHYSICS = scripts.MyAssets.physicsMode == 1;
		
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);
		begin(scripts.MyAssets.initSceneID);
	}
	
	public function begin(initSceneID:Int)
	{		
		atlasesToLoad = new IntHash<Int>();
		atlasesToUnload = new IntHash<Int>();
	
		Input.enable();
		Input.define(INTERNAL_SHIFT, [Key.SHIFT]);
		Input.define(INTERNAL_CTRL, [Key.CONTROL]);
		
		Engine.landscape = scripts.MyAssets.landscape;
		var stageWidth = scripts.MyAssets.stageWidth;
		var stageHeight = scripts.MyAssets.stageHeight;
		
		Engine.screenWidth = Std.int(stageWidth);
		Engine.screenHeight = Std.int(stageHeight);
		Engine.screenWidthHalf = Std.int(stageWidth/2);
		Engine.screenHeightHalf = Std.int(stageHeight/2);
		
		#if (mobile && !air)
		if(!scripts.MyAssets.autorotate)
		{
			if(Engine.landscape)
			{
				Stage.setFixedOrientation(Stage.OrientationLandscapeLeft);
			}
			
			else
			{
				Stage.setFixedOrientation(Stage.OrientationPortrait);
			}
		}
		#end

		Data.get();
		GameModel.get().loadScenes();
		
		g = new G();
		
		//---
			
		started = true;
		cameraMoved = false;
		tileUpdated = false;
		
		//---
		
		shakeTimer = 0;
		shakeIntensity = 0.01;
		isShaking = false;
	
		//---
		
		leave = null;
		enter = null;
		
		cameraX = 0;
		cameraY = 0;
		
		cameraOldX = -1;
		cameraOldY = -1;

		acc = 0;
		lastTime = Lib.getTimer();

		//Constants
		Engine.sceneWidth = stageWidth; //Overriden once scene loads
		Engine.sceneHeight = stageHeight; //Overriden once scene loads
			
		//Display List
		master = new Sprite();
		root.addChild(master);
		
		hudLayer = new Sprite();
		root.addChild(hudLayer);
		
		transitionLayer = new Sprite();
		root.addChild(transitionLayer);
		
		#if (js)
		transitionBitmapLayer = new Bitmap(new BitmapData(1, 1, true, 0));
		#end
		
		#if (cpp || flash)
		transitionBitmapLayer = new Sprite();
		#end
		
		//root.addChild(transitionBitmapLayer);
		
		debugLayer = new Sprite();
		root.addChild(debugLayer);
				
		//Initialize things	
		actorsToCreateInNextScene = new Array();			
		gameAttributes = new Hash<Dynamic>();
		
		//Profiler
		//#if !js
		if(!scripts.MyAssets.releaseMode)
		{
			if(scripts.MyAssets.showConsole)
			{
				stats = new com.nmefermmmtools.debug.Stats();
				stage.addChild(stats);
			}
		}
		//#end
		
		#if (flash)
		movieClip = new MovieClip();
		movieClip.mouseEnabled = false;
		movieClip.mouseChildren = false;
		root.parent.addChild(movieClip);
		#end
		
		//GA's
		for(key in GameModel.get().gameAttributes.keys())
		{
			setGameAttribute(key, GameModel.get().gameAttributes.get(key));
		}
				
		//Sound
		channels = new Array<SoundChannel>();
		
		for(index in 0...Script.CHANNELS)
		{
			channels.push(new SoundChannel(this, index)); 				
		}
		
		//Purchases
		#if (mobile && !android)
		Purchases.initialize();
		#end	
		
		//Now, let's start
		enter = new FadeInTransition(0.5);
		enter.start();
		sceneToEnter = initSceneID;
		
		loadScene(initSceneID);
	}	
	
	public function loadScene(sceneID:Int)
	{
		for(atlas in atlasesToUnload)
		{
			Data.get().unloadAtlas(atlas);
		}
		
		#if cpp
		Gc.run(true);
		#end
		
		for(atlas in atlasesToLoad)
		{
			Data.get().loadAtlas(atlas);
		}
		
		atlasesToLoad = new IntHash<Int>();
		atlasesToUnload = new IntHash<Int>();
	
		//---
	
		setOffscreenTolerance(0, 0, 0, 0);
		
		tasks = new Array<TimedTask>();
		
		scene = GameModel.get().scenes.get(sceneID);
		
		if(sceneID == -1 || scene == null)
		{
			scene = GameModel.get().scenes.get(GameModel.get().defaultSceneID);
			
			//Something really went wrong!
			if(scene == null)
			{
				trace("Could not load scene: " + sceneID);
				stage.removeEventListener(Event.ENTER_FRAME, onUpdate);
				return;
			}
		}
		
		Engine.sceneWidth = scene.sceneWidth;
		Engine.sceneHeight = scene.sceneHeight;
		
		behaviors = new BehaviorManager();
		
		groups = new IntHash<Group>();
		
		for(grp in GameModel.get().groups)
		{
			var g = new Group(grp.ID, grp.name);
			groups.set(grp.ID, g);
			g.name = grp.name;
		}
		
		//force regions in here
		groups.set(GameModel.REGION_ID, new Group(GameModel.REGION_ID, "Regions"));
		
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
		whenKeyPressedListeners = new Hash<Dynamic>();
		whenTypeGroupCreatedListeners = new HashMap<Dynamic, Dynamic>();
		whenTypeGroupDiesListeners = new HashMap<Dynamic, Dynamic>();
		typeGroupPositionListeners = new IntHash<Dynamic>();
		collisionListeners = new IntHash<Dynamic>();
		soundListeners = new HashMap<Dynamic, Dynamic>();
		nativeListeners = new Array<NativeListener>();
		
		whenUpdatedListeners = new Array<Dynamic>();
		whenDrawingListeners = new Array<Dynamic>();
		whenMousePressedListeners = new Array<Dynamic>();
		whenMouseReleasedListeners = new Array<Dynamic>();
		whenMouseMovedListeners = new Array<Dynamic>();
		whenMouseDraggedListeners = new Array<Dynamic>();
		whenPausedListeners = new Array<Dynamic>();
		whenSwipedListeners = new Array<Dynamic>();
		whenMTStartListeners = new Array<Dynamic>();
		whenMTDragListeners = new Array<Dynamic>();
		whenMTEndListeners = new Array<Dynamic>();
		whenFocusChangedListeners = new Array();
		
		if(!NO_PHYSICS)
		{									
			initPhysics();
		}
		
		loadBackgrounds();
		loadTerrain();
		loadRegions();
		loadTerrainRegions();
		loadActors();			
		loadCamera();
		loadJoints();
		
		loadDeferredActors();		
		initBehaviors(behaviors, scene.behaviorValues, this, this, true);			
		initActorScripts();
		
		loadForegrounds();
	}
		
	private function loadBackgrounds()
	{
		var bg = new Shape();
		scene.colorBackground.draw(bg.graphics, 0, 0, Std.int(screenWidth * Engine.SCALE), Std.int(screenHeight * Engine.SCALE));
		master.addChild(bg);
		
		for(backgroundID in scene.bgs)
		{
			loadBackground(backgroundID);
		}
	}
	
	private function loadForegrounds()
	{
		for(backgroundID in scene.fgs)
		{
			loadBackground(backgroundID, true);
		}
	}
	
	private function loadBackground(backgroundID:Int, isForeground:Bool = false)
	{
		var background = cast(Data.get().resources.get(backgroundID), ImageBackground);
		var backImg:BackgroundLayer = new BackgroundLayer(background.img);	
			
		if(background == null || background.img == null)
		{
			trace("Warning: Could not load a background. Ignoring...");
            return;
		}
		
		if(background.repeats)
		{
			background.drawRepeated(backImg, screenWidth, screenHeight);
		}
			
		if(Std.is(background, ScrollingBackground))
		{
			var scroller = cast(background, ScrollingBackground);
			var img = new ScrollingBitmap(backImg.bitmapData, scroller.xVelocity, scroller.yVelocity);
			img.name = SCROLLING_BACKGROUND;
			master.addChild(img);
		}
		
		else if (background.repeats)
		{
			var img = new ScrollingBitmap(backImg.bitmapData, 0, 0, background.parallaxX, background.parallaxY);
			img.name = SCROLLING_BACKGROUND;
			master.addChild(img);
		}
		
		else
		{
			backImg.cacheWidth = backImg.width;
			backImg.cacheHeight = backImg.height;
			backImg.name = BACKGROUND;
			master.addChild(backImg);
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
				
				var att = template.attributes.get(key);
				
				if(att == null)
				{
					continue;
				}
				
				var attribute:Attribute = cast(att, Attribute);

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
		
		var aabb:B2AABB = new B2AABB();
		aabb.lowerBound.x = 0;
		aabb.lowerBound.y = 0;
		aabb.upperBound.x = Engine.screenWidth / physicsScale;
		aabb.upperBound.y = Engine.screenHeight / physicsScale;
		world.setScreenBounds(aabb);
		
		debugDrawer = new B2DebugDraw();
		debugDrawer.setSprite(debugLayer);
		debugDrawer.setLineThickness(3);
		debugDrawer.setDrawScale(10 * Engine.SCALE);
		debugDrawer.setFillAlpha(0);
		debugDrawer.setFlags(B2DebugDraw.e_shapeBit);
		world.setDebugDraw(debugDrawer);
	}
	
	//*-----------------------------------------------
	//* Init - Actors / Regions / Joints / Terrain
	//*-----------------------------------------------
	
	private function loadActors()
	{
		actorsToCreate = new Array<Actor>();
		
		for(instance in scene.actors)
		{
			actorsToCreate.push(createActor(instance, true));
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
		for(a in actorsToCreate)
		{
			a.initScripts();
		}
		
		actorsToCreate = null;
	}
	
	private function loadCamera()
	{
		camera = new Actor(this, -1, GameModel.DOODAD_ID, 0, 0, getTopLayer(), 2, 2, null, null, null, null, true, false, true, false, null, 0, true, false);
		camera.name = "Camera";
		camera.isCamera = true;
		
		cameraMoved = true;
		cameraOldX = -1;
		cameraOldY = -1;
	}
	
	private function loadRegions()
	{					
		regions = new IntHash<Region>();

		for(r in scene.regions)
		{
			var region:Region = new Region(this, r.x, r.y, r.shapes, r.simpleBounds);
			region.name = r.name;
			
			if(!NO_PHYSICS)
			{
				region.setX(Engine.toPixelUnits(r.x) + (region.regionWidth / 2));
				region.setY(Engine.toPixelUnits(r.y) + (region.regionHeight / 2));
			}
			
			region.ID = r.ID;
			
			addRegion(region);
			regions.set(r.ID, region);
		}
	}
	
	private function loadTerrainRegions()
	{						
		terrainRegions = new IntHash<Terrain>();
		
		if(NO_PHYSICS)
		{
			return;
		}
		
		for(r in scene.terrainRegions)
		{
			var region = new Terrain(this, r.x, r.y, r.shapes, r.groupID, r.fillColor);
			region.name = r.name;
			
			region.setX(Engine.toPixelUnits(r.x) + (region.regionWidth / 2));
			region.setY(Engine.toPixelUnits(r.y) + (region.regionHeight / 2));
			
			region.ID = r.ID;
			
			addTerrainRegion(region);
			terrainRegions.set(r.ID, region);
		}
	}
			
	private function loadJoints()
	{
		if(NO_PHYSICS)
		{
			return;
		}
	
		for(jd in scene.joints)
		{
			var a1 = jd.actor1;
			var a2 = jd.actor2;
			var collide = jd.collideConnected;
			
			var one:B2Body = null;
			var two:B2Body = null;
			
			var pt:B2Vec2 = null;
			
			//Types are defined in b2Joint.h
			
			//STICK
			if(jd.type == 3)
			{
				joints.set(jd.ID, createStickJoint(getActor(a1).body, getActor(a2).body, jd.ID, collide));
			}
			
			//HINGE
			else if(jd.type == 1)
			{
				var r = cast(jd, B2RevoluteJointDef);
				pt = getActor(a1).body.getLocalCenter().copy();
				
				pt.x = Engine.toPixelUnits(pt.x);
				pt.y = Engine.toPixelUnits(pt.y);
				
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
				
				joints.set(jd.ID, createHingeJoint
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
				));
			}
			
			//SLIDING
			else if(jd.type == 2 || jd.type == 7)
			{
				var s = cast(jd, B2LineJointDef);
				pt = getActor(a1).body.getLocalCenter().copy();
				
				pt.x = Engine.toPixelUnits(pt.x);
				pt.y = Engine.toPixelUnits(pt.y);
				
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
				
				joints.set(jd.ID, createSlidingJoint
				(
					one,
					two,
					s.localAxisA,
					jd.ID,
					collide,
					s.enableLimit,
					s.enableMotor,
					s.lowerTranslation,
					s.upperTranslation,
					s.maxMotorForce,
					s.motorSpeed
				));
			}
		}
	}
	
	public function loadTerrain()
	{				
		initLayers();
		
		for(wireframe in scene.wireframes)
		{
			var a:Actor = null;
			
			if(NO_PHYSICS)
			{
				/*var p = cast(wireframe.shape2, Polygon);
				p.updateDimensions();

				a = new Actor
				(
					this, 
					Utils.INT_MAX,
					GameModel.TERRAIN_ID,
					wireframe.x, 
					wireframe.y, 
					getTopLayer(),
					Std.int(p.width), 
					Std.int(p.height), 
					null, 
					new Hash<Dynamic>(),
					null,
					null, 
					false, 
					true, 
					false,
					false, 
					wireframe.shape2
				);*/
				
				//master.addChild(a);
			}
			
			else
			{
				a = new Actor
				(
					this, 
					Utils.INT_MAX,
					GameModel.TERRAIN_ID,
					wireframe.x, 
					wireframe.y, 
					getTopLayer(),
					Std.int(wireframe.width), 
					Std.int(wireframe.height), 
					null, 
					new Hash<Dynamic>(),
					null,
					null, 
					false, 
					true, 
					false,
					false, 
					wireframe.shape
				);
			}
			
			a.name = "Terrain";
			a.typeID = -1;
			a.visible = false;
			
			getGroup(GameModel.TERRAIN_ID).list.set(a, a);	
		}
	}
	
	//This is mainly to establish mappings and figure out top, middle, bottom
	private function initLayers()
	{
		var layers = new SizedIntHash<Int>();
		var orders = new SizedIntHash<Int>();
		var exists = new SizedIntHash<Int>();
		var highestLayerOrder = 0;
		
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
				highestLayerOrder = Std.int(Math.max(highestLayerOrder, l.zOrder));
				
				layers.set(l.zOrder, l.layerID);
				orders.set(l.layerID, l.zOrder);
				exists.set(l.zOrder, l.zOrder);
			}
		}
		
		for(i in 0...highestLayerOrder + 1)
		{
			if(!exists.exists(i))
			{
				layers.set(i, -1);
			}
		}
		
		layersToDraw = layers;
		layerOrders = orders;
		
		var foundBottom:Bool = false;
		var foundMiddle:Bool = false;
		var realNumLayers:Int = 0;
		
		//Figure out how many there actually are
		for(i in 0...highestLayerOrder + 1)
		{
			var layerID:Int = layersToDraw.get(i);
			
			if(layerID != -1)
			{
				realNumLayers++;
			}
		}
		
		var numLayersProcessed:Int = 0;
		
		for(i in 0...highestLayerOrder + 1)
		{
			var j = highestLayerOrder - i;
			var layerID:Int = layersToDraw.get(j);
			
			if(layerID == -1 || !layersToDraw.exists(j))
			{
				//trace("No layer exists for drawing order: " + j);
				continue;
			}
			
			var list = new RegularLayer();
			var terrain = null;
			var overlay = new Sprite();
			
			#if (js)
			var bitmapOverlay = new Bitmap(new BitmapData(Engine.screenWidth, Engine.screenHeight, true, 0));
			#end
			
			#if (cpp || flash)
			var bitmapOverlay = new Sprite();
			#end
			
			if(scene.terrain != null)
			{
				terrain = new Layer(layerID, j, scene.terrain.get(layerID), overlay, bitmapOverlay);
			}
			
			if(!foundBottom)
			{
				foundBottom = true;
				bottomLayer = j;
			}
			
			if(!foundMiddle && numLayersProcessed == Math.floor(realNumLayers / 2))
			{
				foundMiddle = true;
				middleLayer = j;
			}

			if(terrain != null)
			{
				var tileLayer = scene.terrain.get(layerID);
				
				if(tileLayer == null)
				{
					trace("LayerID does not exist: " + layerID);
					continue;
				}
				
				tileLayer.reset();
			
				terrain.name = REGULAR_LAYER;
				master.addChild(terrain);
				master.addChild(tileLayer);
				
				if(NO_PHYSICS)
				{
					scene.terrain.get(layerID).mountGrid();
				}
				
				this.layers.set(layerID, terrain);
			}
				
			/*overlay.name =*/ list.name = REGULAR_LAYER;
			master.addChild(list);
			master.addChild(overlay);
			master.addChild(bitmapOverlay);
			
			actorsPerLayer.set(layerID, list);
			
			
			//Eventually, this will become the correct value
			topLayer = j;
			defaultGroup = list;
			
			numLayersProcessed++;
		}
		
		//For scenes with no scene data
		if(defaultGroup == null)
		{
			defaultGroup = new RegularLayer();
			defaultGroup.name = REGULAR_LAYER;
			master.addChild(defaultGroup);
		}
	}

	//*-----------------------------------------------
	//* Scene Switching
	//*-----------------------------------------------
	
	public function cleanup()
	{
		if(debugDrawer != null && debugDrawer.m_sprite != null)
		{
			debugDrawer.m_sprite.graphics.clear();
		}
		
		Utils.removeAllChildren(master);
		Utils.removeAllChildren(hudLayer);
			
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
		if(world != null)
		{
			var worldbody = world.getBodyList();
			var j = world.getJointList();
			
			while(j != null)
			{
				world.destroyJoint(j);
				j = j.getNext();
			}
			
			while(worldbody != null)
			{
				world.destroyBody(worldbody);
				worldbody = worldbody.getNext();
			}
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
		nativeListeners = null;
					
		whenUpdatedListeners = null;
		whenDrawingListeners = null;
		whenMousePressedListeners = null;
		whenMouseReleasedListeners = null;
		whenMouseMovedListeners = null;
		whenMouseDraggedListeners = null;		
		whenPausedListeners = null;
		whenSwipedListeners = null;
		whenMTStartListeners = null;
		whenMTDragListeners = null;
		whenMTEndListeners = null;
		
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
		
		if(!this.leave.isComplete())
		{
			this.leave.start();
		}
		
		sceneToEnter = sceneID;
	}
	
	public function enterScene()
	{
		if(!enter.isComplete())
		{
			enter.start();
			
			if(leave != null)
			{
				leave.cleanup();
			}
		}
		
		leave = null;
		
		//trace("Entering Scene " + sceneToEnter);
		
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
	
	public function createActorInNextScene(type:ActorType, x:Float, y:Float, layer:Int)
	{
		actorsToCreateInNextScene.push(new DeferredActor(type, x, y, layer));
	}
		
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
			NO_PHYSICS ? null : ai.actorType.bodyDef,
			false,
			false,
			false,
			false,
			null,
			ai.actorType.ID,
			ai.actorType.isLightweight || NO_PHYSICS,
			ai.actorType.autoScale,
			ai.actorType.ignoreGravity
		);

		if(ai.angle != 0)
		{
			a.setAngle(ai.angle, false);
		}	
		
		if(ai.scaleX != 1 || ai.scaleY != 1)
		{
			a.growTo(ai.scaleX, ai.scaleY, 0);
		}
		
		a.name = ai.actorType.name;
		
		moveActorToLayer(a, ai.layerID);
		
		//---
		
		//Pre-Recycle
		
		if(recycledActorsOfType.get(ai.actorType.ID) == null)
		{
			//This ought to be a HashSet instead
			recycledActorsOfType.set(ai.actorType.ID, new Array<Actor>());
		}
		
		var cache = recycledActorsOfType.get(ai.actorType.ID);
		cache.push(a);
		
		//----
		
		var group = groups.get(ai.groupID);
		
		if(group != null)
		{
			group.addChild(a);
		}
		
		//---

		//Use the next available ID
		if(ai.elementID == Utils.INT_MAX)
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
	
	public function removeActorFromLayer(a:Actor, layerID:Int)
	{
		var layer = actorsPerLayer.get(layerID);
		
		if(layer == null)
		{
			trace("Layer ID: " + layerID + " does not exist");
			trace("Assuming default group");
			layer = defaultGroup;
		}
		
		//Be gentle and don't error out if it's not in here (in case of a double-remove)
		if(layer.contains(a))
		{
			layer.removeChild(a);
		}
	}
	
	public function moveActorToLayer(a:Actor, layerID:Int)
	{
		var layer = actorsPerLayer.get(layerID);
		
		if(layer == null)
		{
			trace("Layer ID: " + layerID + " does not exist");
			trace("Putting actor inside default group");
			layer = defaultGroup;
		}
		
		//To ensure that it draws after
		layer.addChild(a);
		a.layerID = layerID;
	}
	
	public function recycleActor(a:Actor)
	{
		//trace("recycle " + a);
		
		if(a == null)
		{
			return;
		}
	
		var l1 = engine.whenTypeGroupDiesListeners.get(a.getType());
		var l2 = engine.whenTypeGroupDiesListeners.get(a.getGroup());
	
		Engine.invokeListeners(a.whenKilledListeners);

		if(l1 != null)
		{
			Engine.invokeListeners2(l1, a);
		}
		
		if(l2 != null)
		{
			Engine.invokeListeners2(l2, a);
		}
		
		//Causes strange double-removal error - taking out for now.
		/*if(a.isHUD)
		{
			a.unanchorFromScreen();
		}*/
		
		if(a.alwaysSimulate)
		{
			a.makeSometimesSimulate(false);
		}
	
		a.setX(1000000);
		a.setY(1000000);
		a.recycled = true;
		//a.setFilter(null);
		a.cancelTweens();
		//Only the fading is necessary. Don't fully understand why...
		//a.moveTo(1000000, 1000000, 0.01);
		//a.growTo(1, 1, 0.01);
		//a.spinTo(0, 0.01);
		a.fadeTo(1, 0.01);
		a.switchToDefaultAnimation();
		a.disableActorDrawing();
		
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
			a.body.setActive(false);
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
						actor.body.setActive(true);
						actor.body.setAwake(true);
					}
					
					actor.enableActorDrawing();
					actor.setX(x);
					actor.setY(y);
					actor.setAngle(0, false);
					actor.alpha = 1;
					actor.realScaleX = 1;
					actor.realScaleY = 1;
					//actor.setFilter(null);
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
			Utils.INT_MAX,
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
					
	public function update(elapsedTime:Float)
	{
		if(scene == null)
		{
			//trace("Scene is null");
			return;
		}
		
		if(!NO_PHYSICS)
		{
			var aabb = world.getScreenBounds();
			aabb.lowerBound.x = (Math.abs(cameraX / Engine.SCALE) - paddingLeft) / physicsScale;
			aabb.lowerBound.y = (Math.abs(cameraY / Engine.SCALE) - paddingTop) / physicsScale;
			aabb.upperBound.x = aabb.lowerBound.x + ((Engine.screenWidth + paddingRight + paddingLeft) / physicsScale);
			aabb.upperBound.y = aabb.lowerBound.y + ((Engine.screenHeight + paddingBottom + paddingTop) / physicsScale);
		}
				
		if(Input.mousePressed)
		{
			Script.mpx = Input.mouseX / SCALE;
			Script.mpy = Input.mouseY / SCALE;
			invokeListeners(whenMousePressedListeners);
		}
		
		if(Input.mouseReleased)
		{
			Script.mrx = Input.mouseX / SCALE;
			Script.mry = Input.mouseY / SCALE;
			invokeListeners(whenMouseReleasedListeners);
		}
		
		if(mx != Input.mouseX || my != Input.mouseY)
		{
			mx = Input.mouseX / SCALE;
			my = Input.mouseY / SCALE;
			
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
			
			t.update(STEP_SIZE);
			
			if(t.done)
			{
				tasks.remove(t);	
				i--;
			}
			
			i++;
		}
		
		//Poll Keyboard Inputs
		for(key in whenKeyPressedListeners.keys())
		{
			var listeners = whenKeyPressedListeners.get(key);
			var pressed = Input.pressed(key);
			var released = Input.released(key);
			
			if(pressed || released)
			{
				invokeListeners3(listeners, pressed, released);
			}				
		}
		
		//Native
		#if mobile
		for(listener in nativeListeners)
		{
			listener.checkEvents(Engine.events);
		}
		
		Engine.events.clear();
		#end
		
		invokeListeners2(whenUpdatedListeners, elapsedTime);
		
		if(!NO_PHYSICS)
		{
			world.step(0.01, 3, 3);
			world.clearForces();
			
			if(DEBUG_DRAW)
			{
				world.drawDebugData();
			}
		}

		for(r in regions)
		{
			if(r == null) continue;
			r.innerUpdate(elapsedTime, true);
		}
		
		//TODO: Don't like making a new list each time...
		var disableCollisionList = new Array<Actor>();
		
		if(!NO_PHYSICS)
		{
			collisionPairs = new HashMap<Actor, HashMap<Actor, Bool>>();	
		}
		
		com.stencyl.models.actor.Animation.updateAll(elapsedTime);
		
		for(a in allActors)
		{		
			if(a != null && !a.dead && !a.recycled) 
			{
				//--- HAND INLINED THIS SINCE ITS CALLED SO MUCH
				var isOnScreen = (a.isLightweight || a.body.isActive()) && 
			   	a.colX >= -Engine.cameraX / Engine.SCALE - Engine.paddingLeft && 
			   	a.colY >= -Engine.cameraY / Engine.SCALE - Engine.paddingTop &&
			   	a.colX < -Engine.cameraX / Engine.SCALE + Engine.screenWidth + Engine.paddingRight &&
			   	a.colY < -Engine.cameraY / Engine.SCALE + Engine.screenHeight + Engine.paddingBottom;
				
				//---
			
				if(!a.isLightweight && a.body != null)
				{
					if(a.killLeaveScreen && !isOnScreen)
					{		
						recycleActor(a);
					}
					
					else if(a.body.isActive() || a.alwaysSimulate || a.isHUD)
					{		
						a.innerUpdate(elapsedTime, false);						
					}
				}
				
				else if(a.isLightweight)
				{
					if(a.killLeaveScreen && !isOnScreen)
					{
						recycleActor(a);
					}
					
					else if(isOnScreen || a.alwaysSimulate || a.isHUD)
					{		
						a.innerUpdate(elapsedTime, false);
					}
				}
				
				if(a.dead)
				{
					disableCollisionList.push(a);
				}
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
			tileUpdated = tileUpdated || tile.updateSource;
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
		cameraX = -Math.abs(camera.realX) + screenWidthHalf;
		cameraY = -Math.abs(camera.realY) + screenHeightHalf;

		//Position Limiter - Never go past 0 (which would be fully to the right/bottom)
		var maxCamX = -Engine.sceneWidth + screenWidth;
		var maxCamY = -Engine.sceneHeight + screenHeight;
		
		if(cameraX < maxCamX)
		{
			cameraX = maxCamX;
		} 
		
		if(cameraY < maxCamY)
		{
			cameraY = maxCamY;
		}
		
		cameraX *= Engine.SCALE;
		cameraY *= Engine.SCALE;
		
		//Position Limiter - Never go past 0 (which would be fully to the right/bottom)
		cameraX = Math.min(0, cameraX);
		cameraY = Math.min(0, cameraY);
		
		for(i in 0...master.numChildren)
		{
			var child = master.getChildAt(i);
			
			//Background
			if(Std.is(child, BackgroundLayer))
			{
				var endX = Math.abs(cast(child, BackgroundLayer).cacheWidth - screenWidth * Engine.SCALE);
				var endY = Math.abs(cast(child, BackgroundLayer).cacheHeight - screenHeight * Engine.SCALE);

				//child.x = endX * ( - (cameraX / Engine.SCALE) / Engine.sceneWidth);
				//child.y = endY * ( - (cameraY / Engine.SCALE) / Engine.sceneHeight);
				
				if(maxCamX != 0)
				{
					child.x = -endX * Math.abs(cameraX/(maxCamX * Engine.SCALE));
				}
				
				else
				{
					child.x = 0;
				}
				
				if(maxCamY != 0)
				{
					child.y = -endY * Math.abs(cameraY/(maxCamY * Engine.SCALE));
				}
				
				else
				{
					child.y = 0;
				}
			}
			
			else if(Std.is(child, ScrollingBitmap))
			{
				var bg = cast(child, ScrollingBitmap);
				
				if (bg.parallax)
				{
					bg.updateParallax();
				}
				
				else
				{
					bg.updateAuto(elapsedTime);
				}
			}
			
			//Regular Layer
			else if(Std.is(child, RegularLayer))
			{
				child.x = cameraX;
				child.y = cameraY;
			}
			
			//Something that doesn't scroll - Do nothing
		}
		
		if(!NO_PHYSICS && DEBUG_DRAW)
		{
			debugLayer.x = cameraX;
			debugLayer.y = cameraY;
		}
		
		//Shaking
		if(isShaking)
		{
			shakeTimer -= STEP_SIZE;
        
	        if(shakeTimer <= 0)
	        {
	        	stopShakingScreen();
	            return;
	        }
	        
	        var randX = (-shakeIntensity * Engine.screenWidth + Math.random() * (2 * shakeIntensity * Engine.screenWidth));
	        var randY = (-shakeIntensity * Engine.screenHeight + Math.random() * (2 * shakeIntensity * Engine.screenHeight));
	        
	        master.x = randX * Engine.SCALE;
	        master.y = randY * Engine.SCALE;
		}
	}
	
	//Game Loop
	private function onUpdate(event:Event):Void 
	{
		var currTime:Float = Lib.getTimer();
		var elapsedTime:Float = (currTime - lastTime);
		acc += elapsedTime;
		
		Engine.elapsedTime = elapsedTime;

		if(leave != null)
		{
			if(leave.isComplete())
			{
				leave.stop();
				enterScene();
			}
			
			else
			{
				postUpdate(currTime);
			}
			
			return;
		}
		
		if(enter != null)
		{
			if(enter.isComplete())
			{
				enter.stop();
				enter.cleanup();
				enter = null;
			}
		}
			
		//---
		
		postUpdate(currTime);
	}
	
	private function postUpdate(currTime:Float)
	{
		while(acc > STEP_SIZE)
		{
			update(STEP_SIZE);
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
			
			else if (a.updateMatrix || a.resetOrigin)
			{
				a.updateDrawingMatrix();
				a.updateMatrix = false;
			}
			
			if(a.body == null)
			{
				continue;
			}
		}
		
		//Drawing
		
		var tempX = Std.int(cameraX / scene.tileWidth);
		var tempY = Std.int(cameraY / scene.tileHeight);
		
		cameraMoved = !(cameraOldX == tempX && cameraOldY == tempY);
		
		cameraOldX = tempX;
		cameraOldY = tempY;
		
		draw();
	}
	
	//*-----------------------------------------------
	//* Events Finished
	//*-----------------------------------------------
	
	public function onFocus(event:Event)
	{
		focusChanged(false);
	}
	
	public function onFocusLost(event:Event)
	{
		focusChanged(true);
	}
	
	public function focusChanged(lost:Bool)
	{
		if(whenFocusChangedListeners == null)
		{
			return;
		}
		
		invokeListeners2(whenFocusChangedListeners, lost);
	}		
	
	//TODO: Redo this using ints as lookup keys rather than objects - I feel this is a really inefficient function.
	public function handleCollision(a:Actor, event:Collision)
	{
		var type1 = a.typeID;
		var type2 = event.otherActor.typeID;
		
		var group1:Int = 0;
		var group2:Int = 0;
		
		if(NO_PHYSICS)
		{
			group1 = event.thisActor.groupID;
			group2 = event.otherActor.groupID;
		}
		
		else
		{
			if(event.thisShape != null)
			{
				var value = event.thisShape.groupID;

				if(value == GameModel.INHERIT_ID)
				{
					var body = event.thisShape.getBody();
					
					if(body != null)
					{
						value = cast(body.getUserData()).groupID;
					}
				}
				
				group1 = Actor.GROUP_OFFSET + value;
			}
			
			else
			{
				group1 = Actor.GROUP_OFFSET + event.thisActor.groupID;
			}
			
			if(event.otherShape != null)
			{
				var value = event.otherShape.groupID;
			
				if(value == GameModel.INHERIT_ID)
				{
					var body = event.otherShape.getBody();
					
					if(body != null)
					{
						value = cast(body.getUserData()).groupID;
					}
				}
				
				group2 = Actor.GROUP_OFFSET + value;
			}
			
			else
			{
				group2 = Actor.GROUP_OFFSET + event.otherActor.groupID;
			}
		}
		
		//Check if collision between actors has already happened
		if(collisionPairs != null)
		{
			if(!collisionPairs.exists(a))
			{
				collisionPairs.set(a, new HashMap<Dynamic, Bool>());
			}
			
			if(!collisionPairs.exists(event.otherActor))
			{
				collisionPairs.set(event.otherActor, new HashMap<Dynamic, Bool>());
			}
			
			if(collisionPairs.get(a).exists(event.otherActor) || collisionPairs.get(event.otherActor).exists(a))
			{
				return;
			}
		}
		
		if(type1 > -1 || type2 > -1)
		{
			if(!event.otherCollidedWithTerrain && collisionListeners.exists(type1) && collisionListeners.get(type1).exists(type2))
			{
				var listeners = collisionListeners.get(type1).get(type2);
				invokeListeners2(listeners, event);
				
				if(listeners.length == 0)
				{
					collisionListeners.get(type1).delete(type2);
				}
			}
			
			if(type1 != type2 && collisionListeners.exists(type2) && collisionListeners.get(type2).exists(type1))
			{
				var listeners = collisionListeners.get(type2).get(type1);
				var reverseEvent = event.switchData();
				
				invokeListeners2(listeners, reverseEvent);
				
				if(listeners.length == 0)
				{
					collisionListeners.get(type2).delete(type1);
				}
			}
		}
		
		if(group1 > 0 && group2 > 0)
		{
			if(collisionListeners.exists(group1) && collisionListeners.get(group1).exists(group2))
			{
				var listeners = collisionListeners.get(group1).get(group2);
				invokeListeners2(listeners, event);
				
				if(listeners.length == 0)
				{
					collisionListeners.get(group1).delete(group2);
				}
			}
			
			if(group1 != group2 && collisionListeners.exists(group2) && collisionListeners.get(group2).exists(group1))
			{
				var listeners = collisionListeners.get(group2).get(group1);
				var reverseEvent = event.switchData();
				
				invokeListeners2(listeners, reverseEvent);
				
				if(listeners.length == 0)
				{
					collisionListeners.get(group2).delete(group1);
				}
			}
		}
		
		//Collision has been handled once, hold to prevent from double reporting collisions
		if(collisionPairs != null)
		{
			collisionPairs.get(a).set(event.otherActor, false);
			collisionPairs.get(event.otherActor).set(a, false);
		}
	}
	
	public function soundFinished(channelNum:Int)
	{
		var sc:SoundChannel = cast(channels[channelNum], SoundChannel);
		
		var channelListeners = soundListeners.get(channelNum);
		var clipListeners = soundListeners.get(sc.currentClip);
		
		//trace(soundListeners.keys);
		//trace(channelListeners);
		
		if(channelListeners != null)
		{
			invokeListeners(channelListeners);
		}
		
		if(clipListeners != null)
		{
			invokeListeners(clipListeners);
		}
		
		sc.currentSound = null;
	}
	
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
		shakeTimer = Std.int(MS_PER_SEC * duration);
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
		camera.setLocation
		(
			Math.round(actor.colX + actor.cacheWidth / 2),
			Math.round(actor.colY + actor.cacheHeight / 2)
		);
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
			if(a != null)
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
     
      //TODO: Consider a repainting scheme if performance suffers. Custom drawing only happens when
      //you decide to repaint a layer or all layers. Will likely help on labels.
      
      //Flash + mouse movement = FPS down the drain due to this function
      //Consider pre-rendering the entire tile layers to fix that file part
      //Not sure what to do with the rest...
        
     //The display tree does almost everything now. We only need to invoke the behavior drawers.
     
     //Change to a repaint on demand mechanism
     public function draw()
     {
     	for(l in layers)
		{
			l.overlay.graphics.clear();
			
			#if (js)
			l.bitmapOverlay.bitmapData.fillRect(l.bitmapOverlay.bitmapData.rect, 0);
			#end
			
			#if (cpp || flash)
			l.bitmapOverlay.graphics.clear();
			#end
		}
		
		//Clean up HUD actors
		for(a in hudActors)
		{
			if(a == null || a.dead)
			{
				hudActors.delete(a);
			}
		}
     
		//Walk through all actors
		//TODO: cache the actors that need to be drawn instead upon creation
		for(a in allActors)
		{
			if(a.whenDrawingListeners.length > 0)
			{
				var layer = layers.get(a.layerID);
				g.graphics = layer.overlay.graphics;
				
				#if (js)
				g.canvas = layer.bitmapOverlay.bitmapData;
     			#end
     			
     			#if (cpp || flash)
				g.canvas = layer.bitmapOverlay;
				#end		
     			
				g.translateToActor(a);			
				Engine.invokeListeners4(a.whenDrawingListeners, g, 0, 0);
			}
		}

     	//Walk through each of the drawing events
     	
     	//Only if camera changed? Or tile updated
     	for(layer in tileLayers)
	    {
	    	if(cameraMoved || tileUpdated)
     		{
	     		layer.draw(Std.int(cameraX), Std.int(cameraY), 1 /* TODO */); // FLASH MOUSE SLOWDOWN
	     	}
	     	
	     	layer.x = cameraX;
	     	layer.y = cameraY;
	    }
     	
     	tileUpdated = false;
     	
     	
     	//Scene Behavior/Event Drawing
     	g.graphics = transitionLayer.graphics;
     	
     	#if (js)
     	g.canvas = cast(transitionBitmapLayer, Bitmap).bitmapData;
     	#end
     	
     	#if (cpp || flash)
     	g.canvas = transitionBitmapLayer;
     	#end
     	
     	g.translateToScreen();
     	g.graphics.clear();
     	
     	#if (js)
     	g.canvas.fillRect(g.canvas.rect, 0);
     	#end
     	
     	#if (cpp || flash)
     	g.canvas.graphics.clear();
     	#end
     	
     	Engine.invokeListeners4(whenDrawingListeners, g, 0, 0);
		
		//Draw Transitions
		if(leave != null && leave.isActive())
		{
			//TODO: What is the graphics object supposed to be?
			leave.draw(null);
		}
			
		else if(enter != null && enter.isActive())
		{
			enter.draw(null);
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
	
	public function say(behaviorName:String, msg:String, args:Array<Dynamic> = null):Dynamic
	{
		return behaviors.call2(behaviorName, msg, args);
	}
	
	public function shout(msg:String, args:Array<Dynamic> = null):Dynamic
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
		if(type == null)
		{
			trace("Error: getActorsOfType was passed a null type");
			return [];
		}
	
		var result = actorsOfType.get(type.ID);
	
		if(result != null)
		{
			return actorsOfType.get(type.ID);
		}
		
		else
		{
			return [];
		}
	}
	
	public function getRecycledActorsOfType(type:ActorType):Array<Actor>
	{
		return recycledActorsOfType.get(type.ID);
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
	
	public function moveToLayer(a:Actor, layerID:Int)
	{
		var lID = layerID;

		if(lID < 0 || lID > layersToDraw.size - 1) 
		{
			return;
		}
			
		if(a.layerID == layerID) 
		{
			return;
		}

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
	
	public inline function enableGlobalSleeping()
	{
		world.m_allowSleep = true;
	}
	
	public inline function disableGlobalSleeping()
	{
		world.m_allowSleep = false;
	}
	
	//*-----------------------------------------------
	//* Groups
	//*-----------------------------------------------
	
	public function getGroup(ID:Int, a:Actor = null):Group
	{
		if(ID == GameModel.INHERIT_ID && a != null)
		{
			return groups.get(a.getGroupID());
		}
		
		return groups.get(ID);
	}
	
	//*-----------------------------------------------
	//* Joints
	//*-----------------------------------------------
	
	public function nextJointID():Int
	{
		var ID = -1;

		for(j in joints)
		{
			if(j == null) 
			{
				continue;
			}
			
			ID = Std.int(Math.max(ID, j.ID));
		}
		
		return ID + 1;
	}
	
	public function addJoint(j:B2Joint)
	{
		var nextID = nextJointID();
		j.ID = nextID;
		joints.set(nextID, j);
	}
	
	public function getJoint(ID:Int):B2Joint
	{
		return joints.get(ID);
	}
	
	public function destroyJoint(j:B2Joint)
	{
		joints.remove(j.ID);
		world.destroyJoint(j);
	}
	
	//---
	
	public function createStickJoint
	(
		one:B2Body, 
		two:B2Body, 
		jointID:Int = -1, 
		collide:Bool = false, 
		damping:Float = 0, 
		frequencyHz:Float = 0
	):B2DistanceJoint
	{
		var v1 = one.getLocalCenter();
		var v2 = two.getLocalCenter();
		
		if(one.getType() == 0)
		{
			v1.x = cast(one.getUserData(), Actor).getPhysicsWidth() / 2;
			v1.y = cast(one.getUserData(), Actor).getPhysicsHeight() / 2;
		}
		
		if(two.getType() == 0)
		{
			v2.x = cast(two.getUserData(), Actor).getPhysicsWidth() / 2;
			v2.y = cast(two.getUserData(), Actor).getPhysicsHeight() / 2;
		}
		
		v1 = one.getWorldPoint(v1);
		v2 = two.getWorldPoint(v2);
		
		var jd = new B2DistanceJointDef();
		jd.initialize(one, two, v1, v2);
		jd.collideConnected = collide;
		jd.dampingRatio = damping;
		jd.frequencyHz = frequencyHz;
		
		var toReturn = world.createJoint(jd);
		
		if(jointID == -1)
		{
			addJoint(toReturn);
		}
			
		else
		{
			joints.set(jointID, toReturn);
			toReturn.ID = jointID;
		}
		
		return cast(toReturn, B2DistanceJoint);
	}
	
	public function createCustomStickJoint
	(
		one:B2Body,
		x1:Float, 
		y1:Float, 
		two:B2Body, 
		x2:Float, 
		y2:Float
	):B2DistanceJoint
	{
		var v1 = new B2Vec2(x1, y1);
		var v2 = new B2Vec2(x2, y2);
		
		v1.x = Engine.toPhysicalUnits(v1.x);
		v1.y = Engine.toPhysicalUnits(v1.y);
		v2.x = Engine.toPhysicalUnits(v2.x);
		v2.y = Engine.toPhysicalUnits(v2.y);
		
		v1 = one.getWorldPoint(v1);
		v2 = two.getWorldPoint(v2);
		
		var jd = new B2DistanceJointDef();
		jd.initialize(one, two, v1, v2);
		
		var toReturn = world.createJoint(jd);
		addJoint(toReturn);
		
		return cast(toReturn, B2DistanceJoint);
	}
	
	//---
	
	public function createHingeJoint
	(
		one:B2Body, 
		two:B2Body = null, 
		pt:B2Vec2 = null, 
		jointID:Int = -1,
		collide:Bool = false, 
		limit:Bool = false, 
		motor:Bool = false, 
		lower:Float = 0, 
		upper:Float = 0, 
		torque:Float = 0, 
		speed:Float = 0
	):B2RevoluteJoint
	{
		if(two == null)
		{
			two = world.m_groundBody;
		}
		
		if(pt == null)
		{
			pt = one.getLocalCenter();
		}
	
		var jd = new B2RevoluteJointDef();
		
		jd.bodyA = one;
		jd.bodyB = two;
		
		pt.x = Engine.toPhysicalUnits(pt.x);
		pt.y = Engine.toPhysicalUnits(pt.y);
		
		jd.localAnchorA = pt;
		jd.localAnchorB = two.getLocalPoint(one.getWorldPoint(pt));
		jd.collideConnected = collide;
		jd.enableLimit = limit;
		jd.enableMotor = motor;
		jd.lowerAngle = lower;
		jd.upperAngle = upper;
		jd.maxMotorTorque = torque;
		jd.motorSpeed = speed;
		
		var toReturn = world.createJoint(jd);
		
		if(jointID == -1)
		{
			addJoint(toReturn);
		}
			
		else
		{
			joints.set(jointID, toReturn);
			toReturn.ID = jointID;
		}
		
		return cast(toReturn, B2RevoluteJoint);
	}
	
	//---
											
	public function createSlidingJoint
	(
		one:B2Body, 
		two:B2Body = null, 
		dir:B2Vec2 = null, 
		jointID:Int = -1,
		collide:Bool = false, 
		limit:Bool = false, 
		motor:Bool = false, 
		lower:Float = 0, 
		upper:Float = 0, 
		force:Float = 0, 
		speed:Float = 0
	):B2LineJoint
	{
		if(two == null)
		{
			two = world.m_groundBody;
		}
		
		if(dir == null)
		{
			dir = new B2Vec2(1, 0);
		}
	
		dir.normalize();
		
		var pt1 = one.getWorldCenter();
		var pt2 = two.getWorldCenter();
		
		//Static body
		if(one.getType() == 0)
		{
			if(cast(one.getUserData(), Actor) != null)
			{
				pt1.x = cast(one.getUserData(), Actor).getPhysicsWidth() / 2;
				pt1.y = cast(one.getUserData(), Actor).getPhysicsHeight() / 2;
				pt1 = one.getWorldPoint(pt1);	
			}
		}
		
		if(two.getType() == 0)
		{
			if(cast(two.getUserData(), Actor) != null)
			{
				pt2.x = cast(two.getUserData(), Actor).getPhysicsWidth() / 2;
				pt2.y = cast(two.getUserData(), Actor).getPhysicsHeight() / 2;
				pt2 = two.getWorldPoint(pt2);	
			}
		}
		
		var pjd = new B2LineJointDef();
		pjd.initialize(one, two, pt1, dir);

		pjd.collideConnected = collide;
		pjd.enableLimit = limit;
		pjd.enableMotor = motor;
		pjd.lowerTranslation = toPhysicalUnits(lower);
		pjd.upperTranslation = toPhysicalUnits(upper);
		pjd.maxMotorForce = force;
		pjd.motorSpeed = toPhysicalUnits(speed);
		
		var toReturn = world.createJoint(pjd);
		
		if(jointID == -1)
		{
			addJoint(toReturn);
		}
			
		else
		{
			joints.set(jointID, toReturn);
			toReturn.ID = jointID;
		}
		
		return cast(toReturn, B2LineJoint);
	}
			
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
			region.setX(Engine.toPixelUnits(x) + region.regionWidth / 2);
			region.setY(Engine.toPixelUnits(y) + region.regionHeight / 2);
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
	
		if(NO_PHYSICS)
		{
			var region = new Region(this, x, y, [], new Rectangle(0, 0, w, h));
			addRegion(region);
			return region;
		}
		
		else
		{
			var p = new B2PolygonShape();
			p.setAsBox(w/2, h/2);
			return createRegion(x, y, p, true);
		}
	}
	
	public function createCircularRegion(x:Float, y:Float, r:Float):Region
	{
		x = Engine.toPhysicalUnits(x);
		y = Engine.toPhysicalUnits(y);
		r = Engine.toPhysicalUnits(r);
		
		if(NO_PHYSICS)
		{
			var region = new Region(this, x, y, [], new Rectangle(0, 0, r*2, r*2));
			addRegion(region);
			return region;
		}
		
		else
		{
			var cShape = new B2CircleShape();
			cShape.m_radius = r;
			return createRegion(x, y, cShape, true);
		}
	}
	
	public function addRegion(r:Region)
	{
		var nextID = nextRegionID();
		r.ID = nextID;
		regions.set(nextID, r);
		
		if(NO_PHYSICS)
		{
			groups.get(GameModel.REGION_ID).addChild(r);
		}
	}
	
	public function removeRegion(ID:Int)
	{
		var r = getRegion(ID);	
		regions.remove(r.ID);
		r.destroy();
		
		if(NO_PHYSICS)
		{
			groups.get(GameModel.REGION_ID).removeChild(r);
		}
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
	
	private function createTerrainRegion(x:Float, y:Float, shape:B2Shape, offset:Bool=false, groupID:Int = 1):Terrain
	{
		var shapeList = new Array<B2Shape>();
		shapeList.push(shape);
		var region = new Terrain(this, x, y, shapeList, groupID);
		
		if(offset)
		{
			region.setX(Engine.toPixelUnits(x) + region.regionWidth / 2);
			region.setY(Engine.toPixelUnits(y) + region.regionHeight / 2);
		}
		
		addTerrainRegion(region);
		return region;
	}
	
	public function createBoxTerrainRegion(x:Float, y:Float, w:Float, h:Float, groupID:Int=1):Terrain
	{
		x = Engine.toPhysicalUnits(x);
		y = Engine.toPhysicalUnits(y);
		w = Engine.toPhysicalUnits(w);
		h = Engine.toPhysicalUnits(h);
	
		var p = new B2PolygonShape();
		p.setAsBox(w/2, h/2);
		
		return createTerrainRegion(x, y, p, true, groupID);
	}
	
	public function createCircularTerrainRegion(x:Float, y:Float, r:Float, groupID:Int = 1):Terrain
	{
		x = Engine.toPhysicalUnits(x);
		y = Engine.toPhysicalUnits(y);
		r = Engine.toPhysicalUnits(r);
		
		var cShape = new B2CircleShape();
		cShape.m_radius = r;
		
		return createTerrainRegion(x, y, cShape, true, groupID);
	}
	
	public function addTerrainRegion(r:Terrain)
	{
		var nextID = nextTerrainRegionID();
		r.ID = nextID;
		terrainRegions.set(nextID, r);
	}
	
	public function removeTerrainRegion(ID:Int)
	{
		var t = getTerrainRegion(ID);
		terrainRegions.remove(ID);
		t.destroy();
	}
	
	public function getTerrainRegion(ID:Int):Terrain
	{
		return terrainRegions.get(ID);
	}
	
	public function getTerrainRegions():IntHash<Terrain>
	{
		return terrainRegions;
	}
	
	public function nextTerrainRegionID():Int
	{
		var ID = -1;
		
		for(r in terrainRegions)
		{
			if(r == null) continue;
			ID = Std.int(Math.max(ID, r.ID));
		}
		
		return ID + 1;
	}
	
	//*-----------------------------------------------
	//* Game Attributes
	//*-----------------------------------------------
	
	public inline function setGameAttribute(name:String, value:Dynamic)
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
	
	public inline function setOffscreenTolerance(top:Int, left:Int, bottom:Int, right:Int)
	{
		Engine.paddingTop = top;
		Engine.paddingLeft = left;
		Engine.paddingBottom = bottom;
		Engine.paddingRight = right;
	}
	
	//*-----------------------------------------------
	//* Utils
	//*-----------------------------------------------
	
	//0 args
	public static inline function invokeListeners(listeners:Array<Dynamic>)
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
	public static inline function invokeListeners2(listeners:Array<Dynamic>, value:Dynamic)
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
	public static inline function invokeListeners3(listeners:Array<Dynamic>, value:Dynamic, value2:Dynamic)
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
	
	//3 args
	public static inline function invokeListeners4(listeners:Array<Dynamic>, value:Dynamic, value2:Dynamic, value3:Dynamic)
	{
		var r = 0;
		
		while(r < listeners.length)
		{
			try
			{
				var f:Dynamic->Dynamic->Dynamic->Array<Dynamic>->Void = listeners[r];			
				f(value, value2, value3, listeners);
				
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
	
	//4 args
	public static inline function invokeListeners5(listeners:Array<Dynamic>, value:Dynamic, value2:Dynamic, value3:Dynamic, value4:Dynamic)
	{
		var r = 0;
		
		while(r < listeners.length)
		{
			try
			{
				var f:Dynamic->Dynamic->Dynamic->Dynamic->Array<Dynamic>->Void = listeners[r];			
				f(value, value2, value3, value4, listeners);
				
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
	
	//5 args
	public static inline function invokeListeners6(listeners:Array<Dynamic>, value:Dynamic, value2:Dynamic, value3:Dynamic, value4:Dynamic, value5:Dynamic)
	{
		var r = 0;
		
		while(r < listeners.length)
		{
			try
			{
				var f:Dynamic->Dynamic->Dynamic->Dynamic->Dynamic->Array<Dynamic>->Void = listeners[r];			
				f(value, value2, value3, value4, value5, listeners);
				
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
