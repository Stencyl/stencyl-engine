package;

import com.stencyl.Config;
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
	public static function main ()
	{
		#if scriptable
		if(StencylCppia.gamePath != null)
			Sys.setCwd(StencylCppia.gamePath);
		#end

		#if flash
		var oldTrace = HaxeLog.trace;
		
		#if (flash9 || flash10)
		HaxeLog.trace = function(v,?pos) { untyped __global__["trace"]("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"):",v); }
		#else
		HaxeLog.trace = function(v,?pos) { flash.Lib.trace("Stencyl:" + pos.className+"#"+pos.methodName+"("+pos.lineNumber+"): "+v); }
		#end

		#end
		
		Config.load();
		Input.loadInputConfig();
		
		#if flash
		if(Config.releaseMode)
		{
			HaxeLog.trace = oldTrace;
		}
		else
		{
			LimeLog.level = VERBOSE;
		}
		#end

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
		
		#if (js && html5)
		#if (munit || utest)
		System.embed (projectName, null, ::WIN_WIDTH::, ::WIN_HEIGHT::, config);
		#end
		#else
		create (config);
		#end
		
	}
	
	public static function create (config:LimeConfig):Void
	{
		var app = new Application ();
		app.create (config);
		
		#if flash
		if(!Config.releaseMode)
		{
			Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		#end

		ManifestResources.init (config);

		Universal.initStage(app.window.stage);
		var universal = new Universal();
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