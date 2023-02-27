package com.stencyl.loader;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.net.URLRequest;

import com.stencyl.Config;
import com.stencyl.utils.Utils;

using StringTools;

@:access(openfl.display.LoaderInfo)

class StencylPreloader extends Sprite
{
	#if(flash || html5)
	
	private var barBorder:Sprite;
	private var bar:Sprite;
	private var barBackground:Sprite;
	private var background:Sprite;
	private var barWidth:Int;
	private var barHeight:Int;
	
	private var locked:Bool;
	
	#end
	
	public var onComplete = new lime.app.Event<Void->Void>();
	private var adPlaying:Bool;
	private var ready:Bool;
	
	public function new()
	{
		super();
		
		Lib.current.addChild(this);
		
		#if(flash || html5)
		
		locked = false;
		
		var config = Config.preloader;

		//Background Color && Image
		var backgroundColor = config.backgroundColor;
	
		background = new Sprite();
		background.graphics.beginFill(backgroundColor, 1);
		background.graphics.drawRect(0, 0, getWidth(), getHeight());
		addChild(background);
		
		if(config.backgroundImage != "")
		{
			Utils.getConfigBitmap(config.backgroundImage)
				.onComplete(function (bmp) {
				    addChildAt(bmp, getChildIndex(background) + 1);
			});
		}
		
		showPreloader();

		#end
	}

	#if(flash || html5)

	public function showPreloader()
	{
		var config = Config.preloader;

		//Bar
		var barBorderColor = config.borderColor;
		var barBackgroundColor = config.barBackgroundColor;
		var barColor = config.barColor;
	
		var borderThickness = Engine.SCALE * config.borderThickness;
		barWidth = Std.int(Engine.SCALE * Engine.screenScaleX * config.barWidth);
		barHeight = Std.int(Engine.SCALE * Engine.screenScaleY * config.barHeight);
	
		var offsetX = Engine.SCALE * config.barOffsetX;
		var offsetY = Engine.SCALE * config.barOffsetY;
	
		var barX:Float = getWidth() / 2 - barWidth / 2;
		var barY:Float = 0;

		if (config.barLocation == 0)
		{
			barY = getHeight() / 2 - barHeight / 2;
		}
		else if (config.barLocation == 1)
		{
			barY = borderThickness;
		}
		else
		{
			barY = getHeight() - barHeight - borderThickness;
		}
	
		barBorder = new Sprite();
		barBorder.graphics.beginFill(barBorderColor, 1);
		barBorder.graphics.drawRect(-borderThickness, -borderThickness, barWidth + borderThickness * 2, barHeight + borderThickness * 2);
		barBorder.x = barX + offsetX;
		barBorder.y = barY + offsetY;
		addChild(barBorder);
	
		barBackground = new Sprite();
		barBackground.graphics.beginFill(barBackgroundColor, 1);
		barBackground.graphics.drawRect(0, 0, barWidth, barHeight);
		barBackground.x = barX + offsetX;
		barBackground.y = barY + offsetY;
		barBackground.scaleX = 1;
		addChild(barBackground);
	
		bar = new Sprite();
		bar.graphics.beginFill(barColor, 1);
		bar.graphics.drawRect(0, 0, barWidth, barHeight);
		
		//Setting scaleX = 0 was buggy on HTML5, so we clip instead
		var r = new Rectangle(0, 0, 0, barHeight);
		bar.scrollRect = r;
		
		bar.x = barX + offsetX;
		bar.y = barY + offsetY;
		addChild(bar);
		
		showBadge();
		
		if(getURL() != "")
		{
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 2);
		}
		
		//---
		
