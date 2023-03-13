package com.stencyl.loader;

#if(flash || html5)

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.net.URLRequest;

import com.stencyl.Config;

using StringTools;

@:access(openfl.display.LoaderInfo)

class SiteLock extends Sprite
{
	private var locked:Bool = false;
	
	public function new()
	{
		super();
	}
	
	public function hasSiteLock():Bool
	{
		return Config.lockURL != "";
	}
	
	public function getLockURL():String
	{
		return Config.lockURL;
	}
	
	public function isLocked():Bool
	{
		return locked;
	}

	public function checkSiteLock()
	{
		locked = hasSiteLock();

		if(locked)
		{
			var lockURL = getLockURL();
			var currURL = Lib.current.loaderInfo.url;
			
			if(currURL == null)
			{
				locked = false;
				//trace("Local - HTML5");
			}
			
			else if(currURL.indexOf("http://") < 0 && currURL.indexOf("https://") < 0)
			{
				locked = false;
				//trace("Local - Flash");
			}
			
			//TODO: What if the site's URL coincidentally contains localhost? Tricked.
			else if((currURL.indexOf("stencyl.com") > 0) || (currURL.indexOf("localhost") > 0))
			{
				locked = false;
				//trace("OK - Stencyl.com or localhost");
			}
			
			if(locked)
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
						locked = !r.match(currURL);
					}
					else
					{
						locked = (currURL.indexOf(site) == -1);
					}
					if(!locked) break;
				}
				
				//no matches found, show the error message
				if(locked)
				{
					showLockScreen(siteArray[0]);
				}
			}
		}
	}
	
	public function showLockScreen(realURL:String)
	{
		Lib.current.addChild(this);
	
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
		
		txt.addEventListener(MouseEvent.CLICK, goToLockURL);
		tmp.addEventListener(MouseEvent.CLICK, goToLockURL);
	}
	
	public function goToLockURL(e:MouseEvent):Void
	{
		Lib.getURL(new URLRequest(getLockURL().split(",")[0]), "_parent");
	}
	
	public function getWidth():Float
	{
		return Universal.windowWidth;
	}
	
	public function getHeight():Float
	{
		return Universal.windowHeight;
	}
}

#end