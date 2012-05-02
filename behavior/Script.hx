package behavior;

import nme.display.Graphics;

import models.Actor;

//Actual scripts extend from this
class Script 
{
	public var wrapper:Behavior;
	public var engine:Engine;
	
	public var nameMap:Hash<Dynamic>;
		
	public function new(engine:Engine) 
	{
		this.engine = engine;
		
		nameMap = new Hash<Dynamic>();
	
		mountEvents();		
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

	public function mountEvents()
	{
		//Editor generates the junk here - can these refer to attributes though?!
		
		var updateEvent = function(elapsedTime:Float) 
		{ 
			
		};
		
		updateEvent(10);
	}
	
	//*-----------------------------------------------
	//* Event Registration
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Regions
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Terrain
	//*-----------------------------------------------
	
	
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
	
	//*-----------------------------------------------
	//* Scene Switching
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Tile Layers
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Camera
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Input
	//*-----------------------------------------------
	
	//ALL DONE IN THE INPUT CLASS
	
	//*-----------------------------------------------
	//* Actor Creation
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Actor Getters
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Joints
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Physics
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Sounds
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Background Manipulation (?)
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Eye Candy
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Terrain Changer
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Fonts
	//*-----------------------------------------------
	
	//Moved to Data class
	
	//*-----------------------------------------------
	//* Global
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Saving
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Web Services
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Social Media
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Newgrounds
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Kongregate
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Mochi
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Debug
	//*-----------------------------------------------
	
	//*-----------------------------------------------
	//* Utilities
	//*-----------------------------------------------
	
}
