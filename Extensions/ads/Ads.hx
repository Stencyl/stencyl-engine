package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#else
import nme.Lib;
#end

#if android
import nme.JNI;
#end

import com.stencyl.Engine;
import com.stencyl.event.EventMaster;
import com.stencyl.event.StencylEvent;

import nme.utils.ByteArray;
import nme.display.BitmapData;
import nme.geom.Rectangle;

class Ads 
{	
	//Universal
	private static var initialized:Bool = false;
	
	//Android-Only
	public static var adwhirlCode:String = "none";
	private static inline var ANDROID_CLASS:String = "AdWhirl";
	private static var _init_func:Dynamic;
	private static var _show_func:Dynamic;
	private static var _hide_func:Dynamic;
	
	//Ad Events only happen on iOS. AdWhirl provides no out-of-the-box way.
	private static function notifyListeners(inEvent:Dynamic)
	{
		#if(mobile && !android && !air)
		var data:String = Std.string(Reflect.field(inEvent, "type"));
		
		if(data == "open")
		{
			trace("USER OPENED IT");
			Engine.events.addAdEvent(new StencylEvent(StencylEvent.AD_USER_OPEN));
		}
		
		if(data == "close")
		{
			trace("USER CLOSED IT");
			Engine.events.addAdEvent(new StencylEvent(StencylEvent.AD_USER_CLOSE));
		}
		
		if(data == "load")
		{
			trace("IT SHOWED UP");
			Engine.events.addAdEvent(new StencylEvent(StencylEvent.AD_LOADED));
		}
		
		if(data == "fail")
		{
			trace("IT FAILED TO LOAD");
			Engine.events.addAdEvent(new StencylEvent(StencylEvent.AD_FAILED));
		}
		#end
	}

	public static function initialize(apiCode:String = "none"):Void 
	{
		#if(mobile && !android && !air)
		if(!initialized)
		{
			set_event_handle(notifyListeners);
			initialized = true;
		}
		#end	
		
		#if android
		if(!initialized)
		{
			adwhirlCode = apiCode;
		
			if(_init_func == null)
			{
				_init_func = JNI.createStaticMethod(ANDROID_CLASS, "init", "(Ljava/lang/String;)V", true);
			}
	
			var args = new Array<Dynamic>();
			args.push(adwhirlCode);
			_init_func(args);
			
			initialized = true;
		}
		#end
	}

	public static function showAd(onBottom:Bool = true):Void
	{
		#if(mobile && !android && !air)
		ads_showad(onBottom ? 0 : 1);
		#end
		
		#if android
		if(!initialized)
		{
			Ads.initialize();
		}
		
		if(_show_func == null)
		{
			_show_func = JNI.createStaticMethod(ANDROID_CLASS, "showAd", "(I)V", true);
		}

		var args = new Array<Dynamic>();
		args.push(onBottom ? 0 : 1);
		_show_func(args);
		#end
	}	
	
	public static function hideAd():Void
	{
		#if(mobile && !android && !air)
		ads_hidead();
		#end
		
		#if android
		if(!initialized)
		{
			Ads.initialize();
		}
		
		if(_hide_func == null)
		{
			_hide_func = JNI.createStaticMethod(ANDROID_CLASS, "hideAd", "()V", true);
		}

		var args = new Array<Dynamic>();
		_hide_func(args);
		#end
	}
	
	#if(mobile && !android && !air)
	private static var set_event_handle = nme.Loader.load("ads_set_event_handle", 1);
	private static var ads_showad = nme.Loader.load("ads_showad", 1);
	private static var ads_hidead = nme.Loader.load("ads_hidead", 0);
	#end
}