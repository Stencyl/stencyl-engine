package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.StageDisplayState;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.system.Capabilities;
import openfl.ui.Keyboard;

#if flash
import flash.events.UncaughtErrorEvent;
import flash.events.ErrorEvent;
import flash.errors.Error;
#end

import com.stencyl.Engine;

import scripts.MyAssets;

class Universal extends Sprite 
{
	public function new() 
	{
		super();

		#if flash
		if(!MyAssets.releaseMode)
		{
			#if (flash9 || flash10)
        	haxe.Log.trace = function(v,?pos) { untyped __global__["trace"]("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"):",v); }
        	#else
       		haxe.Log.trace = function(v,?pos) { flash.Lib.trace("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"): "+v); }
        	#end
        	
        	Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		#end

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	#if flash
	function uncaughtErrorHandler(event:UncaughtErrorEvent):Void
	{
		if (Std.is(event.error, Error))
		{
			trace(cast(event.error, Error).message);
		}
		else if (Std.is(event.error,ErrorEvent))
		{
			trace(cast(event.error, ErrorEvent).text);
		}
		else
		{
			trace(event.error.toString());
		}
	}
	#end
	
	private function onAdded(event:Event):Void 
	{
		init();	
	}
	
	public function init()
	{        
        initServices();
        
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		if(MyAssets.startInFullScreen)
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			initScreen(true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 2);
		}
		
		else
		{
			initScreen();
		}
		
		new Engine(this);
	}
	
	private function onKeyDown(e:KeyboardEvent = null)
	{
		/*if(e.keyCode == Keyboard.ESCAPE)
		{
			Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			openfl.system.System.exit(0);
		}*/
	}
	
	public function initServices()
	{
		//Newgrounds and other APIs
		
		#if(mobile)
		Ads.initialize(MyAssets.whirlID);
		#end
		
		#if(flash)
		var newgroundsID = MyAssets.newgroundsID;
		var newgroundsKey = MyAssets.newgroundsKey;
		
		if(newgroundsID != "")
        {
        	com.newgrounds.API.API.connect(root, newgroundsID, newgroundsKey);
        }
        
        #end
	}
	
	//isFullScreen is used on Web/Desktop for full screen mode
	public function initScreen(isFullScreen:Bool = false)
	{
		Lib.current.x = 0;
		Lib.current.y = 0;
		Lib.current.scaleX = 1;
		Lib.current.scaleY = 1;
		
		Engine.stage = stage;

		var skipScaling = false;
		var stageWidth = stage.stageWidth;
		var stageHeight = stage.stageHeight;
		
		#if desktop
		if(isFullScreen)
		{
			stageWidth = Std.int(Capabilities.screenResolutionX);
			stageHeight = Std.int(Capabilities.screenResolutionY);
		}
		
		else if(MyAssets.stageWidth != stage.stageWidth)
		{
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			isFullScreen = true;
		}
		
		else
		{
			skipScaling = true;
		}
		#end
		
		#if flash
		if(isFullScreen || MyAssets.gameScale > MyAssets.maxScale)
		{
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
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
		
		if(stageWidth < stageHeight && MyAssets.landscape)
		{
			stageHeight = stage.stageWidth;
			stageWidth = stage.stageHeight;
		}
		#end
		
		//NME Bug: If waking from sleep, the dimensions can be flipped on iOS.
		#if (mobile && !android)
		
		stageWidth = Std.int(Capabilities.screenResolutionX);
		stageHeight = Std.int(Capabilities.screenResolutionY);
		
		if(stageWidth < stageHeight && MyAssets.landscape)
		{
			var temp = stageHeight;
			stageHeight = stageWidth;
			stageWidth = temp;
		}
		#end

		trace("Stage Width: " + MyAssets.stageWidth);
		trace("Stage Height: " + MyAssets.stageHeight);
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
			widescreen = aspectRatio > (Math.max(MyAssets.stageWidth, MyAssets.stageHeight) / Math.min(MyAssets.stageWidth, MyAssets.stageHeight));
			
			//Scale to fit algorithms reverse on widescreen setups.
			if(widescreen)
			{
				if(MyAssets.scaleToFit1)
				{
					MyAssets.scaleToFit1 = false;
					MyAssets.scaleToFit2 = true;
				}
				
				else if(MyAssets.scaleToFit2)
				{
					MyAssets.scaleToFit1 = true;
					MyAssets.scaleToFit2 = false;
				}
				
				trace("Widescreen (Aspect Ratio > 1.5)");
			}
			
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
			var x1 = MyAssets.stageWidth;
			var y1 = MyAssets.stageHeight;
			
			//TODO: Draw from the game's width/height instead. Games not close to 480x320 may act differently than expected.
			//Can't do today because editor doesn't pass this info in full screen mode.
			if(x1 == -1 || y1 == -1)
			{
				x1 = 480;
				y1 = 320;
			}
			
			else if(!MyAssets.landscape)
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
			if(larger >= x4 && smaller >= y4 && MyAssets.maxScale >= 4)
			{
				Engine.SCALE = 4;
				Engine.IMG_BASE = "4x";
			}
			
			else if(larger >= x3 && smaller >= y3 && MyAssets.maxScale >= 3)
			{
				Engine.SCALE = 3;
				Engine.IMG_BASE = "3x";
			}
			
			else if(larger >= x2 && smaller >= y2 && MyAssets.maxScale >= 2)
			{
				Engine.SCALE = 2;
				Engine.IMG_BASE = "2x";
			}
			
			#if(android || flash || desktop)
			else if(larger >= x15 && smaller >= y15 && MyAssets.maxScale >= 1.5)
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
			Engine.SCALE = MyAssets.gameScale;
			Engine.IMG_BASE = MyAssets.gameImageBase;
		}
		#end

		trace("Max Scale: " + MyAssets.maxScale);
		trace("Engine Scale: " + Engine.IMG_BASE);

		var originalWidth = MyAssets.stageWidth;
		var originalHeight = MyAssets.stageHeight;
		
		MyAssets.stageWidth = Std.int(MyAssets.stageWidth * Engine.SCALE);
		MyAssets.stageHeight = Std.int(MyAssets.stageHeight * Engine.SCALE);

		var usingFullScreen = false;
		var stretchToFit = false;
		
		//Stretch To Fit
		#if(flash || mobile || desktop)
		if(!skipScaling)
		{
			if(MyAssets.stretchToFit)
			{
				stretchToFit = true;
				
				scaleX *= stageWidth / MyAssets.stageWidth;
				scaleY *= stageHeight / MyAssets.stageHeight;
				
				trace("Algorithm: Stretch to Fit");
			}
		}
		#end
		
		//Full Screen Mode
		#if(flash || mobile || desktop)
		if(!skipScaling)
		{
			if(originalWidth == -1 || originalHeight == -1)
			{					
				//Max Scale: set the scale to what it would have been
				if(MyAssets.maxScale < theoreticalScale)
				{
					scaleX = theoreticalScale;
					scaleY = theoreticalScale;
					stageWidth = Std.int(stageWidth / theoreticalScale);
					stageHeight = Std.int(stageHeight / theoreticalScale);
				}
				
				MyAssets.stageWidth = stageWidth;
				MyAssets.stageHeight = stageHeight;
					
				originalWidth = Std.int(stageWidth / Engine.SCALE);
				originalHeight = Std.int(stageHeight / Engine.SCALE);
				
				usingFullScreen = true;
				
				trace("Algorithm: Full Screen");
				stageWidth = Std.int(stageWidth / theoreticalScale);
				stageHeight = Std.int(stageHeight / theoreticalScale);
			}
		}
		#end
	
		#if(flash || mobile || desktop)
		if(!skipScaling)
		{
			if(!usingFullScreen && !stretchToFit)
			{
				var screenW = Std.int(Capabilities.screenResolutionX);
				var screenH = Std.int(Capabilities.screenResolutionY);
				
				if(screenW < screenH && MyAssets.landscape)
				{
					screenH = Std.int(Capabilities.screenResolutionX);
					screenW = Std.int(Capabilities.screenResolutionY);
				}
				
				var screenLandscape = Capabilities.screenResolutionX > Capabilities.screenResolutionY;
				
				trace(screenW);
				trace(screenH);
				trace(screenLandscape);
				
				if(MyAssets.maxScale < 4)
				{
					//Scale to Fit: Letterboxed
					if(MyAssets.scaleToFit1)
					{
						if(MyAssets.landscape)
						{
							scaleX *= stageWidth / MyAssets.stageWidth;
							scaleY = scaleX;
						}
						
						else
						{
							scaleY = stageHeight / MyAssets.stageHeight;
							scaleX = scaleY;
						}
						
						if(widescreen || (screenLandscape && screenW < screenH) || (!screenLandscape && screenW > screenH))
						{
							trace("Algorithm: Scale to Fit (Fill)");
						}
						
						else
						{
							trace("Algorithm: Scale to Fit (Letterbox)");
						}
					}
					
					//Scale to Fit: Fill/Cropped
					else if(MyAssets.scaleToFit2)
					{
						if(MyAssets.landscape)
						{
							scaleY = stageHeight / MyAssets.stageHeight;
							scaleX = scaleY;
						}
						
						else
						{
							scaleX *= stageWidth / MyAssets.stageWidth;
							scaleY = scaleX;
						}
						
						if(widescreen || (screenLandscape && screenW < screenH) || (!screenLandscape && screenW > screenH))
						{
							trace("Algorithm: Scale to Fit (Letterbox)");
						}
						
						else
						{
							trace("Algorithm: Scale to Fit (Fill)");
						}
					}
					
					//Scale to Fit: Full Screen
					else if(MyAssets.scaleToFit3)
					{
						if(MyAssets.landscape)
						{
							scaleY = stageHeight / MyAssets.stageHeight;
							
							//Height's scale causes width to spill over. Clamp to width instead.
							if(originalWidth * Engine.SCALE * scaleY > screenW)
							{
								scaleY = stageWidth / MyAssets.stageWidth;
							}
							
							scaleX = scaleY;
						}
						
						else
						{
							scaleX = stageWidth / MyAssets.stageWidth;
							
							//Width's scale causes width to spill over. Clamp to height instead.
							if(originalHeight * Engine.SCALE * scaleX > screenH)
							{
								scaleX = stageHeight / MyAssets.stageHeight;
							}
							
							scaleY = scaleX;
						}
						
						trace("Algorithm: Scale to Fit (Full Screen)");
						
						MyAssets.stageWidth = stageWidth;
                        MyAssets.stageHeight = stageHeight;
					
                        originalWidth = Std.int(stageWidth / (Engine.SCALE * scaleY));
                        originalHeight = Std.int(stageHeight / (Engine.SCALE * scaleX));

                        stageWidth = Std.int(stageWidth / theoreticalScale);
                        stageHeight = Std.int(stageHeight / theoreticalScale);
					}
					
					//"No Scaling" (Only integer scales)
					else
					{
						if(MyAssets.landscape)
						{
							scaleX *= Std.int(stageWidth / MyAssets.stageWidth);
							scaleY = scaleX;
						}
						
						else
						{
							scaleY = Std.int(stageHeight / MyAssets.stageHeight);
							scaleX = scaleY;
						}
	
						trace("Algorithm: No Scaling (Integer Scaling)");
					}
				}
				
				//TODO: I think the above and below are identical, clean this up later.
				else
				{
					//Scale to Fit: Letterboxed
					if(MyAssets.scaleToFit1)
					{
						if(MyAssets.landscape)
						{
							scaleX *= stageWidth / MyAssets.stageWidth;
							scaleY = scaleX;
						}
						
						else
						{
							scaleY = stageHeight / MyAssets.stageHeight;
							scaleX = scaleY;
						}
						
						if(widescreen || (screenLandscape && screenW < screenH) || (!screenLandscape && screenW > screenH))
						{
							trace("Algorithm: Scale to Fit (Fill)");
						}
						
						else
						{
							trace("Algorithm: Scale to Fit (Letterbox)");
						}
					}
					
					//Scale to Fit: Fill/Cropped
					else if(MyAssets.scaleToFit2)
					{
						if(MyAssets.landscape)
						{
							scaleY = stageHeight / MyAssets.stageHeight;
							scaleX = scaleY;
						}
						
						else
						{
							scaleX *= stageWidth / MyAssets.stageWidth;
							scaleY = scaleX;
						}
						
						if(widescreen || (screenLandscape && screenW < screenH) || (!screenLandscape && screenW > screenH))
						{
							trace("Algorithm: Scale to Fit (Letterbox)");
						}
						
						else
						{
							trace("Algorithm: Scale to Fit (Fill)");
						}
					}
					
					//Scale to Fit: Full Screen
					else if(MyAssets.scaleToFit3)
					{
						if(MyAssets.landscape)
						{
							scaleY = stageHeight / MyAssets.stageHeight;
							
							//Height's scale causes width to spill over. Clamp to width instead.
							if(originalWidth * Engine.SCALE * scaleY > screenW)
							{
								scaleY = stageWidth / MyAssets.stageWidth;
							}
							
							scaleX = scaleY;
						}
						
						else
						{
							scaleX = stageWidth / MyAssets.stageWidth;
							
							//Width's scale causes width to spill over. Clamp to height instead.
							if(originalHeight * Engine.SCALE * scaleX > screenH)
							{
								scaleX = stageHeight / MyAssets.stageHeight;
							}
							
							scaleY = scaleX;
						}
						
						trace("Algorithm: Scale to Fit (Full Screen)");
						
						MyAssets.stageWidth = stageWidth;
                        MyAssets.stageHeight = stageHeight;
					
                        originalWidth = Std.int(stageWidth / (Engine.SCALE * scaleY));
                        originalHeight = Std.int(stageHeight / (Engine.SCALE * scaleX));

                        stageWidth = Std.int(stageWidth / theoreticalScale);
                        stageHeight = Std.int(stageHeight / theoreticalScale);
					}
					
					//"No Scaling" (Only integer scales)
					else
					{
						//Is the game width > device width? Adjust scaleX, then scaleY.
						if(MyAssets.stageWidth > stageWidth)
						{
							scaleX *= stageWidth / MyAssets.stageWidth;
							scaleY = scaleX;
						}
						
						//If the game height * scaleY > device height? Adjust scaleY, then scaleX.
						if(MyAssets.stageHeight * scaleY > stageHeight)
						{
							scaleY = stageHeight / MyAssets.stageHeight;
							scaleX = scaleY;
						}
						
						trace("Algorithm: No Scaling (Integer Scaling)");
					}
				}
				
				if(MyAssets.scaleToFit3)
				{
					//Disabled - this defeats the purpose of full screen?
					//If the scaled game is less than the screen's size, we need to apply an offset to it.
					//For example, native res of (544 x 320) on an iPad (1024 x 768) will be (1088 x 640) at a 2x scale. It will sit high and have black space below.
					
					/*var realX = Lib.current.stage.width * (Engine.SCALE * scaleX);
					var realY = Lib.current.stage.height * (Engine.SCALE * scaleY);
					
					if(screenW > realX)
					{
						x += (screenW - realX) / 2;
						trace("Offset X by: " + ((screenW - realX) / 2));
					}
					
					if(screenH > realY)
					{
						y += (screenH - realY) / 2;
						trace("Offset Y by: " + ((screenH - realY) / 2));
					}*/
				}
				
				else
				{
					x += (stageWidth - MyAssets.stageWidth * scaleX)/2;
					y += (stageHeight - MyAssets.stageHeight * scaleY)/2;
				}
			}
		}
		#end
		
		//Clip the view
		#if(mobile)
		if(!usingFullScreen && !stretchToFit)
		{
			scrollRect = new openfl.geom.Rectangle(0, 0, MyAssets.stageWidth, MyAssets.stageHeight);
		}
		#end
		
		#if(flash || js || (cpp && !mobile))
		scrollRect = new openfl.geom.Rectangle(0, 0, MyAssets.stageWidth, MyAssets.stageHeight);
		#end
		
		MyAssets.stageWidth = originalWidth;
		MyAssets.stageHeight = originalHeight;

		trace("Scale X: " + scaleX);
		trace("Scale Y: " + scaleY);
	}
	
	#if (scriptable && openfl_legacy) @:access(openfl._legacy.Assets.initialized) #end
	public static function main() 
	{
		#if scriptable
		var cppia = Type.resolveClass("scripts.CppiaAssets");
		Reflect.callMethod(cppia, Reflect.field(cppia, "setAssets"), []);

		if(StencylCppia.gamePath != null)
			Sys.setCwd(StencylCppia.gamePath);

		openfl.Assets.registerLibrary("default", Type.createInstance(Type.resolveClass("CppiaAssetLibrary"), []));
		openfl.Assets.initialized = true;
		#end

		var stage = Lib.current.stage;
		
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		#if(mobile && !air)
		stage.opaqueBackground = 0x000000;
		#end

		Lib.current.addChild(new Universal());
	}
}
