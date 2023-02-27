package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.StageDisplayState;
import openfl.display.Shape;
import openfl.events.Event;
import lime.ui.Window;

import com.stencyl.Config;
import com.stencyl.Engine;
import com.stencyl.graphics.Scale;
import com.stencyl.graphics.ScaleMode;

class Universal extends Sprite 
{
	private static var window:Window;
	public static var logicalWidth = 0.0;
	public static var logicalHeight = 0.0;
	public static var windowWidth = 0.0;
	public static var windowHeight = 0.0;
	public static var leftInset = 0.0;
	public static var topInset = 0.0;
	public static var rightInset = 0.0;
	public static var bottomInset = 0.0;
	
	public var maskLayer:Shape;

	public static function initWindow(window:Window):Void
	{
		Universal.window = window;

		window.stage.align = StageAlign.TOP_LEFT;
		window.stage.scaleMode = StageScaleMode.NO_SCALE;
		
		#if mobile
		window.stage.opaqueBackground = 0x000000;
		#end
	}

	public function new() 
	{
		super();
		name = "Root";

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function onAdded(event:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		maskLayer = new Shape();
		maskLayer.name = "Mask Layer";
		initScreen(Config.startInFullScreen);
	}

	//isFullScreen is used on Web/Desktop for full screen mode
	#if (!flash) @:access(openfl.display.Stage.__setLogicalSize) #end
	public function initScreen(isFullScreen:Bool)
	{
		trace("initScreen");

		#if mobile
		isFullScreen = true;
		#end
		
		#if html5
		isFullScreen = false;
		#end

		stage.displayState = isFullScreen ?
			StageDisplayState.FULL_SCREEN_INTERACTIVE :
			StageDisplayState.NORMAL;
		
		#if !flash
		stage.__setLogicalSize (0, 0);
		#end
		
		#if desktop
		if(!isFullScreen)
		{
			window.resize(Std.int(Config.stageWidth * Config.gameScale), Std.int(Config.stageHeight * Config.gameScale));
		}
		#end

		Lib.current.x = 0;
		Lib.current.y = 0;
		Lib.current.scaleX = 1;
		Lib.current.scaleY = 1;

		x = 0;
		y = 0;
		scaleX = 1;
		scaleY = 1;
	
		Engine.stage = stage;

		//enabled scales
		var scales = new Map<Scale,Bool>();
		for(scale in Config.scales)
		{
			scales.set(scale, true);
		}

		windowWidth = isFullScreen ? stage.fullScreenWidth : Config.stageWidth * Config.gameScale;
		windowHeight = isFullScreen ? stage.fullScreenHeight : Config.stageHeight * Config.gameScale;

		trace("Game Width: " + Config.stageWidth);
		trace("Game Height: " + Config.stageHeight);
		trace("Game Scale: " + Config.gameScale);
		trace("Window Width: " + windowWidth);
		trace("Window Height: " + windowHeight);
		trace("FullScreen Width: " + stage.fullScreenWidth);
		trace("FullScreen Height: " + stage.fullScreenHeight);
		trace("Device Pixel Ratio: " + stage.window.scale);
		trace("Enabled Scales: " + Config.scales);
		trace("Scale Mode: " + Config.scaleMode);
		
		var theoreticalWindowedScale = getDesiredScale(windowWidth, windowHeight, Config.stageWidth, Config.stageHeight);
		var theoreticalFullscreenScale = getDesiredScale(stage.fullScreenWidth, stage.fullScreenHeight, Config.stageWidth, Config.stageHeight);
		
		var theoreticalScale = Config.forceHiResAssets ? theoreticalFullscreenScale : theoreticalWindowedScale;
		
		//4 scale scheme
		if(theoreticalScale == 4 && scales.exists(Scale._4X))
		{
			Engine.SCALE = 4;
			Engine.IMG_BASE = "4x";
		}
		
		else if(theoreticalScale >= 3 && scales.exists(Scale._3X))
		{
			Engine.SCALE = 3;
			Engine.IMG_BASE = "3x";
		}
		
		else if(theoreticalScale >= 2 && scales.exists(Scale._2X))
		{
			Engine.SCALE = 2;
			Engine.IMG_BASE = "2x";
		}
		
		else if(theoreticalScale >= 1.5 && scales.exists(Scale._1_5X))
		{
			Engine.SCALE = 1.5;
			Engine.IMG_BASE = "1.5x";
		}
		
		else
		{
			Engine.SCALE = 1;
			Engine.IMG_BASE = "1x";
		}
		
		trace("Theoretical Scale: " + theoreticalScale);
		trace("Asset Scale: " + Engine.IMG_BASE);

		//the dimensions of the game screen after being scaled up
		//to the proper asset size.
		var scaledStageWidth = Config.stageWidth * Engine.SCALE;
		var scaledStageHeight = Config.stageHeight * Engine.SCALE;

		//the remaining x/y scale needed to fit the game screen
		//to the edges of the window.
		var fitWidthScale = windowWidth / scaledStageWidth;
		var fitHeightScale = windowHeight / scaledStageHeight;

		if(Config.forceHiResAssets || windowWidth != Config.stageWidth || windowHeight != Config.stageHeight)
		{
			//after the basic assets scale, how do we fill out the rest of the screen?

			//expand the playable area rather than further scaling it
			if(Config.scaleMode == ScaleMode.FULLSCREEN)
			{
				if(Engine.SCALE != theoreticalWindowedScale)
				{
					scaleX = theoreticalWindowedScale / Engine.SCALE;
					scaleY = scaleX;
				}

				//don't do anything
				//stage width/height are already the size of the screen
			}

			//exactly match the game size to the window size for both width and height
			else if(Config.scaleMode == ScaleMode.STRETCH_TO_FIT)
			{
				scaleX = fitWidthScale;
				scaleY = fitHeightScale;
			}
			
			//keeping aspect ration, stretch until either side of the game screen touches the window's edge
			//for "Scale to fit (fullscreen)", the rest of the space is expanded
			else if(Config.scaleMode == ScaleMode.SCALE_TO_FIT_LETTERBOX || Config.scaleMode == ScaleMode.SCALE_TO_FIT_FULLSCREEN)
			{
				scaleX = Math.min(fitWidthScale, fitHeightScale);
				scaleY = scaleX;
			}
			
			//keeping aspect ration, stretch until both sides of the game screen touch the window's edge
			else if(Config.scaleMode == ScaleMode.SCALE_TO_FIT_FILL)
			{
				scaleX = Math.max(fitWidthScale, fitHeightScale);
				scaleY = scaleX;
			}
			
			//no additional scaling
			else if(Config.scaleMode == ScaleMode.NO_SCALING)
			{
				if(Engine.SCALE != theoreticalWindowedScale)
				{
					scaleX = theoreticalWindowedScale / Engine.SCALE;
					scaleY = scaleX;
				}
			}

			if(Config.scaleMode != ScaleMode.SCALE_TO_FIT_FULLSCREEN && Config.scaleMode != ScaleMode.FULLSCREEN)
			{
				x += (windowWidth - scaledStageWidth * scaleX) / 2;
				y += (windowHeight - scaledStageHeight * scaleY) / 2;
			}
		}

		logicalWidth = Config.stageWidth;
		logicalHeight = Config.stageHeight;

		if(isFullScreen && (Config.scaleMode == ScaleMode.SCALE_TO_FIT_FULLSCREEN || Config.scaleMode == ScaleMode.FULLSCREEN))
		{
			logicalWidth = (windowWidth / scaleX) / Engine.SCALE;
			logicalHeight = (windowHeight / scaleY) / Engine.SCALE;

			//bring logical size to the nearest full pixel of the desired value.

			if(Std.int(logicalWidth) != logicalWidth || Std.int(logicalHeight) != logicalHeight)
			{
				logicalWidth = Std.int(logicalWidth);
				logicalHeight = Std.int(logicalHeight);

				scaleX = windowWidth / Engine.SCALE / logicalWidth;
				scaleY = windowHeight / Engine.SCALE / logicalHeight;
			}
		}
		
		Engine.screenScaleX = scaleX;
		Engine.screenScaleY = scaleY;

		#if mobile
		var insets = com.stencyl.native.Native.getSafeInsets();
		leftInset = insets.x;
		rightInset = insets.width;
		topInset = insets.y;
		bottomInset = insets.height;
		trace('Safe Area Insets: original = (left: $leftInset, top: $topInset, right: $rightInset, bottom: $bottomInset)');

		if(Config.autorotate)
		{
			/*
			TODO: We don't have a way to notify Stencyl of orientation changes at the moment.
			Eventually, we should have lime listen for and pass on SDL's display events, including
			the orientation one.

			For now, to assure the safe areas are actually safe, we'll mirror the
			max inset along an axis to both sides.
			*/

			leftInset = rightInset = Math.max(leftInset, rightInset);
			topInset = bottomInset = Math.max(topInset, bottomInset);
			trace('Safe Area Insets: mirrored = (left: $leftInset, top: $topInset, right: $rightInset, bottom: $bottomInset)');
		}
		
		if(x != 0 || y != 0)
		{
			// we don't need to inset if we're letterboxing over the inset area.
			leftInset = Math.max(0, leftInset - x);
			rightInset = Math.max(0, rightInset - x);
			topInset = Math.max(0, topInset - y);
			bottomInset = Math.max(0, bottomInset - y);
			trace('Safe Area Insets: offset = (left: $leftInset, top: $topInset, right: $rightInset, bottom: $bottomInset)');
		}
		
		// scale to Stencyl's logical coordinates
		leftInset = Math.ceil(leftInset / (Engine.SCALE * scaleX));
		rightInset = Math.ceil(rightInset / (Engine.SCALE * scaleX));
		topInset = Math.ceil(topInset / (Engine.SCALE * scaleY));
		bottomInset = Math.ceil(bottomInset / (Engine.SCALE * scaleY));

		trace('Safe Area Insets: scaled = (left: $leftInset, top: $topInset, right: $rightInset, bottom: $bottomInset)');

		#end
		
		maskLayer.graphics.clear();
		if(isFullScreen && (Config.scaleMode == ScaleMode.SCALE_TO_FIT_LETTERBOX || Config.scaleMode == ScaleMode.NO_SCALING))
		{
			//maskLayer is added as a child of Universal later,
			//so it needs to counteract Universal's scaleX/scaleY.
			var drawX = x / scaleX;
			var drawY = y / scaleY;
			var drawWindowWidth = windowWidth / scaleX;
			maskLayer.graphics.beginFill(stage.color);
			maskLayer.graphics.drawRect(-drawX, -drawY, drawWindowWidth, drawY);
			maskLayer.graphics.drawRect(-drawX, 0, drawX, scaledStageHeight);
			maskLayer.graphics.drawRect(scaledStageWidth, 0, drawX, scaledStageHeight);
			maskLayer.graphics.drawRect(-drawX, scaledStageHeight, drawWindowWidth, drawY);
			maskLayer.graphics.endFill();
		}
		
		trace("Logical Width: " + logicalWidth);
		trace("Logical Height: " + logicalHeight);
		trace("Scale X: " + scaleX);
		trace("Scale Y: " + scaleY);
	}
	
	private function getDesiredScale(checkWidth:Float, checkHeight:Float, baseWidth:Int, baseHeight:Int):Float
	{
		var x1 = baseWidth;
		var y1 = baseHeight;
		
		var x2 = x1 * 2;
		var y2 = y1 * 2;
		
		var x3 = x1 * 3;
		var y3 = y1 * 3;
		
		var x4 = x2 * 2;
		var y4 = y2 * 2;
		
		var x15 = x3 / 2;
		var y15 = y3 / 2;
		
		
		if(checkWidth >= x4 && checkHeight >= y4)
		{
			return 4;
		}
		
		else if(checkWidth >= x3 && checkHeight >= y3)
		{
			return 3;
		}
		
		else if(checkWidth >= x2 && checkHeight >= y2)
		{
			return 2;
		}
		
		else if(checkWidth >= x15 && checkHeight >= y15)
		{
			return 1.5;
		}
		
		else
		{
			return 1;
		}
	}
}
