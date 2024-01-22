package;

import com.stencyl.Config;
import com.stencyl.Data;
import com.stencyl.Engine;
import com.stencyl.Extension;
import com.stencyl.Input;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Utils;
#if stencyltools
import com.stencyl.utils.ToolsetInterface;
#end

import haxe.CallStack;
import haxe.Timer;

import lime.system.System;

import openfl.Lib;
import openfl.display.Application;
import openfl.display.Preloader;
import openfl.display.StageDisplayState;
import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;

import haxe.Log in HaxeLog;
import com.stencyl.utils.Log;

using StringTools;

@:access(Universal)
@:access(lime.app.Application)
@:access(lime.system.System)
@:access(lime.utils.AssetLibrary)

@:dox(hide) class ApplicationMain
{
	private static var app:Application;
	private static var universal:Universal;
	private static var extensions:Array<Extension>;
	private static var originalHaxeTrace:Dynamic;
	#if testing
	private static var launchVars:Map<String, String>;
	#end

	public static function main ()
	{
		#if testing
		loadLaunchVars();
		#end

		configureTracing();

		#if testing
		Log.debug("Launch Vars: " + launchVars);
		#end
		
		#if cppia
		if(StencylCppia.gamePath != null)
			Sys.setCwd(StencylCppia.gamePath);
		#end
		
		Config.load();
		Input.loadInputConfig();
		
		System.__registerEntryPoint ("::APP_FILE::", create);
		
		Lib.current;

		#if stencyltools
		new ToolsetInterface();
		#end

		#if html5
		//application is started from html script with System.embed, which calls create(config)
		#else
		create (null);
		#end
	}

	public static var reloadListeners = new Array<Void->Void>();

	public static function reloadGame()
	{
		for(extension in extensions)
		{
			extension.reloadGame();
		}
		
		for(reloadListener in reloadListeners)
		{
			reloadListener();
		}

		com.stencyl.behavior.Script.resetStatics();
		com.stencyl.graphics.G.resetStatics();
		com.stencyl.models.Actor.resetStatics();
		com.stencyl.models.Font.resetStatics();
		com.stencyl.models.GameModel.resetStatics();
		com.stencyl.models.SoundChannel.resetStatics();
		com.stencyl.models.actor.Animation.resetStatics();
		com.stencyl.models.actor.Collision.resetStatics();
		com.stencyl.models.actor.CollisionPoint.resetStatics();
		com.stencyl.models.collision.CollisionInfo.resetStatics();
		com.stencyl.models.scene.TileLayer.resetStatics();
		com.stencyl.utils.motion.TweenManager.resetStatics();
		com.stencyl.utils.Utils.resetStatics();
		#if stencyltools com.stencyl.utils.ToolsetInterface.resetStatics(); #end
		com.stencyl.Data.resetStatics();
		com.stencyl.Input.resetStatics();
		com.stencyl.Engine.resetStatics();
		Lib.current.removeChild(universal);

		Input.loadInputConfig();
		universal = new Universal();
		Lib.current.addChild(universal);
		preloaderComplete();
	}

	#if testing
	private static function loadLaunchVars()
	{
		launchVars = [];
		#if flash
		for(field in Reflect.fields(Lib.current.loaderInfo.parameters))
		{
			launchVars[field] = Reflect.field(Lib.current.loaderInfo.parameters, field);
		}
		#elseif html5
		var params = new js.html.URL(js.Browser.location.href).searchParams;
		params.forEach((value, key) -> {
			launchVars.set(key, value);
		});
		#elseif android
		launchVars = com.stencyl.native.Native.getIntentExtras();
		#elseif sys
		for(arg in #if ios com.stencyl.native.Native.getProgramArguments() #else Sys.args() #end)
		{
			var equalsIndex = arg.indexOf("=");
			if(equalsIndex < 1 || equalsIndex == arg.length - 1) continue;
			launchVars[arg.substring(0, equalsIndex)] = arg.substring(equalsIndex + 1);
		}
		#end
	}
	#end

	#if stencyltools
	private static var waitForTools = false;
	#end

	public static function create (config):Void
	{
		#if stencyltools
		{
			var waitTime = 0; //-1: wait indefinitely, x >= 0: wait x seconds
			#if testing
			if(launchVars.exists("gciWaitTime"))
				waitTime = Std.parseInt(launchVars.get("gciWaitTime"));
			#end

			waitForTools = waitTime == -1 || waitTime > 0;

			var startTime = 0.0;
			var tryTimeout = function() {
				if(waitTime == -1) return;
				if(startTime == 0.0) startTime = Timer.stamp() - 0.01;
				if(!ToolsetInterface.connected && Timer.stamp() - startTime > waitTime)
				{
					waitForTools = false;
				}
			};

			#if (flash || html5)

			if(waitForTools && !ToolsetInterface.ready)
			{
				var timer = new Timer(10);
				timer.run = function()
				{
					#if !flash
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

			while(waitForTools && !ToolsetInterface.ready)
			{
				ToolsetInterface.preloadedUpdate();
				tryTimeout();
			}

			#end
		}
		#end

		#if mobile
		var orientation:String;
		if(Config.autorotate)
			orientation = Config.landscape ? "LandscapeLeft LandscapeRight" : "Portrait PortraitUpsideDown";
		else
			orientation = Config.landscape ? "LandscapeLeft" : "Portrait";

		Sys.putEnv("SDL_IOS_ORIENTATIONS", orientation);
		#end

		app = new Application ();
		
		ManifestResources.init (config);
		
		app.meta["build"] = "::meta.buildNumber::";
		app.meta["company"] = "::meta.company::";
		app.meta["file"] = "::APP_FILE::";
		app.meta["name"] = "::meta.title::";
		app.meta["packageName"] = "::meta.packageName::";
		app.meta["version"] = "::meta.version::";
		
		::if (config.hxtelemetry != null)::#if hxtelemetry
		app.meta["hxtelemetry-allocations"] = "::config.hxtelemetry.allocations::";
		app.meta["hxtelemetry-host"] = "::config.hxtelemetry.host::";
		#end::end::
		
		#if !flash
		::foreach windows::
		var attributes:lime.ui.WindowAttributes = {
			
			allowHighDPI: ::allowHighDPI::,
			alwaysOnTop: ::alwaysOnTop::,
			borderless: ::borderless::,
			// display: ::display::,
			element: null,
			frameRate: ::fps::,
			#if !web fullscreen: ::fullscreen::, #end
			height: ::height::,
			hidden: ::hidden::,
			maximized: ::maximized::,
			minimized: ::minimized::,
			parameters: ::parameters::,
			resizable: ::resizable::,
			title: "::title::",
			width: ::width::,
			x: ::x::,
			y: ::y::,
			
		};
		
		attributes.context = {
			
			antialiasing: Config.antialias ? 2 : 0,
			background: ::background::,
			colorDepth: ::colorDepth::,
			depth: ::depthBuffer::,
			hardware: ::hardware::,
			stencil: ::stencilBuffer::,
			type: null,
			vsync: ::vsync::
			
		};
		
		if (app.window == null) {
			
			if (config != null) {
				
				for (field in Reflect.fields (config)) {
					
					if (Reflect.hasField (attributes, field)) {
						
						Reflect.setField (attributes, field, Reflect.field (config, field));
						
					} else if (Reflect.hasField (attributes.context, field)) {
						
						Reflect.setField (attributes.context, field, Reflect.field (config, field));
						
					}
					
				}
				
			}
			
		}
		
		app.createWindow (attributes);
		::end::
		#else
		
		app.window.context.attributes.background = ::WIN_BACKGROUND::;
		app.window.frameRate = ::WIN_FPS::;
		
		#end
		
		if(!Config.releaseMode)
		{
			Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		
		Universal.initWindow(app.window);
		universal = new Universal();
		Lib.current.addChild(universal);
		var imgBase = Engine.IMG_BASE;
		
		#if sys
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
		
		#if actuate
		motion.actuators.SimpleActuator.getTime = function():Float {
			return Engine.totalElapsedTime / 1000;
		}
		#end

		extensions = [];

		try
		{
			::if config.stencyl.extension___array::
			 ::foreach (config.stencyl.extension___array)::
			  ::if condition:: #if ::condition:: extensions.push(new ::classname::()); #end ::else:: extensions.push(new ::classname::()); ::end::
			 ::end::
			::else::
			 ::if config.stencyl.extension::
			  ::if config.stencyl.extension.condition:: #if ::config.stencyl.extension.condition:: extensions.push(new ::config.stencyl.extension.classname::()); #end ::else:: extensions.push(new ::config.stencyl.extension.classname::()); ::end::
			 ::end::
			::end::
		}
		catch(e:haxe.Exception)
		{
			#if stencyltools
			if(ToolsetInterface.handlesLogging)
			{
				Log.fullError(e.message, e);
				ToolsetInterface.preloadedUpdate();
			}
			#end
			#if !flash
			@:privateAccess Lib.current.stage.__handleError (e);
			#end
		}
		
		@:privateAccess Engine.am = ApplicationMain;

		var preloader = new #if flash ::APP_PRELOADER::() #else com.stencyl.loader.StencylPreloader() #end;
		preloader.onComplete.add(preloaderComplete);
		app.preloader.onProgress.add(preloader.onUpdate);
		app.preloader.onComplete.add(preloader.onLoaded);
		
		for (library in ManifestResources.preloadLibraries)
		{
			app.preloader.addLibrary (library);
		}
		for (name in ManifestResources.preloadLibraryNames)
		{
			app.preloader.addLibraryName (name);
		}

		#if (flash || html5)
		var sitelock = new ::SET_SITELOCK_CLASS::();
		sitelock.onComplete.add(() -> { if(!sitelock.isLocked()) app.preloader.load(); });
		sitelock.checkSiteLock();
		#else
		app.preloader.load ();
		#end
		
		var result = app.exec ();

		#if (sys && !ios)
		System.exit (result);
		#end
	}
	
	@:access(openfl.display.Stage)
	public static function preloaderComplete():Void
	{
		#if flash
		
		new Engine(universal, extensions);
		
		#else
		
		try {
			
			new Engine(universal, extensions);
			
		} catch (e:haxe.Exception) {
			
			#if stencyltools
			if(ToolsetInterface.handlesLogging)
			{
				Log.fullError(e.message, e);
				ToolsetInterface.preloadedUpdate();
			}
			#end

			Lib.current.stage.__handleError (e);
			
		}

		#end
	}
	
	public static function configureTracing():Void
	{
		#if testing

		#if flash
		//Since flash output is written to a predetermined file that's the same
		//for all sessions, we need to mark the session ID to determine which
		//session the log output corresponds to.

		var gameSession = launchVars.get("gameSession");
		if(gameSession == null) gameSession = "0";
		flash.Lib.trace("gameSession="+gameSession);
		#end

		originalHaxeTrace = HaxeLog.trace;
		Log.level = VERBOSE;
		
		HaxeLog.trace = function(v:String,?pos:haxe.PosInfos) {
			var extra = Log.getExtraInfo(pos);
			var str = 'Stencyl:${extra.time}:${extra.level}:${pos.className}:${pos.methodName}:${pos.lineNumber}:${v.length}:$v';
			#if flash
			flash.Lib.trace(str);
			#elseif js
			(untyped console).log(str);
			#elseif sys
			Sys.println(str);
			#else
			throw new haxe.exceptions.NotImplementedException()
			#end
		}

		#if stencyltools
		if(launchVars.get("trace") == "gci")
		{
			HaxeLog.trace = ToolsetInterface.gciTrace;
			ToolsetInterface.handlesLogging = true;
		}
		#end

		#else

		HaxeLog.trace = function(v,?pos) { };
		Log.level = NONE;

		#end
	}
	
	static function uncaughtErrorHandler(event:UncaughtErrorEvent):Void
	{
		#if (html5 && stencyltools)
		
		if(ToolsetInterface.handlesLogging && Reflect.hasField(event.error, "stack"))
		{
			Log.error(event.error.stack);
		}
		
		#else
		
		if (Std.isOfType(event.error, Error))
		{
			var error = cast(event.error, Error);
			#if flash
			Log.error(error.getStackTrace());
			#else
			Log.fullError(error.message, error);
			#end
		}
		else if (Std.isOfType(event.error, ErrorEvent))
		{
			var errorEvent = cast(event.error, ErrorEvent);
			Log.error(errorEvent.text);
		}
		else
		{
			Log.error(Std.string(event.error));
		}
		
		#end
		
		#if (debug && stencyltools && (cpp || hl))
		
		Log.error(CallStack.toString(CallStack.exceptionStack()));
		ToolsetInterface.preloadedUpdate();
		
		#end
	}
}
