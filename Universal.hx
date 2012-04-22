package;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.Assets;
import nme.Lib;
import nme.ui.Keyboard;

#if cpp
import nme.ui.Accelerometer;
#end

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;

class Universal extends Sprite 
{
	static var STEP_SIZE:Float = 0.01;
	static var MS_PER_SEC:Int = 1000;

	var lastTime:Float;
	var acc:Float;

	var pronger:Bitmap;
	
	public static var stage;

	public function new() 
	{
		super();

		acc = 0;
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function init()
	{
		lastTime = Lib.getTimer() / MS_PER_SEC;
		
		Universal.stage = stage;
	
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		stage.addEventListener(Event.ENTER_FRAME, onUpdate);

		//mobile input
		
		var bg:Bitmap = new Bitmap(Assets.getBitmapData("assets/graphics/bg.png"));
		addChild(bg);
			
		pronger = new Bitmap(Assets.getBitmapData("assets/graphics/icon.png"));
		addChild(pronger);
		
		var xml = Assets.getText("assets/data/test.xml");
		var xmlData = Xml.parse(xml);
		var root = new haxe.xml.Fast(xmlData.firstElement());
		
		for(child in root.nodes.animal) 
		{
     		trace(child.name + " - " + child.att.type);
		}
		
		//var sound = Assets.getSound("assets/music/sample.mp3");
		//sound.play();
		
		Input.enable();
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		
		//randomMotion();
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
	
		if(Input.check("left"))
		{
			pronger.x -= 3;
		}
		
		if(Input.check("right"))
		{
			pronger.x += 3;
		}
		
		if(Input.check("up"))
		{
			pronger.y -= 3;
		}
		
		else if(Input.check("down"))
		{
			pronger.y += 3;
		}
		
		if(Input.mousePressed)
		{
			pronger.x = Input.mouseX;
			pronger.y = Input.mouseY;
		}
	}
	
	private function onAdded(event:Event):Void 
	{
		init();	
	}
	
	private function onUpdate(event:Event):Void 
	{
		var currTime:Float = Lib.getTimer() / MS_PER_SEC;
		var elapsedTime:Float = (currTime - lastTime);
		acc += elapsedTime;
		
		while(acc > STEP_SIZE)
		{
			update(STEP_SIZE);
			acc -= STEP_SIZE;
			
			Input.update();
		}	
		
		lastTime = currTime;
	}
	
	public static function main() 
	{
		Lib.current.addChild(new Universal());	
	}	
}
