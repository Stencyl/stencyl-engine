package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.StageDisplayState;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.system.Capabilities;
import openfl.ui.Keyboard;

import com.stencyl.APIKeys;
import com.stencyl.Config;
import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.graphics.Scale;
import com.stencyl.graphics.ScaleMode;
import com.stencyl.utils.Utils;
import haxe.xml.Fast;

class Universal extends Sprite 
{
	public static function initStage(stage:Stage):Void
	{
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		#if(mobile && !air)
		stage.opaqueBackground = 0x000000;
		#end
	}

	public function new() 
	{
		super();

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function onAdded(event:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);

		initServices();

		if(Config.startInFullScreen)
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}

		initScreen(Config.startInFullScreen);
	}
	
	public function initServices()
	{
		//Newgrounds and other APIs
		
		#if(flash)
		
		if(APIKeys.newgroundsID != "")
        {
        	com.newgrounds.API.API.connect(root, APIKeys.newgroundsID, APIKeys.newgroundsKey);
        }
        
        #end
	}

	//isFullScreen is used on Web/Desktop for full screen mode
	public function initScreen(isFullScreen:Bool)
	{
		Lib.current.x = 0;
		Lib.current.y = 0;
		Lib.current.scaleX = 1;
		Lib.current.scaleY = 1;
	
		Engine.stage = stage;

		var enabledScales:Array<Scale> = Config.scales.get("project");
		#if web
		enabledScales = Config.scales.get("web");
		#elseif desktop
		enabledScales = Config.scales.get("desktop");
		#elseif (mobile && !android)
		enabledScales = Config.scales.get("ios");
		#elseif android
		enabledScales = Config.scales.get("android");
		#end

		var scales = new Map<String,Bool>();
		for(scale in enabledScales)
		{
			scales.set(scale, true);
		}

		var skipScaling = false;
		var stageWidth = stage.stageWidth;
		var stageHeight = stage.stageHeight;
		
		#if desktop
		if(isFullScreen)
		{
			stageWidth = Std.int(Capabilities.screenResolutionX);
			stageHeight = Std.int(Capabilities.screenResolutionY);
		}
		
		else if(Config.stageWidth != stage.stageWidth)
		{
			isFullScreen = true;
		}
		
		else
		{
			skipScaling = true;
		}
		#end
		
		#if flash
		if(isFullScreen || Config.gameScale > Config.maxScale)
		{
			if (Config.gameScale > Config.maxScale && !isFullScreen)
			{
				stageWidth = Std.int(Config.stageWidth * Config.gameScale);
				stageHeight = Std.int(Config.stageHeight * Config.gameScale);				
			}
			isFullScreen = true;
		}
		
		else
		{
			skipScaling = true;
		}
		#end
		
		//NME Bug: If waking from sleep, the dimensions can be flipped on Android.
		#if android
		
		stageWidth = Std.int(Capabilities.screenResolutionX);
		stageHeight = Std.int(Capabilities.screenResolutionY);
		
		if(stageWidth < stageHeight && Config.landscape)
		{
			stageHeight = stage.stageWidth;
			stageWidth = stage.stageHeight;
		}
		#end
		
		//NME Bug: If waking from sleep, the dimensions can be flipped on iOS.
		#if (mobile && !android)
		
		stageWidth = Std.int(Capabilities.screenResolutionX);
		stageHeight = Std.int(Capabilities.screenResolutionY);
		
		if(stageWidth < stageHeight && Config.landscape)
		{
			var temp = stageHeight;
			stageHeight = stageWidth;
			stageWidth = temp;
		}
		#end

		trace("Stage Width: " + Config.stageWidth);
		trace("Stage Height: " + Config.stageHeight);
		trace("Screen Width: " + stageWidth);
		trace("Screen Height: " + stageHeight);
		trace("Screen DPI: " + Capabilities.screenDPI);
		
		//Tablets and other high-res devices get to use 2x mode, (TODO: if it's not a tablet-only game.)
		#if(flash || desktop || mobile)
		
		//Calculate the theoretical scale if no max scale were imposed
		var theoreticalScale:Float = 0;
		var widescreen:Bool = false;
		
		if(!skipScaling)
		{
			var larger = Math.max(stageWidth, stageHeight);
			var smaller = Math.min(stageWidth, stageHeight);
			var aspectRatio:Float = larger / smaller;
			
			if(smaller == 320 && larger == 480)
			{
				Engine.isStandardIOS = true;
			}
			
			else if(smaller == 640 && larger == 960)
			{
				Engine.isStandardIOS = true;
			}
			
			//iPhone 5, 5s, or iPhone 6 with Display Zoom
			else if(smaller == 640 && larger == 1136)
			{
				Engine.isExtendedIOS = true;
			}	
			
			else if(smaller == 750 && larger == 1334)
			{
				Engine.isIPhone6 = true;
			}	
			
			else if(smaller == 1242 && larger == 2208)
			{
				Engine.isIPhone6Plus = true;
			}
			
			//iPhone 6+ with Display Zoom
			else if(smaller == 1125 && larger == 2001)
			{
				Engine.isIPhone6Plus = true;
			}	
			
			else if(smaller == 768 && larger == 1024)
			{
				Engine.isTabletIOS = true;
			}	
			
			else if(smaller == 1536 && larger == 2048)
			{
				Engine.isTabletIOS = true;
			}		
			
			//Generalized this from 320 x 480 to work with any resolution
			var x1 = Config.stageWidth;
			var y1 = Config.stageHeight;
			
			//TODO: Draw from the game's width/height instead. Games not close to 480x320 may act differently than expected.
			//Can't do today because editor doesn't pass this info in full screen mode.
			if(x1 == -1 || y1 == -1)
			{
				x1 = 480;
				y1 = 320;
			}
			
			else if(!Config.landscape)
			{
				var temp = x1;
				x1 = y1;
				y1 = temp;
			}
			
			var x3 = x1 * 3;
			var y3 = y1 * 3;
			
			var x15 = x3 / 2;
			var y15 = y3 / 2;
			
			var x2 = x1 * 2;
			var y2 = y1 * 2;
			
			var x4 = x2 * 2;
			var y4 = y2 * 2;
	
			if(larger >= x4 && smaller >= y4)
			{
				theoreticalScale = 4;
			}
			
			else if(larger >= x3 && smaller >= y3)
			{
				theoreticalScale = 3;
			}
			
			else if(larger >= x2 && smaller >= y2)
			{
				theoreticalScale = 2;
			}
			
			#if(android || flash || desktop)
			else if(larger >= x15 && smaller >= y15)
			{
				theoreticalScale = 1.5;
			}
			#end
			
			else
			{
				theoreticalScale = 1;
			}
			
			//4 scale scheme
			if(larger >= x4 && smaller >= y4 && scales.exists(Scale._4X))
			{
				Engine.SCALE = 4;
				Engine.IMG_BASE = "4x";
			}
			
			else if(larger >= x3 && smaller >= y3 && scales.exists(Scale._3X))
			{
				Engine.SCALE = 3;
				Engine.IMG_BASE = "3x";
			}
			
			else if(larger >= x2 && smaller >= y2 && scales.exists(Scale._2X))
			{
				Engine.SCALE = 2;
				Engine.IMG_BASE = "2x";
			}
			
			#if(android || flash || desktop)
			else if(larger >= x15 && smaller >= y15 && scales.exists(Scale._1_5X))
			{
				Engine.SCALE = 1.5;
				Engine.IMG_BASE = "1.5x";
			}
			#end
			
			else
			{
				Engine.SCALE = 1;
				Engine.IMG_BASE = "1x";
			}
			
			trace("Theoretical Scale: " + theoreticalScale);
		}
		#end
		
		#if(!mobile)
		if(!isFullScreen)
		{
			Engine.SCALE = Config.gameScale;
			Engine.IMG_BASE = Config.gameImageBase;
		}
		#end

		trace("Max Scale: " + Config.maxScale);
		trace("Engine Scale: " + Engine.IMG_BASE);

		var originalWidth = Config.stageWidth;
		var originalHeight = Config.stageHeight;
		
		Config.stageWidth = Std.int(Config.stageWidth * Config.gameScale * Engine.SCALE);
		Config.stageHeight = Std.int(Config.stageHeight * Config.gameScale * Engine.SCALE);

		#if(flash || mobile || desktop)
		if(!skipScaling)
		{
			//Stretch To Fit
			if(Config.scaleMode == ScaleMode.STRETCH_TO_FIT)
			{
				scaleX *= stageWidth / Config.stageWidth;
				scaleY *= stageHeight / Config.stageHeight;
				
				trace("Algorithm: Stretch to Fit");
			}
		
			//Full Screen Mode
			else if(Config.scaleMode == ScaleMode.FULLSCREEN)
			{
				//Max Scale: set the scale to what it would have been
				if(Config.maxScale < theoreticalScale)
				{
					scaleX = theoreticalScale;
					scaleY = theoreticalScale;
					stageWidth = Std.int(stageWidth / theoreticalScale);
					stageHeight = Std.int(stageHeight / theoreticalScale);
				}
				
				Config.stageWidth = stageWidth;
				Config.stageHeight = stageHeight;
					
				originalWidth = Std.int(stageWidth / Engine.SCALE);
				originalHeight = Std.int(stageHeight / Engine.SCALE);
				
				trace("Algorithm: Full Screen");
				stageWidth = Std.int(stageWidth / theoreticalScale);
				stageHeight = Std.int(stageHeight / theoreticalScale);
			}
			
			else
			{
				var screenW = Std.int(Capabilities.screenResolutionX);
				var screenH = Std.int(Capabilities.screenResolutionY);
				
				if(screenW < screenH && Config.landscape)
				{
					screenH = Std.int(Capabilities.screenResolutionX);
					screenW = Std.int(Capabilities.screenResolutionY);
				}
				
				var screenLandscape = Capabilities.screenResolutionX > Capabilities.screenResolutionY;
				
				trace(screenW);
				trace(screenH);
				trace(screenLandscape);
				
				//Scale to Fit: Letterboxed
				if(Config.scaleMode == ScaleMode.SCALE_TO_FIT_LETTERBOX)
				{
					scaleX = Math.min(stageWidth*Config.gameScale / Config.stageWidth, stageHeight*Config.gameScale / Config.stageHeight);
					scaleY = scaleX;
					
					Config.stageWidth = Std.int(Config.stageWidth/Config.gameScale);
					Config.stageHeight = Std.int(Config.stageHeight/Config.gameScale);
					
					trace("Algorithm: Scale to Fit (Letterbox)");
				}
				
				//Scale to Fit: Fill/Cropped
				else if(Config.scaleMode == ScaleMode.SCALE_TO_FIT_FILL)
				{
					scaleX *= Math.max(stageWidth / Config.stageWidth, stageHeight / Config.stageHeight);
					scaleY = scaleX;
					
					Config.stageWidth = Std.int(Config.stageWidth/Config.gameScale);
					Config.stageHeight = Std.int(Config.stageHeight/Config.gameScale);
					
					trace("Algorithm: Scale to Fit (Fill)");
				}
				
				//Scale to Fit: Full Screen
				else if(Config.scaleMode == ScaleMode.SCALE_TO_FIT_FULLSCREEN)
				{
					scaleX *= Math.min(stageWidth / Config.stageWidth, stageHeight / Config.stageHeight);
					scaleY = scaleX;
					
					trace("Algorithm: Scale to Fit (Full Screen)");
							
					originalWidth = Std.int(stageWidth / (Engine.SCALE * scaleY));
					originalHeight = Std.int(stageHeight / (Engine.SCALE * scaleX));
					
					Config.stageWidth = Std.int(stageWidth/scaleX);
					Config.stageHeight = Std.int(stageHeight/scaleY);
					
					stageWidth = Std.int(stageWidth / theoreticalScale);
					stageHeight = Std.int(stageHeight / theoreticalScale);
		                      
				}
				
				//"No Scaling" (Only integer scales)
				else
				{
					scaleX = Math.max(1, Std.int(Math.min(stageWidth*Config.gameScale / Config.stageWidth, stageHeight*Config.gameScale / Config.stageHeight)));
					scaleY = scaleX;

					Config.stageWidth = Std.int(Config.stageWidth/Config.gameScale);
					Config.stageHeight = Std.int(Config.stageHeight/Config.gameScale);					
					
					trace("Algorithm: No Scaling (Integer Scaling)");
				}
				
				if(Config.scaleMode != ScaleMode.SCALE_TO_FIT_FULLSCREEN)
				{
					x += (stageWidth - Config.stageWidth * scaleX)/2;
					y += (stageHeight - Config.stageHeight * scaleY)/2;
				}
			}
		}
		#end
		
		//Clip the view
		#if(mobile)
		if(Config.scaleMode != ScaleMode.FULLSCREEN && Config.scaleMode != ScaleMode.STRETCH_TO_FIT)
		{
			scrollRect = new openfl.geom.Rectangle(0, 0, Config.stageWidth, Config.stageHeight);
		}
		#end
		
		#if(flash || js || (cpp && !mobile))
		scrollRect = new openfl.geom.Rectangle(0, 0, Config.stageWidth, Config.stageHeight);
		#end
		
		Config.stageWidth = originalWidth;
		Config.stageHeight = originalHeight;

		trace("Scale X: " + scaleX);
		trace("Scale Y: " + scaleY);
	}

	@:access(openfl.display.Stage)
	public function preloaderComplete():Void
	{
		#if flash
		
		new Engine(this);
		
		#else
		
		try {
			
			new Engine(this);
			
		} catch (e:Dynamic) {
			
			stage.__handleError (e);
			
		}
		
		stage.dispatchEvent (new openfl.events.Event (openfl.events.Event.RESIZE, false, false));
		
		if (stage.window.fullscreen) {
			
			stage.dispatchEvent (new openfl.events.FullScreenEvent (openfl.events.FullScreenEvent.FULL_SCREEN, false, false, true, true));
			
		}

		#end
	}
}
