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

class GameCenter 
{	
	private static var initialized:Bool = false;
	
	private static inline var ANDROID_CLASS:String = "GreeSDK";
	private static var _init_func:Dynamic;
	

	private static function notifyListeners(inEvent:Dynamic)
	{
		#if(mobile && !android && !air)
		var type:String = Std.string(Reflect.field(inEvent, "type"));
		var data:String = Std.string(Reflect.field(inEvent, "data"));
		
		if(type == "auth-success")
		{
			trace("Game Center: Authenticated");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_READY));
		}
		
		else if(type == "auth-failed")
		{
			trace("Game Center: Failed to Authenticate");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_READY_FAIL, data));
		}
		
		else if(type == "score-success")
		{
			trace("Game Center: Submitted Score");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_SCORE, data));
		}
		
		else if(type == "score-failed")
		{
			trace("Game Center: Failed to Submit Score");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_SCORE_FAIL, data));
		}
		
		else if(type == "achieve-success")
		{
			trace("Game Center: Submitted Achievement");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_ACHIEVEMENT, data));
		}
		
		else if(type == "achieve-failed")
		{
			trace("Game Center: Failed to Submit Achievement");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_ACHIEVEMENT_FAIL, data));
		}
		
		else if(type == "achieve-reset-success")
		{
			trace("Game Center: Reset Achievements");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_ACHIEVEMENT_RESET, data));
		}
		
		else if(type == "achieve-reset-failed")
		{
			trace("Game Center: Failed to Reset Achievements");
			Engine.events.addGameCenterEvent(new StencylEvent(StencylEvent.GAME_CENTER_ACHIEVEMENT_RESET_FAIL, data));
		}
		#end
	}

	public static function initialize():Void 
	{
		#if android
		/*if(_init_func == null)
		{
			//_init_func = JNI.createStaticMethod(ANDROID_CLASS, "init", "()Ljava/lang/String;", true);
			_init_func = JNI.createStaticMethod("Test", "init", "(Ljava/lang/String;)Ljava/lang/String;", true);
		}

		var args = new Array<Dynamic>();
		args.push("testing");
		_init_func(args);*/
		#end
	
		#if(mobile && !android && !air)
		if(!initialized)
		{
			set_event_handle(notifyListeners);
			gamecenter_initialize();
			initialized = true;
		}
		#end	
	}

	public static function authenticate():Void 
	{
		#if(mobile && !android && !air)
			gamecenter_authenticate();
		#end	
	}
	
	public static function isAvailable():Bool 
	{
		#if(mobile && !android && !air)
			return gamecenter_isavailable();
		#else
			return false;
		#end
	}
	
	public static function isAuthenticated():Bool 
	{
		#if(mobile && !android && !air)
			return gamecenter_isauthenticated();
		#else
			return false;
		#end
	}
	
	public static function getPlayerName():String 
	{
		#if(mobile && !android && !air)
			return gamecenter_playername();
		#else
			return "None";
		#end
	}
	
	public static function getPlayerID():String 
	{
		#if(mobile && !android && !air)
			return gamecenter_playerid();
		#else
			return "None";
		#end
	}
	
	public static function showLeaderboard(categoryID:String):Void 
	{
		#if(mobile && !android && !air)
			gamecenter_showleaderboard(categoryID);
		#end	
	}
	
	public static function showAchievements():Void 
	{
		#if(mobile && !android && !air)
			gamecenter_showachievements();
		#end	
	}
	
	public static function reportScore(categoryID:String, score:Int):Void 
	{
		#if(mobile && !android && !air)
			gamecenter_reportscore(categoryID, score);
		#end	
	}
	
	public static function reportAchievement(achievementID:String, percent:Float):Void 
	{
		#if(mobile && !android && !air)
			gamecenter_reportachievement(achievementID, percent);
		#end	
	}
	
	public static function resetAchievements():Void 
	{
		#if(mobile && !android && !air)
			gamecenter_resetachievements();
		#end	
	}
	
	#if(mobile && !android && !air)
	private static var set_event_handle = nme.Loader.load("gamecenter_set_event_handle", 1);
	private static var gamecenter_initialize = Lib.load("gamecenter", "gamecenter_initialize", 0);
	private static var gamecenter_authenticate = Lib.load("gamecenter", "gamecenter_authenticate", 0);
	private static var gamecenter_isavailable = Lib.load("gamecenter", "gamecenter_isavailable", 0);
	private static var gamecenter_isauthenticated = Lib.load("gamecenter", "gamecenter_isauthenticated", 0);
	
	private static var gamecenter_playername = Lib.load("gamecenter", "gamecenter_playername", 0);
	private static var gamecenter_playerid = Lib.load("gamecenter", "gamecenter_playerid", 0);
	
	private static var gamecenter_showleaderboard = Lib.load("gamecenter", "gamecenter_showleaderboard", 1);
	private static var gamecenter_showachievements = Lib.load("gamecenter", "gamecenter_showachievements", 0);
	private static var gamecenter_reportscore = Lib.load("gamecenter", "gamecenter_reportscore", 2);
	private static var gamecenter_reportachievement = Lib.load("gamecenter", "gamecenter_reportachievement", 2);
	private static var gamecenter_resetachievements = Lib.load("gamecenter", "gamecenter_resetachievements", 0);
	#end
}