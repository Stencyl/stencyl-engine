package com.stencyl;

#if cpp
import cpp.vm.Gc;
#end

import polygonal.ds.IntHashTable;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Shape;
import openfl.display.Graphics;
import openfl.display.MovieClip;
import openfl.display.StageDisplayState;
import openfl.text.TextField;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event as FlashEvent;
import openfl.events.FullScreenEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.Lib;
import openfl.ui.Keyboard;

import com.stencyl.behavior.Attribute;
import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.BehaviorInstance;
import com.stencyl.behavior.BehaviorManager;
import com.stencyl.behavior.Script;
import com.stencyl.behavior.TimedTask;
import com.stencyl.event.Event;
import com.stencyl.event.EventMap;
import com.stencyl.graphics.BitmapWrapper;
import com.stencyl.graphics.DynamicTileset;
import com.stencyl.graphics.EngineScaleUpdateListener;
import com.stencyl.graphics.G;
import com.stencyl.graphics.shaders.PostProcess;
import com.stencyl.graphics.shaders.Shader;
import com.stencyl.graphics.transitions.CircleTransition;
import com.stencyl.graphics.transitions.FadeInTransition;
import com.stencyl.graphics.transitions.FadeOutTransition;
import com.stencyl.graphics.transitions.Transition;
import com.stencyl.io.AttributeValues;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Assets;
import com.stencyl.utils.Log;
import com.stencyl.utils.Utils;

import com.stencyl.models.Actor;
import com.stencyl.models.Background;
import com.stencyl.models.GameModel;
import com.stencyl.models.Region;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.SoundChannel;
import com.stencyl.models.Terrain;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.background.ColorBackground;
import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.background.ScrollingBackground;
import com.stencyl.models.collision.Mask;
import com.stencyl.models.scene.ActorInstance;
import com.stencyl.models.scene.ActorLayer;
import com.stencyl.models.scene.DeferredActor;
import com.stencyl.models.scene.DrawingLayer;
import com.stencyl.models.scene.Layer;
import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.TileLayer;
import com.stencyl.models.scene.ScrollingBitmap;
import com.stencyl.models.scene.layers.BackgroundLayer;
import com.stencyl.models.scene.layers.RegularLayer;

//Do not remove - forces your behaviors to be included
import scripts.MyScripts;

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
import haxe.CallStack;

//import com.nmefermmmtools.debug.Console;

#if (haxe_ver >= 4.1)
import Std.isOfType as isOfType;
#else
import Std.is as isOfType;
#end

using com.stencyl.event.EventDispatcher;

class Engine
{
	//*-----------------------------------------------
	//* Constants
	//*-----------------------------------------------
		
	public static inline var DOODAD:String = "";
	
	public static inline var INTERNAL_SHIFT:String = "iSHIFT";
	public static inline var INTERNAL_CTRL:String = "iCTRL";
	public static inline var INTERNAL_COMMAND:String = "iCOMMAND";
	
	//*-----------------------------------------------
	//* Important Values
	//*-----------------------------------------------

	public static var NO_PHYSICS:Bool = false;
	public static var DEBUG_DRAW:Bool = false; //!NO_PHYSICS && true;
	
	public static var IMG_BASE:String = "";
	public static var SCALE:Float = 1;
	
	public static var checkedWideScreen:Bool = false;
	public static var isStandardIOS:Bool = false;
	public static var isExtendedIOS:Bool = false;
	public static var isIPhone6:Bool = false;
	public static var isIPhone6Plus:Bool = false;
	public static var isIPhoneX:Bool = false;
	public static var isIPhoneXMax:Bool = false;
	public static var isIPhoneXR:Bool = false;
	public static var isTabletIOS:Bool = false;
	
	public static var engine:Engine = null;
	
	public static var landscape:Bool = false; //Only applies to mobile
	
	public static var limitCameraToScene:Bool = true;
	public static var cameraX:Float;
	public static var cameraY:Float;
	
	public static var screenScaleX:Float;
	public static var screenScaleY:Float;
	
	public static var unzoomedScaleX:Float;
	public static var unzoomedScaleY:Float;
	
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
	public static var inFocus:Bool = true;
	
	//*-----------------------------------------------
	//* Zooming
	//*-----------------------------------------------
	
	public var zoomMultiplier:Float = 1;
	public var isHUDZoomable:Bool = false;

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
	
	public static var preservePadding = false;
	
	public static var paddingLeft:Int = 0;
	public static var paddingRight:Int = 0;
	public static var paddingTop:Int = 0;
	public static var paddingBottom:Int = 0;
	
	
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
	private var sceneInitialized = false;
	
	public var channels:Array<SoundChannel>;
	public var tasks:Array<TimedTask>;
	
	//Scene-Specific
	public var regions:IntHashTable<Region>;
	public var terrainRegions:Map<Int,Terrain>;
	public var joints:Map<Int,B2Joint>;
	
	public static var movieClip:MovieClip;
	public static var stage:Stage;
	
	public var root:Universal; //The absolute root
	public var colorLayer:Shape;
	public var maskLayer:Shape;
	public var master:Sprite; // the root of the main node
	public var hudLayer:Layer; //Shows above everything else
	public var drawingLayer:DrawingLayer; //Shows above everything else
	public var transitionLayer:Sprite; //Shows above everything else
	public var debugLayer:Sprite;
	
	public var g:G;
	
	public var extensions:Array<Extension>;
	
	
	//*-----------------------------------------------
	//* Model - Actors & Groups
	//*-----------------------------------------------
	
	public var groups:Map<Int,Group>;
	public var reverseGroups:Map<String,Group>;
	
	public var allActors:IntHashTable<Actor>;
	public var nextID:Int;
	
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
	
	public var topLayer:Layer;
	public var bottomLayer:Layer;
	public var middleLayer:Layer;
	
	public var layersToDraw:Map<Int,RegularLayer>; //Map order -> Layer/BackgroundLayer

	public var tileUpdated:Bool;
	
	public var loadedAtlases:Map<Int,Int>;
	public var atlasesToLoad:Map<Int,Int>;
	public var atlasesToUnload:Map<Int,Int>;
	
	#if (use_actor_tilemap && use_dynamic_tilemap)
	public var actorTilesets:Array<DynamicTileset>;
	public var loadedAnimations:Array<Animation>;
	public var nextTileset = 0;
	#end
	
	
	//*-----------------------------------------------
	//* Model - ?????
	//*-----------------------------------------------
	
	public var actorsToCreate:Array<Actor>;
	
	
	//*-----------------------------------------------
	//* Model - Behaviors & Game Attributes
	//*-----------------------------------------------
	
	public var gameAttributes:Map<String,Dynamic>;
	public var savableAttributes:Map<String,Bool>;
	public var behaviors:BehaviorManager;
	
	
	//*-----------------------------------------------
	//* Timing
	//*-----------------------------------------------
	
	public static var STEP_SIZE:Int = 10;
	public static var MS_PER_SEC:Int = 1000;
	
	public static var elapsedTime:Float = 0;
	public static var timeScale:Float = 1;
	public static var totalElapsedTime:Int = 0;
	
	private var lastTime:Float;
	private var acc:Float;
	
	
	//*-----------------------------------------------
	//* Debug
	//*-----------------------------------------------
	
	public static var debug:Bool = false;
	public static var debugDrawer:B2DebugDraw;
	
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------
	
	private var mx:Float;
	private var my:Float;

	private var collisionPairs:IntHashTable<Map<Int,Bool>>;
	private var disableCollisionList:Array<Actor>;

	public var keyPollOccurred:Bool = false;
	
