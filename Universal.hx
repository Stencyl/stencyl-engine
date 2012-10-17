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
		if(!scripts.MyAssets.releaseMode)
		{
			com.nmefermmmtools.debug.Console.create(true, 192, false);
		}
		#end

		#if (mobile && !android && !air)
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
		
		#if(mobile && !air)
		Ads.initialize(scripts.MyAssets.whirlID);
		#end
		
		#if(flash && !air)
		var mochiID = scripts.MyAssets.mochiID;
		var newgroundsID = scripts.MyAssets.newgroundsID;
		var newgroundsKey = scripts.MyAssets.newgroundsKey;
		
		if(newgroundsID != "")
        {
        	com.newgrounds.API.API.connect(root, newgroundsID, newgroundsKey);
        }
        
        if(mochiID != "")
        {
            mochi.as3.MochiServices.connect(mochiID, root);
        }
        #end
            
		//---
	
		#if (mobile && !android && !air)
		Lib.current.stage.removeEventListener(Event.RESIZE, onAdded);
		#else
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		#end
		
		com.stencyl.Engine.stage = Lib.current.stage;
		
		var stageWidth = stage.stageWidth;
		var stageHeight = stage.stageHeight;
		
		//NME Bug: If waking from sleep, the dimensions can be flipped on Android.
		#if android
		if(stageWidth < stageHeight && scripts.MyAssets.landscape)
		{
			stageHeight = stage.stageWidth;
			stageWidth = stage.stageHeight;
		}
		#end
		
		trace("Stage Width: " + scripts.MyAssets.stageWidth);
		trace("Stage Height: " + scripts.MyAssets.stageHeight);
		trace("Screen Width: " + stageWidth);
		trace("Screen Height: " + stageHeight);
		trace("Screen DPI: " + Capabilities.screenDPI);
		
		//Tablets and other high-res devices get to use 2x mode, (TODO: if it's not a tablet-only game.)
		#if(mobile && !air)	
		
		var larger = Math.max(stageWidth, stageHeight);
		var smaller = Math.min(stageWidth, stageHeight);
		
		if(smaller == 320 && larger == 480)
		{
			Engine.isStandardIOS = true;
		}
		
		else if(smaller == 640 && larger == 960)
		{
			Engine.isStandardIOS = true;
		}
		
		else if(smaller == 640 && larger == 1136)
		{
			Engine.isExtendedIOS = true;
		}	
		
		else if(smaller == 768 && larger == 1024)
		{
			Engine.isTabletIOS = true;
		}	
		
		else if(smaller == 1536 && larger == 2048)
		{
			Engine.isTabletIOS = true;
		}		
		
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
		
		#if(!mobile)
		Engine.SCALE = scripts.MyAssets.gameScale;
		Engine.IMG_BASE = scripts.MyAssets.gameImageBase;
		#end
		
		//Purely for testing
		#if(air && mobile)
		Engine.SCALE = 1;
		Engine.IMG_BASE = "1x";
		#end
		
		var originalWidth = scripts.MyAssets.stageWidth;
		var originalHeight = scripts.MyAssets.stageHeight;
		
		scripts.MyAssets.stageWidth = Std.int(scripts.MyAssets.stageWidth * Engine.SCALE);
		scripts.MyAssets.stageHeight = Std.int(scripts.MyAssets.stageHeight * Engine.SCALE);

		var usingFullScreen = false;
		var stretchToFit = false;
		
		//Stretch To Fit
		#if(mobile && !air)
		if(scripts.MyAssets.stretchToFit)
		{
			stretchToFit = true;
			
			scaleX *= stageWidth / scripts.MyAssets.stageWidth;
			scaleY *= stageHeight / scripts.MyAssets.stageHeight;
		}
		#end
		
		//Full Screen Mode
		#if(mobile && !air)
		if(originalWidth == -1 || originalHeight == -1)
		{
			originalWidth = scripts.MyAssets.stageWidth = stageWidth;
			originalHeight = scripts.MyAssets.stageHeight = stageHeight;
			
			usingFullScreen = true;
		}
		#end
			
		#if(mobile && !air)
		if(!usingFullScreen && !stretchToFit)
		{
			//Is the game width > device width? Adjust scaleX, then scaleY.
			if(scripts.MyAssets.stageWidth > stageWidth)
			{
				scaleX *= stageWidth / scripts.MyAssets.stageWidth;
				scaleY = scaleX;
			}
			
			//If the game height * scaleY > device height? Adjust scaleY, then scaleX.
			if(scripts.MyAssets.stageHeight * scaleY > stageHeight)
			{
				scaleY = stageHeight / scripts.MyAssets.stageHeight;
				scaleX = scaleY;
			}

			x += (stageWidth - scripts.MyAssets.stageWidth * scaleX)/2;
			y += (stageHeight - scripts.MyAssets.stageHeight * scaleY)/2;
		}
		#end
		
		//Clip the view
		#if(mobile && !air)
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
		
		#if(mobile && !air)
		stage.opaqueBackground = 0x000000;
		#end

		Lib.current.addChild(new Universal());
	}
}
