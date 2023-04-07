package lime.utils;

import haxe.PosInfos;
import com.stencyl.utils.Log in StencylLog;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Log
{
	public static var level(get,set):LogLevel;
	public static var throwErrors:Bool = true;

	public static inline function get_level():LogLevel
	{
		return StencylLog.level;
	}

	public static inline function set_level(level:LogLevel):LogLevel
	{
		return StencylLog.level = level;
	}

	public static inline function debug(message:Dynamic, ?posInfo:PosInfos):Void
	{
		StencylLog.debug(message, posInfo);
	}

	public static inline function error(message:Dynamic, ?posInfo:PosInfos):Void
	{
		if (throwErrors)
		{
			var message = "[" + posInfo.className + "] ERROR: " + message;
			throw message;
		}
		StencylLog.error(message, posInfo);
	}

	public static inline function info(message:Dynamic, ?posInfo:PosInfos):Void
	{
		StencylLog.info(message, posInfo);
	}

	public static inline function print(message:Dynamic, ?posInfo:PosInfos):Void
	{
		info(message, posInfo);
	}

	public static inline function println(message:Dynamic, ?posInfo:PosInfos):Void
	{
		info(message, posInfo);
	}

	public static inline function verbose(message:Dynamic, ?posInfo:PosInfos):Void
	{
		StencylLog.verbose(message, posInfo);
	}

	public static inline function warn(message:Dynamic, ?posInfo:PosInfos):Void
	{
		StencylLog.warn(message, posInfo);
	}
}