	public var whenKeyPressedEvents:EventMap<String, Event<Bool->Bool->Void>>;
	public var whenAnyKeyPressed:Event<KeyboardEvent->Void>;
	public var whenAnyKeyReleased:Event<KeyboardEvent->Void>;
	public var whenAnyGamepadPressed:Event<String->Void>;
	public var whenAnyGamepadReleased:Event<String->Void>;
	public var whenTypeGroupCreatedEvents:Map<Int, Event<Actor->Void>>;
	public var whenTypeGroupKilledEvents:Map<Int, Event<Actor->Void>>;
	public var whenTypeGroupPositionStateChangedEvents:Map<Int, Event<Actor->Bool->Bool->Bool->Bool->Void>>;
	public var whenCollidedEvents:Map<Int, Map<Int, Event<Collision->Void>>>;
	public var whenSoundEndedEvents:Map<Sound, Event<Void->Void>>;
	public var whenChannelEndedEvents:Map<Int, Event<Void->Void>>;
	
	public var whenUpdated:Event<Float->Void>;
	public var whenDrawing:Event<G->Float->Float->Void>;
	public var whenMousePressed:Event<Void->Void>;
	public var whenMouseReleased:Event<Void->Void>;
	public var whenMouseMoved:Event<Void->Void>;
	public var whenMouseDragged:Event<Void->Void>;	
	public var whenPaused:Event<Bool->Void>;
	
	public var whenFullscreenChanged:Event<Void->Void>;
	public var whenScreenSizeChanged:Event<Void->Void>;
	public var whenGameScaleChanged:Event<Void->Void>;
	
	public var whenSwiped:Event<Void->Void>;
	public var whenMTStarted:Event<TouchEvent->Void>;
	public var whenMTDragged:Event<TouchEvent->Void>;
	public var whenMTEnded:Event<TouchEvent->Void>;
	
	public var whenFocusChanged:Event<Bool->Void>;
	
	//*-----------------------------------------------
	//* Reloading
	//*-----------------------------------------------
	
	public static function resetStatics():Void
	{
		//global effects
		#if flash
		engine.root.parent.removeChild(movieClip);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, engine.onKeyDown);
		#end

		stage.removeEventListener(FlashEvent.ENTER_FRAME, engine.onUpdate);
		stage.removeEventListener(FlashEvent.DEACTIVATE, engine.onFocusLost);
		stage.removeEventListener(FlashEvent.ACTIVATE, engine.onFocus);
		#if !flash
		stage.removeEventListener(FlashEvent.RESIZE, engine.onWindowResize);
		stage.window.onRestore.remove(engine.onWindowRestore);
		stage.window.onMaximize.remove(engine.onWindowMaximize);
		stage.window.onFullscreen.remove(engine.onWindowFullScreen);
		#end

		if(engine.stats != null)
		{
			stage.removeChild(engine.stats);
		}

		//static cleanup

		NO_PHYSICS = false;
		DEBUG_DRAW = false;
		
		IMG_BASE = "";
		SCALE = 1;
		
		checkedWideScreen = false;
		isStandardIOS = false;
		isExtendedIOS = false;
		isIPhone6 = false;
		isIPhone6Plus = false;
		isTabletIOS = false;
		
		#if (use_actor_tilemap && use_dynamic_tilemap)
		resetActorTilesets();
		#end
		
		engine = null;
		
		landscape = false; //Only applies to mobile
		
		cameraX = 0;
		cameraY = 0;
		
		screenScaleX = 0;
		screenScaleY = 0;
		
		unzoomedScaleX = 0;
		unzoomedScaleY = 0;
		
		screenOffsetX = 0;
		screenOffsetY = 0;
		
		screenWidth = 0;
		screenHeight = 0;
		
		sceneWidth = 0;
		sceneHeight = 0;
		
		screenWidthHalf = 0;
		screenHeightHalf = 0;
		
		paused = false;
		started = false;
		
		ITERATIONS = 3;
		physicsScale = 10.0;
		
		preservePadding = false;
		paddingLeft = 0;
		paddingRight = 0;
		paddingTop = 0;
		paddingBottom = 0;
		
		movieClip = null;
		stage = null;

		STEP_SIZE = 10;
		MS_PER_SEC = 1000;
		
		elapsedTime = 0;
		timeScale = 1;
		totalElapsedTime = 0;
		
