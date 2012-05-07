package;

import com.stencyl.Engine;

import nme.Lib;
import nme.display.Sprite;

import nme.events.Event;

import nme.display.StageAlign;
import nme.display.StageScaleMode;

import com.nmefermmmtools.debug.Console;

class Universal extends Sprite 
{
	var engine:Engine;

	public function new() 
	{
		super();
		
		Console.create(true, 192, false);
		
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
