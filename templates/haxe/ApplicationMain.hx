package;

import com.stencyl.Config;
import com.stencyl.Data;
import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.utils.Utils;
#if stencyltools
import com.stencyl.utils.ToolsetInterface;
#end

import haxe.Timer;

import lime.app.Config in LimeConfig;
import lime.system.System;

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

@:access(Universal)
@:access(lime.app.Application)
@:access(lime.system.System)
@:access(lime.utils.AssetLibrary)

@:dox(hide) class ApplicationMain
{
	private static var app:Application;
	private static var universal:Universal;
	
	public static function main ()
	{
		#if cppia
		if(StencylCppia.gamePath != null)
			Sys.setCwd(StencylCppia.gamePath);
		#end
		Universal.am = ApplicationMain;
		Universal.setupTracing(true);

		Config.load();
		Input.loadInputConfig();
		Universal.setupTracing();

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
					alwaysOnTop: ::alwaysOnTop::,
					antialiasing: ::antialiasing::,
					background: ::background::,
					borderless: ::borderless::,
					colorDepth: ::colorDepth::,
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

		#if (stencyltools)
		new ToolsetInterface();
		#end

		#if (js && html5)
		//application is started from html script with System.embed, which calls create(config)
		#else
		create (config);
		#end

	}

	public static var reloadListeners = new Array<Void->Void>();

	public static function reloadGame()
	{
		for(reloadListener in reloadListeners)
		{
			reloadListener();
		}

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
		#if flash com.stencyl.utils.Kongregate.resetStatics(); #end
		com.stencyl.utils.Utils.resetStatics();
		#if stencyltools com.stencyl.utils.ToolsetInterface.resetStatics(); #end
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
		#if stencyltools
		{
			var startTime = Timer.stamp();
			var tryTimeout = function() {
				if(!ToolsetInterface.connected && Timer.stamp() - startTime > 1)
				{
					ToolsetInterface.cancelConnection();
				}
			};

			#if (flash || html5)

			if(!ToolsetInterface.ready)
			{
				var timer = new Timer(10);
				timer.run = function()
				{
					#if (!flash)
					ToolsetInterface.preloadedUpdate();
					#end

					tryTimeout();
					if(ToolsetInterface.ready)
					{
						timer.stop();
						create (config);
					}
				}

				return;
			}

			#else

			while(!ToolsetInterface.ready)
			{
				ToolsetInterface.preloadedUpdate();
				tryTimeout();
			}

			#end
		}
		#end

		app = new Application ();
		app.create (config);
		
		//XXX: On mac, creating the application seems to reset the cwd to the programPath at some point.
		#if cppia
		if(StencylCppia.gamePath != null)
			Sys.setCwd(StencylCppia.gamePath);
		#end
		
		#if flash
		if(!Config.releaseMode)
		{
			Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		#end

		ManifestResources.init (config);

		Universal.initWindow(app.window);
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