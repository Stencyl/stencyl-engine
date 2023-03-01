package com.stencyl;

import lime.utils.Bytes;
import haxe.Json;
import haxe.Resource;
import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.graphics.BitmapWrapper;
import com.stencyl.graphics.Scale;
import com.stencyl.graphics.ScaleMode;
import com.stencyl.models.PhysicsMode;
import com.stencyl.utils.Utils;

using Lambda;
using StringTools;

class Config
{
	//Game
	public static var landscape:Bool;
	public static var autorotate:Bool;
	public static var scaleMode:ScaleMode;
	public static var stageWidth:Int;
	public static var stageHeight:Int;
	public static var initSceneID:Int;
	public static var physicsMode:PhysicsMode;
	public static var gameScale:Float;
	public static var forceHiResAssets:Bool;
	public static var antialias:Bool;
	public static var pixelsnap:Bool;
	public static var startInFullScreen:Bool;
	public static var disposeImages:Bool;
	public static var keys:Map<String,Array<String>>;
	public static var scales:Array<Scale>;
	
	public static var toolsetInterfaceHost:String;
	public static var toolsetInterfacePort:Null<Int>;
	public static var projectName:String;
	public static var buildConfig:Dynamic;

	//Other
	public static var releaseMode:Bool;
	public static var useGciLogging:Bool;
	public static var showConsole:Bool;
	public static var debugDraw:Bool;
	public static var disableBackButton:Bool;

	#if(flash || html5)
	public static var preloader:com.stencyl.loader.PreloaderConfig;
	#end
	#if flash
	public static var swfPreloader:com.stencyl.loader.SwfPreloaderConfig;
	#end

	private static var data:Dynamic;
	private static var defines = com.stencyl.utils.HaxeDefines.getDefines();
	
	public static function load():Void
	{
		var text = Utils.getConfigText("config/game-config.json");
		loadFromString(text);
	}

	private static function loadMap(jsonData:Dynamic, mapData:Dynamic):Dynamic
	{
		for(field in Reflect.fields(jsonData))
		{
			if(field.startsWith("config-"))
			{
				if(defines.exists(field.substr("config-".length)))
				{
					loadMap(Reflect.field(jsonData, field), mapData);
				}
			}
			else
			{
				Reflect.setField(mapData, field, Reflect.field(jsonData, field));
			}
		}

		return mapData;
	}

	public static function loadFromString(text:String, handleReload:Bool = true):Void
	{
		if(data == null || !handleReload)
		{
			data = loadMap(Json.parse(text), {});
			setStaticFields();
		}
		else
		{
			var oldData = data;
			data = loadMap(Json.parse(text), {});
			setStaticFields();

			var needsScreenReload = false;
			var needsGameReload = false;
			var fullScreenChanged = false;

			for(key in Reflect.fields(oldData))
			{
				var oldValue = Reflect.field(oldData, key);
				var newValue = Reflect.field(data, key);
				
				if(oldValue != newValue)
				{
					trace('value of $key changed: $oldValue -> $newValue');

					switch(key)
					{
						case "scaleMode", "scales", "gameScale",
							 "stageWidth", "stageHeight", "antialias",
							 "forceHiResAssets":
							needsScreenReload = true;

						case "debugDraw":
							Engine.DEBUG_DRAW = debugDraw;
							if(!debugDraw)
								if(Engine.debugDrawer != null && Engine.debugDrawer.m_sprite != null)
									Engine.debugDrawer.m_sprite.graphics.clear();

						case "keys":
							Input.loadInputConfig();

						case "disposeImages", "physicsMode":
							needsGameReload = true;

						case "releaseMode", "useGciLogging":
							Engine.reloadTracingConfig();

						case "showConsole":
							Engine.engine.setStatsVisible(showConsole);

					}
				}
			}
			if(needsGameReload)
			{
				Engine.reloadGame();
			}
			else if(needsScreenReload)
			{
				Engine.engine.reloadScreen();
			}
		}
	}
	
	private static function setStaticFields():Void
	{
		landscape = data.landscape;
		autorotate = data.autorotate;
		scaleMode = (data.scaleMode : String);
		stageWidth = data.stageWidth;
		stageHeight = data.stageHeight;
		initSceneID = data.initSceneID;
		physicsMode = (data.physicsMode : String);
		gameScale = data.gameScale;
		forceHiResAssets = data.forceHiResAssets;
		antialias = data.antialias;
		pixelsnap = data.pixelsnap;
		startInFullScreen = data.startInFullScreen;
		disposeImages = data.disposeImages;
		releaseMode = data.releaseMode;
		showConsole = data.showConsole;
		debugDraw = data.debugDraw;
		disableBackButton = data.disableBackButton;
		useGciLogging = data.useGciLogging;
		keys = asMap(data.keys);
		scales = (data.scales : Array<String>).map(Scale.fromString).array();
		toolsetInterfaceHost = data.toolsetInterfaceHost;
		toolsetInterfacePort = data.toolsetInterfacePort;
		projectName = data.projectName;
		buildConfig = data.buildConfig;

		#if(flash || html5)
		if(data.preloader != null)
		{
			if(preloader == null) preloader = new com.stencyl.loader.PreloaderConfig();
			preloader.setFields(data.preloader);
		}
		else
			preloader = null;
		#end
		#if(flash)
		if(data.swfPreloader != null)
		{
			if(swfPreloader == null) swfPreloader = new com.stencyl.loader.SwfPreloaderConfig();
			swfPreloader.setFields(data.swfPreloader);
		}
		else
			swfPreloader = null;
		#end
	}

	private static function asMap<T>(anon:Dynamic):Map<String,T>
	{
		var map = new Map<String,T>();
		for(field in Reflect.fields(anon))
		{
			map.set(field, cast Reflect.field(anon, field));
		}
		return map;
	}
}