package com.stencyl;

#if cpp
import cpp.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end

import de.polygonal.ds.IntHashTable;

import com.stencyl.behavior.Attribute;
import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.TimedTask;
import com.stencyl.behavior.BehaviorManager;
import com.stencyl.behavior.BehaviorInstance;
import com.stencyl.behavior.Script;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Shape;
import openfl.display.Graphics;
import openfl.display.MovieClip;
import openfl.display.StageDisplayState;
import openfl.text.TextField;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.Assets;
import openfl.Lib;
import openfl.ui.Keyboard;

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
import com.stencyl.models.Sound;

import com.stencyl.models.scene.DeferredActor;
import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.Layer;
import com.stencyl.models.scene.TileLayer;
import com.stencyl.models.scene.ScrollingBitmap;

import com.stencyl.models.Background;
import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.background.ScrollingBackground;

//Do not remove - forces your behaviors to be included
import scripts.MyScripts;
import com.stencyl.models.collision.Mask;

import com.stencyl.utils.Utils;

import com.stencyl.event.EventMaster;
import com.stencyl.event.NativeListener;

import motion.Actuate;
import motion.easing.Elastic;

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
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.B2AABB;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;

import haxe.ds.ObjectMap;
import com.stencyl.graphics.shaders.PostProcess;
import com.stencyl.graphics.shaders.Shader;

//import com.nmefermmmtools.debug.Console;

class Engine 
{
	//*-----------------------------------------------
	//* Constants
	//*-----------------------------------------------
		
	public static var DOODAD:String = "";
	
	public static var INTERNAL_SHIFT:String = "iSHIFT";
	public static var INTERNAL_CTRL:String = "iCTRL";
	
	public static var NO_PHYSICS:Bool = false;
	public static var DEBUG_DRAW:Bool = false; //!NO_PHYSICS && true;
	
	public static var IMG_BASE:String = "";
	public static var SCALE:Float = 1;
	
	public static var isStandardIOS:Bool = false;
	public static var isExtendedIOS:Bool = false;
	public static var isIPhone6:Bool = false;
	public static var isIPhone6Plus:Bool = false;
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
	public var gravityX:Float;
	public var gravityY:Float;
	
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
	public var regions:IntHashTable<Region>;
	public var terrainRegions:Map<Int,Terrain>;
	public var joints:Map<Int,B2Joint>;
	
	public static var movieClip:MovieClip;
	public static var stage:Stage;
	public var defaultGroup:Sprite; //The default layer (bottom-most)
	public var root:Sprite; //The absolute root
	public var colorLayer:Shape;
	public var master:Sprite; // the root of the main node
	public var hudLayer:Sprite; //Shows above everything else

	//Shows above everything else
	#if (js)
	public var transitionBitmapLayer:Bitmap;
	#else
	public var transitionBitmapLayer:Sprite;
	#end

	public var transitionLayer:Sprite; //Shows above everything else
	public var debugLayer:Sprite;
	
	public var g:G;
	
	
	//*-----------------------------------------------
	//* Model - Actors & Groups
	//*-----------------------------------------------
	
	public var groups:Map<Int,Group>;
	public var reverseGroups:Map<String,Group>;
	
	public var allActors:IntHashTable<Actor>;
	public var nextID:Int;
	
	//Used to be called actorsToRender
	public var actorsPerLayer:Map<Int,DisplayObjectContainer>;
	
	public var hudActors:IntHashTable<Actor>;
	
	//HashMap<Integer, HashSet<Actor>>
	public var actorsOfType:Map<Int,Array<Actor>>;
	
	//HashMap<Integer, HashSet<Actor>>
	public var recycledActorsOfType:Map<Int,Array<Actor>>;
	
	//List<DeferredActor>
	public var actorsToCreateInNextScene:Array<DeferredActor>;
	
	//TODO: Map<String, Layer>
	
	
	//*-----------------------------------------------
	//* Model - Layers / Terrain
	//*-----------------------------------------------
	
	//My feeling is that we don't need anything except a way to map from layerID to Layer, which in turn
	//can tell us the order and which layers are above, below. And what layer is on top/bottom.
	//A Layer = Sprite/Container.

	//complete listing	
	public var layers:IntHashTable<RegularLayer>;
	public var layersByName:Map<String,RegularLayer>;

	//For quick iteration
	public var interactiveLayers:Array<Layer>;
	public var backgroundLayers:Array<BackgroundLayer>;

	public var dynamicTiles:Map<String,Actor>;
	public var animatedTiles:Array<Tile>;
	
	public var topLayer:Int; //order of top layer among interactive layers
	public var bottomLayer:Int; //order of bottom layer among interactive layers
	public var middleLayer:Int; //order of middle layer among interactive layers
	
	public var layersToDraw:Map<Int,RegularLayer>; //Map order -> Layer/BackgroundLayer

	public var tileUpdated:Bool;
	
	public var loadedAtlases:Map<Int,Int>;
	public var atlasesToLoad:Map<Int,Int>;
	public var atlasesToUnload:Map<Int,Int>;
	
	
	//*-----------------------------------------------
	//* Model - ?????
	//*-----------------------------------------------
	
	public var actorsToCreate:Array<Actor>;
	
	
	//*-----------------------------------------------
	//* Model - Behaviors & Game Attributes
	//*-----------------------------------------------
	
	public var gameAttributes:Map<String,Dynamic>;
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

	private var collisionPairs:IntHashTable<Map<Int,Bool>>;
	private var disableCollisionList:Array<Actor>;

	public var keyPollOccurred:Bool = false;
	
	public var whenKeyPressedListeners:Map<String, Dynamic>;
	public var hasKeyPressedListeners:Bool;
	public var whenAnyKeyPressedListeners:Array<Dynamic>;
	public var whenAnyKeyReleasedListeners:Array<Dynamic>;
	public var whenAnyGamepadPressedListeners:Array<Dynamic>;
	public var whenAnyGamepadReleasedListeners:Array<Dynamic>;
	public var whenTypeGroupCreatedListeners:ObjectMap<Dynamic, Dynamic>;
	public var whenTypeGroupDiesListeners:ObjectMap<Dynamic, Dynamic>;
	public var typeGroupPositionListeners:Map<Int,Dynamic>;
	public var collisionListeners:Map<Int,Dynamic>;
	public var soundListeners:ObjectMap<Dynamic, Dynamic>;		
			
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
	//* Full Screen Shaders - EXPERIMENTAL - C++
	//*-----------------------------------------------
	
	#if(desktop || iphone || android)
	private var shader:PostProcess;
	public var shaderLayer:Sprite;
	public var shaders:Array<PostProcess>;
	#end
	
	
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
	
	public function isInFullScreen():Bool
	{
		return Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE;
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
			
			var screenWidth = Lib.current.stage.stageWidth;
			var screenHeight = Lib.current.stage.stageHeight;
			
			root.scaleX = 1.0;
			root.scaleY = 1.0;
			root.x = 0.0;
			root.y = 0.0;
			
			screenScaleX = root.scaleX;
			screenScaleY = root.scaleY;
			screenOffsetX = Std.int(root.x);
			screenOffsetY = Std.int(root.y);
					
			if(stats != null)
			{
				stats.x = Std.int(scripts.MyAssets.stageWidth * scripts.MyAssets.gameScale) - stats.width;
				stats.y = 0;
			}
			
			Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			resetShaders();
		} 
		
