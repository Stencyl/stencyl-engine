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
import nme.text.TextField;
import nme.display.DisplayObjectContainer;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.Assets;
import nme.Lib;
import nme.ui.Keyboard;

import com.stencyl.graphics.transitions.Transition;
import com.stencyl.graphics.BitmapFont;

import com.stencyl.models.Actor;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.scene.ActorInstance;
import com.stencyl.models.GameModel;
import com.stencyl.models.Scene;
import com.stencyl.models.SoundChannel;
import com.stencyl.models.Region;
import com.stencyl.models.Terrain;

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


class Engine 
{
	//*-----------------------------------------------
	//* Constants
	//*-----------------------------------------------
		
	//None?
	
	
	//*-----------------------------------------------
	//* Important Values
	//*-----------------------------------------------
	
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
	
	
	//*-----------------------------------------------
	//* Model - Actors & Groups
	//*-----------------------------------------------
	
	public var groups:IntHash<DisplayObjectContainer>;
	public var allActors:IntHash<Actor>;
	public var nextID:Int;
	
	//Used to be called actorsToRender
	public var actorsPerLayer:IntHash<DisplayObjectContainer>;
	
	public var hudActors:Array<Actor>;
	
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
	
	public var layers:Array;
	public var tileLayers:Array;
	public var dynamicTiles:Dictionary;
	public var animatedTiles:Array;
	
	public var topLayer:Int;
	public var bottomLayer:Int;
	public var middleLayer:Int;
	
	//int[]
	//index -> order
	//value -> layerID
	public var layersToDraw:Array;
	public var layerOrders:Array;		
	
	public var parallax:ParallaxArea;
	public var playfield:Area;
	
	
	//*-----------------------------------------------
	//* Model - ?????
	//*-----------------------------------------------
	
	public var actors:Array<Actor>;
	public var g:Graphics;
	
	
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
	
	var lastTime:Float;
	var acc:Float;
	
	var framerate:Int;
	var framerateCounter:Float;
	
	
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
		Input.enable();
		
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
		root.addChild(master);
		
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
		
		//TODO: Key to toggle this, does not work on HTML5
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
	}
	
	public function loadScene(sceneID:Int)
	{
		//trace("Loading Scene: " + sceneID);
		
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
	
	public function loadBackgrounds()
	{
		var bg = new Shape();
		scene.colorBackground.draw(bg.graphics, 0, 0, screenWidth, screenHeight);
		master.addChild(bg);
	}
	
	public function loadActors()
	{
		actors = new Array<Actor>();
		
		for(instance in scene.actors)
		{
			actors.push(createActor(instance, true));
		}
	}
	
	public function initActorScripts()
	{
		for(a in actors)
		{
			a.initScripts();
		}
		
		//actors = null;
	}
		
	public function switchScene(sceneID:Int, leave:Transition=null, enter:Transition=null)
	{
	}
		
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
		
	/*private function randomMotion():Void 
	{
		var randomX = Math.random () * (stage.stageWidth - pronger.width);
		var randomY = Math.random () * (stage.stageHeight - pronger.height);
	 
		Actuate.tween (pronger, 2, { x: randomX, y: randomY } )
			.ease (Elastic.easeOut)
			.onComplete (randomMotion); 
	}*/

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
	
	//---
	
	
	
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
	//* Scene Switching
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* General Loading
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Actor Creation
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Terrain Creation
	//*-----------------------------------------------
	
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
		return allActors[ID];
	}
	
	public function getActorsOfType(type:ActorType):Array<Actor>
	{
		return actorsOfType[type.ID];
	}
	
	public function getRecycledActorsOfType(type:ActorType):Array<Actor>
	{
		return recycledActorsOfType[type.ID];
	}
	
	public function addAlwaysOnActor(a:Actor)
	{
		addHUDActor(a);
	}
	
	public function addHUDActor(a:Actor)
	{
		if(!hudActors.has(a))
		{
			hudActors.add(a);
		}
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
		var lID:Int;
		lID = layerOrder - 1;

		if(lID < 0 || lID > layersToDraw.length-1) return;
		if(a.layerID == layersToDraw[lID]) return;
		
		lID = layersToDraw[lID];

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
		
		if(order < layersToDraw.length - 1)
		{
			a.layerID = layersToDraw[order + 1];	
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
			a.layerID = layersToDraw[order - 1];	
		}
		
		moveActorToLayer(a, a.layerID);
	}
	
	public function getOrderForLayerID(layerID:Int):Int
	{
		return layerOrders[layerID];
	}
	
	public function getIDFromLayerOrder(layerOrder:Int):Int
	{
		return layersToDraw[layerOrder - 1];
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
	
	//*-----------------------------------------------
	//* Groups
	//*-----------------------------------------------
	
	public function getGroup(ID:Int, a:Actor = null):Dynamic
	{
		if(ID == -1000 && a != null)
		{
			return groups[a.getGroupID()];
		}
		
		return groups[ID];
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
