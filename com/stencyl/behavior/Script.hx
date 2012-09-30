package com.stencyl.behavior;

import nme.net.SharedObject;

import nme.ui.Mouse;
import nme.events.Event;
import nme.events.IOErrorEvent;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLRequestMethod;
import nme.net.URLVariables;
import nme.Lib;
import nme.filters.BitmapFilter;
import nme.text.TextField;

import nme.display.Graphics;

import com.stencyl.graphics.G;
import com.stencyl.models.scene.ScrollingBitmap;

import com.stencyl.models.Actor;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.GameModel;
import com.stencyl.models.scene.Layer;
import com.stencyl.models.Region;
import com.stencyl.models.Terrain;
import com.stencyl.graphics.transitions.Transition;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.Font;
import com.stencyl.models.Sound;
import com.stencyl.models.SoundChannel;

import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.Tileset;

import com.stencyl.utils.HashMap;

import com.stencyl.event.EventMaster;
import com.stencyl.event.NativeListener;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;

import box2D.collision.shapes.B2Shape;
import box2D.dynamics.joints.B2Joint;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Fixture;

#if flash
import flash.filters.ColorMatrixFilter;
import com.stencyl.utils.ColorMatrix;
#end

import scripts.MyAssets;

//XXX: For some reason, it wasn't working by importing nme.net.SharedObjectFlushedStatus
#if js
typedef JeashSharedObjectFlushStatus = jeash.net.SharedObjectFlushedStatus;
#end

//Actual scripts extend from this
class Script 
{
	//*-----------------------------------------------
	//* Data
	//*-----------------------------------------------
	
	public var wrapper:Behavior;
	
	public var engine:Engine;
	public var scene:Engine; //for compatibility - we'll remove it later
	
	public var propertyChangeListeners:Hash<Dynamic>;
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
	public static var lastCreatedJoint:B2Joint = null;
	public static var lastCreatedRegion:Region = null;
	public static var lastCreatedTerrainRegion:Terrain = null;
	
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
		this.engine = this.scene = engine;
		
