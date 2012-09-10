package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.Shape;
import nme.system.Capabilities;
import com.stencyl.Engine;

class Universal extends Sprite 
{
	public function new() 
	{
		super();

		#if flash
		//com.nmefermmmtools.debug.Console.create(true, 192, false);
		
		haxe.Log.trace = function(s: String, ?pi: haxe.PosInfos)
		{
		    untyped __global__["trace"]("Stencyl:" + s);
		};
		#end

		#if (mobile && !android)
		Lib.current.stage.addEventListener(Event.RESIZE, onAdded);
		#else
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		#end
	}
	
	private function onAdded(event:Event):Void 
	{
		init();	
	}
	
	public function init()
	{
		//Mochi, Newgrounds and other APIs
		
		#if flash
		var mochiID = scripts.MyAssets.mochiID;
		var newgroundsID = scripts.MyAssets.newgroundsID;
		var newgroundsKey = scripts.MyAssets.newgroundsKey;
		
		if(newgroundsID != "")
        {
        	//Newgrounds breaks build. Hiding for now.
        	//com.newgrounds.API.API.connect(root, newgroundsID, newgroundsKey);
        }
        
        if(mochiID != "")
        {
            mochi.as3.MochiServices.connect(mochiID, root);
        }
        #end
            
		//---
	
		#if (mobile && !android)
		Lib.current.stage.removeEventListener(Event.RESIZE, onAdded);
		#else
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		#end
		
		com.stencyl.Engine.stage = Lib.current.stage;
		
		trace("Stage Width: " + scripts.MyAssets.stageWidth);
		trace("Stage Height: " + scripts.MyAssets.stageHeight);
		trace("Screen Width: " + stage.stageWidth);
		trace("Screen Height: " + stage.stageHeight);
		trace("Screen DPI: " + Capabilities.screenDPI);

		//Tablets and other high-res devices get to use 2x mode, (TODO: if it's not a tablet-only game.)
		#if (mobile)		
		var larger = Math.max(stage.stageWidth, stage.stageHeight);
		
		//4 scale sceheme
		/*if(larger >= 1920)
		{
			Engine.SCALE = 4;
			Engine.IMG_BASE = "4x";
		}
		
		else if(larger >= 960)
		{
			Engine.SCALE = 2;
			Engine.IMG_BASE = "2x";
		}
		
		else if(larger >= 720)
		{
			Engine.SCALE = 1.5;
			Engine.IMG_BASE = "1.5x";
		}
		
		else
		{
			Engine.SCALE = 1;
			Engine.IMG_BASE = "1x";
		}*/
		
		//2 scale scheme
		if(larger >= 720)
		{
			Engine.SCALE = 2;
			Engine.IMG_BASE = "2x";
		}
		
		else
		{
			Engine.SCALE = 1;
			Engine.IMG_BASE = "1x";
		}
		
		trace("Engine Scale: " + Engine.IMG_BASE);
		#end
		
		#if (!mobile)
		Engine.SCALE = scripts.MyAssets.gameScale;
		Engine.IMG_BASE = scripts.MyAssets.gameImageBase;
		#end
		
		var originalWidth = scripts.MyAssets.stageWidth;
		var originalHeight = scripts.MyAssets.stageHeight;
		
		scripts.MyAssets.stageWidth = Std.int(scripts.MyAssets.stageWidth * Engine.SCALE);
		scripts.MyAssets.stageHeight = Std.int(scripts.MyAssets.stageHeight * Engine.SCALE);
		
		mouseChildren = false;
		mouseEnabled = false;
		stage.mouseChildren = false;
		
		var usingFullScreen = false;
		var stretchToFit = false;
		
		//Stretch To Fit
		#if (mobile)
		if(scripts.MyAssets.stretchToFit)
		{
			stretchToFit = true;
			
			scaleX *= stage.stageWidth / scripts.MyAssets.stageWidth;
			scaleY *= stage.stageHeight / scripts.MyAssets.stageHeight;
		}
		#end
		
		//Full Screen Mode
		#if (mobile)
		if(scripts.MyAssets.stageWidth == -1 || scripts.MyAssets.stageHeight == -1)
		{
			scripts.MyAssets.stageWidth = stage.stageWidth;
			scripts.MyAssets.stageHeight = stage.stageHeight;
			
			usingFullScreen = true;
		}
		#end
			
		#if (mobile)
		if(!usingFullScreen && !stretchToFit)
		{
			//Is the game width > device width? Adjust scaleX, then scaleY.
			if(scripts.MyAssets.stageWidth > stage.stageWidth)
			{
				scaleX *= stage.stageWidth / scripts.MyAssets.stageWidth;
				scaleY = scaleX;
			}
			
			//If the game height * scaleY > device height? Adjust scaleY, then scaleX.
			if(scripts.MyAssets.stageHeight * scaleY > stage.stageHeight)
			{
				scaleY = stage.stageHeight / scripts.MyAssets.stageHeight;
				scaleX = scaleY;
			}

			x += (stage.stageWidth - scripts.MyAssets.stageWidth * scaleX)/2;
			y += (stage.stageHeight - scripts.MyAssets.stageHeight * scaleY)/2;
		}
		#end
		
		//Clip the view
		#if (mobile)
		if(!usingFullScreen && !stretchToFit)
		{
			scrollRect = new nme.geom.Rectangle(0, 0, scripts.MyAssets.stageWidth, scripts.MyAssets.stageHeight);
		}
		#end
		
		scripts.MyAssets.stageWidth = originalWidth;
		scripts.MyAssets.stageHeight = originalHeight;
		
		trace("Scale X: " + scaleX);
		trace("Scale Y: " + scaleY);
		
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
