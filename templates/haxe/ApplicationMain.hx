package;

import com.stencyl.Config;
import com.stencyl.Data;
import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.utils.Utils;

import haxe.Log in HaxeLog;

import lime.app.Config in LimeConfig;
import lime.system.System;
import lime.utils.Log in LimeLog;

import openfl.Lib;
import openfl.display.Application;
import openfl.display.Preloader;
import openfl.display.StageDisplayState;

import scripts.StencylPreloader;

#if flash
import flash.events.UncaughtErrorEvent;
import flash.events.ErrorEvent;
import flash.errors.Error;
#end

using StringTools;

@:access(lime.app.Application)
@:access(lime.system.System)
@:access(lime.utils.AssetLibrary)

@:dox(hide) class ApplicationMain
{
	private static var app:Application;
	private static var universal:Universal;

	public static function main ()
	{
		#if scriptable
		if(StencylCppia.gamePath != null)
			Sys.setCwd(StencylCppia.gamePath);
		#end

		setupTracing(true);

		Config.load();
		Input.loadInputConfig();
		
		setupTracing(!Config.releaseMode);

		var projectName = "::APP_FILE::";
		
		var config = {
			
			build: "::meta.buildNumber::",
			company: "::meta.company::",
			file: "::APP_FILE::",
			fps: ::WIN_FPS::,
			name: "::meta.title::",
			orientation: "::WIN_ORIENTATION::",
			packageName: "::meta.packageName::",
			version: "::meta.version::",
			windows: [
				::foreach windows::
				{
					allowHighDPI: ::allowHighDPI::,
					antialiasing: ::antialiasing::,
					background: ::background::,
					borderless: ::borderless::,
					depthBuffer: ::depthBuffer::,
					display: ::display::,
					fullscreen: ::fullscreen::,
					hardware: ::hardware::,
					height: ::height::,
					hidden: #if munit true #else ::hidden:: #end,
					maximized: ::maximized::,
					minimized: ::minimized::,
					parameters: ::parameters::,
					resizable: ::resizable::,
					stencilBuffer: ::stencilBuffer::,
					title: "::title::",
					vsync: ::vsync::,
					width: ::width::,
					x: ::x::,
					y: ::y::
				},::end::
			]
			
		};

		System.__registerEntryPoint (projectName, create, config);
		
		#if (hxtelemetry)
		var telemetry = new hxtelemetry.HxTelemetry.Config ();
		telemetry.allocations = ::if (config.hxtelemetry != null)::("::config.hxtelemetry.allocations::" == "true")::else::true::end::;
		telemetry.host = ::if (config.hxtelemetry != null)::"::config.hxtelemetry.host::"::else::"localhost"::end::;
		telemetry.app_name = config.name;
		Reflect.setField (config, "telemetry", telemetry);
		#end

		new com.stencyl.utils.ToolsetInterface();
		
		#if (js && html5)
		#if (munit || utest)
		System.embed (projectName, null, ::WIN_WIDTH::, ::WIN_HEIGHT::, config);
		#end
		#else
		create (config);
		#end
		
	}

	private static var oldTrace;

	public static function setupTracing(enable:Bool):Void
	{
		if(oldTrace == null)
			oldTrace = HaxeLog.trace;

		if(enable)
		{
			#if (flash9 || flash10)
			HaxeLog.trace = function(v,?pos) { untyped __global__["trace"]("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"):",v); }
			#elseif flash
			HaxeLog.trace = function(v,?pos) { flash.Lib.trace("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"): "+v); }
			#else
			HaxeLog.trace = oldTrace;
			#end

			LimeLog.level = VERBOSE;
		}
		else
		{
			HaxeLog.trace = function(v,?pos) { };
			LimeLog.level = NONE;
		}
	}

	public static function reloadScales(oldConfig:Dynamic, newConfig:Dynamic)
	{
		//"scaleMode", "gameImageBase", "maxScale", "scales"
		//All are only used in Universal.
		var oldImgBase = Engine.IMG_BASE;

		var fs = Config.startInFullScreen;
		app.window.stage.displayState = fs ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.NORMAL;
		universal.initScreen(fs);

		if(oldImgBase != Engine.IMG_BASE)
		{
			Data.get().reloadScaledResources();
		}
		Engine.engine.g.scaleX = Engine.engine.g.scaleY = Engine.SCALE;
	}

	public static function reloadScreen(oldConfig:Dynamic, newConfig:Dynamic)
	{
		//"stageWidth", "stageHeight", "gameScale", "antialias"
		//only used in Engine, PostProcess, Universal: stageWidth, stageHeight, gameScale
		
		app.window.resize(Std.int(Config.stageWidth * Config.gameScale), Std.int(Config.stageHeight * Config.gameScale));
		reloadScales(oldConfig, newConfig);
	}

	public static function reloadGame()
	{
		//"physicsMode"
		com.stencyl.behavior.Script.resetStatics();
		com.stencyl.graphics.G.resetStatics();
		com.stencyl.models.Actor.resetStatics();
		com.stencyl.models.Font.resetStatics();
		com.stencyl.models.GameModel.resetStatics();
		com.stencyl.models.Joystick.resetStatics();
		com.stencyl.models.SoundChannel.resetStatics();
		com.stencyl.models.actor.Animation.resetStatics();
		com.stencyl.models.actor.Collision.resetStatics();
		com.stencyl.models.collision.CollisionInfo.resetStatics();
		com.stencyl.models.scene.TileLayer.resetStatics();
		com.stencyl.utils.Kongregate.resetStatics();
		com.stencyl.utils.Utils.resetStatics();
		com.stencyl.Data.resetStatics();
		com.stencyl.Input.resetStatics();
		com.stencyl.Engine.resetStatics();
		Lib.current.removeChild(universal);

		Input.loadInputConfig();
		universal = new Universal();
		Lib.current.addChild(universal);
		universal.preloaderComplete();
	}
	
	public static function create (config:LimeConfig):Void
	{
		app = new Application ();
		app.create (config);
		
		#if flash
		if(!Config.releaseMode)
		{
			Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		#end

		ManifestResources.init (config);

		Universal.initStage(app.window.stage);
		universal = new Universal();
		Lib.current.addChild(universal);
		var imgBase = Engine.IMG_BASE;

		#if (sys)
		var preloadPaths = Utils.getConfigText("config/preloadPaths.txt");
		for(library in ManifestResources.preloadLibraries)
		{
			for(path in preloadPaths.split("\n"))
			{
				if(path.length == 0)
					continue;
				path = path.replace("IMG_BASE", imgBase);
				library.preload.set(path, true);
			}
		}
		#end

		var preloader = new Preloader (new StencylPreloader ());
		app.setPreloader (preloader);
		preloader.create (config);
		preloader.onComplete.add (universal.preloaderComplete);
		
		for (library in ManifestResources.preloadLibraries)
		{
			preloader.addLibrary (library);
		}
		for (name in ManifestResources.preloadLibraryNames)
		{
			preloader.addLibraryName (name);
		}

		preloader.load ();
		
		var result = app.exec ();
		
		#if (sys && !ios && !nodejs && !emscripten)
		System.exit (result);
		#end
	}

	#if flash
	static function uncaughtErrorHandler(event:UncaughtErrorEvent):Void
	{
		if (Std.is(event.error, Error))
		{
			trace(cast(event.error, Error).message);
		}
		else if (Std.is(event.error,ErrorEvent))
		{
			trace(cast(event.error, ErrorEvent).text);
		}
		else
		{
			trace(event.error.toString());
		}
	}
	#end
}