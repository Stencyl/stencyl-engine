package;

import com.stencyl.Engine;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.display.StageAlign;
import nme.display.StageScaleMode;

#if flash
import com.nmefermmmtools.debug.Console;
#end

class Universal extends Sprite 
{
	var engine:Engine;

	public function new() 
	{
		super();
		
		#if flash
		Console.create(true, 192, false);
		
		//MochiServices.connect("60347b2977273733", root);
		//MochiAd.showPreGameAd( { id:"60347b2977273733", res:"640x580", clip: root});
		#end
		
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
		
		//var stats = new com.nmefermmmtools.debug.Stats();
		//stage.addChild(stats);
		
		engine = new Engine(this);
	}
	
	public static function main() 
	{
		Lib.current.addChild(new Universal());	
	}	
}