		checkSiteLock();
	}
	
	public function showBadge()
	{
		var config = Config.preloader;
		if(config.badgeImage != "")
		{
			Utils.getConfigBitmap(config.badgeImage)
				.onComplete(function (bmp) {
					addChild(bmp);
					bmp.x = getWidth() - 114 - 5;
					bmp.y = getHeight() - 62 - 5;
					
			});
		}
	}

	public function checkSiteLock()
	{
		var lockURL = getLockURL();
		
		if(isSiteLocked() && (lockURL != null && lockURL != ""))
		{
			var ok = false;
			var currURL = Lib.current.loaderInfo.url;
			
			if(currURL == null)
			{
				ok = true;
				//trace("Local - HTML5");
			}
			
			else if(currURL.indexOf("http://") < 0 && currURL.indexOf("https://") < 0)
			{
				ok = true;
				//trace("Local - Flash");
			}
			
			//TODO: What if the site's URL coincidentally contains localhost? Tricked.
			else if((currURL.indexOf("stencyl.com") > 0) || (currURL.indexOf("localhost") > 0))
			{
				ok = true;
				//trace("OK - Stencyl.com or localhost");
			}
			
			if(!ok)
			{
				//site lock value can be a comma delimited list of sites
				var siteArray = lockURL.split(",");	
				
				//check to see if we're playing from a valid site
				for(site in siteArray)
				{
					site = StringTools.trim(site);

					var useRegex = site.indexOf("*") >= 0 || (site.startsWith("^") && site.endsWith("$"));

					if(useRegex)
					{
						var r:EReg = new EReg(site, "");
						ok = r.match(currURL);
					}
					else
					{
						ok = (currURL.indexOf(site) >= 0);
					}
					if(ok) break;
				}
				
				//no matches found, show the error message
				if(!ok)
				{
					showLockScreen(siteArray[0]);
				}
			}	
		}
	}
	
	public function getLockURL():String
	{
		return Config.preloader.lockURL;
	}
	
	public function isSiteLocked():Bool
	{
		return Config.preloader.lockURL != "";
	}
	
	public function showLockScreen(realURL:String)
	{
		//trace("Show Lock Screen");
		locked = true;
		
		Utils.removeAllChildren(this);
	
		var tmp = new Bitmap(new BitmapData(Std.int(getWidth()), Std.int(getHeight()), false, 0x565656));
		addChild(tmp);

		var txt = new TextField();
		txt.width = getWidth() - 16;
		txt.height = getHeight() - 16;
		txt.x = 8;
		txt.y = 8;
		txt.textColor = 0xffffff;
		txt.multiline = true;
		txt.wordWrap = true;

		var lockText = "Hi there!  It looks like somebody copied this game without my permission. Just click anywhere, or copy-paste this URL into your browser.\n\n"+realURL+"\n\nThanks, and have fun!";
		txt.text = lockText;
		
		var txtFormat = new TextFormat(null, 25);
		txt.setTextFormat(txtFormat);
	
		addChild(txt);
		
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		txt.addEventListener(MouseEvent.CLICK, goToLockURL);
		tmp.addEventListener(MouseEvent.CLICK, goToLockURL);
	}
	
	public function getURL():String
	{
		return Config.preloader.authorURL;
	}
	
	public function goToLockURL(e:MouseEvent):Void
	{
		Lib.getURL(new URLRequest(getLockURL().split(",")[0]), "_parent");
	}
	
	public function onMouseDown(e:MouseEvent):Void
	{
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.getURL(new URLRequest(getURL()), "_blank");
	}
	
	public function getBackgroundColor():Int
	{
		return 0x336699;
	}
	
	public function getWidth():Float
	{
		return Universal.windowWidth;
	}
	
	public function getHeight():Float
	{
		return Universal.windowHeight;
	}
	
	#end
	
	public function onUpdate(loaded:Int, total:Int)
	{
		#if !flash
		Lib.current.loaderInfo.__update (loaded, total);
		#end
		
		#if(flash || html5)
		var percentLoaded = loaded / total;
	
		if(percentLoaded > 1)
		{
			percentLoaded == 1;
		}
	
		if(bar != null)
		{
			//This approach was buggy on HTML5
			//bar.scaleX = percentLoaded;
			
			var r = new Rectangle(0, 0, barWidth * percentLoaded, barHeight);
			bar.scrollRect = r;
		}
		#end
	}
	
	public function onLoaded()
	{
		#if !flash
		Lib.current.loaderInfo.__complete ();
		#end
		
		ready = true;
		if(!adPlaying)
		{
			unload();
		}
	}

	public function adStarted()
	{
		adPlaying = true;
	}
	
	public function adFinished()
	{
		adPlaying = false;
		if(ready)
		{
			unload();
		}
	}
	
	public function unload()
	{
		#if stencyldemo
		new com.stencyl.loader.SplashBox();
		#end
		
		#if(flash || html5)
		if(isSiteLocked() && locked)
		{
			return;
		}
		#end
		
		if(parent == Lib.current)
		{
			Lib.current.removeChild(this);
		}
		
		Lib.current.stage.focus = null;
		
		onComplete.dispatch();
	}
}