		debug = false;
		debugDrawer = null;
	}
	
	//*-----------------------------------------------
	//* Full Screen Shaders - C++
	//*-----------------------------------------------
	
	#if !flash
	private var shader:PostProcess;
	public var shaderLayer:Sprite;
	public var shaders:Array<PostProcess>;
	#end
	
	
	//*-----------------------------------------------
	//* Full Screen
	//*-----------------------------------------------
	
	private var isFullScreen:Bool = false;
	private var ignoreResize:Bool = false;
	private var stats:com.nmefermmmtools.debug.Stats;
	
	private function onKeyDown(e:KeyboardEvent = null)
	{
		if(isFullScreen && e.keyCode == Key.ESCAPE)
		{
			setFullScreen(false);
		}
	}

	#if !flash
	private function onWindowResize(event:FlashEvent):Void
	{
		if(isFullScreen && !stage.window.fullscreen && !stage.window.minimized && !ignoreResize)
		{
			setFullScreen(false);
		}
	}

	//XXX: Seems a little odd. Cancels out window.__fullscreen = false in NativeApplication.hx
	@:access(lime.ui.Window.__fullscreen)
	private function onWindowRestore():Void
	{
		if(isFullScreen && !stage.window.fullscreen)
		{
			stage.window.__fullscreen = true;
		}
	}

	@:access(lime.ui.Window.__fullscreen)
	private function onWindowMaximize():Void
	{
		if(isFullScreen && !stage.window.fullscreen)
		{
			stage.window.__fullscreen = true;
		}
	}

	private function onWindowFullScreen():Void
	{
		if(!isFullScreen)
		{
			setFullScreen(true);
		}
	}
	#end
	
	public function isInFullScreen():Bool
	{
		return Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE;
	}

	public function setFullScreen(value:Bool):Void
	{
		Log.debug("Set fullScreen: " + value);
		if(isFullScreen != value)
		{
			ignoreResize = true;
			isFullScreen = value;
			reloadScreen();
			whenFullscreenChanged.dispatch();
			ignoreResize = false;
		}
	}
	
	public function toggleFullScreen():Void
	{
		setFullScreen(!isFullScreen);
	}

	public function reloadScreen():Void
	{
		var oldImgBase = IMG_BASE;
		var oldScale = SCALE;
		var oldScreenWidth = screenWidth;
		var oldScreenHeight = screenHeight;

		root.initScreen(isFullScreen);
		
		screenWidth = Std.int(Universal.logicalWidth);
		screenWidthHalf = Std.int(screenWidth / 2);
		screenHeight = Std.int(Universal.logicalHeight);
		screenHeightHalf = Std.int(screenHeight / 2);
		setColorBackground(scene.colorBackground);
		
		var screensizeUpdated = screenWidth != oldScreenWidth || screenHeight != oldScreenHeight;
		var gameScaleUpdated = oldScale != SCALE;
		
		if(oldImgBase != IMG_BASE)
		{
			Data.get().reloadScaledResources();
		}
		if(oldScale != SCALE)
		{
			if(debugDrawer != null)
				debugDrawer.setDrawScale(10 * SCALE);

			g.scaleX = g.scaleY = SCALE;

			Utils.applyToAllChildren(root, function(obj) {

				if(isOfType(obj, EngineScaleUpdateListener))
				{
					cast(obj, EngineScaleUpdateListener).updateScale();
				}

			});

			for(a in allActors)
			{
				if(a != null && !a.dead && !a.recycled) 
				{
					a.updateMatrix = true;
				}
			}
			
			for (actors in recycledActorsOfType)
			{
				for (a in actors)
				{
					if(a.currAnimation != null)
					{
						a.currAnimation.framesUpdated();
					}
					a.updateMatrix = true;
				}
			}
			
			g.resetFont();
			
			moveCamera(camera.realX, camera.realY);
		}

		unzoomedScaleX = screenScaleX = root.scaleX;
		unzoomedScaleY = screenScaleY = root.scaleY;
		screenOffsetX = Std.int(root.x);
		screenOffsetY = Std.int(root.y);
		
		if(stats != null)
		{
			stats.x = stage.stageWidth - stats.width;
			stats.y = 0;
		}

		#if !flash
		resetShaders();
		#end
		
		if(gameScaleUpdated)
			whenGameScaleChanged.dispatch();
		if(screensizeUpdated)
			whenScreenSizeChanged.dispatch();
	}
	
	#if (use_actor_tilemap && use_dynamic_tilemap)
	public static function resetActorTilesets()
	{
		for(ts in engine.actorTilesets)
		{
			ts.clearSheet();
		}
		for(anim in engine.loadedAnimations)
		{
			anim.tilesetInitialized = false;
		}
		engine.nextTileset = 0;
	}
	#end

	#if ios
	public static function determineIosScreenType()
	{
		var larger = Math.max(stage.fullScreenWidth, stage.fullScreenHeight);
		var smaller = Math.min(stage.fullScreenWidth, stage.fullScreenHeight);
		
		if(smaller == 320 && larger == 480)
		{
			Engine.isStandardIOS = true;
		}
		
		else if(smaller == 640 && larger == 960)
		{
			Engine.isStandardIOS = true;
		}
		
		//iPhone 5, 5s, or iPhone 6 with Display Zoom
		else if(smaller == 640 && larger == 1136)
		{
			Engine.isExtendedIOS = true;
		}	
		
		else if(smaller == 750 && larger == 1334)
		{
			Engine.isIPhone6 = true;
		}	
		
		else if(smaller == 1242 && larger == 2208)
		{
			Engine.isIPhone6Plus = true;
		}
		
		//iPhone 6+ with Display Zoom
		else if(smaller == 1125 && larger == 2001)
		{
			Engine.isIPhone6Plus = true;
		}

		else if(smaller == 1125 && larger == 2436)
		{
			Engine.isIPhoneX = true;
		}
		
		else if(smaller == 1242 && larger >= 2688 && larger <= 2690)
		{
			Engine.isIPhoneXMax = true;
		}
		
		else if(smaller == 828 && larger == 1792)
		{
			Engine.isIPhoneXR = true;
		}
		
		else if
		(
			(smaller == 768 && larger == 1024) ||
			(smaller == 1488 && larger == 2266) ||
			(smaller == 1536 && larger == 2048) ||
			(smaller == 1620 && larger == 2160) ||
			(smaller == 1640 && larger == 2360) ||
			(smaller == 1668 && larger == 2224) ||
			(smaller == 1668 && larger == 2388) ||
			(smaller == 2048 && larger == 2732)
		)
		{
			Engine.isTabletIOS = true;
		}
	}
	#end
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------

	public function new(root:Universal, extensions:Array<Extension>) 
	{
		this.extensions = extensions;
		
		#if !flash
		if(com.stencyl.graphics.shaders.PostProcess.isSupported)
		{
			shaderLayer = new Sprite();
			shaderLayer.name = "Shader Layer";
		}
		#end
		
		root.mouseChildren = false;
		root.mouseEnabled = false;
		//root.stage.mouseChildren = false;

		if(Config.debugDraw)
		{
			DEBUG_DRAW = true;
		}
		
		engine = this;
		Script.engine = this;
		this.root = root;
		
		isFullScreen = Config.startInFullScreen;
		screenScaleX = unzoomedScaleX = root.scaleX;
		screenScaleY = unzoomedScaleY = root.scaleY;
		screenOffsetX = Std.int(root.x);
		screenOffsetY = Std.int(root.y);
		#if ios
		determineIosScreenType();
		#end
		
		NO_PHYSICS = Config.physicsMode == SIMPLE_PHYSICS;
		
		stage.addEventListener(FlashEvent.ENTER_FRAME, onUpdate);
		stage.addEventListener(FlashEvent.DEACTIVATE, onFocusLost);
		stage.addEventListener(FlashEvent.ACTIVATE, onFocus);
		#if !flash
		stage.addEventListener(FlashEvent.RESIZE, onWindowResize);
		stage.window.onRestore.add(onWindowRestore);
		stage.window.onMaximize.add(onWindowMaximize);
		stage.window.onFullscreen.add(onWindowFullScreen);
		if(isFullScreen && !stage.window.fullscreen)
			@:privateAccess stage.window.__fullscreen = true;
		#end
		
		#if (use_actor_tilemap && use_dynamic_tilemap)
		actorTilesets = new Array<DynamicTileset>();
		loadedAnimations = new Array<Animation>();
		#end
		
		var initSceneID = Config.initSceneID;
		#if testing
		var launchVars = getLaunchVars();
		if(launchVars.exists("startingScene"))
		{
			initSceneID = Std.parseInt(launchVars.get("startingScene"));
		}
		#end
		begin(initSceneID);
		
		#if flash
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 2);
		#end
	}
	
	#if flash
	public function addShader(pp:PostProcess, addToDisplayTree:Bool = true) {}
	public function clearShaders() {}
	public function toggleShadersForHUD() {} 
	public function resetShaders() {}
	#else
	public function addShader(pp:PostProcess)
	{
		if(com.stencyl.graphics.shaders.PostProcess.isSupported)
		{
			var s = pp.basicShader;
			
			//Clear out existing shader if one is currently active, otherwise we hit graphical glitches.
			if(shaders != null)
			{
				Log.debug("Enabling a shader over an existing shader. Clearing existing shader first.");
				clearShaders();
			}
			
			shaders = [s.model];
			
			s = s.multipassParent;
			while(s != null)
			{
				shaders.insert(0, s.model);
				s = s.multipassParent;
			}
			
			for(postProcess in shaders)
				shaderLayer.addChild(postProcess);
		}
		
		else
		{
			Log.warn("Shaders are not supported on this platform.");
		}
	}
	
	public function clearShaders()
	{
		Utils.removeAllChildren(shaderLayer);
		stage.context3D.setRenderToBackBuffer();
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
		Input.define(INTERNAL_COMMAND, [Key.COMMAND]);
		
		landscape = Config.landscape;
		var stageWidth = Universal.logicalWidth;
		var stageHeight = Universal.logicalHeight;

		screenWidth = Std.int(stageWidth);
		screenHeight = Std.int(stageHeight);
		screenWidthHalf = Std.int(stageWidth/2);
		screenHeightHalf = Std.int(stageHeight/2);
		
		#if use_tilemap
		Assets.loadAtlases();
		#end
		Data.get();
		GameModel.get().loadScenes();

		#if (cpp || hl)
		{
			for(atlas in GameModel.get().atlases)
			{
				if(atlas.active)
					atlasesToLoad.set(atlas.ID, atlas.ID);
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
		sceneWidth = Std.int(stageWidth); //Overriden once scene loads
		sceneHeight = Std.int(stageHeight); //Overriden once scene loads
		
		//Display List
		colorLayer = new Shape();
		colorLayer.name = "Color Layer";
		root.addChild(colorLayer);

		master = new Sprite();
		master.name = "Master";
		root.addChild(master);
		
		hudLayer = new Layer(-1, "__hud__", -1, 0.0, 0.0, 1.0, BlendMode.NORMAL, null #if use_actor_tilemap, 0, 0 #end);
		hudLayer.name = "HUD Layer";
		root.addChild(hudLayer);
		
		drawingLayer = new DrawingLayer(Std.int(screenWidth * SCALE), Std.int(screenHeight * SCALE));
		drawingLayer.name = "Drawing Layer";
		root.addChild(drawingLayer);

		transitionLayer = new Sprite();
		transitionLayer.name = "Transition Layer";
		root.addChild(transitionLayer);
		
		debugLayer = new Sprite();
		debugLayer.name = "Debug Layer";
		root.addChild(debugLayer);
		
		#if !flash
		if(com.stencyl.graphics.shaders.PostProcess.isSupported)
		{
			root.addChild(shaderLayer);
		}
		#end
		
		root.addChild(root.maskLayer);
		
		//Initialize things	
		actorsToCreateInNextScene = new Array();			
		gameAttributes = new Map<String,Dynamic>();
		savableAttributes = new Map<String,Bool>();
		
		//Profiler
		setStatsVisible(Config.showConsole);
		
		#if flash
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
		
		for(extension in extensions)
		{
			extension.initialize();
		}
		
		//Now, let's start
		//enter = new FadeInTransition(0.5);
		//enter.start();
		sceneToEnter = initSceneID;
		
		loadScene(initSceneID);
		sceneInitialized = true;
	}	

	public function setStatsVisible(value:Bool):Void
	{
		if(value == (stats != null))
			return;

		if(value)
		{
			stats = new com.nmefermmmtools.debug.Stats();
			stage.addChild(stats);
			stats.x = stage.stageWidth - stats.width;
			stats.y = 0;
		}
		else
		{
			stage.removeChild(stats);
			stats = null;
		}
	}
	
	public function loadScene(sceneID:Int)
	{
		collisionPairs = new IntHashTable<Map<Int,Bool>>(32);
		
		//---
		
		if(!preservePadding)
		{
			setOffscreenTolerance(0, 0, 0, 0);
		}
		
		tasks = new Array<TimedTask>();
		
		scene = GameModel.get().scenes.get(sceneID);
		
		if(sceneID == -1 || scene == null)
		{
			scene = GameModel.get().scenes.get(Config.initSceneID);
			
			//Something really went wrong!
			if(scene == null)
			{
				Log.error("Could not load scene: " + sceneID);
				stage.removeEventListener(FlashEvent.ENTER_FRAME, onUpdate);
				return;
			}
		}
		
		#if (use_actor_tilemap && use_dynamic_tilemap)
		resetActorTilesets();
		#end
		
		scene.load();

		#if use_actor_tilemap
		hudLayer.setSize(scene.sceneWidth, scene.sceneHeight);
		#end

		#if !flash
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

			#if cpp
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
		allActors = new IntHashTable<Actor>(256); 
		allActors.reuseIterator = true;
		nextID = 0;
		
		//Events
		
		whenKeyPressedEvents = new EventMap<String, Event<Bool->Bool->Void>>();
		whenAnyKeyPressed = new Event<KeyboardEvent->Void>();
		whenAnyKeyReleased = new Event<KeyboardEvent->Void>();
		whenAnyGamepadPressed = new Event<String->Void>();
		whenAnyGamepadReleased = new Event<String->Void>();

		whenTypeGroupCreatedEvents = new Map<Int, Event<Actor->Void>>();
		whenTypeGroupKilledEvents = new Map<Int, Event<Actor->Void>>();
		whenTypeGroupPositionStateChangedEvents = new Map<Int, Event<Actor->Bool->Bool->Bool->Bool->Void>>();
		whenCollidedEvents = new Map<Int, Map<Int, Event<Collision->Void>>>();
		whenSoundEndedEvents = new Map<Sound, Event<Void->Void>>();
		whenChannelEndedEvents = new Map<Int, Event<Void->Void>>();
		
		whenUpdated = new Event<Float->Void>();
		whenDrawing = new Event<G->Float->Float->Void>();
		whenMousePressed = new Event<Void->Void>();
		whenMouseReleased = new Event<Void->Void>();
		whenMouseMoved = new Event<Void->Void>();
		whenMouseDragged = new Event<Void->Void>();	
		whenPaused = new Event<Bool->Void>();
		whenSwiped = new Event<Void->Void>();
		whenMTStarted = new Event<TouchEvent->Void>();
		whenMTDragged = new Event<TouchEvent->Void>();
		whenMTEnded = new Event<TouchEvent->Void>();
		whenFocusChanged = new Event<Bool->Void>();
		
		whenFullscreenChanged = new Event<Void->Void>();
		whenScreenSizeChanged = new Event<Void->Void>();
		whenGameScaleChanged = new Event<Void->Void>();

		for(extension in extensions)
		{
			extension.loadScene(scene);
		}

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
		
		#if cpp
		Gc.run(true);
		#end
	}
	
	public static function initBehaviors
	(
		manager:BehaviorManager, 
		behaviorValues:Map<String,BehaviorInstance>, 
		parent:Dynamic, 
		game:Engine,
		initialize:Bool
	)
	{
		if(behaviorValues == null)
		{
			return;
		}
		
		for(bi in behaviorValues)
		{
			if(bi == null || !bi.enabled)
			{
				continue;
			}
			
			var template:Behavior = Data.get().behaviors.get(bi.behaviorID);
			var attributes:Map<String,Attribute> = new Map<String,Attribute>();
			
			if(template == null)
			{
				Log.error("Non-Existent Behavior ID (Init): " + bi.behaviorID);
				continue;
			}
			
			//Start honoring default values for events.
			if(template.isEvent)
			{
				for(key in template.attributes.keys())
				{
					var attribute = template.attributes.get(key);
	
					if(attribute == null)
					{
						continue;
					}
					
					var type:String = attribute.type;
					var ID:Int = attribute.ID;
					
					if(type == "list")
					{
						attributes.set(key, new Attribute(ID, attribute.fieldName, attribute.fullName, new Array<Dynamic>(), type, null, attribute.hidden));
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
				
				var attribute = template.attributes.get(key);

				if(attribute == null)
				{
					continue;
				}
				
				var type:String = attribute.type;
				var ID:Int = attribute.ID;
				
				attributes.set(key, new Attribute(ID, attribute.fieldName, attribute.fullName, value, type, null, attribute.hidden));
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
		for(layer in interactiveLayers)
		{
			#if use_actor_tilemap
			for(i in 0...layer.actorContainer.numTiles)
			{
				var actor:Actor = cast layer.actorContainer.getTileAt(i);
				var actorInstance = scene.actors.get(actor.ID);
				while(actorInstance.orderInLayer != i)
				{
					layer.actorContainer.swapTilesAt(i, actorInstance.orderInLayer);
					actor = cast layer.actorContainer.getTileAt(i);
					actorInstance = scene.actors.get(actor.ID);
				}
			}
			#else
			for(i in 0...layer.actorContainer.numChildren)
			{
				var actor:Actor = cast layer.actorContainer.getChildAt(i);
				var actorInstance = scene.actors.get(actor.ID);
				while(actorInstance.orderInLayer != i)
				{
					layer.actorContainer.swapChildrenAt(i, actorInstance.orderInLayer);
					actor = cast layer.actorContainer.getChildAt(i);
					actorInstance = scene.actors.get(actor.ID);
				}
			}
			#end
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
		camera = new Actor(this, -1, GameModel.DOODAD_ID, 0, 0, -1, 2, 2, null, null, null, null, true, false, true, false, null, true, false);
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
				region.setXY(r.x + region.regionWidth / 2, r.y + region.regionHeight / 2);
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
					-1, 
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
					-1, 
					Std.int(wireframe.width), 
					Std.int(wireframe.height), 
					null, 
					new Map<String,BehaviorInstance>(),
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
				tile.updateSource = true;
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
		
		if(layers.isEmpty())
		{
			//For scenes with no scene data
			var tileLayer = new TileLayer(0, scene, Std.int(scene.sceneWidth / scene.tileWidth), Std.int(scene.sceneHeight / scene.tileHeight));
			var layer = new Layer(0, "default", 0, 1.0, 1.0, 1.0, BlendMode.NORMAL, tileLayer #if use_actor_tilemap, scene.sceneWidth, scene.sceneHeight #end);
			layers.set(layer.ID, layer);
		}

		for(l in layers)
		{
			highestLayerOrder = Std.int(Math.max(highestLayerOrder, l.order));

			reverseOrders.set(l.order, l);
			layersByName.set(l.layerName, l);
			if(isOfType(l, Layer))
				interactiveLayers.push(cast(l, Layer));
			else if(isOfType(l, BackgroundLayer))
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

			if(isOfType(l, BackgroundLayer))
			{
				var layer = cast(l, BackgroundLayer);
				layer.load();
				master.addChild(layer);
			}
			else if(isOfType(l, Layer))
			{
				var layer = cast(l, Layer);
				
				if(!foundBottom)
				{
					foundBottom = true;
					bottomLayer = layer;
				}
				
				if(!foundMiddle && numLayersProcessed == Math.floor(interactiveLayers.length / 2))
				{
					foundMiddle = true;
					middleLayer = layer;
				}

				master.addChild(layer);
				
				//Eventually, this will become the correct value
				topLayer = layer;

				// changed to work in box2D mode too to fix collisions with simple actors: http://community.stencyl.com/index.php?issue=99.0
				layer.tiles.mountGrid();

				numLayersProcessed++;
			}
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
		if(debugDrawer != null && debugDrawer.m_sprite != null)
		{
			debugDrawer.m_sprite.graphics.clear();
		}

		for(layer in interactiveLayers)
		{
			layer.clear();
		}
		hudLayer.clear();
		
		Utils.removeAllChildren(master);
		
		behaviors.destroy();
		
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
		
		for(a in allActors)
		{
			a.destroy();
			//removeActor(a);
		}
		
		while(Lambda.count(allActors) > 0)
		{
			for(key in allActors.keys())
			{
				allActors.unset(key);
			}
		}
		
		scene.unload();
		
		actorsOfType = null;
		recycledActorsOfType = null;
		
		layers = null;
		layersByName = null;
		interactiveLayers = null;
		backgroundLayers = null;
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
		
		whenKeyPressedEvents = null;
		whenAnyKeyPressed = null;
		whenAnyKeyReleased = null;
		whenAnyGamepadPressed = null;
		whenAnyGamepadReleased = null;
		whenTypeGroupCreatedEvents = null;
		whenTypeGroupKilledEvents = null;
		whenTypeGroupPositionStateChangedEvents = null;
		whenCollidedEvents = null;
		whenSoundEndedEvents = null;
		whenChannelEndedEvents = null;
		
		whenUpdated = null;
		whenDrawing = null;
		whenMousePressed = null;
		whenMouseReleased = null;
		whenMouseMoved = null;
		whenMouseDragged = null;
		whenPaused = null;

		whenFullscreenChanged = null;
		whenScreenSizeChanged = null;
		whenGameScaleChanged = null;

		whenSwiped = null;
		whenMTStarted = null;
		whenMTDragged = null;
		whenMTEnded = null;
		
		whenFocusChanged = null;

		for(extension in extensions)
		{
			extension.cleanupScene();
		}

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
		// Log.debug("Request to switch to Scene " + sceneID);

		if(isTransitioning())
		{
			// Log.warn("Warning: Switching Scene while already switching. Ignoring.");
			return;
		}
		
		Log.info("Switching to scene " + sceneID);
		
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
		
		//Log.debug("Entering Scene " + sceneToEnter);
		
		sceneInitialized = false;
		cleanup();
		loadScene(sceneToEnter);
		sceneInitialized = true;
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
			ai.x, 
			ai.y,
			ai.layerID,
			-1, 
			-1, 
			s,
			ai.behaviorValues,
			ai.actorType,
			NO_PHYSICS ? null : ai.actorType.bodyDef,
			false,
			false,
			false,
			false,
			null,
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
			var centerOriginX = Std.int(a.cacheWidth / 2);
			var centerOriginY = Std.int(a.cacheHeight / 2);
			if (a.currOrigin.x != centerOriginX || a.currOrigin.y != centerOriginY)
			{
				var sin = Math.sin(Utils.RAD * ai.angle);
				var cos = Math.cos(Utils.RAD * ai.angle);
				var xDiff = ((a.currOrigin.x - centerOriginX) * ai.scaleX) - a.currOffset.x;
				var yDiff = ((a.currOrigin.y - centerOriginY) * ai.scaleY) - a.currOffset.y;
				a.setX(a.getX(false) + xDiff * cos - yDiff * sin);
				a.setY(a.getY(false) + xDiff * sin + yDiff * cos);
			}
			
			a.growTo(ai.scaleX, ai.scaleY, 0);
		}
		
		a.name = ai.actorType.name;
		
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
		
		if(ai.actorType.physicsMode != MINIMAL_PHYSICS)
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
		if(ai.actorType != null && ai.actorType.ID != -1)
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
		
		Script.lastCreatedActor = a;
		
		return a;
	}
	
	public function removeActor(a:Actor)
	{
		allActors.unset(a.ID);

		//Remove from the layer group
		removeActorFromLayer(a, a.layer);
		
		//Remove from normal group
		groups.get(a.getGroupID()).removeChild(a);
		
		a.destroy();
		
		//---
		
		if (a.type != null && a.typeID != -1)
		{
			var cache = actorsOfType.get(a.typeID);
			
			if(cache != null)
			{
				cache.remove(a);
			}
		}
	}
	
	public function removeActorFromLayer(a:Actor, layer:Layer)
	{
		if(layer == null || a.layer != layer)
		{
			return;
		}
		if(layer == hudLayer)
		{
			if(a.physicsMode == NORMAL_PHYSICS)
			{
				a.body.setAlwaysActive(a.alwaysSimulate);
			}
			
			a.isHUD = false;
			a.cachedLayer = null;
		}
		
		//Be gentle and don't error out if it's not in here (in case of a double-remove)
		if(layer.actorContainer.contains(a))
		{
			#if use_actor_tilemap
			layer.actorContainer.removeTile(a);
			#else
			layer.actorContainer.removeChild(a);
			#end
			a.layer = null;
		}
	}
	
	public function moveActorToLayer(a:Actor, layer:Layer)
	{
		if(a.layer == layer || layer == null)
		{
			return;
		}
		
		if(a.layer == null || a.layer.scrollFactorX != layer.scrollFactorX || a.layer.scrollFactorY != layer.scrollFactorY)
		{
			a.updateMatrix = true;
		}
		
		if(layer == hudLayer)
		{
			if(a.physicsMode == NORMAL_PHYSICS)
			{
				a.body.setAlwaysActive(true);
			}
			
			a.isHUD = true;
			a.cachedLayer = a.layer;
		}
		
		if(a.layer != null)
		{
			removeActorFromLayer(a, a.layer);
		}
		
		#if use_actor_tilemap
		layer.actorContainer.addTile(a);
		#else
		layer.actorContainer.addChild(a);
		#end
		a.layer = layer;
	}
	
	public function recycleActor(a:Actor)
	{
		//Log.debug("recycle " + a);
		
		if(a == null || a.recycled)
		{
			return;
		}
	
		var l1 = engine.whenTypeGroupKilledEvents.get(a.getType().ID);
		var l2 = engine.whenTypeGroupKilledEvents.get(Actor.GROUP_OFFSET + a.getGroupID());
	
		a.whenKilled.dispatch();

		if(l1 != null)
		{
			l1.dispatch(a);
		}
		
		if(l2 != null)
		{
			l2.dispatch(a);
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
		a.setXY(1000000, 1000000, false, true);
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
		
		a.alpha = 1;
		a.realScaleX = 1;
		a.realScaleY = 1;
		
		a.switchToDefaultAnimation();
		a.disableActorDrawing();
		a.removeAttachedImages();
		
		//Kill previous contacts
		if(a.physicsMode == NORMAL_PHYSICS && a.body != null)
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
		
		removeActorFromLayer(a, a.layer);
		
		if(a.physicsMode == NORMAL_PHYSICS)
		{
			a.body.setActive(false);
			a.body.setAwake(false);
			a.body.setBullet(a.type.bodyDef.bullet); /////
			
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
		
		//Remove associated timed tasks
		var i = 0;
		
		while(i < tasks.length)
		{
			var t:TimedTask = tasks[i];
			
			if(t.actor == a)
			{
				tasks.remove(t);
				i--;
			}
			
			i++;
		}
		
		allActors.unset(a.ID);
	}
	
	public function getRecycledActorOfType(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		var a:Actor = getRecycledActorOfTypeOnLayer(type, x, y, getLayerByOrder(layerConst).ID);
		
		if (Engine.paused)
		{
			a.updateDrawingMatrix();
			a.pause();
		}
		
		return a;
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
					
					if(actor.customizedBehaviors)
					{
						actor.customizedBehaviors = false;
						actor.behaviors = new BehaviorManager();
						Engine.initBehaviors(actor.behaviors, type.behaviorValues, actor, this, false);
					}
					else
					{
						actor.enableAllBehaviors();
					}
					
					if(actor.physicsMode == NORMAL_PHYSICS)
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
					actor.setXY(x, y, false, true);
					
					if(actor.physicsMode == NORMAL_PHYSICS)
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
					
					actor.updateDrawingMatrix(true);
					
					//actor.setFilter(null);					

					//move to specified layer
					moveActorToLayer(actor, cast getLayerById(layerID));
					
					actor.initScripts();
					
					var f1 = whenTypeGroupCreatedEvents.get(type.ID);
					var f2 = whenTypeGroupCreatedEvents.get(Actor.GROUP_OFFSET + actor.getGroupID());
		
					if(f1 != null)
					{
						f1.dispatch(actor);
					}
		
					if(f2 != null)
					{
						f2.dispatch(actor);
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
			Log.error("Tried to create actor with null or invalid type.");
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
			-1,
			0,
			type.groupID,
			type.ID,
			null,
			false
		);
		
		var a:Actor = createActor(ai, true);
		a.initScripts();
		
		var f1 = whenTypeGroupCreatedEvents.get(type.ID);
		var f2 = whenTypeGroupCreatedEvents.get(Actor.GROUP_OFFSET + a.getGroupID());
		
		if(f1 != null)
		{
			f1.dispatch(a);
		}
		
		if(f2 != null)
		{
			f2.dispatch(a);
		}
		
		return a;
	}
	
	//*-----------------------------------------------
	//* Terrain Creation
	//*-----------------------------------------------
		
	public function getTopLayer():Int
	{
		return topLayer.ID;
	}
	
	public function getBottomLayer():Int
	{
		return bottomLayer.ID;
	}
	
	public function getMiddleLayer():Int
	{
		return middleLayer.ID;
	}
		
		
	//*-----------------------------------------------
	//* Update Loop
	//*-----------------------------------------------
	
	public function update(elapsedTime:Float)
	{
		if(scene == null)
		{
			//Log.error("Scene is null");
			return;
		}
		
		//Update Tweens - Synced to engine
		TweenManager.update(Std.int(elapsedTime));
		#if actuate
		motion.actuators.SimpleActuator.stage_onEnterFrame(null);
		#end
		
		if(!NO_PHYSICS)
		{
			var aabb = world.getScreenBounds();
			aabb.lowerBound.x = (cameraX / SCALE - paddingLeft) / physicsScale;
			aabb.lowerBound.y = (cameraY / SCALE - paddingTop) / physicsScale;
			aabb.upperBound.x = aabb.lowerBound.x + ((screenWidth + paddingRight + paddingLeft) / physicsScale);
			aabb.upperBound.y = aabb.lowerBound.y + ((screenHeight + paddingBottom + paddingTop) / physicsScale);
		}
		
		var inputx = Std.int(Input.mouseX / SCALE);
		var inputy = Std.int(Input.mouseY / SCALE);
						
		if(Input.mousePressed)
		{
			Script.mpx = inputx;
			Script.mpy = inputy;
			whenMousePressed.dispatch();
		}
		
		if(Input.mouseReleased)
		{
			Script.mrx = inputx;
			Script.mry = inputy;
			whenMouseReleased.dispatch();
		}

		if(mx != inputx || my != inputy)
		{
			mx = inputx;
			my = inputy;
			
			whenMouseMoved.dispatch();
			
			if(Input.mouseDown && !Input.mousePressed)
			{
				whenMouseDragged.dispatch();
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
		if(whenKeyPressedEvents.hasEvents())
		{
			for(i in 0...whenKeyPressedEvents.keys.length)
			{
				var key = whenKeyPressedEvents.keys[i];
				var pressed = Input.pressed(key);
				var released = Input.released(key);
				
				if(pressed || released)
				{
					var keyPressedEvent = whenKeyPressedEvents.getEvent(key);
					keyPressedEvent.dispatch(pressed, released);
				}				
			}

			keyPollOccurred = true;
		}
		
		for(extension in extensions)
		{
			extension.preSceneUpdate();
		}
		
		whenUpdated.dispatch(elapsedTime);
		
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
				collisionPairs.unset(pair);
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
						(a.physicsMode != NORMAL_PHYSICS || a.body.isActive()) && 
						a.colX + a.cacheWidth * a.realScaleX >= cameraX / SCALE - paddingLeft && 
						a.colY + a.cacheHeight * a.realScaleY >= cameraY / SCALE - paddingTop &&
						a.colX < cameraX / SCALE + screenWidth + paddingRight &&
						a.colY < cameraY / SCALE + screenHeight + paddingBottom;
					
					a.isOnScreenCache = (isOnScreen || a.isHUD);
					
					//---
				
					if(a.physicsMode == NORMAL_PHYSICS && a.body != null)
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
					
					else if(a.physicsMode != NORMAL_PHYSICS)
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
			debugLayer.x = -cameraX;
			debugLayer.y = -cameraY;
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
	private function onUpdate(event:FlashEvent):Void 
	{
		var currTime:Float = Lib.getTimer();
		var elapsedTime:Float = (currTime - lastTime);
		
		#if stencyltools
		@:privateAccess if(com.stencyl.utils.ToolsetInterface.paused)
		{
			com.stencyl.utils.ToolsetInterface.pause();
		}
		if(elapsedTime > 10 && com.stencyl.utils.ToolsetInterface.wasPaused)
		{
			elapsedTime = 10;
			com.stencyl.utils.ToolsetInterface.wasPaused = false;
		}
		#end
		
		//Max Frame Duration = 5 FPS
		//Prevents spikes and prevents mobile backgrounding from going haywire.
		if(elapsedTime >= 200)
		{
			elapsedTime = 200;
		}
		
		acc += elapsedTime;
		
		Engine.elapsedTime = elapsedTime;
		Engine.totalElapsedTime += Std.int(elapsedTime);

		if(leave != null)
		{
			//Update here, or you can have a transition that fails to finish
			#if actuate
			motion.actuators.SimpleActuator.stage_onEnterFrame(null);
			#end
			
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
		
		if(sceneInitialized)
		{
			postUpdate(currTime);
		}
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
				if(a == null || (a.physicsMode == NORMAL_PHYSICS && a.body == null))
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
	
	public function onFocus(event:FlashEvent)
	{
		if (!inFocus)
		{
			inFocus = true;
			focusChanged(false);
		}
	}
	
	public function onFocusLost(event:FlashEvent)
	{
		if (inFocus)
		{
			inFocus = false;
			focusChanged(true);
		}
	}
	
	public function focusChanged(lost:Bool)
	{
		if(whenFocusChanged == null)
		{
			return;
		}
		
		whenFocusChanged.dispatch(lost);
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
			group1 = Actor.GROUP_OFFSET + event.thisActor.groupID;
			group2 = Actor.GROUP_OFFSET + event.otherActor.groupID;
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
						value = body.getUserData().groupID;
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
						value = body.getUserData().groupID;
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
			if(!event.otherCollidedWithTerrain && whenCollidedEvents.exists(type1) && whenCollidedEvents.get(type1).exists(type2))
			{
				var collidedEvent = whenCollidedEvents.get(type1).get(type2);
				collidedEvent.dispatch(event);
				
				if(collidedEvent.length == 0)
				{
					whenCollidedEvents.get(type1).remove(type2);
				}
			}
			
			if(type1 != type2 && whenCollidedEvents.exists(type2) && whenCollidedEvents.get(type2).exists(type1))
			{
				var collidedEvent = whenCollidedEvents.get(type2).get(type1);
				var reverseEvent = event.switchData(Collision.get());
				
				collidedEvent.dispatch(reverseEvent);
				
				if(collidedEvent.length == 0)
				{
					whenCollidedEvents.get(type2).remove(type1);
				}
			}
		}
		
		if(group1 > 0 && group2 > 0)
		{
			if(whenCollidedEvents.exists(group1) && whenCollidedEvents.get(group1).exists(group2))
			{
				var collidedEvent = whenCollidedEvents.get(group1).get(group2);
				collidedEvent.dispatch(event);
				
				if(collidedEvent.length == 0)
				{
					whenCollidedEvents.get(group1).remove(group2);
				}
			}
			
			if(group1 != group2 && whenCollidedEvents.exists(group2) && whenCollidedEvents.get(group2).exists(group1))
			{
				var collidedEvent = whenCollidedEvents.get(group2).get(group1);
				var reverseEvent = event.switchData(Collision.get());
				
				collidedEvent.dispatch(reverseEvent);
				
				if(collidedEvent.length == 0)
				{
					whenCollidedEvents.get(group2).remove(group1);
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
		
		if(whenSoundEndedEvents != null)
		{
			var soundEndedEvent = whenSoundEndedEvents.get(sc.currentClip);
			
			sc.currentSound = null;
			
			if(soundEndedEvent != null)
			{
				soundEndedEvent.dispatch();
			}
		}
		else
		{
			sc.currentSound = null;
		}
		
		if(whenChannelEndedEvents != null)
		{
			var channelEndedEvent = whenChannelEndedEvents.get(channelNum);
			
			if(channelEndedEvent != null)
			{
				channelEndedEvent.dispatch();
			}
		}
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
	//* Camera & Zoom
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

		cameraX = camera.realX - screenWidthHalf;
		cameraY = camera.realY - screenHeightHalf;

		//Position Limiter: Never go past 0 or sceneDimension-screenDimension
		if(limitCameraToScene)
		{
			cameraX = Math.max(0, Math.min(sceneWidth - screenWidth, cameraX));
			cameraY = Math.max(0, Math.min(sceneHeight - screenHeight, cameraY));
		}
		
		cameraX *= SCALE;
		cameraY *= SCALE;
		
		// Moving the HUD Layer when zoom is activated
		if ((zoomMultiplier != 1.0 ) && isHUDZoomable)
		{
			hudLayer.x = -Script.getScreenX();
			hudLayer.y = -Script.getScreenY();
		}
	}
	
	public function setZoom(m:Float, changeSize:Bool = true)
	{
		if (m <= 0)
		{
			Log.warn("You cannot set Zoom less than or equal to 0"); 
			return;
		}
		
		if(zoomMultiplier == m)
		{
			return;
		}
		
		zoomMultiplier = m;
		
		root.scaleX = screenScaleX = m * unzoomedScaleX;
		root.scaleY = screenScaleY = m * unzoomedScaleY;
		
		if (changeSize)
		{
			screenWidth = Std.int(Universal.logicalWidth * (1 / m));
			screenWidthHalf = Std.int(screenWidth / 2);
			screenHeight = Std.int(Universal.logicalHeight * (1 / m));
			screenHeightHalf = Std.int(screenHeight / 2);
			
			#if !use_tilemap
			Utils.applyToAllChildren(root, function(obj) {
				if(isOfType(obj, TileLayer))
					cast(obj, TileLayer).expandBitmap();
			});
			#end
		}

		setColorBackground(scene.colorBackground);
		root.scrollRect = new Rectangle(0, 0, screenWidth * SCALE, screenHeight * SCALE);
		moveCamera(camera.realX, camera.realY);

		if (!isHUDZoomable)
		{
			hudLayer.scaleX = 1 / m;
			hudLayer.scaleY = 1 / m;
		}
	}

	//*-----------------------------------------------
	//* Pausing
	//*-----------------------------------------------
	
	public function pause()
	{
		if(isTransitioning())
		{
			Log.warn("Cannot pause while scene is transitioning.");
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
		
		whenPaused.dispatch(true);
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
		
		whenPaused.dispatch(false);
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
			l.overlay.clearFrame();
		}
		hudLayer.overlay.clearFrame();
		drawingLayer.clearFrame();
		transitionLayer.graphics.clear();
		
     	g.resetGraphicsSettings();
		
		//Walk through all actors
		//TODO: cache the actors that need to be drawn instead upon creation
		if(!allActors.isEmpty())
		{
			for(a in allActors)
			{
				if(a.whenDrawing.length > 0 && a.layer != null)
				{
					g.layer = a.layer.overlay;
					if(Config.drawToLayers)
					{
						g.graphics = g.layer.graphics;
					}
					g.translateToActor(a);
					g.resetGraphicsSettings();

					a.whenDrawing.dispatch(g, 0, 0);
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
     	g.layer = drawingLayer;
     	if(Config.drawToLayers)
		{
			g.graphics = g.layer.graphics;
		}
     	g.translateToScreen();
		g.resetGraphicsSettings();

		whenDrawing.dispatch(g, 0, 0);

     	G.visitStringCache();
		
		g.layer = null;
		g.graphics = transitionLayer.graphics;
     	
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
		
		if(Config.drawToLayers)
		{
			for(l in interactiveLayers)
			{
				l.overlay.renderFrame(g);
			}
			hudLayer.overlay.renderFrame(g);
			drawingLayer.renderFrame(g);
			g.layer = null;
			g.graphics = g.layer.graphics;
		}

		g.graphics = null;
		
		#if !flash
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
			Log.error("Error: getActorsOfType was passed a null type" + Utils.printCallstackIfAvailable());
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
	
	
	//*-----------------------------------------------
	//* Actors - Layering
	//*-----------------------------------------------
	
	@deprecated("Use getLayerById or getLayerByName")
	public function getLayer(refType:Int, ref:String):RegularLayer
	{
		if(refType == 0)
			return getLayerById(Std.parseInt(ref));
		else
			return getLayerByName(ref);
	}
	
	public function getLayerById(id:Int, withFallback:Bool = true):RegularLayer
	{
		if (id == -1)
		{
			return null;
		}
		
		var layer = engine.layers.get(id);
		
		if(layer == null && withFallback)
		{
			Log.error("Layer ID \"" + id + "\" does not exist -- assuming top layer");
			layer = topLayer;
		}
		
		return layer;
	}
	
	public function getLayerByName(name:String, withFallback:Bool = true):RegularLayer
	{
		var layer = engine.layersByName.get(name);
		
		if(layer == null && withFallback)
		{
			Log.error("Layer name \"" + name + "\" does not exist -- assuming top layer");
			layer = topLayer;
		}
		
		return layer;
	}
	
	public function getLayerByOrder(layerConst:Int):Layer
	{
		return cast switch(layerConst)
		{
			case Script.FRONT: topLayer;
			case Script.MIDDLE: middleLayer;
			case Script.BACK: bottomLayer;
			default: {
				Log.error("Layer order identifier \"" + layerConst + "\" is not FRONT, MIDDLE, or BACK -- assuming top layer");
				topLayer;
			}
		}
	}
	
	public function sendToBack(a:Actor)
	{
		if(a.isHUD) return;
		
		moveActorToLayer(a, bottomLayer);
	}
	
	public function sendBackward(a:Actor)
	{
		if(a.isHUD) return;
		
		var order:Int = a.layer.order;
		while(layersToDraw.exists(--order))
		{
			if(isOfType(layersToDraw.get(order), Layer))
			{
				moveActorToLayer(a, cast layersToDraw.get(order));
				return;
			}
		}
	}
	
	public function bringToFront(a:Actor)
	{
		if(a.isHUD) return;
		
		moveActorToLayer(a, topLayer);
	}
	
	public function bringForward(a:Actor)
	{
		if(a.isHUD) return;
		
		var order:Int = a.layer.order;
		while(layersToDraw.exists(++order))
		{
			if(isOfType(layersToDraw.get(order), Layer))
			{
				moveActorToLayer(a, cast layersToDraw.get(order));
				return;
			}
		}
	}
	
	public function getNumberOfActorsWithinLayer(layer:RegularLayer):Int
	{
		if(isOfType(layer, Layer))
			#if use_actor_tilemap
			return cast(layer, Layer).actorContainer.numTiles;
			#else
			return cast(layer, Layer).actorContainer.numChildren;
			#end
		else
			return 0;
	}

	public function getNumberOfLayers():Int
	{
		return master.numChildren;
	}

	public function getOrderOfLayer(layer:RegularLayer):Int
	{
		return layer.order;
	}

	public function moveLayerToOrder(layer:RegularLayer, order:Int)
	{
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

		if(isOfType(layer, BackgroundLayer))
			backgroundLayers.push(cast(layer, BackgroundLayer));
		else if(isOfType(layer, Layer))
			interactiveLayers.push(cast(layer, Layer));
		layers.set(layer.ID, layer);
		layersByName.set(layer.layerName, layer);

		refreshLayers();
	}

	public function removeLayer(layer:RegularLayer)
	{
		master.removeChild(layer);
		
		if(isOfType(layer, BackgroundLayer))
			backgroundLayers.remove(cast(layer, BackgroundLayer));
		else if(isOfType(layer, Layer))
			interactiveLayers.remove(cast(layer, Layer));
		layers.unset(layer.ID);
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
			l.order = i;
			
			if(isOfType(l, Layer))
			{
				if(!foundBottom)
				{
					foundBottom = true;
					bottomLayer = cast l;
				}
				
				if(!foundMiddle && numLayersProcessed == Math.floor(interactiveLayers.length / 2))
				{
					foundMiddle = true;
					middleLayer = cast l;
				}

				topLayer = cast l;
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
			v1.x = one.getUserData().getPhysicsWidth() / 2;
			v1.y = one.getUserData().getPhysicsHeight() / 2;
		}
		
		if(two.getType() == 0)
		{
			v2.x = two.getUserData().getPhysicsWidth() / 2;
			v2.y = two.getUserData().getPhysicsHeight() / 2;
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
			if(one.getUserData() != null)
			{
				pt1.x = one.getUserData().getPhysicsWidth() / 2;
				pt1.y = one.getUserData().getPhysicsHeight() / 2;
				pt1 = one.getWorldPoint(pt1);	
			}
		}
		
		if(two.getType() == 0)
		{
			if(two.getUserData() != null)
			{
				pt2.x = two.getUserData().getPhysicsWidth() / 2;
				pt2.y = two.getUserData().getPhysicsHeight() / 2;
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
			region.setXY(x + region.regionWidth / 2, y + region.regionHeight / 2);
		}
		
		addRegion(region);
		return region;
	}
	
	public function createBoxRegion(x:Float, y:Float, w:Float, h:Float):Region
	{
		if(NO_PHYSICS)
		{
			var region = new Region(this, x, y, [], new Rectangle(0, 0, w, h));
			addRegion(region);
			return region;
		}
		
		else
		{
			w = toPhysicalUnits(w);
			h = toPhysicalUnits(h);
			
			var p = new B2PolygonShape();
			p.setAsBox(w/2, h/2);
			return createRegion(x, y, p, true);
		}
	}
	
	public function createCircularRegion(x:Float, y:Float, r:Float):Region
	{
		if(NO_PHYSICS)
		{
			var region = new Region(this, x, y, [], new Rectangle(0, 0, r*2, r*2));
			addRegion(region);
			return region;
		}
		
		else
		{
			r = toPhysicalUnits(r);
			
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
		regions.unset(r.ID);
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
			Log.error("Region does not exist.");
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
			region.setXY(x + region.regionWidth / 2, y + region.regionHeight / 2);
		}
		
		addTerrainRegion(region);
		return region;
	}
	
	public function createBoxTerrainRegion(x:Float, y:Float, w:Float, h:Float, groupID:Int=1):Terrain
	{
		w = toPhysicalUnits(w);
		h = toPhysicalUnits(h);
	
		var p = new B2PolygonShape();
		p.setAsBox(w/2, h/2);
		
		return createTerrainRegion(x, y, p, true, groupID);
	}
	
	public function createCircularTerrainRegion(x:Float, y:Float, r:Float, groupID:Int = 1):Terrain
	{
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
	
	public function restoreGameAttributes()
	{
		var mbsGame = Data.get().readGameMbs();
		var gma = AttributeValues.readMap(mbsGame.getGameAttributes());
		
		#if haxe4
		gameAttributes.clear();
		#else
		for(key in gameAttributes.keys())
		{
			gameAttributes.remove(key);
		}
		#end
		for(key in gma.keys())
		{
			gameAttributes.set(key, gma.get(key));
		}
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
	
	@:deprecated("use setLayerScrollFactor")
	public function setScrollFactor(id:Int, amountX:Float, ?amountY:Float)
	{
		setLayerScrollFactor(getLayerById(id), amountX, amountY);
	}
	
	public function setLayerScrollFactor(layer:RegularLayer, amountX:Float, ?amountY:Float)
	{
		if(amountY == null)
			amountY = amountX;
		layer.scrollFactorX = amountX;
		layer.scrollFactorY = amountY;
	}
	
	//*-----------------------------------------------
	//* ApplicationMain Access
	//*-----------------------------------------------
	
	//for Cppia, don't directly call ApplicationMain functions

	private static var am:Class<Dynamic>;
	
	public static function reloadGame()
	{
		Reflect.callMethod(am, Reflect.field(am, "reloadGame"), []);
	}

	public static function addReloadListener(reloadListener:Void->Void)
	{
		var reloadListeners:Array<Void->Void> = Reflect.field(am, "reloadListeners");
		reloadListeners.push(reloadListener);
	}
	
	public static function reloadTracingConfig()
	{
		Reflect.callMethod(am, Reflect.field(am, "reloadTracingConfig"), []);
	}

	#if testing
	public static function getLaunchVars():Map<String, String>
	{
		return Reflect.field(am, "launchVars");
	}
	#end
}
