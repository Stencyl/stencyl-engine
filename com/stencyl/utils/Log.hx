package com.stencyl.utils;

import haxe.PosInfos;
import haxe.Timer;
import lime.utils.LogLevel;

@:structInit class ExtraInfo
{
	public final level:LogLevel;
	public final time:Float;
}

class Log
{
	public static var level:LogLevel;

	public static function debug(message:Dynamic, ?posInfo:PosInfos):Void
	{
		if (level >= LogLevel.DEBUG)
		{
			stamp(posInfo, DEBUG);
			haxe.Log.trace(Std.string(message), posInfo);
		}
	}

	public static function error(message:Dynamic, ?posInfo:PosInfos):Void
	{
		if (level >= LogLevel.ERROR)
		{
			stamp(posInfo, ERROR);
			haxe.Log.trace(Std.string(message), posInfo);
		}
	}

	public static function info(message:Dynamic, ?posInfo:PosInfos):Void
	{
		if (level >= LogLevel.INFO)
		{
			stamp(posInfo, INFO);
			haxe.Log.trace(Std.string(message), posInfo);
		}
	}

	public static function verbose(message:Dynamic, ?posInfo:PosInfos):Void
	{
		if (level >= LogLevel.VERBOSE)
		{
			stamp(posInfo, VERBOSE);
			haxe.Log.trace(Std.string(message), posInfo);
		}
	}

	public static function warn(message:Dynamic, ?posInfo:PosInfos):Void
	{
		if (level >= LogLevel.WARN)
		{
			stamp(posInfo, WARN);
			haxe.Log.trace(Std.string(message), posInfo);
		}
	}

	public static inline function getExtraInfo(posInfo:PosInfos):ExtraInfo
	{
		if(posInfo.customParams == null || posInfo.customParams.length == 0)
			return {level: LogLevel.INFO, time: Timer.stamp()};
		
		var lastParam = posInfo.customParams[posInfo.customParams.length - 1];
		if(!(lastParam is ExtraInfo))
			return {level: LogLevel.INFO, time: Timer.stamp()};
		
		return cast lastParam;
	}

	public static inline function stamp(posInfo:PosInfos, level:LogLevel):Void
	{
		var extra:ExtraInfo = {level: level, time: Timer.stamp()};
		if (posInfo.customParams == null)
			posInfo.customParams = [extra];
		else
			posInfo.customParams.push(extra);
	}

	public static inline function ensureStamped(posInfo:PosInfos, level:LogLevel):Void
	{
		if(
			posInfo.customParams != null &&
			posInfo.customParams.length > 0 &&
			posInfo.customParams[posInfo.customParams.length - 1] is ExtraInfo
		)
			return;

		stamp(posInfo, level);
	}

	private static function __init__():Void
	{
		#if no_traces
		level = NONE;
		#elseif verbose
		level = VERBOSE;
		#else
		#if sys
		var args = Sys.args();
		if (args.indexOf("-v") > -1 || args.indexOf("-verbose") > -1)
		{
			level = VERBOSE;
		}
		else
		#end
		{
			#if debug
			level = DEBUG;
			#else
			level = INFO;
			#end
		}
		#end

		#if js
		if (untyped #if haxe4 js.Syntax.code #else __js__ #end ("typeof console") == "undefined")
		{
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console = {}");
		}
		if (untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log == null)
		{
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log = function() {};
		}
		#end
	}
}
