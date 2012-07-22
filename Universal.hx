package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.Shape;
import nme.system.Capabilities;

class Universal extends Sprite 
{
	public function new() 
	{
		super();

		#if flash
		com.nmefermmmtools.debug.Console.create(true, 192, false);
		
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
		com.stencyl.Engine.stage = Lib.current.stage;
		
		mouseChildren = false;
		mouseEnabled = false;
		stage.mouseChildren = false;
				
		#if mobile
		//if game width > screen width
		//scaleX = 0.5;
		//scaleY = scaleX;
		
		/*if(scripts.MyAssets.stageWidth > stage.stageWidth)
		{
			scaleX = stage.stageWidth / scripts.MyAssets.stageWidth;
			scaleY = scaleX;
		}
		
		scaleX = 0.66;
		scaleY = scaleX;*/
		
		x += (stage.stageWidth - scripts.MyAssets.stageWidth)/2;
		y += (stage.stageHeight - scripts.MyAssets.stageHeight)/2;
		
		//TODO: Add black bars instead. Can't figure out how to clip the view!
		//Only ever need 2 so it's not too wasteful.
		
		#end
		
		//Preloader Hook - When force-testing preloader, uncomment this
		//var loader = new scripts.StencylPreloader();
		//loader.onUpdate(5, 15);
		//addChild(loader);
		
		new com.stencyl.Engine(this);
	}
	
	public static function main() 
	{
		var stage = Lib.current.stage;
		
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		#if mobile
		stage.opaqueBackground = 0x000000;
		#end

		Lib.current.addChild(new Universal());	
	}
}
