package com.stencyl.behavior;

#if !js
import nme.net.SharedObject;
import nme.net.SharedObjectFlushStatus;
#end

import nme.events.Event;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLRequestMethod;
import nme.net.URLVariables;
import nme.Lib;

import nme.display.Graphics;

import com.stencyl.models.Actor;
import com.stencyl.models.Scene;
import com.stencyl.models.GameModel;
import com.stencyl.models.scene.Layer;
import com.stencyl.graphics.transitions.Transition;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.Font;

import com.stencyl.models.Sound;
import com.stencyl.models.SoundChannel;

import com.stencyl.utils.HashMap;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;

import com.stencyl.utils.Kongregate;


//Actual scripts extend from this
class Script 
{
	//*-----------------------------------------------
	//* Data
	//*-----------------------------------------------
	
	public var wrapper:Behavior;
	public var engine:Engine;
	
	public var propertyChangeListeners:HashMap<Dynamic, Dynamic>;
	public var equalityPairs:HashMap<Dynamic, Dynamic>;
		
		
	//*-----------------------------------------------
	//* Constants
	//*-----------------------------------------------
	
	public static var FRONT:Int = 0;
	public static var MIDDLE:Int = 1;
	public static var BACK:Int = 2;
	
	public static var CHANNELS:Int = 32;
	
	
	//*-----------------------------------------------
	//* Data
	//*-----------------------------------------------
	
	public static var lastCreatedActor:Actor = null;
	/*public static var lastCreatedJoint:b2Joint = null;
	public static var lastCreatedRegion:Region = null;
	public static var lastCreatedTerrainRegion:TerrainRegion = null;*/
	
	public static var mpx:Float = 0;
	public static var mpy:Float = 0;
	public static var mrx:Float = 0;
	public static var mry:Float = 0;
		
		
	//*-----------------------------------------------
	//* Display Names
	//*-----------------------------------------------
	
	public var nameMap:Hash<Dynamic>;
		
		
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------
	
	public function new(engine:Engine) 
	{
		this.engine = engine;
		
		nameMap = new Hash<Dynamic>();	
		propertyChangeListeners = new HashMap<Dynamic, Dynamic>();
		equalityPairs = new HashMap<Dynamic, Dynamic>();
	}		

	//*-----------------------------------------------
	//* Internals
	//*-----------------------------------------------
	
	public function toInternalName(displayName:String)
	{
		if(nameMap == null)
		{
			return displayName;
		}
		
		var newName:String = nameMap.get(displayName);
		
		if(newName == null)
		{
			// the name is already internal, so just return it.
			return displayName;
		}
		
		else
		{
			return newName;
		}
	}
	
	public function forwardMessage(msg:String)
	{
	}
	
	public function clearListeners()
	{
		propertyChangeListeners = new HashMap<Dynamic, Dynamic>();
	}
	
	//*-----------------------------------------------
	//* Basics
	//*-----------------------------------------------

	public function init()
	{
	}
	
	public function update(elapsedTime:Float)
	{
	}
	
	public function draw(g:Graphics, x:Int, y:Int)
	{
	}
	
	//*-----------------------------------------------
	//* Event Registration
	//*-----------------------------------------------
	
	//Intended for auto code generation. Programmers should use init/update/draw instead.
	
	public function addWhenCreatedListener(a:Actor, func:Dynamic->Void)
	{			
		var isActorScript = Std.is(this, ActorScript);
		
		if(a == null)
		{
			trace("Error in " + wrapper.classname + ": Cannot add listener function to null actor.");
			return;
		}
		
		a.whenCreatedListeners.push(func);
		
		if(isActorScript)
		{
			cast(this, ActorScript).actor.registerListener(a.whenCreatedListeners, func);
		}
	}
	
	public function addWhenKilledListener(a:Actor, func:Dynamic->Void)
	{	
		var isActorScript = Std.is(this, ActorScript);
		
		if(a == null)
		{
			trace("Error in " + wrapper.classname + ": Cannot add listener function to null actor.");
			return;
		}
		
		a.whenKilledListeners.push(func);
		
		if(isActorScript)
		{
			cast(this, ActorScript).actor.registerListener(a.whenKilledListeners, func);
		}	
	}
					
