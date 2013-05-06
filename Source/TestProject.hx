package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.Shape;
import nme.system.Capabilities;
import com.stencyl.Engine;

class TestProject extends Universal 
{
	public function new() 
	{
		super();
	}
	
	public static function main() 
	{
		var stage = Lib.current.stage;
		
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		#if(mobile && !air)
		stage.opaqueBackground = 0x000000;
		#end

		Lib.current.addChild(new TestProject());
	}
}