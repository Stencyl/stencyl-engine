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
		com.nmefermmmtools.debug.Console.create(true, 192, false);
		
		//MochiServices.connect("60347b2977273733", root);
		//MochiAd.showPreGameAd( { id:"60347b2977273733", res:"640x580", clip: root});
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
		/*if(stage.stageWidth >= 800 || stage.stageHeight >= 800)
		{
			Engine.SCALE = 2;
			Engine.IMG_BASE = "2x";
		}
		
		else
		{
			Engine.SCALE = 1;
			Engine.IMG_BASE = "1x";
		}*/
		#end
		
		//NOTICE FOR DEVELOPERS
		#if (!mobile)
		//Engine.SCALE = 2;
		//Engine.IMG_BASE = "2x";
		//Engine.SCALE = 1;
		//Engine.IMG_BASE = "1x";
		#end
		
		var originalWidth = scripts.MyAssets.stageWidth;
		var originalHeight = scripts.MyAssets.stageHeight;
		
		scripts.MyAssets.stageWidth *= Engine.SCALE;
		scripts.MyAssets.stageHeight *= Engine.SCALE;
		
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
		
		//Preloader Hook - When force-testing preloader, uncomment this
		//var loader = new scripts.StencylPreloader();
		//loader.onUpdate(5, 15);
		//addChild(loader);
		
		new com.stencyl.Engine(this);
		
		//Text Testing
		/*var textBytes = nme.Assets.getText("assets/graphics/NavTitle.fnt");
		var XMLData = Xml.parse(textBytes);
		var font = new com.stencyl.graphics.fonts.BitmapFont().loadAngelCode(nme.Assets.getBitmapData("assets/graphics/NavTitle.png"), XMLData);
		var label = new com.stencyl.graphics.fonts.Label();
		label.text = "Long ago, the War of the Magi reduced the world to a scorched wasteland, and Magic simply ceased to exist. 1000 years have passed... Iron, gunpowder and steam engines have been rediscovered, and high technology reigns. But there are those who would enslave the world by reviving the dread destructive power known as 'Magic'. Can it be that those in power are on the verge of repeating a senseless and deadly mistake?";
		label.shadow = true;
		label.multiLine = true;
		label.x = 10;
		label.y = 10;
		label.color = 0xff6600;
		label.fontScale = 2;
		label.setWidth(640);
		label.autoUpperCase = true;
		addChild(label);*/
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
