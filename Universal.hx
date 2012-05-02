package;

import nme.Lib;
import nme.display.Sprite;

import nme.events.Event;

import nme.display.StageAlign;
import nme.display.StageScaleMode;

class Universal extends Sprite 
{
	var engine:Engine;

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function onAdded(event:Event):Void 
	{
		init();	
	}
	
	public function init()
	{
		Engine.stage = stage;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;		

		engine = new Engine(this);
	}
	
	public static function main() 
	{
		Lib.current.addChild(new Universal());	
	}	
}
