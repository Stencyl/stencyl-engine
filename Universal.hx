package;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.text.TextField;
import nme.display.DisplayObjectContainer;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.Assets;
import nme.Lib;
import nme.ui.Keyboard;

import behavior.Behavior;
import behavior.Script;

import graphics.transitions.Transition;
import graphics.BitmapFont;

import models.Actor;
import models.GameModel;

import scripts.Motion;

#if cpp
import nme.ui.Accelerometer;
#end

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;

class Universal extends Sprite 
{
	public static var STEP_SIZE:Float = 0.01;
	public static var MS_PER_SEC:Int = 1000;
	public static var elapsedTime:Float = 0;
	
	var engine:Engine;
	
	var lastTime:Float;
	var acc:Float;
	
	var framerate:Int;
	var framerateCounter:Float;
	var fpsLabel:TextField;
	
	var layers:Array<Sprite>;

	var master:Sprite;
	var pronger:Actor;
	
	public static var stage;
	
	public static var cameraX:Float;
	public static var cameraY:Float;
	
	public static var screenWidth:Int;
	public static var screenHeight:Int;
	
	public static var sceneWidth:Int;
	public static var sceneHeight:Int;

	public function new() 
	{
		super();
		
		GameModel.get();
		Data.get();
		
		engine = new Engine();
		
		cameraX = 0;
		cameraY = 0;

		acc = 0;
		framerateCounter = 0;
		
		//---
		
		layers = new Array<Sprite>();
		
		//---
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function init()
	{
		sceneWidth = 640;
		sceneHeight = 640;
		
		screenWidth = Std.int(stage.stageWidth);
		screenHeight = Std.int(stage.stageHeight);
		
		//---
	
		lastTime = Lib.getTimer() / MS_PER_SEC;
		
		Universal.stage = stage;
	
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);

		//mobile input
				
		var bg:Bitmap = new Bitmap(Assets.getBitmapData("assets/graphics/bg.png"));
		addChild(bg);
		
		master = new Sprite();
		addChild(master);
		
		
		
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
		for(i in 0...10)
		{
			var sprite = new Bitmap(Assets.getBitmapData("assets/graphics/tile.png"));
			sprite.smoothing = true;
			sprite.x = -sprite.width/2;
			sprite.y = -sprite.height/2;
		
			var actor = new Actor(i * 32 + 16, 96 + 16);
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
		
			var actor = new Actor(96 + 16, i * 32 + 16);
			master.addChild(actor);
			actor.addAnimation("d", sprite);
			actor.switchAnimation("d");
		}
	
		pronger = new Actor(16, 32);
		master.addChild(pronger);
		//pronger.addAnimation("anim1", "assets/graphics/anim1.png");
		//pronger.addAnimation("anim2", "assets/graphics/anim2.png");
		//pronger.switchAnimation("anim1");
		
		pronger.tileTest();
		
		new Universal();
		
		var font:BitmapFont = new BitmapFont("assets/graphics/font.png", 32, 32, BitmapFont.TEXT_SET11 + "#", 9, 1, 1);
		font.text = "NME is great";
		font.x = 100;
		font.y = 100;
		master.addChild(font);
		
		//---
		
		//new io.BackgroundReader();
		
		/*var xml = Assets.getText("assets/data/test.xml");
		var xmlData = Xml.parse(xml);
		var root = new haxe.xml.Fast(xmlData.firstElement());
		
		for(child in root.nodes.animal) 
		{
     		//trace(child.name + " - " + child.att.type);
		}*/
		
		//var sound = Assets.getSound("assets/music/sample.mp3");
		//var soundChannel = sound.play();
		
		Input.enable();
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		
		//randomMotion();
		
		//var thing = Type.createInstance(Type.resolveClass("behavior.Motion"), [pronger, engine]);
		var behavior = new Behavior(pronger, engine, 0, "Pronger", "behavior.Motion", true, false, null);
		pronger.behaviors.add(behavior);
		pronger.initScripts();	
		
		//FPS Counter
		fpsLabel = new TextField();
		fpsLabel.x = 10;
		fpsLabel.y = 10;
		//addChild(fpsLabel);
	}
	
	private function randomMotion():Void 
	{
		var randomX = Math.random () * (stage.stageWidth - pronger.width);
		var randomY = Math.random () * (stage.stageHeight - pronger.height);
	 
		Actuate.tween (pronger, 2, { x: randomX, y: randomY } )
			.ease (Elastic.easeOut)
			.onComplete (randomMotion); 
	}

	private function update(elapsedTime:Float)
	{
		#if cpp
		if(nme.sensors.Accelerometer.isSupported)
		{
			var data = Accelerometer.get();
			
			pronger.x += data.x;
			pronger.y -= data.y;
		}
		#end
		
		//---
		
		cameraX = pronger.x - screenWidth/2;
		cameraY = pronger.y - screenHeight/2;
		
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
		
		pronger.update(elapsedTime);
		
		engine.update(elapsedTime);
	}
	
	private function onAdded(event:Event):Void 
	{
		init();	
	}
	
	//Game Loop
	private function onUpdate(event:Event):Void 
	{
		var currTime:Float = Lib.getTimer() / MS_PER_SEC;
		var elapsedTime:Float = (currTime - lastTime);
		acc += elapsedTime;
		
		Universal.elapsedTime = elapsedTime;
		
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
	
	public static function main() 
	{
		Lib.current.addChild(new Universal());	
	}	
}