		nameMap = new Hash<Dynamic>();	
		propertyChangeListeners = new Hash<Dynamic>();
		equalityPairs = new HashMap<Dynamic, Dynamic>();
	}		

	//*-----------------------------------------------
	//* Internals
	//*-----------------------------------------------
	
	public inline function sameAs(o:Dynamic, o2:Dynamic):Bool
	{
		return o == o2;
	}
	
	public inline function sameAsAny(o:Dynamic, one:Dynamic, two:Dynamic):Bool
	{
		return (o == one) || (o == two);
	}
	
	public inline function asBoolean(o:Dynamic):Bool
	{
		return (o == true || o == "true");
	}
	
	public static inline function strCompare(one:String, two:String, whichWay:Int):Bool
	{
		if(whichWay < 0)
		{
			return strCompareBefore(one, two);
		}
		
		else
		{
			return strCompareAfter(one, two);
		}
	}
	
	public static inline function strCompareBefore(a:String, b:String):Bool
	{
		return(a < b);
	} 
	
	public static inline function strCompareAfter(a:String, b:String):Bool
	{
		return(a > b);
	} 
	
	public inline function asNumber(o:Dynamic):Float
	{
		if(o == null)
		{
			return 0;
		}
		
		else if(Std.is(o, Bool))
		{
			return cast(o, Bool) ? 1 : 0;
		}
		
		else if(Std.is(o, String))
		{
			return Std.parseFloat(o);
		}
		
		else if(Std.is(o, Float) || Std.is(o, Int))
		{
			return o;
		}
		
		//Can't do it - return junk
		else
		{
			trace(o + " is not a number!");
			return 0;
		}
	}
		
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
		propertyChangeListeners = new Hash<Dynamic>();
	}
	
	//Physics = Pass in event.~Shape (a b2Shape)
	//No-Physics = Pass in the actor
	public function internalGetGroup(arg:Dynamic, arg2:Dynamic):Group
	{
		if(Engine.NO_PHYSICS)
		{
			return cast(arg, Actor).getGroup();
		}
		
		else
		{
			var fixture = cast(arg2, B2Fixture);
			return engine.getGroup(fixture.groupID, cast(fixture.getBody().getUserData(), Actor));
		}
	}
	
	//*-----------------------------------------------
	//* Basics
	//*-----------------------------------------------

	public function init()
	{
	}
	
	//*-----------------------------------------------
	//* Event Registration
	//*-----------------------------------------------
	
	//Intended for auto code generation. Programmers should use init/update/draw instead.
	
	//Native Listeners poll on a special place where events are infrequent. Do NOT attempt to use
	//for anything normal in the engine!
	
	public function addMobileAdListener(type:Int, func:Void->Void)
	{
		engine.nativeListeners.push(new NativeListener(EventMaster.TYPE_ADS, type, func));
	}
	
	public function addGameCenterListener(type:Int, func:String->Void)
	{
		engine.nativeListeners.push(new NativeListener(EventMaster.TYPE_GAMECENTER, type, func));
	}
	
	public function addPurchaseListener(type:Int, func:String->Void)
	{
		engine.nativeListeners.push(new NativeListener(EventMaster.TYPE_PURCHASES, type, func));
	}
	
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
	
	public function addWhenDrawingListener(a:Actor, func:G->Int->Int->Dynamic->Void)
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
	
	public function addActorEntersRegionListener(reg:Region, func:Dynamic->Array<Dynamic>->Void)
	{
		if(reg == null)
		{
			trace("Error in " + wrapper.classname +": Cannot add listener function to null region.");
			return;
		}
		
		reg.whenActorEntersListeners.push(func);
								
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(reg.whenActorEntersListeners, func);
		}
	}
	
	public function addActorExitsRegionListener(reg:Region, func:Dynamic->Array<Dynamic>->Void)
	{
		if(reg == null)
		{
			trace("Error in " + wrapper.classname +": Cannot add listener function to null region.");
			return;
		}
		
		reg.whenActorExitsListeners.push(func);
								
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(reg.whenActorExitsListeners, func);
		}
	}
	
	public function addActorPositionListener(a:Actor, func:Dynamic->Dynamic->Dynamic->Dynamic->Array<Dynamic>->Void)
	{
		if(a == null)
		{
			trace("Error in " + wrapper.classname + ": Cannot add listener function to null actor.");
			return;
		}
		
		a.positionListeners.push(func);
		a.positionListenerCount++;
								
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(a.positionListeners, func);
		}
	}
	
	public function addActorTypeGroupPositionListener(obj:Dynamic, func:Actor->Dynamic->Dynamic->Dynamic->Dynamic->Array<Dynamic>->Void)
	{
		if(!engine.typeGroupPositionListeners.exists(obj))
		{
			engine.typeGroupPositionListeners.set(obj, new Array<Dynamic>());
		}
		
		var listeners = cast(engine.typeGroupPositionListeners.get(obj), Array<Dynamic>);
		listeners.push(func);		
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addSwipeListener(func:Array<Dynamic>->Void)
	{
		#if(mobile && !air)
		engine.whenSwipedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenSwipedListeners, func);
		}
		#end
	}
	
	public function addKeyStateListener(key:String, func:Dynamic->Dynamic->Array<Dynamic>->Void)
	{			
		if(engine.whenKeyPressedListeners.get(key) == null)
		{
			engine.whenKeyPressedListeners.set(key, new Array<Dynamic>());
		}
		
		var listeners = engine.whenKeyPressedListeners.get(key);
		listeners.push(func);
								
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addMousePressedListener(func:Array<Dynamic>->Void)
	{
		engine.whenMousePressedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenMousePressedListeners, func);
		}
	}
	
	public function addMouseReleasedListener(func:Array<Dynamic>->Void)
	{
		engine.whenMouseReleasedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenMouseReleasedListeners, func);
		}
	}
	
	public function addMouseMovedListener(func:Array<Dynamic>->Void)
	{
		engine.whenMouseMovedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenMouseMovedListeners, func);
		}
	}
	
	public function addMouseDraggedListener(func:Array<Dynamic>->Void)
	{
		engine.whenMouseDraggedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenMouseDraggedListeners, func);
		}
	}
	
	public function addMouseOverActorListener(a:Actor, func:Int->Array<Dynamic>->Void)
	{	
		if(a == null)
		{
			trace("Error in " + wrapper.classname +": Cannot add listener function to null actor.");
			return;
		}
		
		a.mouseOverListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(a.mouseOverListeners, func);
		}
	}
	
	public function addPropertyChangeListener(propertyKey:String, propertyKey2:String, func:Dynamic->Array<Dynamic>->Void)
	{
		if(!propertyChangeListeners.exists(propertyKey))
		{
			propertyChangeListeners.set(propertyKey, new Array<Dynamic>());
		}
		
		//Equality block needs to be added to two listener lists
		if(propertyKey2 != null && !propertyChangeListeners.exists(propertyKey2))
		{
			propertyChangeListeners.set(propertyKey2, new Array<Dynamic>());
		}
		
		var listeners = propertyChangeListeners.get(propertyKey);
		var listeners2 = propertyChangeListeners.get(propertyKey2);
		
		listeners.push(func);			
		
		if(propertyKey2 != null)
		{
			listeners2.push(func);
			
			//If equality, keep note of other listener list
			var arr = new Array<Dynamic>();
			arr.push(listeners);
			arr.push(listeners2);
			equalityPairs.set(func, arr);
		}
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
			
			if(propertyKey2 != null)
			{
				cast(this, ActorScript).actor.registerListener(listeners2, func);
			}
		}
	}
	
	public function propertyChanged(propertyKey:String, property:Dynamic)
	{
		var listeners = propertyChangeListeners.get(propertyKey);
		
		if(listeners != null)
		{
			var r = 0;
		
			while(r < listeners.length)
			{
				try
				{
					var f:Dynamic->Array<Dynamic>->Void = listeners[r];			
					f(property, listeners);
					
					if(com.stencyl.utils.Utils.indexOf(listeners, f) == -1)
					{
						r--;
						
						//If equality, remove from other list as well
						if(equalityPairs.get(f) != null)
						{
							for(list in cast(equalityPairs.get(f), Array<Dynamic>))
							{
								if(list != listeners)
								{
									list.splice(com.stencyl.utils.Utils.indexOf(list, f), 1);
								}
							}
							
							equalityPairs.delete(f);
						}
					}
				}
				
				catch(e:String)
				{
					trace(e);
				}
				
				r++;
			}
		}
	}
	
	public function addCollisionListener(a:Actor, func:Collision->Array<Dynamic>->Void)
	{					
		if(a == null)
		{				
			trace("Error in " + wrapper.classname +": Cannot add listener function to null actor.");
			return;
		}
		
		a.collisionListeners.push(func);
		a.collisionListenerCount++;
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(a.collisionListeners, func);
		}
	}
	
	//Only used for type/group type/group collisions
	public function addSceneCollisionListener(obj:Dynamic, obj2:Dynamic, func:Collision->Array<Dynamic>->Void)
	{
		if(!engine.collisionListeners.exists(obj))
		{
			engine.collisionListeners.set(obj, new HashMap<Dynamic, Dynamic>());									
		}
		
		if(!engine.collisionListeners.exists(obj2))
		{
			engine.collisionListeners.set(obj2, new HashMap<Dynamic, Dynamic>());
		}	
		
		if(!engine.collisionListeners.get(obj).exists(obj2))
		{				
			engine.collisionListeners.get(obj).set(obj2, new Array<Dynamic>());			
		}
		
		var listeners = cast(engine.collisionListeners.get(obj).get(obj2), Array<Dynamic>);
		listeners.push(func);	
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addWhenTypeGroupCreatedListener(obj:Dynamic, func:Actor->Array<Dynamic>->Void)
	{
		if(!engine.whenTypeGroupCreatedListeners.exists(obj))
		{
			engine.whenTypeGroupCreatedListeners.set(obj, new Array<Dynamic>());
		}
		
		var listeners = engine.whenTypeGroupCreatedListeners.get(obj);
		listeners.push(func);		
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addWhenTypeGroupKilledListener(obj:Dynamic, func:Actor->Array<Dynamic>->Void)
	{
		if(!engine.whenTypeGroupDiesListeners.exists(obj))
		{
			engine.whenTypeGroupDiesListeners.set(obj, new Array<Dynamic>());
		}
		
		var listeners = engine.whenTypeGroupDiesListeners.get(obj);
		listeners.push(func);		
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addSoundListener(obj:Dynamic, func:Array<Dynamic>->Void)
	{
		if(!engine.soundListeners.exists(obj))
		{
			engine.soundListeners.set(obj, new Array<Dynamic>());
		}
		
		var listeners:Array<Dynamic> = engine.soundListeners.get(obj);
		listeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addFocusChangeListener(func:Bool->Array<Dynamic>->Void)
	{						
		engine.whenFocusChangedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenFocusChangedListeners, func);
		}
	}
	
	public function addPauseListener(func:Bool->Array<Dynamic>->Void)
	{						
		engine.whenPausedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenPausedListeners, func);
		}
	}
	
	//*-----------------------------------------------
	//* Regions
	//*-----------------------------------------------
	
	public function getLastCreatedRegion():Region
	{
		return lastCreatedRegion;
	}
	
	public function getAllRegions():Array<Region>
	{
		var regions = new Array<Region>();
		
		for(r in engine.regions)
		{
			if(r == null) continue;
			regions.push(r);
		}
		
		return regions;
	}
	
	public function getRegion(regionID:Int):Region
	{
		return engine.getRegion(regionID);
	}
	
	public function removeRegion(regionID:Int)
	{
		engine.removeRegion(regionID);
	}
		
	public function createBoxRegion(x:Float, y:Float, w:Float, h:Float):Region
	{
		return lastCreatedRegion = engine.createBoxRegion(x, y, w, h);
	}
			
	public function createCircularRegion(x:Float, y:Float, r:Float):Region
	{
		return lastCreatedRegion = engine.createCircularRegion(x, y, r);
	}
			
	public function isInRegion(a:Actor, r:Region):Bool
	{
		return engine.isInRegion(a, r);
	}
	
	public function getActorsInRegion(r:Region):Array<Actor>
	{
		var ids = r.getContainedActors();
		
		var toReturn = new Array<Actor>();
		
		for(i in ids)
		{
			toReturn.push(engine.getActor(i));
		}
		
		return toReturn;
	}
	
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
	public function shoutToScene(msg:String, args:Array<Dynamic> = null):Dynamic
	{
		return engine.shout(msg, args);
	}
	
	/**
	 * Send a messege to a behavior in this scene with optional arguments.
	 */		
	public function sayToScene(behaviorName:String, msg:String, args:Array<Dynamic> = null):Dynamic
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
	public function runLater(delay:Float, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
	{
		var t:TimedTask = new TimedTask(toExecute, Std.int(delay), false, actor);
		engine.addTask(t);

		return t;
	}
	
	/**
	 * Runs the given function periodically (every n seconds).
	 *
	 * @param	interval	How frequently to execute (in milliseconds)
	 * @param	toExecute	The function to execute after the delay
	 */
	public function runPeriodically(interval:Float, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
	{
		var t:TimedTask = new TimedTask(toExecute, Std.int(interval), true, actor);
		engine.addTask(t);
		
		return t;
	}
	
	public function getStepSize():Int
	{
		return Engine.STEP_SIZE;
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
	
	/**
	 * Create a pixelize out transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	pixelSize	size that pixels grow to
	 *
	 * @return Pixelize out transition that you pass into reloadScene and switchScene
	 */
	public function createPixelizeOut(duration:Float, pixelSize:Int = 15):Transition
	{
		return new com.stencyl.graphics.transitions.PixelizeTransition(duration, 1, pixelSize);
	}
		
	/**
	 * Create a pixelize in transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	pixelSize	size that pixels shrink from
	 *
	 * @return Pixelize in transition that you pass into reloadScene and switchScene
	 */
	public function createPixelizeIn(duration:Float, pixelSize:Int = 15):Transition
	{
		return new com.stencyl.graphics.transitions.PixelizeTransition(duration, pixelSize, 1);
	}
	
	/**
	 * Create a bubbles out transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	color		color to bubble out to. Default is black.
	 *
	 * @return Bubbles out transition that you pass into reloadScene and switchScene
	 */
	public function createBubblesOut(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.BubblesTransition(Transition.OUT, duration, 50, color);
	}
		
	/**
	 * Create a bubbles in transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	color		color to bubble in from. Default is black.
	 *
	 * @return Bubble in transition that you pass into reloadScene and switchScene
	 */
	public function createBubblesIn(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.BubblesTransition(Transition.IN, duration, 50, color);
	}
	
	/**
	 * Create a blinds out transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	color		color to blind out to. Default is black.
	 *
	 * @return Blinds out transition that you pass into reloadScene and switchScene
	 */
	public function createBlindsOut(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.BlindsTransition(Transition.OUT, duration, 10, color);
	}
		
	/**
	 * Create a blinds in transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	color		color to blind in from. Default is black.
	 *
	 * @return Blinds in transition that you pass into reloadScene and switchScene
	 */
	public function createBlindsIn(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.BlindsTransition(Transition.IN, duration, 10, color);
	}
		
	/**
	 * Create a rectangle out transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	color		color to fade out to. Default is black.
	 *
	 * @return Rectangle out transition that you pass into reloadScene and switchScene
	 */
	public function createRectangleOut(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.RectangleTransition(Transition.OUT, duration, color);
	}
		
	/**
	 * Create a rectangle in transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	color		color to fade in from. Default is black.
	 *
	 * @return Rectangle in transition that you pass into reloadScene and switchScene
	 */
	public function createRectangleIn(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.RectangleTransition(Transition.IN, duration, color);
	}
	
	/**
	 * Create a slide transition for use in scene switching.
	 *
	 * @param	duration	how long the transition lasts (in milliseconds)
	 * @param	direction	direction to slide the camera. Use direction constants from SlideTransition
	 *
	 * @return Slide transition that you pass into reloadScene and switchScene
	 */
	public function createSlideTransition(duration:Float, direction:String):Transition
	{
		return new com.stencyl.graphics.transitions.SlideTransition(engine.master, duration, direction);
	}
		
	//These are for SW's convenience.		
	public function createSlideUpTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_UP);
	}
		
	public function createSlideDownTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_DOWN);
	}
		
	public function createSlideLeftTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_LEFT);
	}
		
	public function createSlideRightTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_RIGHT);
	}
		
	public function createCrossfadeTransition(duration:Float):Transition
	{
		return new com.stencyl.graphics.transitions.CrossfadeTransition(engine.root, duration);
	}
	
	public function createFadeOut(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.FadeOutTransition(duration, color);
	}
	
	public function createFadeIn(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.FadeInTransition(duration, color);
	}
	
	public function createCircleOut(duration:Int, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.CircleTransition(Transition.OUT, duration, color);
	}
		
	public function createCircleIn(duration:Int, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.CircleTransition(Transition.IN, duration, color);
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
    	return engine.layers.get(layerID);
    }
    
    public function setBlendModeForLayer(layerID:Int, mode:nme.display.BlendMode)
    {
    	engine.layers.get(layerID).blendMode = mode;
		engine.actorsPerLayer.get(layerID).blendMode = mode;
    }
	
	/**
	 * Force the given layer to show.
	 *
	 * @param	layerID		ID of the layer
	 */
	public function showTileLayer(layerID:Int)
	{
		engine.layers.get(layerID).alpha = 255;
		engine.actorsPerLayer.get(layerID).alpha = 255;
	}
	
	/**
	 * Force the given layer to become invisible.
	 *
	 * @param	layerID		ID of the layer
	 */
	public function hideTileLayer(layerID:Int)
	{
		engine.layers.get(layerID).alpha = 0;
		engine.actorsPerLayer.get(layerID).alpha = 0;
	}
	
	/**
	 * Force the given layer to fade to the given opacity over time, applying the easing function.
	 *
	 * @param	layerID		ID of the layer
	 * @param	alphaPct	the opacity (0-255) to fade to
	 * @param	duration	the duration of the fading (in milliseconds)
	 * @param	easing		easing function to apply. Linear (no smoothing) is the default.
	 */
	public function fadeTileLayerTo(layerID:Int, alphaPct:Float, duration:Float, easing:Dynamic = null)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		Actuate.tween(engine.layers.get(layerID), duration, {alpha:alphaPct}).ease(easing);
		Actuate.tween(engine.actorsPerLayer.get(layerID), duration, {alpha:alphaPct}).ease(easing);
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
		return Math.abs(Engine.cameraX / Engine.SCALE);
	}
	
	/**
	 * y-position of the camera
	 *
	 * @return The y-position of the camera
	 */
	public function getScreenY():Float
	{
		return Math.abs(Engine.cameraY / Engine.SCALE);
	}
	
	/**
	 * Returns the actor that represents the camera
	 *
	 * @return The actor representing the camera
	 */
	public function getCamera():Actor
	{
		return engine.camera;
	}
	
	//*-----------------------------------------------
	//* Input
	//*-----------------------------------------------
	
	//Programmers: Use the Input class directly. It's much nicer.
	//We're keeping this API around for compatibility for now.
	
	public function isCtrlDown():Bool
	{
		return Input.check(Engine.INTERNAL_CTRL);
	}
	
	public function isShiftDown():Bool
	{
		return Input.check(Engine.INTERNAL_SHIFT);
	}
	
	public function simulateKeyPress(abstractKey:String)
	{
		Input.simulateKeyPress(abstractKey);
	}
	
	public function simulateKeyRelease(abstractKey:String)
	{
		Input.simulateKeyRelease(abstractKey);
	}

	public function isKeyDown(abstractKey:String):Bool
	{
		return Input.check(abstractKey);
	}

	public function isKeyPressed(abstractKey:String):Bool
	{
		return Input.pressed(abstractKey);
	}
	
	public function isKeyReleased(abstractKey:String):Bool
	{
		return Input.released(abstractKey);
	}
	
	public function isMouseDown():Bool
	{
		return Input.mouseDown;
	}
	
	public function isMousePressed():Bool
	{
		return Input.mousePressed;
	}

	public function isMouseReleased():Bool
	{
		return Input.mouseReleased;
	}
	
	public function getMouseX():Float
	{
		return Input.mouseX / Engine.SCALE;
	}

	public function getMouseY():Float
	{
		return Input.mouseY / Engine.SCALE;
	}
	
	public function getMouseWorldX():Float
	{
		return Input.mouseX / Engine.SCALE + Engine.cameraY;
	}
	
	public function getMouseWorldY():Float
	{
		return Input.mouseY / Engine.SCALE + Engine.cameraX;
	}
	
	public function getMousePressedX():Float
	{
		return mpx;
	}
	
	public function getMousePressedY():Float
	{
		return mpy;
	}

	public function getMouseReleasedX():Float
	{
		return mrx;
	}
	
	public function getMouseReleasedY():Float
	{
		return mry;
	}
	
	/*public function setCursor(graphic:Class=null, xOffset:int=0, yOffset:int=0);
	{
		FlxG.mouse.show(graphic, xOffset, yOffset);
	}*/

	public function showCursor()
	{
		Mouse.show();
	}

	public function hideCursor()
	{
		Mouse.hide();
	}
	
	//*-----------------------------------------------
	//* Actor Creation
	//*-----------------------------------------------
	
	public function getLastCreatedActor():Actor
	{
		return lastCreatedActor;
	}
	
	public function createActor(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		var a:Actor = engine.createActorOfType(type, x, y, layerConst);
		Script.lastCreatedActor = a;
		return a;
	}	
		
	public function createRecycledActor(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		var a:Actor = engine.getRecycledActorOfType(type, x, y, layerConst);		
		Script.lastCreatedActor = a;	
		return a;
	}
	
	public function recycleActor(a:Actor)
	{
		engine.recycleActor(a);
	}
		
	public function createActorInNextScene(type:ActorType, x:Float, y:Float, layerConst:Int)
	{
		engine.createActorInNextScene(type, x, y, layerConst);
	}
	
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
		return Data.get().getAllActorTypes();
	}
	
	/**
	* Returns an array of all Actors of the given type in the scene
	*/
	public function getActorsOfType(type:ActorType):Array<Actor>
	{
		return engine.getActorsOfType(type);
	}
	
	/**
	* Returns an actor in the scene by ID
	*/
	public function getActor(actorID:Int):Actor
	{
		return engine.getActor(actorID);
	}
	
	/**
	* Returns an ActorGroup by ID
	*/
	public function getActorGroup(groupID:Int):Group
	{
		return engine.getGroup(groupID);
	}
	
	//*-----------------------------------------------
	//* Joints
	//*-----------------------------------------------
	
	//wait for Box2D
	
	//*-----------------------------------------------
	//* Physics
	//*-----------------------------------------------
	
	//wait for Box2D
	
	public function setGravity(x:Float, y:Float)
	{
		engine.world.setGravity(new B2Vec2(x, y));
	}

	public function getGravity():B2Vec2
	{
		return engine.world.getGravity();
	}

	public function enableContinuousCollisions()
	{
		B2World.m_continuousPhysics = true;
	}
		
	public function toPhysicalUnits(value:Float):Float
	{
		return Engine.toPhysicalUnits(value);
	}

	public function toPixelUnits(value:Float):Float
	{
		return Engine.toPixelUnits(value);
	}
	
	public function makeActorNotPassThroughTerrain(actor:Actor)
	{
		B2World.m_continuousPhysics = true;
		
		if(actor != null && !actor.isLightweight)
		{
			actor.body.setBullet(true);
		}
	}
	
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
	//* Background Manipulation
	//*-----------------------------------------------
	
	/**
	* Set the speed of all scrolling backgrounds (Backgrounds must already be set to scrolling)
	*/
	public function setScrollSpeedForBackground(xSpeed:Float, ySpeed:Float)
	{
		for(i in 0...Engine.engine.master.numChildren)
		{
			var child = Engine.engine.master.getChildAt(i);
			
			//Background
			if(child.name == Engine.BACKGROUND)
			{
				if(Std.is(child, ScrollingBitmap))
				{
					var bg = cast(child, ScrollingBitmap);
					bg.xVelocity = xSpeed;
					bg.yVelocity = ySpeed;
				}
			}
		}
	}
	
	/**
	* Switches one background for another
	*/
	public function setBackground(oldBackName:String, newBackName:String)
	{
		/*var newBg:ImageBackground = Assets.get().resources[getIDForResource(newBackName)];
		
		if (newBg == null || !(newBg is ImageBackground))
		{
			print("Entered background does not exist");
			return;
		}
		
		for each (var bArea:Area in scene.parallax.backLayers)
		{		
			var oldBg:ImageBackground = bArea.getBackgroundImage();
			
			if (oldBg != null && oldBg.name == oldBackName)
			{
				bArea.setBackgroundImage(newBg);
				return;
			}
		}*/
	}
		
	//*-----------------------------------------------
	//* Eye Candy
	//*-----------------------------------------------
	
	/**
	* Begin screen shake
	*/
	public function startShakingScreen(intensity:Float=0.05, duration:Float=0.5)
	{
		engine.shakeScreen(intensity, duration);
	}
	
	/**
	* End screen shake
	*/
	public function stopShakingScreen()
	{
		engine.stopShakingScreen();
	}
	
	//*-----------------------------------------------
	//* Terrain Changer (Tile API)
	//*-----------------------------------------------
	
	/**
	* Get the top terrain layer
	*/
	public function getTopLayer():Int
	{
		return engine.getTopLayer();
	}
	
	/**
	* Get the bottom terrain layer
	*/
	public function getBottomLayer():Int
	{
		return engine.getBottomLayer();
	}
	
	/**
	* Get the middle terrain layer
	*/
	public function getMiddleLayer():Int
	{
		return engine.getMiddleLayer();
	}
	
	public function setTileAt(row:Int, col:Int, layerID:Int, tilesetID:Int, tileID:Int)
	{
		var tlayer = engine.tileLayers.get(layerID);
		
		if(tlayer == null)
		{
			return;
		}
		
		var tset = cast(Data.get().resources.get(tilesetID), Tileset);
		var tile:Tile = tset.tiles[tileID];
		
		//add the Tile to the TileLayer
		tlayer.setTileAt(row, col, tile);    
		
		//If animated tile, add to update list
		if(tile != null && tile.pixels != null && com.stencyl.utils.Utils.contains(engine.animatedTiles, tile))
		{
			engine.animatedTiles.push(tile);
		}
		
		//Now add the shape as a body
		if(tile != null && tile.collisionID != -1)
		{
			var tileShape = GameModel.get().shapes.get(tile.collisionID);
			var x = col * getTileWidth();
			var y = row * getTileHeight();
			
			if(tileShape != null)
			{
				engine.createDynamicTile(tileShape, toPhysicalUnits(x), toPhysicalUnits(y), layerID, getTileWidth(), getTileHeight());
			}
		}
	}
	
	public function tileExistsAt(row:Int, col:Int, layerID:Int):Bool
	{
		return getTileAt(row, col, layerID) != null;
	}
	
	public function getTileAt(row:Int, col:Int, layerID:Int):Tile
	{
		var tlayer = engine.tileLayers.get(layerID);
		
		if(tlayer == null)
		{
			return null;
		}
		
		return tlayer.getTileAt(row, col);
	}
	
	public function removeTileAt(row:Int, col:Int, layerID:Int)
	{
		var tlayer = engine.tileLayers.get(layerID);
		
		if(tlayer == null)
		{
			return;
		}
		
		//grab the tile to get the shape
		var tile:Tile = getTileAt(row, col, layerID);
		
		//If we find a tile in this location
		if(tile != null)
		{
			//Remove the collision box
			if(tile.collisionID != -1)
			{
				var x = col * getTileWidth();
				var y = row * getTileHeight();
				var key = "ID" + "-" + x + "-" + y + "-" + layerID;
				var a = engine.dynamicTiles.get(key);
				
				if(a != null)
				{
					engine.removeActor(a);
					engine.dynamicTiles.remove(key);
				}
			}
			
			//Remove the tile image
			tlayer.setTileAt(row, col, null);
		}
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
	
	public function pause()
	{
		engine.pause();
	}
	
	public function unpause()
	{
		engine.unpause();
	}
	
	public function toggleFullScreen()
	{
		#if((flash && !air) || (cpp && !mobile))
		Engine.engine.toggleFullscreen();
		#end
	}
		
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
		return engine.isTransitioning();
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
	public function randomInt(low:Float, high:Float):Int
	{
		return Std.int(low) + Math.floor(randomFloat() * (Std.int(high) - Std.int(low) + 1));
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
	public function saveGame(fileName:String, onComplete:Bool->Void=null)
	{
		var so = SharedObject.getLocal(fileName);
		
		for(key in engine.gameAttributes.keys())
		{
			Reflect.setField(so.data, key, engine.gameAttributes.get(key));
		}	

		#if (cpp || neko)
		var flushStatus:nme.net.SharedObjectFlushStatus = null;
		#else
		var flushStatus:String = null;
		#end
		
		try 
		{
		    flushStatus = so.flush();
		} 
		
		catch(e:Dynamic) 
		{
			trace("Error: Failed to save - " + fileName +  " - " + e);
			//TODO: Event
			onComplete(false);
			return;
		}
		
		trace(flushStatus);
		
		if(flushStatus != null) 
		{
		    switch(flushStatus) 
		    {
		    	#if js
		    	case JeashSharedObjectFlushStatus.PENDING:
		            //trace('requesting permission to save');
		        case JeashSharedObjectFlushStatus.FLUSHED:
		            trace("Saved Game: " + fileName);
		            onComplete(true);
		            //TODO: Event
		    	#end
		    	
		    	#if !js
		        case nme.net.SharedObjectFlushStatus.PENDING:
		            //trace('requesting permission to save');
		        case nme.net.SharedObjectFlushStatus.FLUSHED:
		            trace("Saved Game: " + fileName);
		            onComplete(true);
		            //TODO: Event
		        #end
		    }
		}
	}
	
	/**
  	 * Load a saved game
	 *
	 * Callback = function(success:Boolean):void
	 */
	public function loadGame(fileName:String, onComplete:Bool->Void=null)
	{
		var data = SharedObject.getLocal(fileName);
		
		trace("Loaded Save: " + fileName);
		
		for(key in Reflect.fields(data.data))
		{
			trace(key + " - " + Reflect.field(data.data, key));		
			engine.gameAttributes.set(key, Reflect.field(data.data, key));
		}
		
		onComplete(true);
	}
	
	//*-----------------------------------------------
	//* Web Services
	//*-----------------------------------------------
	
	private function defaultURLHandler(event:Event)
	{
		var loader:URLLoader = new URLLoader(event.target);
		trace("Visited URL: " + loader.data);
	}
	
	#if flash
	private function defaultURLError(event:IOErrorEvent)
	{
		trace("Could not visit URL");
	}
	#end
	
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
		
		try 
		{
			var request = new URLRequest(URL);
			request.method = URLRequestMethod.GET;
			
			var loader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, fn);
			
			#if flash
			loader.addEventListener(IOErrorEvent.NETWORK_ERROR, defaultURLError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, defaultURLError);
			#end
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
		
		var request:URLRequest = new URLRequest(URL);
		request.method = URLRequestMethod.POST;
		
		if(data != null) 
		{
			request.data = new URLVariables(data);
		}
		
		try 
		{
			var loader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, fn);
			
			#if flash
			loader.addEventListener(IOErrorEvent.NETWORK_ERROR, defaultURLError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, defaultURLError);
			#end
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
	
	#if(flash && !air)
	private static var medalPopup:com.newgrounds.components.MedalPopup = null;
	private static var clickArea:TextField = null;
	private static var scoreBrowser:com.newgrounds.components.ScoreBrowser = null;
	#end
	
	public function newgroundsShowAd()
	{
		#if(flash && !air)
		var flashAd = new com.newgrounds.components.FlashAd();
		flashAd.fullScreen = true;
		flashAd.showPlayButton = true;
		flashAd.mouseChildren = true;
		flashAd.mouseEnabled = true;
		Engine.engine.root.parent.addChild(flashAd);
		#end
	}
	
	public function newgroundsSetMedalPosition(x:Int, y:Int)
	{
		#if(flash && !air)
		if(medalPopup == null)
		{
			medalPopup = new com.newgrounds.components.MedalPopup();
			Engine.engine.root.parent.addChild(medalPopup);
		}
		
		medalPopup.x = x;
		medalPopup.y = y;
		#end
	}
	
	public function newgroundsUnlockMedal(medalName:String)
	{
		#if(flash && !air)
		if(medalPopup == null)
		{
			medalPopup = new com.newgrounds.components.MedalPopup();
			Engine.engine.root.parent.addChild(medalPopup);
		}
		
		com.newgrounds.API.API.unlockMedal(medalName);
		#end
	}
	
	public function newgroundsSubmitScore(boardName:String, value:Float)
	{
		#if(flash && !air)
		com.newgrounds.API.API.postScore(boardName, value);
		#end
	}
	
	public function newgroundsShowScore(boardName:String)
	{
		#if(flash && !air)
		if(scoreBrowser == null)
		{
			scoreBrowser = new com.newgrounds.components.ScoreBrowser();
			scoreBrowser.scoreBoardName = boardName;
			scoreBrowser.period = com.newgrounds.ScoreBoard.ALL_TIME;
			scoreBrowser.loadScores();
			
			scoreBrowser.x = Engine.screenWidth/2*Engine.SCALE - scoreBrowser.width/2;
			scoreBrowser.y = Engine.screenHeight/2*Engine.SCALE - scoreBrowser.height/2;
			
			var button = new nme.display.Sprite();
			button.x = 8;
			button.y = scoreBrowser.height - 31;
			
			button.graphics.beginFill(0x0aaaaaa);
     		button.graphics.drawRoundRect(0, 0, 50, 20, 8, 8);
     		button.graphics.endFill();
			
			button.graphics.beginFill(0x713912);
     		button.graphics.drawRoundRect(1, 1, 50 - 2, 20 - 2, 8, 8);
     		button.graphics.endFill();
     		
			clickArea = new TextField();
			clickArea.selectable = false;
			clickArea.x = button.x + 9;
			clickArea.y = button.y + 3;
			clickArea.width = 50;
			clickArea.height = 20;
			clickArea.textColor = 0xffffff;
			clickArea.text = "Close";	
			
			scoreBrowser.addChild(button);
			scoreBrowser.addChild(clickArea);
			
			clickArea.addEventListener
			(
				nme.events.MouseEvent.CLICK,
				newgroundsHelper
			);
		}
		
		Engine.engine.root.parent.addChild(scoreBrowser);
		#end
	}
		
	private function newgroundsHelper(event:nme.events.MouseEvent)
	{
		#if(flash && !air)
		Engine.engine.root.parent.removeChild(scoreBrowser);
		#end
	}
	
	//*-----------------------------------------------
	//* Kongregate
	//*-----------------------------------------------

	public function kongregateInitAPI()
	{
		#if(flash && !air)
		com.stencyl.utils.Kongregate.initAPI();
		#end
	}
	
	public function kongregateSubmitStat(name:String, stat:Float) 
	{
		#if(flash && !air)
		com.stencyl.utils.Kongregate.submitStat(name, stat);
		#end
	}
	
	public function kongregateIsGuest():Bool
	{
		#if(flash && !air)
		return com.stencyl.utils.Kongregate.isGuest();
		#else
		return true;
		#end
	}
	
	public function kongregateGetUsername():String
	{
		#if(flash && !air)
		return com.stencyl.utils.Kongregate.getUsername();
		#else
		return "Guest";
		#end
	}
	
	public function kongregateGetUserID():Int
	{
		#if(flash && !air)
		return com.stencyl.utils.Kongregate.getUserID();
		#else
		return 0;
		#end
	}
	
	//*-----------------------------------------------
	//* Mochi
	//*-----------------------------------------------
	
	public function mochiShowAd(width:Int, height:Int)
	{
		#if(flash && !air)
		mochi.as3.MochiAd.showInterLevelAd
		(
			{
				clip:Engine.movieClip, 
				id:MyAssets.mochiID, 
				res: width + "x" + height, 
				ad_started:function():Void
				{
					trace("Ad Started");
					Engine.movieClip.mouseEnabled = true;
					Engine.movieClip.mouseChildren = true;
				}, 
				ad_finished:function():Void
				{
					trace("Ad Ended");
					Engine.movieClip.mouseEnabled = false;
					Engine.movieClip.mouseChildren = false;
				}
			}
		);
		#end
	}
	
	public function mochiShowScores(boardID:String)
	{
		#if(flash && !air)
		mochi.as3.MochiScores.showLeaderboard
		(
			{
				boardID:boardID, 
				onDisplay:function():Void
				{
					trace("Board Shown");
				}, 
				onClose:function():Void
				{
					trace("Board Closed");
				}
			}
		);
		#end
	}
	
	public function mochiSubmitScore(boardID:String, score:Float)
	{
		#if(flash && !air)
		mochi.as3.MochiScores.showLeaderboard
		(
			{
				boardID:boardID, 
				score:score, 
				onDisplay:function():Void
				{
					trace("Board Shown");
				}, 
				onClose:function():Void
				{
					trace("Board Closed");
				}
			}
		);
		#end
	}
	
	//*-----------------------------------------------
	//* Mobile
	//*-----------------------------------------------
	
	//Ads
	
	public function showMobileAd(position:Int = 0)
	{
		#if (mobile && !android && !air)
		Ads.initialize();
		Ads.showAd(position);
		#end
		
		#if android
		Ads.showAd(position);
		#end
	}
	
	public function hideMobileAd()
	{
		#if (mobile && !android && !air)
		Ads.initialize();
		Ads.hideAd();
		#end
		
		#if android
		Ads.hideAd();
		#end
	}
	
	//Game Center
	
	public function gameCenterInitialize():Void 
	{
		#if (mobile && !android && !air)
			GameCenter.initialize();
		#end	
	}
	
	public function gameCenterIsAuthenticated():Bool 
	{
		#if (mobile && !android && !air)
			return GameCenter.isAuthenticated();
		#else
			return false;
		#end
	}
	
	public function gameCenterGetPlayerName():String 
	{
		#if (mobile && !android && !air)
			return GameCenter.getPlayerName();
		#else
			return "None";
		#end
	}
	
	public function gameCenterGetPlayerID():String 
	{
		#if (mobile && !android && !air)
			return GameCenter.getPlayerID();
		#else
			return "None";
		#end
	}
	
	public function gameCenterShowLeaderboard(categoryID:String):Void 
	{
		#if (mobile && !android && !air)
			GameCenter.showLeaderboard(categoryID);
		#end	
	}
	
	public function gameCenterShowAchievements():Void 
	{
		#if (mobile && !android && !air)
			GameCenter.showAchievements();
		#end	
	}
	
	public function gameCenterSubmitScore(score:Int, categoryID:String):Void 
	{
		#if (mobile && !android && !air)
			GameCenter.reportScore(categoryID, score);
		#end	
	}
	
	public function gameCenterSubmitAchievement(achievementID:String, percent:Float):Void 
	{
		#if (mobile && !android && !air)
			GameCenter.reportAchievement(achievementID, percent);
		#end	
	}
	
	public function gameCenterResetAchievements():Void 
	{
		#if (mobile && !android && !air)
			GameCenter.resetAchievements();
		#end	
	}
	
	//Purchases
	
	public function purchasesAreInitialized():Bool 
	{
		#if (mobile && !android && !air)
			return Purchases.canBuy();
		#else
			return false;
		#end
	}
	
	public function purchasesRestore():Void 
	{
		#if (mobile && !android && !air)
			Purchases.restorePurchases();
		#end	
	}
	
	public function purchasesBuy(productID:String):Void 
	{
		#if (mobile && !android)
			Purchases.buy(productID);
		#end	
	}
	
	public function purchasesHasBought(productID:String):Bool 
	{
		#if (mobile && !android && !air)
			return Purchases.hasBought(productID);
		#else
			return false;
		#end
	}
	
	public function purchasesGetTitle(productID:String):String 
	{
		#if (mobile && !android && !air)
			return Purchases.getTitle(productID);
		#else
			return "";
		#end
	}
	
	public function purchasesGetDescription(productID:String):String 
	{
		#if (mobile && !android && !air)
			return Purchases.getDescription(productID);
		#else
			return "";
		#end
	}
	
	public function purchasesGetPrice(productID:String):String 
	{
		#if (mobile && !android && !air)
			return Purchases.getPrice(productID);
		#else
			return "";
		#end
	}
	
	//Consumables
	
	public function purchasesUse(productID:String):Void 
	{
		#if (mobile && !android && !air)
			Purchases.use(productID);
		#end	
	}
	
	public function purchasesGetQuantity(productID:String):Int 
	{
		#if (mobile && !android && !air)
			return Purchases.getQuantity(productID);
		#else
			return 0;
		#end
	}
	
	//*-----------------------------------------------
	//* Native
	//*-----------------------------------------------
	
	public function showAlert(title:String, msg:String)
	{
		#if(mobile && !air)
		Native.showAlert(title, msg);
		#end
	}
	
	public function vibrate(time:Float)
	{
		#if(mobile && !air)
		Native.vibrate(time);
		#end
	}
	
	public function showKeyboard()
	{
		#if(mobile && !air)
		Native.showKeyboard();
		#end
	}
	
	public function hideKeyboard()
	{
		#if(mobile && !air)
		Native.hideKeyboard();
		#end
	}
	
	public function setIconBadgeNumber(n:Int)
	{
		#if(mobile && !air)
		Native.setIconBadgeNumber(n);
		#end
	}
	
	//*-----------------------------------------------
	//* Debug
	//*-----------------------------------------------
	
	public function enableDebugDrawing()
	{
		Engine.DEBUG_DRAW = true;
		Engine.debugDrawer.m_sprite.graphics.clear();
	}

	public function disableDebugDrawing()
	{
		Engine.DEBUG_DRAW = false;
		Engine.debugDrawer.m_sprite.graphics.clear();
	}
	
	//*-----------------------------------------------
	//* Utilities
	//*-----------------------------------------------
	
	//Flash only till NME supports ColorMatrixFilter!
	
	#if (cpp || js)
	public function createGrayscaleFilter():BitmapFilter
	{
		return new BitmapFilter("");
	}
	
	public function createSepiaFilter():BitmapFilter
	{
		return new BitmapFilter("");
	}
	
	public function createNegativeFilter():BitmapFilter
	{
		return new BitmapFilter("");
	}
	
	public function createTintFilter(color:Int, amount:Float = 1):BitmapFilter
	{
		return new BitmapFilter("");
	}
	
	public function createHueFilter(h:Float):BitmapFilter
	{
		return new BitmapFilter("");
	}

	public function createSaturationFilter(s:Float):BitmapFilter
	{
		return new BitmapFilter("");
	}

	public function createBrightnessFilter(b:Float):BitmapFilter
	{
		return new BitmapFilter("");
	}
	#end
	
	#if flash
	public function createGrayscaleFilter():ColorMatrixFilter
	{
		var matrix:Array<Dynamic> = new Array<Dynamic>();
		
		matrix = matrix.concat([0.5,0.5,0.5,0,0]);
		matrix = matrix.concat([0.5,0.5,0.5,0,0]);
		matrix = matrix.concat([0.5,0.5,0.5,0,0]);
		matrix = matrix.concat([0,0,0,1,0]);
		
		return new ColorMatrixFilter(matrix);
	}
	
	/**
	* Returns a ColorMatrixFilter that is sepia colored 
	*/
	public function createSepiaFilter():ColorMatrixFilter
	{
		var matrix:Array<Dynamic> = new Array<Dynamic>();
		
		matrix = matrix.concat([0.34, 0.33, 0.33, 0.00, 30.00]);
		matrix = matrix.concat([0.33, 0.34, 0.33, 0.00, 20.00]);
		matrix = matrix.concat([0.33, 0.33, 0.34, 0.00, 0.00]);
		matrix = matrix.concat([0.00, 0.00, 0.00, 1.00, 0.00]);
		
		return new ColorMatrixFilter(matrix);
	}
	
	/**
	* Returns a ColorMatrixFilter that is a negative
	*/
	public function createNegativeFilter():ColorMatrixFilter
	{
		var matrix:Array<Dynamic> = new Array<Dynamic>();
		
		matrix = matrix.concat([-1, 0, 0, 0, 255]);
		matrix = matrix.concat([0, -1, 0, 0, 255]);
		matrix = matrix.concat([0, 0, -1, 0, 255]);
		matrix = matrix.concat([0, 0, 0, 1, 0]);
		
		return new ColorMatrixFilter(matrix);
	}
	
	/**
	* Returns a ColorMatrixFilter that is a specific color
	*/
	public function createTintFilter(color:Int, amount:Float = 1):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.colorize(color, amount);
		
		return cm.getFilter();
	}
	
	/*
	h is in degrees (RELATIVE)
	s is [0-2 where 1 is reset] (ABSOLUTE)
	b is [0-100] (RELATIVE)
	*/
	/**
	* Returns a ColorMatrixFilter that adjusts hue (in relative degrees) 
	*/
	public function createHueFilter(h:Float):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.adjustHue(h);
		cm.adjustSaturation(1);
		
		return cm.getFilter();
	}
	
	/**
	* Returns a ColorMatrixFilter that adjusts saturation (measured 0 - 2 with 1 being normal) 
	*/
	public function createSaturationFilter(s:Float):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.adjustSaturation(s/100);
		
		return cm.getFilter();
	}
	
	/**
	* Returns a ColorMatrixFilter that adjusts brightness (in relative degrees) 
	*/
	public function createBrightnessFilter(b:Float):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.adjustBrightness(b);
		
		return cm.getFilter();
	}
		
	#end	
}
