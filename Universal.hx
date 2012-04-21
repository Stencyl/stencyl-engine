package;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.Assets;
import nme.Lib;

/**
 * ...
 * @author jon
 */
class Universal extends Sprite 
{
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function init()
	{
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
			
		var pronger:Bitmap = new Bitmap(Assets.getBitmapData("assets/icon.png"));
		addChild(pronger);
	}
	
	private function onAdded(event:Event):Void 
	{
		init();	
	}
	
	public static function main() 
	{
		Lib.current.addChild(new Universal());	
	}	

}