		else 
		{
			isFullScreen = true;
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			cast(root, Universal).initScreen(true);
			
			screenScaleX = root.scaleX;
			screenScaleY = root.scaleY;
			screenOffsetX = Std.int(root.x);
			screenOffsetY = Std.int(root.y);
			
			if(stats != null)
			{
				stats.x = Std.int(openfl.system.Capabilities.screenResolutionX) - stats.width;
				stats.y = 0;
			}
			
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 2);
			resetShaders();
		}
	}
	#end
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------

	public function new(root:Sprite) 
	{		
		#if(desktop || iphone || android)
		if(openfl.display.OpenGLView.isSupported)
		{
			shaderLayer = new Sprite();
		}
		#end
		
		root.mouseChildren = false;
		root.mouseEnabled = false;
		//root.stage.mouseChildren = false;

		if(scripts.MyAssets.debugDraw)
		{
			DEBUG_DRAW = true;
		}
		
		engine = this;
		Script.engine = this;
		this.root = root;
		
		screenScaleX = root.scaleX;
		screenScaleY = root.scaleY;
		screenOffsetX = Std.int(root.x);
		screenOffsetY = Std.int(root.y);
		
		NO_PHYSICS = scripts.MyAssets.physicsMode == 1;
		
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);
		begin(scripts.MyAssets.initSceneID);
		
		#if(desktop || iphone || android)
		if(openfl.display.OpenGLView.isSupported)
		{
			root.addChild(shaderLayer);
		}
		#end
	}
	
	#if(flash || js)
	public function addShader(s:PostProcess, addToDisplayTree:Bool = true) {}
	public function clearShaders() {}
	public function toggleShadersForHUD() {} 
	public function resetShaders() {}
	#else
	public function addShader(s:PostProcess, addToDisplayTree:Bool = true) 
	{
		if(openfl.display.OpenGLView.isSupported)
		{
			//Clear out existing shader if one is currently active, otherwise we hit graphical glitches.
			if(shaders != null && s.renderTo == null)
			{
				var removeAll = false;
				
				for(shader in shaders)
				{
					if(shader.renderTo == null)
					{
						removeAll = true;
						break;
					}
				}
				
				if(removeAll)
				{
					trace("Enabling a shader over an existing shader. Clearing existing shader first.");
					clearShaders();
				}
			}
			
			if(addToDisplayTree)
			{
				shaderLayer.addChild(s);
			}

			if(shaders == null)
			{
				shaders = [s];
			}
			
			else
			{
				shaders.push(s);
			}
		}
		
		else
		{
			trace("Shaders are not supported on this platform.");
		}
	}
	
	public function clearShaders()
	{
		Utils.removeAllChildren(shaderLayer);
		shaders = [];
	}
	
	public function toggleShadersForHUD()
	{
		if(shaderLayer != null && hudLayer != null && root != null)
		{
			root.swapChildren(shaderLayer, hudLayer);
		}
	}
	
	public function resetShaders()
	{
		if(shaders != null)
		{
			for(shader in shaders)
			{
				shader.rebuild();
			}
		}
	}
	#end
	
	public function begin(initSceneID:Int)
	{
		loadedAtlases = new Map<Int,Int>();
		atlasesToLoad = new Map<Int,Int>();
		atlasesToUnload = new Map<Int,Int>();

		Input.enable();
		Input.define(INTERNAL_SHIFT, [Key.SHIFT]);
		Input.define(INTERNAL_CTRL, [Key.CONTROL]);
		
		landscape = scripts.MyAssets.landscape;
		var stageWidth = scripts.MyAssets.stageWidth;
		var stageHeight = scripts.MyAssets.stageHeight;
		
		screenWidth = Std.int(stageWidth);
		screenHeight = Std.int(stageHeight);
		screenWidthHalf = Std.int(stageWidth/2);
		screenHeightHalf = Std.int(stageHeight/2);
		
		#if (mobile && !air)
		if(!scripts.MyAssets.autorotate)
		{
			if(landscape)
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

		#if (cpp || neko)
		{
			for(atlas in GameModel.get().atlases)
			{
				if(atlas.active)
					atlasesToLoad.set(atlas.ID, atlas.ID);
			}
		}
		#end
		
		#if mobile
		//Preload sounds here.
		for(r in Data.get().resources)
		{
			if(Std.is(r, Sound))
			{
				var sound = cast(r, Sound);		
				var atlas = GameModel.get().atlases.get(sound.atlasID);
	
				if(atlas != null && atlas.active)
				{
					sound.loadGraphics();
				}
			}
		}
		#end
		
		g = new G();
		
		//---
			
		started = true;
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
		
		acc = 0;
		lastTime = Lib.getTimer();

		//Constants
		sceneWidth = stageWidth; //Overriden once scene loads
		sceneHeight = stageHeight; //Overriden once scene loads
			
		//Display List
		colorLayer = new Shape();
		root.addChild(colorLayer);

		master = new Sprite();
		root.addChild(master);
		
		hudLayer = new Sprite();
		root.addChild(hudLayer);
		
		transitionLayer = new Sprite();
		root.addChild(transitionLayer);
		
		#if (js)
		transitionBitmapLayer = new Bitmap(new BitmapData(1, 1, true, 0));
		#else
		transitionBitmapLayer = new Sprite();
		#end
		
		//root.addChild(transitionBitmapLayer);
		
		debugLayer = new Sprite();
		root.addChild(debugLayer);
				
		//Initialize things	
		actorsToCreateInNextScene = new Array();			
		gameAttributes = new Map<String,Dynamic>();
		
		//Profiler
		#if !js
		//if(!scripts.MyAssets.releaseMode)
		{
			if(scripts.MyAssets.showConsole)
			{
				stats = new com.nmefermmmtools.debug.Stats();
				stage.addChild(stats);
			}
		}
		
		/*if(scripts.MyAssets.showConsole)
		{
			pgr.gconsole.GameConsole.init();
			pgr.GameConsole.setConsoleFont('./path/to/your/font.ttf');
        	pgr.GameConsole.setPromptFont('./remember/to/make/it/relative.ttf');
        	pgr.GameConsole.setMonitorFont('./or/you/will/be/confused.ttf');   
		}*/
		#end
		
		//Console.create();
		
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
		
		#if (mobile && android)
		Purchases.initialize(scripts.MyAssets.androidPublicKey);
		#end	
		
		//Now, let's start
		enter = new FadeInTransition(0.5);
		enter.start();
		sceneToEnter = initSceneID;
		
		loadScene(initSceneID);
	}	
	
	public function loadScene(sceneID:Int)
	{
		collisionPairs = new IntHashTable<Map<Int,Bool>>(32);
		
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
		
		scene.load();

		#if(!flash)
		{
			//figure out which atlases we want for this scene
			var desiredAtlasList = new Map<Int,Int>();

			if(scene.retainsAtlases)
			{
				//if the scene retains atlases, it's easy. Copy them over.

				for(i in loadedAtlases)
					desiredAtlasList.set(i, i);
			}
			else
			{
				//make sure that the "all scenes" atlases are copied over
				//other than that, only the atlases the scene has marked.

				for(i in loadedAtlases)
				{
					if(GameModel.get().atlases.get(i).allScenes)
						desiredAtlasList.set(i, i);
				}
				for(i in scene.atlases)
					desiredAtlasList.set(i, i);
			}

			//using the load/unload blocks overwrites everything
			for(atlas in atlasesToLoad)
				desiredAtlasList.set(atlas, atlas);
			for(atlas in atlasesToUnload)
				desiredAtlasList.remove(atlas);

			for(atlas in loadedAtlases)
			{
				if(!desiredAtlasList.exists(atlas))
				{
					Data.get().unloadAtlas(atlas);
					loadedAtlases.remove(atlas);
				}
			}

			#if (cpp || neko)
			Gc.run(true);
			#end
			
			for(atlas in desiredAtlasList)
			{
				if(!loadedAtlases.exists(atlas))
				{
					Data.get().loadAtlas(atlas);
					loadedAtlases.set(atlas, atlas);
				}
			}
			
			atlasesToLoad = new Map<Int,Int>();
			atlasesToUnload = new Map<Int,Int>();
		}
		#end
		
		sceneWidth = scene.sceneWidth;
		sceneHeight = scene.sceneHeight;
		
		behaviors = new BehaviorManager();
		
		groups = new Map<Int,Group>();
		reverseGroups = new Map<String,Group>();
		
		for(grp in GameModel.get().groups)
		{
			var g = new Group(grp.ID, grp.name);
			groups.set(grp.ID, g);
			reverseGroups.set(grp.name, g);
			g.name = grp.name;
		}
		
		//force regions in here
		var regionGroup = new Group(GameModel.REGION_ID, "Regions");
		groups.set(GameModel.REGION_ID, regionGroup);
		reverseGroups.set("Regions", regionGroup);
		
		disableCollisionList = new Array<Actor>();
		actorsOfType = new Map<Int,Array<Actor>>();
		recycledActorsOfType = new Map<Int,Array<Actor>>();
		
		regions = new IntHashTable<Region>(32);
		regions.reuseIterator = true;
		
		terrainRegions = new Map<Int,Terrain>();
		joints = new Map<Int,B2Joint>();
		
		dynamicTiles = new Map<String,Actor>();
		animatedTiles = new Array<Tile>();
		hudActors = new IntHashTable<Actor>(64);
		hudActors.reuseIterator = true;
		allActors = new IntHashTable<Actor>(256); 
		allActors.reuseIterator = true;
		actorsPerLayer = new Map<Int,DisplayObjectContainer>();
		nextID = 0;
		
		//Events
		whenKeyPressedListeners = new Map<String, Dynamic>();
		hasKeyPressedListeners = false;
		whenAnyKeyPressedListeners = new Array<Dynamic>();
		whenAnyKeyReleasedListeners = new Array<Dynamic>();
		whenAnyGamepadPressedListeners = new Array<Dynamic>();
		whenAnyGamepadReleasedListeners = new Array<Dynamic>();
	
		whenTypeGroupCreatedListeners = new ObjectMap<Dynamic, Dynamic>();
		whenTypeGroupDiesListeners = new ObjectMap<Dynamic, Dynamic>();
		typeGroupPositionListeners = new Map<Int,Dynamic>();
		collisionListeners = new Map<Int,Dynamic>();
		soundListeners = new ObjectMap<Dynamic, Dynamic>();
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
			
			gravityX = scene.gravityX;
			gravityY = scene.gravityY;
		}
		
		else
		{
			gravityX = scene.gravityX;
			gravityY = scene.gravityY;
		}
		
		loadTerrain();
		loadRegions();
		loadTerrainRegions();
		loadActors();
		loadCamera();
		loadJoints();
		
		loadDeferredActors();		
		initBehaviors(behaviors, scene.behaviorValues, this, this, true);			
		initActorScripts();
		
		#if (cpp || neko)
		Gc.run(true);
		#end
	}
	
	public static function initBehaviors
	(
		manager:BehaviorManager, 
		behaviorValues:Map<String,Dynamic>, 
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
			var attributes:Map<String,Attribute> = new Map<String,Attribute>();
			
			if(template == null)
			{
				trace("Non-Existent Behavior ID (Init): " + bi.behaviorID);
				continue;
			}
			
			//Start honoring default values for events.
			if(template.isEvent)
			{
				for(key in template.attributes.keys())
				{
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
					
					if(type == "list")
					{
						attributes.set(key, new Attribute(ID, attribute.fieldName, attribute.fullName, [], type, null, attribute.hidden));
					}
					
					else if(type == "map")
					{
						attributes.set(key, new Attribute(ID, attribute.fieldName, attribute.fullName, new Map<String, Dynamic>(), type, null, attribute.hidden));
					}
				}
			}

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
				
				attributes.set(key, new Attribute(ID, attribute.fieldName, attribute.fullName, value, type, null, attribute.hidden));
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
				template.type,
				template.isEvent
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
		aabb.upperBound.x = screenWidth / physicsScale;
		aabb.upperBound.y = screenHeight / physicsScale;
		world.setScreenBounds(aabb);
		
		debugDrawer = new B2DebugDraw();
		debugDrawer.setSprite(debugLayer);
		debugDrawer.setLineThickness(3);
		debugDrawer.setDrawScale(10 * SCALE);
		debugDrawer.setFillAlpha(0);
		debugDrawer.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
		world.setDebugDraw(debugDrawer);
		
		//---
		
		//TODO: Developers - uncomment this block out to turn on the edge shapes test case.
		//Run on any blank game, blank scene - doesn't matter what it is.
		/*var bodyDef:B2BodyDef = new B2BodyDef();
		bodyDef.position.set(100/physicsScale, 100/physicsScale);
		bodyDef.groupID = GameModel.TERRAIN_ID;
		bodyDef.type = B2Body.b2_staticBody;
		
		var edge:B2EdgeShape = new B2EdgeShape(new B2Vec2(0, 0), new B2Vec2(130/physicsScale, 30/physicsScale));
		
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = edge;
		fixtureDef.density = 1;
		fixtureDef.groupID = GameModel.TERRAIN_ID;
		
		var body:B2Body = world.createBody(bodyDef);
		body.createFixture(fixtureDef);
		
		bodyDef.position.set(120/physicsScale, 10/physicsScale);
		fixtureDef.shape = B2PolygonShape.asBox(1, 1);
		//fixtureDef.shape = new B2CircleShape(1);
		bodyDef.ignoreGravity = false;
		bodyDef.groupID = 3;
		fixtureDef.groupID = 3;
		bodyDef.type = B2Body.b2_dynamicBody;
		body = world.createBody(bodyDef);
		body.createFixture(fixtureDef);*/
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
		cameraX = 0;
		cameraY = 0;
	}
	
	private function loadRegions()
	{					
		regions = new IntHashTable<Region>(32);
		regions.reuseIterator = true;

		for(r in scene.regions)
		{
			var region:Region = new Region(this, r.x, r.y, r.shapes, r.simpleBounds);
			region.name = r.name;
			
			if(!NO_PHYSICS)
			{
				region.setX(toPixelUnits(r.x) + (region.regionWidth / 2));
				region.setY(toPixelUnits(r.y) + (region.regionHeight / 2));
			}
			
			region.ID = r.ID;
			
			addRegion(region);
		}
	}
	
	private function loadTerrainRegions()
	{						
		terrainRegions = new Map<Int,Terrain>();
		
		if(NO_PHYSICS)
		{
			return;
		}
		
		for(r in scene.terrainRegions)
		{
			var region = new Terrain(this, r.x, r.y, r.shapes, r.groupID, r.fillColor);
			region.name = r.name;
			
			region.setX(toPixelUnits(r.x) + (region.regionWidth / 2));
			region.setY(toPixelUnits(r.y) + (region.regionHeight / 2));
			
			region.ID = r.ID;
			
			addTerrainRegion(region);
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
				
				pt.x = toPixelUnits(pt.x);
				pt.y = toPixelUnits(pt.y);
				
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
				
				pt.x = toPixelUnits(pt.x);
				pt.y = toPixelUnits(pt.y);
				
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
					Utils.INTEGER_MAX,
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
					Utils.INTEGER_MAX,
					GameModel.TERRAIN_ID,
					wireframe.x, 
					wireframe.y, 
					getTopLayer(),
					Std.int(wireframe.width), 
					Std.int(wireframe.height), 
					null, 
					new Map<String,Dynamic>(),
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
			
			getGroup(GameModel.TERRAIN_ID).addChild(a);	
		}
	}
	
	//This is mainly to establish mappings and figure out top, middle, bottom
	private function initLayers()
	{
		setColorBackground(scene.colorBackground);

		animatedTiles = scene.animatedTiles;
		
		if(animatedTiles != null)
		{
			for(tile in animatedTiles)
			{
				tile.currFrame = 0;
				tile.currTime = 0;
			}
		}

		layers = scene.layers;
		layersToDraw = new Map<Int,RegularLayer>();
		layersByName = new Map<String, RegularLayer>();
		interactiveLayers = new Array<Layer>();
		backgroundLayers = new Array<BackgroundLayer>();

		var foundBottom:Bool = false;
		var foundMiddle:Bool = false;
		var numLayersProcessed:Int = 0; //for finding middle
		var highestLayerOrder = -1;

		var reverseOrders = new Map<Int,RegularLayer>();

		for(l in layers)
		{
			highestLayerOrder = Std.int(Math.max(highestLayerOrder, l.order));

			reverseOrders.set(l.order, l);
			layersByName.set(l.layerName, l);
			if(Std.is(l, Layer))
				interactiveLayers.push(cast(l, Layer));
			else if(Std.is(l, BackgroundLayer))
				backgroundLayers.push(cast(l, BackgroundLayer));
		}

		for(i in 0...highestLayerOrder + 1)
		{
			var j:Int = highestLayerOrder - i;
			var l:RegularLayer = reverseOrders.get(i);
			l.order = j;
			layersToDraw.set(j, l);
		}

		for(i in 0...highestLayerOrder + 1)
		{
			var l:RegularLayer = layersToDraw.get(i);

			if(Std.is(l, BackgroundLayer))
			{
				var layer = cast(l, BackgroundLayer);
				layer.load();
				master.addChild(layer);
			}
			else if(Std.is(l, Layer))
			{
				var layer = cast(l, Layer);
				
				if(!foundBottom)
				{
					foundBottom = true;
					bottomLayer = i;
				}
				
				if(!foundMiddle && numLayersProcessed == Math.floor(interactiveLayers.length / 2))
				{
					foundMiddle = true;
					middleLayer = i;
				}

				master.addChild(layer);
				actorsPerLayer.set(layer.ID, layer.actorContainer);
				
				//Eventually, this will become the correct value
				topLayer = i;
				defaultGroup = layer.actorContainer;

				if(NO_PHYSICS)
				{
					layer.tiles.mountGrid();
				}

				numLayersProcessed++;
			}
		}
		
		//For scenes with no scene data
		if(defaultGroup == null)
		{
			defaultGroup = new RegularLayer(0, "", 0, 1, 1, 1, openfl.display.BlendMode.NORMAL);
			master.addChild(defaultGroup);
		}
	}

	public function setColorBackground(bg:Background)
	{
		bg.draw(colorLayer.graphics, 0, 0, Std.int(screenWidth * SCALE), Std.int(screenHeight * SCALE));
	}

	//*-----------------------------------------------
	//* Scene Switching
	//*-----------------------------------------------
	
	//PRIVATE API - No guarantee of this existing in the future!
	//Shrink the pool down to its current size to optimize memory usage.
	//Recommended: No more than every 5 seconds.
	//Warning: Will memory leak a little beyond baseline memory. Leak cleared upon switching or reloading scene.
	public function optimizePool()
	{
		for(cache in recycledActorsOfType)
		{
			var toRemove:Array<Actor> = new Array<Actor>();
			
			for(actor in cache)
			{
				if(actor != null && actor.recycled)
				{
					toRemove.push(actor);
				}
			}
			
			for(actor in toRemove)
			{
				cache.remove(actor);
				removeActor(actor);
			}
		}
	}

	public function cleanup()
	{
		#if mobile
		JoystickController.reset();
		#end
		
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
		
		for (rList in recycledActorsOfType)
		{
			for (a in rList)
			{
				if (!a.destroyed)
				{
					a.destroy();
				}
			}
		}
		
		for(set in recycledActorsOfType)
		{
			Utils.clear(set);
		}
		
		//Clear old TileLayer data
		for(layer in interactiveLayers)
		{
			layer.tiles.clearBitmap();
		}
		
		for(a in allActors)
		{
			a.destroy();
			//removeActor(a);
		}
		
		while(Lambda.count(allActors) > 0)
		{
			for(key in allActors.keys())
			{
				allActors.clr(key);
			}
		}
		
		scene.unload();
		
		actorsOfType = null;
		recycledActorsOfType = null;
		
		hudActors = null;
		layers = null;
		layersByName = null;
		interactiveLayers = null;
		backgroundLayers = null;
		actorsPerLayer = null;
		layersToDraw = null;
		
		dynamicTiles = null;
		animatedTiles = null;
		
		regions = null;
		terrainRegions = null;
		joints = null;
		groups = null;
		reverseGroups = null;
		allActors = null;
		scene = null;
		tasks = null;
		
		collisionPairs = null;
		disableCollisionList = null;
		
		whenKeyPressedListeners = null;	
		hasKeyPressedListeners = false;
		whenAnyKeyPressedListeners = null;
		whenAnyKeyReleasedListeners = null;
		whenAnyGamepadPressedListeners = null;
		whenAnyGamepadReleasedListeners = null;
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
		
		whenSwipedListeners = null;
		whenMTStartListeners = null;
		whenMTDragListeners = null;
		whenMTEndListeners = null;
		
		whenFocusChangedListeners = null;
		nativeListeners = null;
		
		Script.lastCreatedActor = null;
		Script.lastCreatedJoint = null;
		Script.lastCreatedRegion = null;
		Script.lastCreatedTerrainRegion = null;
		
		
		//Reset
		Input.update();
		
		world = null;
	}
	
	public function switchScene(sceneID:Int, leave:Transition=null, enter:Transition=null)
	{
		// trace("Request to switch to Scene " + sceneID);

		if(isTransitioning())
		{
			// trace("Warning: Switching Scene while already switching. Ignoring.");
			return;
		}
		
		trace("Switching to scene " + sceneID);
		
		if(leave != null && leave.isComplete())
		{
			leave.reset();
		}
		
		if(leave == null || leave.duration == 0)
		{
			leave = new Transition(0);
		}
		
		if(enter == null || enter.duration == 0)
		{
			enter = new Transition(1);
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
	
	public function isTransitioningOut():Bool
	{
		if(leave != null && leave.isActive())
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
			ai.actorType.autoScale,
			ai.actorType.ignoreGravity,
			ai.actorType.physicsMode
		);

		if(ai.angle != 0)
		{								
			if (a.currOffset.x != 0 || a.currOffset.y != 0)
			{
				var resetOrigX:Int = Std.int(a.currOrigin.x);
				var resetOrigY:Int = Std.int(a.currOrigin.y);
				
				a.setOriginPoint(Std.int(a.cacheWidth / 2), Std.int(a.cacheHeight / 2));
				a.setAngle(ai.angle, false);
				a.setOriginPoint(resetOrigX, resetOrigY);
			}
			
			else
			{
				a.setAngle(ai.angle, false);
			}
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
		
		if(ai.actorType.physicsMode < 2)
		{
			var group = groups.get(ai.groupID);
			
			if(group != null)
			{
				group.addChild(a);
			}
		}
		
		//---
		
		//Use the next available ID
		if(ai.elementID == Utils.INTEGER_MAX)
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
		a.updateDrawingMatrix();
		
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
		allActors.clr(a.ID);

		//Remove from the layer group
		removeActorFromLayer(a, a.layerID);
		
		//Remove from normal group
		groups.get(a.getGroupID()).removeChild(a);
		
		if(a.isHUD || a.alwaysSimulate)
		{
			hudActors.clr(a.ID);
		}
		
		a.destroy();
		
		//---
		
		if (Data.get().resources.get(a.typeID) != null)
		{
			var typeID:ActorType = cast(Data.get().resources.get(a.typeID), ActorType);
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
		
		if(a == null || a.recycled)
		{
			return;
		}
	
		var l1 = engine.whenTypeGroupDiesListeners.get(a.getType());
		var l2 = engine.whenTypeGroupDiesListeners.get(a.getGroup());
	
		invokeListeners(a.whenKilledListeners);

		if(l1 != null)
		{
			invokeListeners2(l1, a);
		}
		
		if(l2 != null)
		{
			invokeListeners2(l2, a);
		}
				
		if(a.isHUD)
		{
			a.unanchorFromScreen();
		}
		
		if(a.alwaysSimulate)
		{
			a.makeSometimesSimulate(false);
		}
	
		a.firstMove = false;
		a.setX(1000000, false, true);
		a.setY(1000000, false, true);
		a.colX = 1000000;
		a.colY = 1000000;
		a.recycled = true;
		a.killLeaveScreen = false;
		a.lastScreenState = false;
		a.lastSceneState = false;
		//a.setFilter(null);
		
		a.cancelTweens();
		a.clearFilters();
		a.resetBlendMode();
		
		//Only the fading is necessary. Don't fully understand why...
		//a.moveTo(1000000, 1000000, 0.01);
		//a.growTo(1, 1, 0.02);
		//a.spinTo(0, 0.01);
		a.fadeTo(1, 0.01);
		
		a.realScaleX = 1;
		a.realScaleY = 1;
		
		a.switchToDefaultAnimation();
		a.disableActorDrawing();
		a.removeAttachedImages();
		
		//Kill previous contacts
		if(a.physicsMode == 0 && a.body != null)
		{
			var contact:B2ContactEdge = a.body.getContactList();
			
			while(contact != null)
			{	
				engine.world.m_contactManager.m_contactListener.endContact(contact.contact);
				contact = contact.next;
			}
		}
		
		a.removeAllListeners();
		a.resetListeners();
		
		removeActorFromLayer(a, a.layerID);
		
		if(a.physicsMode == 0)
		{
			a.body.setActive(false);
			a.body.setAwake(false);
			
			// Remove world body list.
			if (a.body.m_prev != null)
			{
				a.body.m_prev.m_next = a.body.m_next;		
			}
		
			if (a.body.m_next != null)
			{
				a.body.m_next.m_prev = a.body.m_prev;				
			}
		
			if (a.body == world.m_bodyList)
			{
				world.m_bodyList = a.body.m_next;
			}
			
			a.body.m_prev = null;
			a.body.m_next = null;
			
			--world.m_bodyCount;
		}
		
		a.xSpeed = 0;
		a.ySpeed = 0;
		a.rSpeed = 0;
		a.continuousCollision = false;
		
		allActors.clr(a.ID);
	}
	
	public function getRecycledActorOfType(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
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

		return getRecycledActorOfTypeOnLayer(type, x, y, layerID);
	}

	public function getRecycledActorOfTypeOnLayer(type:ActorType, x:Float, y:Float, layerID:Int):Actor
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
					actor.createTime = Lib.getTimer();
					allActors.set(actor.ID, actor);
				
					actor.dead = false;
					actor.dying = false;
					actor.recycled = false;
					actor.killLeaveScreen = false;
					actor.switchToDefaultAnimation();						
					actor.enableAllBehaviors();
					
					if(actor.physicsMode == 0)
					{
						actor.body.setActive(true);
						actor.body.setAwake(true);
						
						actor.body.m_prev = null;
						actor.body.m_next = world.m_bodyList;
						
						if (world.m_bodyList != null)
						{
							world.m_bodyList.m_prev = actor.body;
						}
						
						world.m_bodyList = actor.body;
						++world.m_bodyCount;
					}
					
					actor.registry = new Map<String,Dynamic>();
					actor.enableActorDrawing();					
					actor.setX(x, false, true);
					actor.setY(y, false, true);
					
					if(actor.physicsMode == 0)
					{
						actor.colX = x;
						actor.colY = y;
					}
					
					actor.setAngle(0, false);
					actor.setIgnoreGravity(actor.defaultGravity);
					actor.alpha = 1;
					actor.realScaleX = 1;
					actor.realScaleY = 1;
					
					if(actor.bodyDef != null)
					{
						actor.continuousCollision = actor.bodyDef.bullet;
					}
					
					//actor.setFilter(null);					

					//move to specified layer
					moveActorToLayer(actor, layerID);
					
					actor.initScripts();
					
					var f1 = whenTypeGroupCreatedListeners.get(type);
					var f2 = whenTypeGroupCreatedListeners.get(actor.getGroup());
		
					if(f1 != null)
					{
						invokeListeners2(f1, actor);
					}
		
					if(f2 != null)
					{
						invokeListeners2(f2, actor);
					}

					return actor;
				}
			}
			
			//Otherwise make a new one
			a = createActorOfType(type, x, y, layerID);
			//cache.push(a);
		}
		
		return a;
	}
	
	public function createActorOfType(type:ActorType, x:Float, y:Float, layerID:Int):Actor
	{
		if(type == null)
		{
			trace("Tried to create actor with null or invalid type.");
			return null;
		}
		
		var ai:ActorInstance = new ActorInstance
		(
			Utils.INTEGER_MAX,
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
		return layersToDraw.get(topLayer).ID;
	}
	
	public function getBottomLayer():Int
	{
		return layersToDraw.get(bottomLayer).ID;
	}
	
	public function getMiddleLayer():Int
	{
		return layersToDraw.get(middleLayer).ID;
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
		
		//Update Tweens - Synced to engine
		motion.actuators.SimpleActuator.stage_onEnterFrame(null);
		
		if(!NO_PHYSICS)
		{
			var aabb = world.getScreenBounds();
			aabb.lowerBound.x = (Math.abs(cameraX / SCALE) - paddingLeft) / physicsScale;
			aabb.lowerBound.y = (Math.abs(cameraY / SCALE) - paddingTop) / physicsScale;
			aabb.upperBound.x = aabb.lowerBound.x + ((screenWidth + paddingRight + paddingLeft) / physicsScale);
			aabb.upperBound.y = aabb.lowerBound.y + ((screenHeight + paddingBottom + paddingTop) / physicsScale);
		}
		
		var inputx = Std.int(Input.mouseX / SCALE);
		var inputy = Std.int(Input.mouseY / SCALE);
						
		if(Input.mousePressed)
		{
			Script.mpx = inputx;
			Script.mpy = inputy;
			invokeListeners(whenMousePressedListeners);
		}
		
		if(Input.mouseReleased)
		{
			Script.mrx = inputx;
			Script.mry = inputy;
			invokeListeners(whenMouseReleasedListeners);
		}

		if(mx != inputx || my != inputy)
		{
			mx = inputx;
			my = inputy;
			
			invokeListeners(whenMouseMovedListeners);
			
			if(Input.mouseDown && !Input.mousePressed)
			{
				invokeListeners(whenMouseDraggedListeners);
			}
		}
		
		//Update Timed Tasks
		var i = 0;
		
		while(i < tasks.length)
		{
			var t:TimedTask = tasks[i];
			
			if(!t.done)
			{
				t.update(STEP_SIZE);
			}
			
			if(t.done)
			{
				tasks.remove(t);	
				i--;
			}
			
			i++;
		}
		
		//Poll Keyboard Inputs
		if(hasKeyPressedListeners)
		{
			//Creates array per frame. Not optimal but hard to optimize out because of string keys.
			for(key in whenKeyPressedListeners.keys())
			{
				var pressed = Input.pressed(key);
				var released = Input.released(key);
				
				if(pressed || released)
				{
					var listeners = whenKeyPressedListeners.get(key);
					invokeListeners3(listeners, pressed, released);
				}				
			}

			keyPollOccurred = true;
		}
		
		//Native
		#if mobile
		for(n in 0...nativeListeners.length)
		{
			var listener = nativeListeners[n];
			listener.checkEvents(events);
		}
		
		events.clear();
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

		if(!regions.isEmpty())
		{
			for(r in regions)
			{
				if(r == null) continue;
				r.innerUpdate(elapsedTime, true);
			}
		}
		
		while(disableCollisionList.length > 0)
		{
			disableCollisionList.pop();
		}
				
		if(!collisionPairs.isEmpty())
		{
			for(pair in collisionPairs.keys())
			{
				collisionPairs.clr(pair);
			}
		}
		
		com.stencyl.models.actor.Animation.updateAll(elapsedTime);
		
		if(!allActors.isEmpty())
		{
			for(a in allActors)
			{		
				if(a != null && !a.dead && !a.recycled) 
				{
					//--- HAND INLINED THIS SINCE ITS CALLED SO MUCH
					var isOnScreen =
						(a.physicsMode > 0 || a.body.isActive()) && 
						a.colX + a.cacheWidth >= -cameraX / SCALE - paddingLeft && 
						a.colY + a.cacheHeight >= -cameraY / SCALE - paddingTop &&
						a.colX < -cameraX / SCALE + screenWidth + paddingRight &&
						a.colY < -cameraY / SCALE + screenHeight + paddingBottom;
					
					a.isOnScreenCache = isOnScreen;
					
					//---
				
					if(a.physicsMode == 0 && a.body != null)
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
					
					else if(a.physicsMode > 0)
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
		}

		keyPollOccurred = false;
			
		for(n in 0...disableCollisionList.length)
		{
			var a = disableCollisionList[n];
			
			if(a != null)
			{
				a.handlesCollisions = false;
			}
		}
		
		for(n in 0...animatedTiles.length)
		{
			var tile = animatedTiles[n];
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
		
		for(layer in layers)
		{
			layer.updatePosition(cameraX, cameraY, elapsedTime);
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
	        
	        var randX = (-shakeIntensity * screenWidth + Math.random() * (2 * shakeIntensity * screenWidth));
	        var randY = (-shakeIntensity * screenHeight + Math.random() * (2 * shakeIntensity * screenHeight));
	        
	        master.x = randX * SCALE;
	        master.y = randY * SCALE;
		}
	}
	
	//Game Loop
	private function onUpdate(event:Event):Void 
	{
		var currTime:Float = Lib.getTimer();
		var elapsedTime:Float = (currTime - lastTime);
		
		//Max Frame Duration = 5 FPS
		//Prevents spikes and prevents mobile backgrounding from going haywire.
		if(elapsedTime >= 200)
		{
			elapsedTime = 200;
		}
		
		acc += elapsedTime;
		
		Engine.elapsedTime = elapsedTime;

		if(leave != null)
		{
			//Update here, or you can have a transition that fails to finish
			motion.actuators.SimpleActuator.stage_onEnterFrame(null);
		
			if(leave.isComplete())
			{
				leave.deactivate();
				enterScene();
			}
			
			postUpdate(currTime);			
			
			return;
		}
		
		if(enter != null)
		{
			if(enter.isComplete())
			{
				enter.deactivate();
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
		if(!allActors.isEmpty())
		{
			for(a in allActors)
			{
				if(a == null || (a.physicsMode == 0 && a.body == null))
				{
					continue;
				}
				
				if(a.currAnimation != null && a.currAnimation.needsBitmapUpdate())
				{
					a.currAnimation.updateBitmap();
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
					a.resetOrigin = false;
				}
				else if (a.smoothMove)
				{
					if (a.drawX != a.realX || a.drawY != a.realY)
					{
						a.updateDrawingMatrix();
					}
				}		
				
				if(a.body == null)
				{
					continue;
				}
			}
		}
		
		//Drawing
		
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
			group1 = Actor.GROUP_OFFSET + event.groupA;
			group2 = Actor.GROUP_OFFSET + event.groupB;
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
			if(!collisionPairs.hasKey(a.ID))
			{
				collisionPairs.set(a.ID, new Map<Int,Bool>());
			}
			
			if(!collisionPairs.hasKey(event.otherActor.ID))
			{
				collisionPairs.set(event.otherActor.ID, new Map<Int,Bool>());
			}
			
			if(collisionPairs.get(a.ID).exists(event.otherActor.ID) || collisionPairs.get(event.otherActor.ID).exists(a.ID))
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
					collisionListeners.get(type1).remove(type2);
				}
			}
			
			if(type1 != type2 && collisionListeners.exists(type2) && collisionListeners.get(type2).exists(type1))
			{
				var listeners = collisionListeners.get(type2).get(type1);
				var reverseEvent = event.switchData(Collision.get());
				
				invokeListeners2(listeners, reverseEvent);
				
				if(listeners.length == 0)
				{
					collisionListeners.get(type2).remove(type1);
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
					collisionListeners.get(group1).remove(group2);
				}
			}
			
			if(group1 != group2 && collisionListeners.exists(group2) && collisionListeners.get(group2).exists(group1))
			{
				var listeners = collisionListeners.get(group2).get(group1);
				var reverseEvent = event.switchData(Collision.get());
				
				invokeListeners2(listeners, reverseEvent);
				
				if(listeners.length == 0)
				{
					collisionListeners.get(group2).remove(group1);
				}
			}
		}
		
		//Collision has been handled once, hold to prevent from double reporting collisions
		if(collisionPairs != null)
		{
			collisionPairs.get(a.ID).set(event.otherActor.ID, false);
			collisionPairs.get(event.otherActor.ID).set(a.ID, false);
		}
	}
	
	public function soundFinished(channelNum:Int)
	{
		var sc:SoundChannel = cast(channels[channelNum], SoundChannel);
		
		if(soundListeners != null)
		{
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
		moveCamera
		(
			actor.colX + actor.cacheWidth / 2,
			actor.colY + actor.cacheHeight / 2
		);
	}
	
	public function moveCamera(x:Float, y:Float)
	{
		camera.setLocation(x, y);

		cameraX = -Math.abs(camera.realX) + screenWidthHalf;
		cameraY = -Math.abs(camera.realY) + screenHeightHalf;

		//Position Limiter - Never go past 0 (which would be fully to the right/bottom)
		cameraX = Math.max(cameraX, -sceneWidth + screenWidth);
		cameraY = Math.max(cameraY, -sceneHeight + screenHeight);

		cameraX *= SCALE;
		cameraY *= SCALE;
		
		//Position Limiter - Never go past 0 (which would be fully to the right/bottom)
		cameraX = Math.min(0, cameraX);
		cameraY = Math.min(0, cameraY);
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
		
		if(!allActors.isEmpty())
		{
			for(actorID in allActors.keys())
			{
				var a = allActors.get(actorID);
				
				if(a != null)
				{
					a.pause();
				}									
			}
		}
		
		invokeListeners2(whenPausedListeners, true);
	}
	
	public function unpause()
	{
		paused = false;
		
		if(!allActors.isEmpty())
		{
			for(actorID in allActors.keys())
			{
				var a = allActors.get(actorID);
			
				if(a != null)
				{
					a.unpause();
				}								
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
     	for(l in interactiveLayers)
		{
			l.overlay.graphics.clear();
			
			#if (js)

			if (l.drawnOn)
			{
				//l.overlay.graphics.__invalidate(); Seems to be obselete - unsure what replaced it
				l.bitmapOverlay.bitmapData.fillRect(l.bitmapOverlay.bitmapData.rect, 0);
				l.drawnOn = false;
			}
			
			#else
			
			l.bitmapOverlay.graphics.clear();
			
			#end
		}
		
		//Clean up HUD actors
		if(!hudActors.isEmpty())
		{
			for(a in hudActors)
			{
				if(a.dead || a.recycled)
				{
					hudActors.clr(a.ID);
				}
			}
		}
		
		//Walk through all actors
		//TODO: cache the actors that need to be drawn instead upon creation
		if(!allActors.isEmpty())
		{
			for(a in allActors)
			{
				if(a.whenDrawingListeners.length > 0)
				{
					var layer = cast(layers.get(a.layerID), Layer);
					
					if(layer != null)
					{
						layer.drawnOn = true;
						
						g.graphics = layer.overlay.graphics;

						#if (js)
						g.canvas = layer.bitmapOverlay.bitmapData;
						#end
						
						#if (cpp || flash || neko)
						g.canvas = layer.bitmapOverlay;
						#end		
						
						g.translateToActor(a);
						g.resetGraphicsSettings();
						invokeListeners4(a.whenDrawingListeners, g, 0, 0);
					}
				}
			}
		}
		
     	//Walk through each of the drawing events
     	
     	//Only if camera changed? Or tile updated
     	for(layer in interactiveLayers)
	    {
	    	if(layer.cameraMoved || tileUpdated)
     		{
	     		layer.tiles.draw(Std.int(cameraX * layer.scrollFactorX), Std.int(cameraY * layer.scrollFactorY));
	     		layer.cameraMoved = false;
	     	}
	    }
     	
     	tileUpdated = false;
     	
     	
     	//Scene Behavior/Event Drawing
     	g.graphics = transitionLayer.graphics;
     	
     	#if (js)
     	g.canvas = transitionBitmapLayer.bitmapData;
     	#else
     	g.canvas = transitionBitmapLayer;
     	#end
     	
     	g.translateToScreen();
     	g.graphics.clear();
     	
     	#if (js)
     	g.canvas.fillRect(g.canvas.rect, 0);
     	#end
     	
     	#if (cpp || flash || neko)
     	g.canvas.graphics.clear();
     	#end
     	
     	g.resetGraphicsSettings();
     	invokeListeners4(whenDrawingListeners, g, 0, 0);
		
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
		
		#if(desktop || iphone || android)
		if(shaders != null && shaders.length > 0)
		{
			//Only need to capture the first shader in the chain
			shaders[0].capture();
		}
		#end
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
		hudActors.set(a.ID, a);
	}
	
	public function removeHUDActor(a:Actor)
	{
		hudActors.clr(a.ID);
	}
	
	
	//*-----------------------------------------------
	//* Actors - Layering
	//*-----------------------------------------------
	
	public function getLayer(refType:Int, ref:String):RegularLayer
	{
		if(refType == 0)
			return engine.layers.get(Std.parseInt(ref));
		else
			return engine.layersByName.get(ref);
	}

	public function moveToLayer(a:Actor, refType:Int, ref:String)
	{
		var layer = getLayer(refType, ref);
		
		if(!Std.is(layer, Layer))
		{
			return;
		}
		if(a.layerID == layer.ID) 
		{
			return;
		}

		removeActorFromLayer(a, a.layerID);
		a.layerID = layer.ID;
		moveActorToLayer(a,layer.ID);
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
		
		var order:Int = layers.get(a.layerID).order;
		while(layersToDraw.exists(--order))
		{
			if(Std.is(layersToDraw.get(order), Layer))
			{
				a.layerID = layersToDraw.get(order).ID;
				moveActorToLayer(a, a.layerID);
				return;
			}
		}
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
		
		var order:Int = layers.get(a.layerID).order;
		while(layersToDraw.exists(++order))
		{
			if(Std.is(layersToDraw.get(order), Layer))
			{
				a.layerID = layersToDraw.get(order).ID;
				moveActorToLayer(a, a.layerID);
				return;
			}
		}
	}
	
	public function getNumberOfActorsWithinLayer(refType:Int, ref:String):Int
	{
		var layer = getLayer(refType, ref);
		
		if(Std.is(layer, Layer))
			return cast(layer, Layer).actorContainer.numChildren;
		else
			return 0;
	}

	public function getNumberOfLayers():Int
	{
		return master.numChildren;
	}

	public function getOrderOfLayer(refType:Int, ref:String):Int
	{
		return getLayer(refType, ref).order;
	}

	public function moveLayerToOrder(refType:Int, ref:String, order:Int)
	{
		var layer = getLayer(refType, ref);

		if(order < 0)
			order = 0;
		if(order > master.numChildren - 1)
			order = master.numChildren - 1;

		if(layer.order == order)
			return;

		master.setChildIndex(layer, order);

		refreshLayers();
	}

	public function getNextLayerID():Int
	{
		var highestID:Int = -1;
		for(l in layers)
		{
			highestID = Std.int(Math.max(highestID, l.ID));
		}
		return highestID + 1;
	}

	public function insertLayer(layer:RegularLayer, order:Int)
	{
		master.addChildAt(layer, order);

		if(Std.is(layer, BackgroundLayer))
			backgroundLayers.push(cast(layer, BackgroundLayer));
		else if(Std.is(layer, Layer))
			interactiveLayers.push(cast(layer, Layer));
		layers.set(layer.ID, layer);
		layersByName.set(layer.layerName, layer);

		refreshLayers();
	}

	public function removeLayer(layer:RegularLayer)
	{
		master.removeChild(layer);
		
		if(Std.is(layer, BackgroundLayer))
			backgroundLayers.remove(cast(layer, BackgroundLayer));
		else if(Std.is(layer, Layer))
			interactiveLayers.remove(cast(layer, Layer));
		layers.clr(layer.ID);
		layersByName.remove(layer.layerName);

		refreshLayers();
	}

	public function refreshLayers()
	{
		var foundBottom:Bool = false;
		var foundMiddle:Bool = false;
		var numLayersProcessed:Int = 0; //for finding middle
		
		for(i in 0...master.numChildren)
		{
			var l:RegularLayer = cast(master.getChildAt(i), RegularLayer);
			layersToDraw.set(i, l);
			
			if(Std.is(l, Layer))
			{
				if(!foundBottom)
				{
					foundBottom = true;
					bottomLayer = i;
				}
				
				if(!foundMiddle && numLayersProcessed == Math.floor(interactiveLayers.length / 2))
				{
					foundMiddle = true;
					middleLayer = i;
				}

				topLayer = i;
				numLayersProcessed++;
			}
		}
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
	
	public function getGroupByName(groupName:String):Group
	{
		var group = reverseGroups.get(groupName);
		
		if(group == null)
		{
			return groups.get(GameModel.ACTOR_ID);
		}
		
		return group;
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
		
		v1.x = toPhysicalUnits(v1.x);
		v1.y = toPhysicalUnits(v1.y);
		v2.x = toPhysicalUnits(v2.x);
		v2.y = toPhysicalUnits(v2.y);
		
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
		
		pt.x = toPhysicalUnits(pt.x);
		pt.y = toPhysicalUnits(pt.y);
		
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
			region.setX(toPixelUnits(x) + region.regionWidth / 2);
			region.setY(toPixelUnits(y) + region.regionHeight / 2);
		}
		
		addRegion(region);
		return region;
	}
	
	public function createBoxRegion(x:Float, y:Float, w:Float, h:Float):Region
	{
		x = toPhysicalUnits(x);
		y = toPhysicalUnits(y);
		w = toPhysicalUnits(w);
		h = toPhysicalUnits(h);
	
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
		x = toPhysicalUnits(x);
		y = toPhysicalUnits(y);
		r = toPhysicalUnits(r);
		
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
		if(r.ID == Region.UNSET_ID)
			r.ID = nextRegionID();
		regions.set(r.ID, r);
		
		if(NO_PHYSICS)
		{
			groups.get(GameModel.REGION_ID).addChild(r);
		}
	}
	
	public function removeRegion(ID:Int)
	{
		var r = getRegion(ID);	
		regions.clr(r.ID);
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
	
	public function getRegions():IntHashTable<Region>
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
			region.setX(toPixelUnits(x) + region.regionWidth / 2);
			region.setY(toPixelUnits(y) + region.regionHeight / 2);
		}
		
		addTerrainRegion(region);
		return region;
	}
	
	public function createBoxTerrainRegion(x:Float, y:Float, w:Float, h:Float, groupID:Int=1):Terrain
	{
		x = toPhysicalUnits(x);
		y = toPhysicalUnits(y);
		w = toPhysicalUnits(w);
		h = toPhysicalUnits(h);
	
		var p = new B2PolygonShape();
		p.setAsBox(w/2, h/2);
		
		return createTerrainRegion(x, y, p, true, groupID);
	}
	
	public function createCircularTerrainRegion(x:Float, y:Float, r:Float, groupID:Int = 1):Terrain
	{
		x = toPhysicalUnits(x);
		y = toPhysicalUnits(y);
		r = toPhysicalUnits(r);
		
		var cShape = new B2CircleShape();
		cShape.m_radius = r;
		
		return createTerrainRegion(x, y, cShape, true, groupID);
	}
	
	public function addTerrainRegion(r:Terrain)
	{
		if(r.ID == Terrain.UNSET_ID)
			r.ID = nextTerrainRegionID();
		terrainRegions.set(r.ID, r);
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
	
	public function getTerrainRegions():Map<Int,Terrain>
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
		paddingTop = top;
		paddingLeft = left;
		paddingBottom = bottom;
		paddingRight = right;
	}
	
	//*-----------------------------------------------
	//* Utils
	//*-----------------------------------------------
	
	public function setScrollFactor(layerID:Int, amountX:Float, ?amountY:Float)
	{
		if(amountY == null)
			amountY = amountX;
		layers.get(layerID).scrollFactorX = amountX;
		layers.get(layerID).scrollFactorY = amountY;
	}
	
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
