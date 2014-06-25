package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.ui.Keyboard;
import nme.events.KeyboardEvent;
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
			#if (flash9 || flash10)
        	haxe.Log.trace = function(v,?pos) { untyped __global__["trace"]("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"):",v); }
        	#else
       		haxe.Log.trace = function(v,?pos) { flash.Lib.trace("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"): "+v); }
        	#end
		}
		#end

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	private function onAdded(event:Event):Void 
	{
		init();	
	}
	
	public function init()
	{        
        initServices();
        
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		if(scripts.MyAssets.startInFullScreen)
		{
			Lib.current.stage.displayState = nme.display.StageDisplayState.FULL_SCREEN_INTERACTIVE;
			initScreen(true);
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 2);
		}
		
		else
		{
			initScreen();
		}
		
		new com.stencyl.Engine(this);
	}
	
	private function onKeyDown(e:KeyboardEvent = null)
	{
		if(e.keyCode == Keyboard.ESCAPE)
		{
			Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			nme.system.System.exit(0);
		}
	}
	
	public function initServices()
	{
		//Mochi, Newgrounds and other APIs
		
		#if(mobile)
		Ads.initialize(scripts.MyAssets.whirlID);
		#end
		
		#if(flash)
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
	}
	
	//isFullScreen is used on Web/Desktop for full screen mode
	public function initScreen(isFullScreen:Bool = false)
	{
		com.stencyl.Engine.stage = Lib.current.stage;
	
		var skipScaling = false;
		var stageWidth = stage.stageWidth;
		var stageHeight = stage.stageHeight;
		
		#if desktop
		if(isFullScreen)
		{
			stageWidth = Std.int(nme.system.Capabilities.screenResolutionX);
			stageHeight = Std.int(nme.system.Capabilities.screenResolutionY);
		}
		
		else if(scripts.MyAssets.stageWidth != Lib.current.stage.stageWidth)
		{
			stageWidth = Lib.current.stage.stageWidth;
			stageHeight = Lib.current.stage.stageHeight;
			isFullScreen = true;
		}
		
		else
		{
			skipScaling = true;
		}
		#end
		
		#if flash
		if(isFullScreen || scripts.MyAssets.gameScale > scripts.MyAssets.maxScale)
		{
			stageWidth = Lib.current.stage.stageWidth;
			stageHeight = Lib.current.stage.stageHeight;
			isFullScreen = true;
		}
		
		else
		{
			skipScaling = true;
		}
		#end
		
		//NME Bug: If waking from sleep, the dimensions can be flipped on Android.
		#if android
		stageWidth = Std.int(nme.system.Capabilities.screenResolutionX);
		stageHeight = Std.int(nme.system.Capabilities.screenResolutionY);
		
		if(stageWidth < stageHeight && scripts.MyAssets.landscape)
		{
			stageHeight = stage.stageWidth;
			stageWidth = stage.stageHeight;
		}
		#end
		
		//NME Bug: If waking from sleep, the dimensions can be flipped on iOS.
		#if (mobile && !android)
		stageWidth = Std.int(nme.system.Capabilities.screenResolutionX);
		stageHeight = Std.int(nme.system.Capabilities.screenResolutionY);
		
		if(stageWidth < stageHeight && scripts.MyAssets.landscape)
		{
			var temp = stageHeight;
			stageHeight = stageWidth;
			stageWidth = temp;
		}
		#end

		trace("Stage Width: " + scripts.MyAssets.stageWidth);
		trace("Stage Height: " + scripts.MyAssets.stageHeight);
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
			widescreen = aspectRatio > 1.5;
			
			//Scale to fit algorithms reverse on widescreen setups.
			if(widescreen)
			{
				if(scripts.MyAssets.scaleToFit1)
				{
					scripts.MyAssets.scaleToFit1 = false;
					scripts.MyAssets.scaleToFit2 = true;
				}
				
				else if(scripts.MyAssets.scaleToFit2)
				{
					scripts.MyAssets.scaleToFit1 = true;
					scripts.MyAssets.scaleToFit2 = false;
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
			
			//Generalized this from 320 x 480 to work with any resolution
			var x1 = scripts.MyAssets.stageWidth;
			var y1 = scripts.MyAssets.stageHeight;
			
			//TODO: Draw from the game's width/height instead. Games not close to 480x320 may act differently than expected.
			//Can't do today because editor doesn't pass this info in full screen mode.
			if(x1 == -1 || y1 == -1)
			{
				x1 = 480;
				y1 = 320;
			}
			
			else if(!scripts.MyAssets.landscape)
			{
				var temp = x1;
				x1 = y1;
				y1 = temp;
			}
			
			var x15 = x1 * 3 / 2;
			var y15 = y1 * 3 / 2;
			
			var x2 = x1 * 2;
			var y2 = y1 * 2;
			
			var x4 = x2 * 2;
			var y4 = y2 * 2;
	
			if(larger >= x4 && smaller >= y4)
			{
				theoreticalScale = 4;
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
			if(larger >= x4 && smaller >= y4 && scripts.MyAssets.maxScale >= 4)
			{
				Engine.SCALE = 4;
				Engine.IMG_BASE = "4x";
			}
			
			else if(larger >= x2 && smaller >= y2 && scripts.MyAssets.maxScale >= 2)
			{
				Engine.SCALE = 2;
				Engine.IMG_BASE = "2x";
			}
			
			#if(android || flash || desktop)
			else if(larger >= x15 && smaller >= y15 && scripts.MyAssets.maxScale >= 1.5)
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
			Engine.SCALE = scripts.MyAssets.gameScale;
			Engine.IMG_BASE = scripts.MyAssets.gameImageBase;
		}
		#end

		trace("Max Scale: " + scripts.MyAssets.maxScale);
		trace("Engine Scale: " + Engine.IMG_BASE);

		var originalWidth = scripts.MyAssets.stageWidth;
		var originalHeight = scripts.MyAssets.stageHeight;
		
		scripts.MyAssets.stageWidth = Std.int(scripts.MyAssets.stageWidth * Engine.SCALE);
		scripts.MyAssets.stageHeight = Std.int(scripts.MyAssets.stageHeight * Engine.SCALE);

		var usingFullScreen = false;
		var stretchToFit = false;
		
		//Stretch To Fit
		#if(flash || mobile || desktop)
		if(!skipScaling)
		{
			if(scripts.MyAssets.stretchToFit)
			{
				stretchToFit = true;
				
				scaleX *= stageWidth / scripts.MyAssets.stageWidth;
				scaleY *= stageHeight / scripts.MyAssets.stageHeight;
				
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
				if(scripts.MyAssets.maxScale < theoreticalScale)
				{
					scaleX = theoreticalScale;
					scaleY = theoreticalScale;
					stageWidth = Std.int(stageWidth / theoreticalScale);
					stageHeight = Std.int(stageHeight / theoreticalScale);
				}
				
				scripts.MyAssets.stageWidth = stageWidth;
				scripts.MyAssets.stageHeight = stageHeight;
					
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
				var screenW = Std.int(nme.system.Capabilities.screenResolutionX);
				var screenH = Std.int(nme.system.Capabilities.screenResolutionY);
				
				if(screenW < screenH && scripts.MyAssets.landscape)
				{
					screenH = Std.int(nme.system.Capabilities.screenResolutionX);
					screenW = Std.int(nme.system.Capabilities.screenResolutionY);
				}
				
				var screenLandscape = Lib.current.stage.width > Lib.current.stage.height;
				
				trace(screenW);
				trace(screenH);
				trace(screenLandscape);
				
				if(scripts.MyAssets.maxScale < 4)
				{
					//Scale to Fit: Letterboxed
					if(scripts.MyAssets.scaleToFit1)
					{
						if(scripts.MyAssets.landscape)
						{
							scaleX *= stageWidth / scripts.MyAssets.stageWidth;
							scaleY = scaleX;
						}
						
						else
						{
							scaleY = stageHeight / scripts.MyAssets.stageHeight;
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
					else if(scripts.MyAssets.scaleToFit2)
					{
						if(scripts.MyAssets.landscape)
						{
							scaleY = stageHeight / scripts.MyAssets.stageHeight;
							scaleX = scaleY;
						}
						
						else
						{
							scaleX *= stageWidth / scripts.MyAssets.stageWidth;
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
					else if(scripts.MyAssets.scaleToFit3)
					{
						if(scripts.MyAssets.landscape)
						{
							scaleY = stageHeight / scripts.MyAssets.stageHeight;
							
							//Height's scale causes width to spill over. Clamp to width instead.
							if(Lib.current.stage.width * Engine.SCALE * scaleY > screenW)
							{
								scaleY = stageWidth / scripts.MyAssets.stageWidth;
							}
							
							scaleX = scaleY;
						}
						
						else
						{
							scaleX = stageWidth / scripts.MyAssets.stageWidth;
							
							//Width's scale causes width to spill over. Clamp to height instead.
							if(Lib.current.stage.height * Engine.SCALE * scaleX > screenH)
							{
								scaleX = stageHeight / scripts.MyAssets.stageHeight;
							}
							
							scaleY = scaleX;
						}
						
						trace("Algorithm: Scale to Fit (Full Screen)");
						
						scripts.MyAssets.stageWidth = stageWidth;
                        scripts.MyAssets.stageHeight = stageHeight;
					
                        originalWidth = Std.int(stageWidth / (Engine.SCALE * scaleY));
                        originalHeight = Std.int(stageHeight / (Engine.SCALE * scaleX));

                        stageWidth = Std.int(stageWidth / theoreticalScale);
                        stageHeight = Std.int(stageHeight / theoreticalScale);
					}
					
					//"No Scaling" (Only integer scales)
					else
					{
						if(scripts.MyAssets.landscape)
						{
							scaleX *= Std.int(stageWidth / scripts.MyAssets.stageWidth);
							scaleY = scaleX;
						}
						
						else
						{
							scaleY = Std.int(stageHeight / scripts.MyAssets.stageHeight);
							scaleX = scaleY;
						}
						
						trace("Algorithm: No Scaling (Integer Scaling)");
					}
				}
				
				//TODO: I think the above and below are identical, clean this up later.
				else
				{
					//Scale to Fit: Letterboxed
					if(scripts.MyAssets.scaleToFit1)
					{
						if(scripts.MyAssets.landscape)
						{
							scaleX *= stageWidth / scripts.MyAssets.stageWidth;
							scaleY = scaleX;
						}
						
						else
						{
							scaleY = stageHeight / scripts.MyAssets.stageHeight;
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
					else if(scripts.MyAssets.scaleToFit2)
					{
						if(scripts.MyAssets.landscape)
						{
							scaleY = stageHeight / scripts.MyAssets.stageHeight;
							scaleX = scaleY;
						}
						
						else
						{
							scaleX *= stageWidth / scripts.MyAssets.stageWidth;
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
					else if(scripts.MyAssets.scaleToFit3)
					{
						if(scripts.MyAssets.landscape)
						{
							scaleY = stageHeight / scripts.MyAssets.stageHeight;
							
							//Height's scale causes width to spill over. Clamp to width instead.
							if(Lib.current.stage.width * scaleY > screenW)
							{
								scaleY = stageWidth / scripts.MyAssets.stageWidth;
							}
							
							scaleX = scaleY;
						}
						
						else
						{
							scaleX = stageWidth / scripts.MyAssets.stageWidth;
							
							//Width's scale causes width to spill over. Clamp to height instead.
							if(Lib.current.stage.height * scaleX > screenH)
							{
								scaleX = stageHeight / scripts.MyAssets.stageHeight;
							}
							
							scaleY = scaleX;
						}
						
						trace("Algorithm: Scale to Fit (Full Screen)");
						
						scripts.MyAssets.stageWidth = stageWidth;
                        scripts.MyAssets.stageHeight = stageHeight;
					
                        originalWidth = Std.int(stageWidth / (Engine.SCALE * scaleY));
                        originalHeight = Std.int(stageHeight / (Engine.SCALE * scaleX));

                        stageWidth = Std.int(stageWidth / theoreticalScale);
                        stageHeight = Std.int(stageHeight / theoreticalScale);
					}
					
					//"No Scaling" (Only integer scales)
					else
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
						
						trace("Algorithm: No Scaling (Integer Scaling)");
					}
				}
				
				if(scripts.MyAssets.scaleToFit3)
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
					x += (stageWidth - scripts.MyAssets.stageWidth * scaleX)/2;
					y += (stageHeight - scripts.MyAssets.stageHeight * scaleY)/2;
				}
			}
		}
		#end
		
		//Clip the view
		#if(mobile)
		if(!usingFullScreen && !stretchToFit)
		{
			scrollRect = new nme.geom.Rectangle(0, 0, scripts.MyAssets.stageWidth, scripts.MyAssets.stageHeight);
		}
		#end
		
		#if(flash || js || (cpp && !mobile))
		scrollRect = new nme.geom.Rectangle(0, 0, scripts.MyAssets.stageWidth, scripts.MyAssets.stageHeight);
		#end
		
		scripts.MyAssets.stageWidth = originalWidth;
		scripts.MyAssets.stageHeight = originalHeight;
		
		trace("Scale X: " + scaleX);
		trace("Scale Y: " + scaleY);
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