	public function addWhenUpdatedListener(a:Actor, func:Float->Dynamic->Void)
	{
		var isActorScript = Std.is(this, ActorScript);
	
		if(a == null)
		{
			if(isActorScript)
			{
				a = cast(this, ActorScript).actor;
			}
		}
								
		var listeners:Array<Dynamic>;
		
		if(a != null)
		{
			listeners = a.whenUpdatedListeners;				
		}	
				
		else
		{
			listeners = engine.whenUpdatedListeners;
		}
		
		listeners.push(func);
						
		if(isActorScript)
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addWhenDrawingListener(a:Actor, func:Graphics->Int->Int->Dynamic->Void)
	{
		var isActorScript = Std.is(this, ActorScript);
	
		if(a == null)
		{
			if(isActorScript)
			{
				a = cast(this, ActorScript).actor;
			}
		}
								
		var listeners:Array<Dynamic>;
		
		if(a != null)
		{
			listeners = a.whenDrawingListeners;				
		}	
				
		else
		{
			listeners = engine.whenDrawingListeners;
		}
		
		listeners.push(func);
						
		if(isActorScript)
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	//*-----------------------------------------------
	//* Regions
	//*-----------------------------------------------
	
	//wait for Box2D
	
	//*-----------------------------------------------
	//* Terrain
	//*-----------------------------------------------
	
	//wait for Box2D
	
	//*-----------------------------------------------
	//* Behavior Status
	//*-----------------------------------------------
	
	/**
	 * Check if the current scene contains the given Behavior (by name)
	 *
	 * @param	behaviorName	The display name of the <code>Behavior</code>
	 * 
	 * @return	True if the scene contains the Behavior
	 */
	public function sceneHasBehavior(behaviorName:String):Bool
	{
		return engine.behaviors.hasBehavior(behaviorName);
	}
	
	/**
	 * Enable the given Behavior (by name) for the current scene
	 *
	 * @param	behaviorName	The display name of the <code>Behavior</code>
	 */
	public function enableBehaviorForScene(behaviorName:String)
	{
		engine.behaviors.enableBehavior(behaviorName);
	}
	
	/**
	 * Disable the given Behavior (by name) for the current scene
	 *
	 * @param	behaviorName	The display name of the <code>Behavior</code>
	 */
	public function disableBehaviorForScene(behaviorName:String)
	{
		engine.behaviors.disableBehavior(behaviorName);
	}
	
	/**
	 * Check if the current scene contains the given Behavior (by name) and if said behavior is enabled.
	 *
	 * @param	behaviorName	The display name of the <code>Behavior</code>
	 * 
	 * @return	True if the scene contains the Behavior AND said behavior is enabled
	 */
	public function isBehaviorEnabledForScene(behaviorName:String):Bool
	{
		return engine.behaviors.isBehaviorEnabled(behaviorName);
	}
	
	/**
	 * Disable the current Behavior. The rest of this script will continue running, and cessation
	 * happens for any future run.
	 */
	public function disableThisBehavior()
	{
		engine.behaviors.disableBehavior(wrapper.name);
	}
	
			
	//*-----------------------------------------------
	//* Messaging
	//*-----------------------------------------------
	
	/**
	 * Get the attribute value for a behavior attached to the scene.
	 */
	public function getValueForScene(behaviorName:String, attributeName:String):Dynamic
	{
		return engine.getValue(behaviorName, attributeName);
	}
	
	/**
	 * Set the value for an attribute of a behavior in the scene.
	 */
	public function setValueForScene(behaviorName:String, attributeName:String, value:Dynamic)
	{
		engine.setValue(behaviorName, attributeName, value);
	}
	
	/**
	 * Send a messege to this scene with optional arguments.
	 */
	public function shoutToScene(msg:String, args:Array<Dynamic>):Dynamic
	{
		return engine.shout(msg, args);
	}
	
	/**
	 * Send a messege to a behavior in this scene with optional arguments.
	 */		
	public function sayToScene(behaviorName:String, msg:String, args:Array<Dynamic>):Dynamic
	{
		return engine.say(behaviorName, msg, args);
	}
	
	//*-----------------------------------------------
	//* Game Attributes
	//*-----------------------------------------------
	
	/**
	 * Set a game attribute (pass a Number/Text/Boolean/List)
	 */		
	public function setGameAttribute(name:String, value:Dynamic)
	{
		engine.setGameAttribute(name, value);
	}
	
	/**
	 * Get a game attribute (Returns a Number/Text/Boolean/List)
	 */	
	public function getGameAttribute(name:String):Dynamic
	{
		return engine.getGameAttribute(name);
	}
		
	//*-----------------------------------------------
	//* Timing
	//*-----------------------------------------------
		
	/**
	 * Runs the given function after a delay.
	 *
	 * @param	delay		Delay in execution (in milliseconds)
	 * @param	toExecute	The function to execute after the delay
	 */
	public function runLater(delay:Int, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
	{
		var t:TimedTask = new TimedTask(toExecute, delay, false, actor);
		engine.addTask(t);

		return t;
	}
	
	/**
	 * Runs the given function periodically (every n seconds).
	 *
	 * @param	interval	How frequently to execute (in milliseconds)
	 * @param	toExecute	The function to execute after the delay
	 */
	public function runPeriodically(interval:Int, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
	{
		var t:TimedTask = new TimedTask(toExecute, interval, true, actor);
		engine.addTask(t);
		
		return t;
	}
	
	//*-----------------------------------------------
	//* Scene
	//*-----------------------------------------------
	
	/**
	 * Get the current scene.
	 *
	 * @return The current scene
	 */
	public function getScene():Scene
	{
		return engine.scene;
	}
	
	/**
	 * Get the ID of the current scene.
	 *
	 * @return The ID current scene
	 */
	public function getCurrentScene():Int
	{
		return getScene().ID;
	}
	
	/**
	 * Get the ID of a scene by name.
	 *
	 * @return The ID current scene or 0 if it doesn't exist.
	 */
	public function getIDForScene(sceneName:String):Int
	{
		for(s in GameModel.get().scenes)
		{
			if(sceneName == s.name)
			{
				return s.ID;	
			}
		}
		
		return 0;
	}
	
	/**
	 * Get the name of the current scene.
	 *
	 * @return The name of the current scene
	 */
	public function getCurrentSceneName():String
	{
		return getScene().name;
	}
	
	/**
	 * Get the width (in pixels) of the current scene.
	 *
	 * @return width (in pixels) of the current scene
	 */
	public function getSceneWidth():Int
	{
		return getScene().sceneWidth;
	}
	
	/**
	 * Get the height (in pixels) of the current scene.
	 *
	 * @return height (in pixels) of the current scene
	 */
	public function getSceneHeight():Int
	{
		return getScene().sceneHeight;
	}
	
	/**
	 * Get the width (in tiles) of the current scene.
	 *
	 * @return width (in tiles) of the current scene
	 */
	public function getTileWidth():Int
	{
		return getScene().tileWidth;
	}
	
	/**
	 * Get the height (in tiles) of the current scene.
	 *
	 * @return height (in tiles) of the current scene
	 */
	public function getTileHeight():Int
	{
		return getScene().tileHeight;
	}
	
	//*-----------------------------------------------
	//* Scene Switching
	//*-----------------------------------------------
	
	/**
	 * Reload the current scene, using an exit transition and then an enter transition.
	 *
	 * @param	leave	exit transition
	 * @param	enter	enter transition
	 */
	public function reloadCurrentScene(leave:Transition=null, enter:Transition=null)
	{
		engine.switchScene(getCurrentScene(), leave, enter);
	}
	
	/**
	 * Switch to the given scene, using an exit transition and then an enter transition.
	 *
	 * @param	sceneID		IT of the scene to switch to
	 * @param	leave		exit transition
	 * @param	enter		enter transition
	 */
	public function switchScene(sceneID:Int, leave:Transition=null, enter:Transition=null)
	{
		engine.switchScene(sceneID, leave, enter);
	}
	
	//*-----------------------------------------------
	//* Tile Layers
	//*-----------------------------------------------
	
	/**
     * Force the given layer to show.
     *
     * @param   layerID     ID of the layer
     */
    public function getLayer(layerID:Int):Layer
    {
    	return null;
        //return scene.layers[layerID] as Layer;
    }
	
	/**
	 * Force the given layer to show.
	 *
	 * @param	layerID		ID of the layer
	 */
	public function showTileLayer(layerID:Int)
	{
		//(scene.layers[layerID] as Layer).alpha = 255;
	}
	
	/**
	 * Force the given layer to become invisible.
	 *
	 * @param	layerID		ID of the layer
	 */
	public function hideTileLayer(layerID:Int)
	{
		//(scene.layers[layerID] as Layer).alpha = 0;
	}
	
	/**
	 * Force the given layer to fade to the given opacity over time, applying the easing function.
	 *
	 * @param	layerID		ID of the layer
	 * @param	alphaPct	the opacity (0-255) to fade to
	 * @param	duration	the duration of the fading (in milliseconds)
	 * @param	easing		easing function to apply. Linear (no smoothing) is the default.
	 */
	public function fadeTileLayerTo(layerID:Int, alphaPct:Int, duration:Float, easing:Dynamic = null)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		//Actuate.tween(scene.layers[layerID, duration, {alpha:alphaPct}).ease(easing);
	}
	
	//*-----------------------------------------------
	//* Camera
	//*-----------------------------------------------
	
	/**
	 * x-position of the camera
	 *
	 * @return The x-position of the camera
	 */
	public function getScreenX():Float
	{
		return Math.abs(Engine.cameraX);
	}
	
	/**
	 * y-position of the camera
	 *
	 * @return The y-position of the camera
	 */
	public function getScreenY():Float
	{
		return Math.abs(Engine.cameraY);
	}
	
	/**
	 * Returns the actor that represents the camera
	 *
	 * @return The actor representing the camera
	 */
	public function getCamera():Actor
	{
		return null;
	}
	
	//*-----------------------------------------------
	//* Input
	//*-----------------------------------------------
	
	//ALL DONE IN THE INPUT CLASS
	
	//*-----------------------------------------------
	//* Actor Creation
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Actor-Related Getters
	//*-----------------------------------------------
	
	/**
	 * Returns an ActorType by name
	 */
	public function getActorTypeByName(typeName:String):ActorType
	{
		var types = getAllActorTypes();
		
		for(type in types)
		{
			if(type.name == typeName)
			{
				return type;
			}
		}
		
		return null;
	}
	
	/**
	* Returns an ActorType by ID
	*/
	public function getActorType(actorTypeID:Int):ActorType
	{
		return cast(Data.get().resources.get(actorTypeID), ActorType);
	}
	
	/**
	* Returns an array of all ActorTypes in the game
	*/
	public function getAllActorTypes():Array<ActorType>
	{
		return null;
		//return Data.get().getAllActorTypes();
	}
	
	/**
	* Returns an array of all Actors of the given type in the scene
	*/
	public function getActorsOfType(type:ActorType):Array<Actor>
	{
		return null;
		//return engine.getActorsOfType(type);
	}
	
	/**
	* Returns an actor in the scene by ID
	*/
	public function getActor(actorID:Int):Actor
	{
		return null;
		//return engine.getActor(actorID);
	}
	
	/**
	* Returns an ActorGroup by ID
	*/
	public function getActorGroup(groupID:Int):Dynamic
	{
		return null;
		//return engine.getGroup(groupID);
	}
	
	//*-----------------------------------------------
	//* Joints
	//*-----------------------------------------------
	
	//wait for Box2D
	
	//*-----------------------------------------------
	//* Physics
	//*-----------------------------------------------
	
	//wait for Box2D
	
	//*-----------------------------------------------
	//* Sounds
	//*-----------------------------------------------
	
	public function mute()
	{
		//FlxG.mute = true;
	}
	
	public function unmute()
	{
		//FlxG.mute = false;
	}
	
	/**
	* Returns a SoundClip resource by ID
	*/
	public function getSound(soundID:Int):Sound
	{
		return cast(Data.get().resources.get(soundID), Sound);
	}
	
	/**
	* Play a specific SoundClip resource once (use loopSound() to play a looped version)
	*/
	public function playSound(clip:Sound)
	{
		if(clip != null)
		{				
			for(i in 0...CHANNELS)
			{
				var sc = engine.channels[i];
				
				if(sc.currentSound == null)
				{
					sc.playSound(clip);
					return;
				}
			}
		}			
	}
	
	/**
	* Loop a specific SoundClip resource (use playSound() to play only once)
	*/
	public function loopSound(clip:Sound)
	{
		if(clip != null)
		{				
			for(i in 0...CHANNELS)
			{
				var sc = engine.channels[i];
				
				if(sc.currentSound == null)
				{
					sc.loopSound(clip);
					return;
				}
			}
		}			
	}
	
	/**
	* Play a specific SoundClip resource once on a specific channel (use loopSoundOnChannel() to play a looped version)
	*/
	public function playSoundOnChannel(clip:Sound, channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];		
		sc.playSound(clip);			
	}
	
	/**
	* Play a specific SoundClip resource looped on a specific channel (use playSoundOnChannel() to play once)
	*/
	public function loopSoundOnChannel(clip:Sound, channelNum:Int)
	{		
		var sc:SoundChannel = engine.channels[channelNum];	
		sc.loopSound(clip);			
	}
	
	/**
	* Stop all sound on a specific channel (use pauseSoundOnChannel() to just pause)
	*/
	public function stopSoundOnChannel(channelNum:Int)
	{					
		var sc:SoundChannel = engine.channels[channelNum];
		sc.stopSound();
	}
	
	/**
	* Pause all sound on a specific channel (use stopSoundOnChannel() to stop it)
	*/
	public function pauseSoundOnChannel(channelNum:Int)
	{					
		var sc:SoundChannel = engine.channels[channelNum];	
		sc.setPause(true);			
	}
	
	/**
	* Resume all sound on a specific channel (must have been paused with pauseSoundOnChannel())
	*/
	public function resumeSoundOnChannel(channelNum:Int)
	{					
		var sc:SoundChannel = engine.channels[channelNum];		
		sc.setPause(false);			
	}
	
	/**
	* Set the volume of all sound on a specific channel (use decimal volume such as .5)
	*/
	public function setVolumeForChannel(volume:Float, channelNum:Int)
	{			
		var sc:SoundChannel = engine.channels[channelNum];		
		sc.setVolume(volume);
	}
	
	/**
	* Stop all the sounds currently playing (use mute() to mute the game).
	*/
	public function stopAllSounds()
	{			
		for(i in 0...CHANNELS)
		{
			var sc:SoundChannel = engine.channels[i];		
			sc.stopSound();
		}
	}
	
	/**
	* Set the volume for the game
	*/
	public function setVolumeForAllSounds(volume:Float)
	{
		SoundChannel.masterVolume = volume;
		
		for(i in 0...CHANNELS)
		{
			var sc:SoundChannel = engine.channels[i];
			sc.setVolume(volume);
		}
	}
	
	/**
	* Fade a specific channel's audio in over time (milliseconds)
	*/
	public function fadeInSoundOnChannel(channelNum:Int, time:Float)
	{						
		var sc:SoundChannel = engine.channels[channelNum];
		sc.fadeInSound(time);			
	}
	
	/**
	* Fade a specific channel's audio out over time (milliseconds)
	*/
	public function fadeOutSoundOnChannel(channelNum:Int, time:Float)
	{						
		var sc:SoundChannel = engine.channels[channelNum];
		sc.fadeOutSound(time);			
	}
	
	/**
	* Fade all audio in over time (milliseconds)
	*/
	public function fadeInForAllSounds(time:Float)
	{
		for(i in 0...CHANNELS)
		{
			var sc:SoundChannel = engine.channels[i];
			sc.fadeInSound(time);
		}
	}
	
	/**
	* Fade all audio out over time (milliseconds)
	*/
	public function fadeOutForAllSounds(time:Float)
	{
		for(i in 0...CHANNELS)
		{
			var sc:SoundChannel = engine.channels[i];	
			sc.fadeOutSound(time);
		}
	}
	
	
	//*-----------------------------------------------
	//* Background Manipulation (?)
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Eye Candy
	//*-----------------------------------------------
	
	/**
	* Begin screen shake
	*/
	public function startShakingScreen(intensity:Float=0.05, duration:Float=0.5)
	{
		//FlxG.quake.start(intensity, duration);
	}
	
	/**
	* End screen shake
	*/
	public function stopShakingScreen()
	{
		//FlxG.quake.stop();
	}
	
	//*-----------------------------------------------
	//* Terrain Changer (Tile API)
	//*-----------------------------------------------
	
	/**
	* Get the top terrain layer
	*/
	public function getTopLayer():Int
	{
		return 0;
		//return engine.getTopLayer();
	}
	
	/**
	* Get the bottom terrain layer
	*/
	public function getBottomLayer():Int
	{
		return 0;
		//return engine.getBottomLayer();
	}
	
	/**
	* Get the middle terrain layer
	*/
	public function getMiddleLayer():Int
	{
		return 0;
		//return engine.getMiddleLayer();
	}
	
	//*-----------------------------------------------
	//* Fonts
	//*-----------------------------------------------
	
	public function getFont(fontID:Int):Font
	{
		return cast(Data.get().resources.get(fontID), Font);
	}
	
	//*-----------------------------------------------
	//* Global
	//*-----------------------------------------------
	
	/**
	* Pause the game
	*/
	public function pauseAll()
	{
		Engine.paused = true;
	}
	
	/**
	* Unpause the game
	*/
	public function unpauseAll()
	{
		Engine.paused = false;
	}
	
	/**
	* Get the screen width in pixels
	*/
	public function getScreenWidth()
	{
		return Engine.screenWidth;
	}
	
	/**
	* Get the screen height in pixels
	*/
	public function getScreenHeight()
	{
		return Engine.screenHeight;
	}
	
	/**
	* Sets the distance an actor can travel offscreen before being deleted.
	*/
	public function setOffscreenTolerance(top:Int, left:Int, bottom:Int, right:Int)
	{
		Engine.paddingTop = top;
		Engine.paddingLeft = left;
		Engine.paddingRight = right;
		Engine.paddingBottom = bottom;
	}
	
	/**
	* Returns true if the scene is transitioning
	*/
	public function isTransitioning():Bool
	{
		return false;
		//return engine.isTransitioning();
	}
	
	/**
	* Adjust how fast or slow time should pass in the game; default is 1.0. 
	*/
	public function setTimeScale(scale:Float)
	{
		Engine.timeScale = scale;
	}
	
	/**
	 * Generates a random number. Deterministic, meaning safe to use if you want to record replays in random environments
	 */
	public function randomFloat():Float
	{
		return Math.random();
	}
	
	/**
	 * Generates a random number. Set the lowest and highest values.
	 */
	public function randomInt(low:Int, high:Int):Int
	{
		return low + Math.floor(randomFloat() * (high - low + 1));
	}
	
	/**
	* Change a Number to another specific Number over time  
	*/
	public function tweenNumber(attributeName:String, toValue:Float, duration:Float, easing:Dynamic) 
	{
		/*var params:Object = { time: duration / 1000, transition: easing };
		attributeName = toInternalName(attributeName);
		params[attributeName] = toValue;
		
		return Tweener.addTween(this, params);*/
		
		//TODO
	}
	
	/**
	* Stops a tween 
	*/
	public static function abortTween(target:Dynamic)
	{
		
	}
	
	//*-----------------------------------------------
	//* Saving
	//*-----------------------------------------------
	
	/**
	 * Saves a game to the "StencylSaves/[GameName]/[FileName]" location with an in-game displayTitle
	 *
	 * Callback = function(success:Boolean):void
	 */
	public function saveGame(fileName:String, fn:Bool->Void=null)
	{
		#if !js
		var so = SharedObject.getLocal(fileName);
		so.data.message = "<somexml></somexml>";
		#end
		
		//Prepare to save.. with some checks
		#if ( cpp || neko )
		        // Android didn't wanted SharedObjectFlushStatus not to be a String
		        var flushStatus:SharedObjectFlushStatus = null;
		#else
		        // Flash wanted it very much to be a String
		        var flushStatus:String = null;
		#end
		
		#if !js
		try 
		{
		    flushStatus = so.flush();
		} 
		
		catch(e:Dynamic) 
		{
			trace("Error: Failed to save");
		}
		
		if(flushStatus != null) 
		{
		    switch(flushStatus) 
		    {
		        case SharedObjectFlushStatus.PENDING:
		            //trace('requesting permission to save');
		        case SharedObjectFlushStatus.FLUSHED:
		            //trace('value saved');
		    }
		}
		#end
	}
	
	/**
  	 * Load a saved game
	 *
	 * Callback = function(success:Boolean):void
	 */
	public function loadGame(fileName:String, fn:Bool->Void=null)
	{
		#if !js
		var data = SharedObject.getLocal(fileName);
		trace('Loaded Save: ' + data.data.message);
		#end
	}
	
	/*
	 * Callback: function(success:Boolean, saveFile:String, isLast:Boolean):void
	 */
	public function retrieveSaves(fn:Bool->String->Bool->Void=null)
	{
		#if !js
		#end
	}
	
	//*-----------------------------------------------
	//* Web Services
	//*-----------------------------------------------
	
	private function defaultURLHandler(event:Event)
	{
		var loader:URLLoader = new URLLoader(event.target);
		trace("Visited URL: " + loader.data);
	}
	
	public function openURLInBrowser(URL:String)
	{
		Lib.getURL(new URLRequest(URL));
	}
		
	/**
	* Attempts to connect to a URL
	*/
	public function visitURL(URL:String, fn:Event->Void = null)
	{
		if(fn == null)
		{
			fn = defaultURLHandler;
		}
		
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, fn);
		
		var request:URLRequest = new URLRequest(URL);
		
		try 
		{
			loader.load(request);
		} 
		
		catch(error:String) 
		{
			trace("Cannot open URL.");
		}
	}
	
	/**
	* Attempts to POST data to a URL
	*/
	public function postToURL(URL:String, data:String = null, fn:Event->Void = null)
	{
		if(fn == null)
		{
			fn = defaultURLHandler;
		}
		
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, fn);
		
		var request:URLRequest = new URLRequest(URL);
		request.method = URLRequestMethod.POST;
		
		if(data != null) 
		{
			request.data = new URLVariables(data);
		}
		
		try 
		{
			loader.load(request);
		} 
		
		catch(error:String) 
		{
			trace("Cannot open URL.");
		}
	}
	
	//*-----------------------------------------------
	//* Social Media
	//*-----------------------------------------------
	
	/**
	* Send a Tweet (GameURL is the twitter account that it will be posted to)
	*/
	public function simpleTweet(message:String, gameURL:String)
	{
		openURLInBrowser("http://twitter.com/home?status=" + StringTools.urlEncode(message + " " + gameURL));
	}
	
	//*-----------------------------------------------
	//* Newgrounds
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Kongregate
	//*-----------------------------------------------
	
	#if flash
	public function initKongregateAPI()
	{
		Kongregate.initAPI();
	}
	
	public function submitScore(score:Float, mode:String) 
	{
		Kongregate.submitScore(score, mode);
	}
	
	public function submitStat(name:String, stat:Float) 
	{
		Kongregate.submitStat(name, stat);
	}
	#end
	
	//*-----------------------------------------------
	//* Mochi
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Debug
	//*-----------------------------------------------
	
	//box2d
	
	//*-----------------------------------------------
	//* Utilities
	//*-----------------------------------------------
	
}
