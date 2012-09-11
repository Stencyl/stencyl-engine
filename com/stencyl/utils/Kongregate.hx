#if flash
package com.stencyl.utils;

class Kongregate 
{
	private static var kongregate:Dynamic;
	
	public static function initAPI():Void
	{
		if(Kongregate.kongregate == null)
		{
			new Kongregate();
		}
	}
	
	private function new() 
	{ 
		kongregate = null;
		var parameters = flash.Lib.current.loaderInfo.parameters;
		var url:String = parameters.api_path;
		
		if(url == null)
		{
			url = "http://www.kongregate.com/flash/API_AS3_Local.swf";
		}
			
		var request = new flash.net.URLRequest(url);
		var loader = new flash.display.Loader();
		loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoadComplete);
		loader.load(request);
		
		flash.Lib.current.addChild(loader);
	}

	function onLoadComplete(e:flash.events.Event) 
	{
		try 
		{
			Kongregate.kongregate = e.target.content;
			Kongregate.kongregate.services.connect();
		}
		
		catch(msg:Dynamic) 
		{
			Kongregate.kongregate = null; 
		}
	} 

	/*public static function submitScore(score:Float, mode:String) 
	{
		if(Kongregate.kongregate != null)
		{
			Kongregate.kongregate.scores.submit(score, mode); 
		}
		
		else
		{
			error();
		}
	}*/
	
	public static function submitStat(name:String, stat:Float) 
	{
		if(Kongregate.kongregate != null) 
		{
			Kongregate.kongregate.stats.submit(name, Std.int(stat));
		}
		
		else
		{
			error();
		}
	}
	
	public static function isGuest():Bool
	{
		if(Kongregate.kongregate != null)
		{
			return Kongregate.kongregate.services.isGuest(); 
		}
		
		else
		{
			error();
		}
	
		return false;
	}
	
	public static function getUsername():String
	{
		if(Kongregate.kongregate != null)
		{
			return Kongregate.kongregate.services.getUsername(); 
		}
		
		else
		{
			error();
		}
	
		return "Guest";
	}
	
	public static function getUserID():Int
	{
		if(Kongregate.kongregate != null)
		{
			return Kongregate.kongregate.services.getUserId(); 
		}
		
		else
		{
			error();
		}
	
		return 0;
	}
	
	public static function error()
	{
		trace("Kongregate API is not ready yet. Call initAPI() first.");
	}
} 
#end