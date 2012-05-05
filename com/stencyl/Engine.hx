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
import com.stencyl.models.scene.ActorInstance;
import com.stencyl.models.GameModel;
import com.stencyl.models.Scene;

import scripts.MyScripts;

import com.stencyl.utils.HashMap;

#if cpp
import nme.ui.Accelerometer;
#end

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;

class Engine 
{
	public static var STEP_SIZE:Float = 0.01;
	public static var MS_PER_SEC:Int = 1000;
	public static var elapsedTime:Float = 0;
	public static var stage:Stage;
	
	var root:Sprite;
	var tasks:Array<TimedTask>;
	
		
	var lastTime:Float;
	var acc:Float;
	
	var framerate:Int;
	var framerateCounter:Float;
	var fpsLabel:TextField;
	
	var layers:Array<Sprite>;

	var master:Sprite;

	public static var cameraX:Float;
	public static var cameraY:Float;
	
	public static var screenWidth:Int;
	public static var screenHeight:Int;
	
	public static var sceneWidth:Int;
	public static var sceneHeight:Int;
		
	public var scene:Scene;
	public var actors:Array<Actor>;
			
			
	//*-----------------------------------------------
	//* Transitioning
	//*-----------------------------------------------
		
	private var leave:Transition;
	private var enter:Transition;
	private var sceneToEnter:Int;
	
	
	//*-----------------------------------------------
	//* Game Attributes
	//*-----------------------------------------------
	
	private var gameAttributes:Hash<Dynamic>;
	
	public var behaviors:BehaviorManager;
	
	
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
		
		//mobile input
				
		//var bg:Bitmap = new Bitmap(Assets.getBitmapData("assets/graphics/bg.png"));
		//root.addChild(bg);
		
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
		
		//FPS Counter
		fpsLabel = new TextField();
		fpsLabel.x = 10;
		fpsLabel.y = 10;
		//addChild(fpsLabel);
		
		//enter = new FadeInTransition(500);
		//enter.start();
		//sceneToEnter = initSceneID;
			
		loadScene(sceneToEnter);
		
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);
	}
	
	public function loadScene(sceneID:Int)
	{
		//trace("Loading Scene: " + sceneID);
		
		scene = GameModel.get().scenes.get("" + sceneID);
		
		if(sceneID == -1 || scene == null)
		{
			scene = GameModel.get().scenes.get("" + GameModel.get().defaultSceneID);
		}
		
		loadActors();
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
			cameraX = a.x - screenWidth/2;
			cameraY = a.y - screenHeight/2;
			
			a.update(elapsedTime);
		}

		//---
		
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
			
		framerate = Std.int(1 / elapsedTime);
		framerateCounter += elapsedTime;
		
		if(framerateCounter > 1)
		{
			framerateCounter -= 1;
			fpsLabel.text = Std.string(framerate);
		}
	}
	
	//---
	
	public function addTask(task:TimedTask)
	{
		tasks.push(task);
	}
	
	public function removeTask(taskToRemove:TimedTask)
	{
		tasks.remove(taskToRemove);
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
				attributes
			);
			
			manager.add(b);
		}
		
		if(initialize)
		{
			manager.initScripts();
		}
	}
	
	//---
	
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
}
