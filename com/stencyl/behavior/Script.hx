package com.stencyl.behavior;

import openfl.net.SharedObject;

import openfl.ui.Mouse;
import openfl.events.Event as FlashEvent;
import openfl.events.IOErrorEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.Lib;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.text.TextField;
import openfl.errors.SecurityError;

import openfl.system.Capabilities;
import openfl.display.Stage;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Graphics;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import com.stencyl.graphics.G;
import com.stencyl.models.scene.ScrollingBitmap;

import com.stencyl.Config;
import com.stencyl.event.Event;
import com.stencyl.models.Actor;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.CollisionPoint;
import com.stencyl.models.actor.Group;
import com.stencyl.models.background.ColorBackground;
import com.stencyl.models.background.GradientBackground;
import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.Scene;
import com.stencyl.models.GameModel;
import com.stencyl.models.scene.layers.BackgroundLayer;
import com.stencyl.models.scene.layers.RegularLayer;
import com.stencyl.models.scene.Layer;
import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.Tileset;
import com.stencyl.models.scene.TileLayer;
import com.stencyl.models.Region;
import com.stencyl.models.Resource;
import com.stencyl.models.Terrain;
import com.stencyl.graphics.BitmapWrapper;
import com.stencyl.graphics.fonts.BitmapFont;
import com.stencyl.graphics.transitions.Transition;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.Font;
import com.stencyl.models.Sound;
import com.stencyl.models.SoundChannel;

import com.stencyl.utils.motion.*;
import com.stencyl.utils.Assets;
import com.stencyl.utils.Utils;
import com.stencyl.utils.ColorMatrix;
import com.stencyl.io.SpriteReader;

#if mobile
import com.stencyl.native.Native;
#end

import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.joints.B2Joint;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Fixture;

import haxe.ds.ObjectMap;

import openfl.utils.ByteArray;
import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import haxe.io.BytesData;
import lime.app.Application;

using com.stencyl.event.EventDispatcher;
using lime._internal.unifill.Unifill;

//Actual scripts extend from this
class Script 
{
	//*-----------------------------------------------
	//* Global
	//*-----------------------------------------------
	
	public static var engine:Engine;
	
	//*-----------------------------------------------
	//* Constants
	//*-----------------------------------------------
	
	public static inline var FRONT:Int = 0;
	public static inline var MIDDLE:Int = 1;
	public static inline var BACK:Int = 2;
	
	public static inline var CHANNELS:Int = 32;
	
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
	
	public static var dummyVec:B2Vec2 = new B2Vec2();
	
	public static var imageApiAutoscale = true;
	
	public static function resetStatics():Void
	{
		engine = null;
		lastCreatedActor = null;
		lastCreatedJoint = null;
		lastCreatedRegion = null;
		lastCreatedTerrainRegion = null;
		mpx = 0; mpy = 0; mrx = 0; mry = 0;
		imageApiAutoscale = true;
	}

	//*-----------------------------------------------
	//* Behavior
	//*-----------------------------------------------

	public var wrapper:Behavior;

	// Property Change Support
	
	public var propertyChangeEvents:Map<String, Event<()->Void>>;
	public var equalityPairs:ObjectMap<Dynamic, Dynamic>; //hashmap does badly on some platforms when checking key equality (for primitives) - beware
	
	public var checkProperties:Bool;
	
	// Display Names
	
	public var nameMap:Map<String,Dynamic>;
	
	private var attributeTweens:Map<String, TweenFloat>;
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------
	public var scriptInit:Bool;
	
	public function new()
	{
		scriptInit = false;
		checkProperties = false;
		nameMap = new Map<String,Dynamic>();	
		propertyChangeEvents = new Map<String, Event<()->Void>>();
		equalityPairs = new ObjectMap<Dynamic, Dynamic>();
		attributeTweens = new Map<String, TweenFloat>();
	}

	//*-----------------------------------------------
	//* Internals
	//*-----------------------------------------------
	
	public static inline function sameAs(o:Dynamic, o2:Dynamic):Bool
	{
		return o == o2;
	}
	
	public static inline function sameAsAny(o:Dynamic, one:Dynamic, two:Dynamic):Bool
	{
		return (o == one) || (o == two);
	}
	
	public static function asBoolean(o:Dynamic):Bool
	{
		if (o == true)
		{
			return true;
		}
		else if (o == "true")
		{
			return true;
		}
		else
		{
			return false;
		}
		//return (o == true || o == "true"); // This stopped working in 3.5: http://community.stencyl.com/index.php?issue=845.0
	}
	
	public static function strCompare(one:String, two:String, whichWay:Int):Bool
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
	
	public static function asNumber(o:Dynamic):Float
	{
		if(o == null)
		{
			return 0;
		}

		else if(Std.isOfType(o, Float))
		{
			return cast(o, Float);
		}
		
		else if(Std.isOfType(o, Int))
		{
			return cast(o, Int);
		}
		
		else if(Std.isOfType(o, Bool))
		{
			return cast(o, Bool) ? 1 : 0;
		}
		
		else if(Std.isOfType(o, String))
		{
			return Std.parseFloat(o);
		}
		
		else
		{
			return Std.parseFloat(Std.string(o));
		}
	}
	
	public static function hasValue(o:Dynamic):Bool
	{
		if(isPrimitive(o))
		{
			return true;
		}
		
		else if(Std.isOfType(o, String))
		{
			return cast(o, String) != "";
		}
		
		else
		{
			return o != null;
		}
	}
	
	public static function isPrimitive(o:Dynamic):Bool
	{
		if(Std.isOfType(o, Bool))
		{
			return true;
		}
		
		else if(Std.isOfType(o, Float))
		{
			return true;
		}
		
		else if(Std.isOfType(o, Int))
		{
			return true;
		}
		
		return false;
	}

	public static function getDefaultValue(o:Dynamic):Dynamic
	{
		if(Std.isOfType(o, Bool))
		{
			return false;
		}
		
		else if(Std.isOfType(o, Float))
		{
			return 0.0;
		}
		
		else if(Std.isOfType(o, Int))
		{
			return 0;
		}
		
		else if(Std.isOfType(o, String))
		{
			return "";
		}
		
		return null;
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
		propertyChangeEvents = new Map<String, Event<() -> Void>>();
	}
	
	//Physics = Pass in event.~Shape (a b2Shape)
	//No-Physics = Pass in the actor and event
	public function internalGetGroup(arg:Dynamic, arg2:Dynamic, arg3:Dynamic):Group
	{
		if(Engine.NO_PHYSICS)
		{
			var event:Collision = cast(arg3, Collision);
			
			if (arg == event.actorA)
			{
				return engine.getGroup(event.groupA);
			}
			
			return engine.getGroup(event.groupB);
		}
		
		else
		{
			var fixture = cast(arg2, B2Fixture);
			
			if(fixture == null)
			{
				trace("internalGetGroup - Warning - null shape passed in");
				return cast(arg, Actor).getGroup();
			}
			
			else
			{
				var value = fixture.groupID;

				if(value == GameModel.INHERIT_ID)
				{
					var body = fixture.getBody();
					
					if(body != null)
					{
						return engine.getGroup(body.getUserData().groupID);
					}
					
					trace("internalGetGroup - Warning - shape inherits groupID from actor but is not attached to a body");
				}
				
				return engine.getGroup(value);
			}
		}
	}
	
	public static function getGroupByName(groupName:String):Group
	{
		return engine.getGroupByName(groupName);
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
	
	public function addListener<T>(event:Event<T>, func:T #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		event.add(func #if debug_event_dispatch , posInfo #end);

		if(Std.isOfType(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(event, func);
		}
	}

	public function addListenerWithKey<K,T>(eventMap:Map<K,Event<T>>, key:K, func:T #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(!eventMap.exists(key))
		{
			eventMap.set(key, new Event<T>());
		}
		var event = eventMap.get(key);
		
		event.add(func #if debug_event_dispatch , posInfo #end);

		if(Std.isOfType(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(event, func);
		}
	}

	public function addListenerWithKey2<T>(eventMap:Map<Int,Map<Int,Event<T>>>, key1:Int, key2:Int, func:T #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(!eventMap.exists(key1))
		{
			eventMap.set(key1, new Map<Int,Event<T>>());
		}
		if(!eventMap.get(key1).exists(key2))
		{
			eventMap.get(key1).set(key2, new Event<T>());
		}
		var event = eventMap.get(key1).get(key2);
		
		event.add(func #if debug_event_dispatch , posInfo #end);

		if(Std.isOfType(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(event, func);
		}
	}

	public function addWhenCreatedListener(a:Actor, func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(a == null)
		{
			trace("Error in " + wrapper.classname + ": Cannot add listener function to null actor.");
			return;
		}
		
		addListener(a.whenCreated, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addWhenKilledListener(a:Actor, func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(a == null)
		{
			trace("Error in " + wrapper.classname + ": Cannot add listener function to null actor.");
			return;
		}
		
		addListener(a.whenKilled, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
					
	public function addWhenUpdatedListener(a:Actor, func:(Float, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		var isActorScript = Std.isOfType(this, ActorScript);
	
		if(a == null)
		{
			if(isActorScript)
			{
				a = cast(this, ActorScript).actor;
			}
		}
								
		if(a != null)
		{
			addListener(a.whenUpdated, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
		}
				
		else
		{
			addListener(engine.whenUpdated, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
		}
	}
	
	public function addWhenDrawingListener(a:Actor, func:(G, Float, Float, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		var isActorScript = Std.isOfType(this, ActorScript);
	
		if(a == null)
		{
			if(isActorScript)
			{
				a = cast(this, ActorScript).actor;
			}
		}
								
		if(a != null)
		{
			addListener(a.whenDrawing, func.bind(_, _, _, null) #if debug_event_dispatch , posInfo #end);
		}	
				
		else
		{
			addListener(engine.whenDrawing, func.bind(_, _, _, null) #if debug_event_dispatch , posInfo #end);
		}
	}
	
	public function addActorEntersRegionListener(reg:Region, func:(Actor, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(reg == null)
		{
			trace("Error in " + wrapper.classname +": Cannot add listener function to null region.");
			return;
		}
		
		addListener(reg.whenActorEntered, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addActorExitsRegionListener(reg:Region, func:Dynamic->Array<Dynamic>->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(reg == null)
		{
			trace("Error in " + wrapper.classname +": Cannot add listener function to null region.");
			return;
		}
		
		addListener(reg.whenActorExited, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addActorPositionListener(a:Actor, func:(Bool, Bool, Bool, Bool, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(a == null)
		{
			trace("Error in " + wrapper.classname + ": Cannot add listener function to null actor.");
			return;
		}
		
		addListener(a.whenPositionStateChanged, func.bind(_, _, _, _, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addActorTypeGroupPositionListener(obj:Dynamic, func:(Actor, Bool, Bool, Bool, Bool, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListenerWithKey(engine.whenTypeGroupPositionStateChangedEvents, obj, func.bind(_, _, _, _, _, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addSwipeListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenSwiped, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMultiTouchStartListener(func:(TouchEvent, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenMTStarted, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMultiTouchMoveListener(func:(TouchEvent, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenMTDragged, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMultiTouchEndListener(func:(TouchEvent, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenMTEnded, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addKeyStateListener(key:String, func:(Bool, Bool, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenKeyPressedEvents.getOrCreateEvent(key), func.bind(_, _, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addAnyKeyPressedListener(func:(KeyboardEvent, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenAnyKeyPressed, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addAnyKeyReleasedListener(func:(KeyboardEvent, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenAnyKeyReleased, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}

	public function addAnyGamepadPressedListener(func:(String, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenAnyGamepadPressed, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addAnyGamepadReleasedListener(func:(String, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenAnyGamepadReleased, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMousePressedListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenMousePressed, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMouseReleasedListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenMouseReleased, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMouseMovedListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenMouseMoved, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMouseDraggedListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenMouseDragged, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addMouseOverActorListener(a:Actor, func:(Int, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{	
		if(a == null)
		{
			trace("Error in " + wrapper.classname +": Cannot add listener function to null actor.");
			return;
		}
		
		addListener(a.whenMousedOver, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addPropertyChangeListener(propertyKey:String, propertyKey2:String, func:Dynamic->Array<Dynamic>->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		var callback = func.bind(null, null);
		addListenerWithKey(propertyChangeEvents, propertyKey, callback #if debug_event_dispatch , posInfo #end);
		if(propertyKey2 != null)
		{
			addListenerWithKey(propertyChangeEvents, propertyKey2, callback #if debug_event_dispatch , posInfo #end);
		}
		checkProperties = true;

		//TODO: previously, there was special case code here for equality pairs
	}

	public function propertyChanged(propertyKey:String)
	{
		if (checkProperties)
		{					
			var event = propertyChangeEvents.get(propertyKey);
		
			if(event != null)
			{
				event.dispatch();
				
				//TODO: previously, events that had finished here, if they were one of an equality pair, would also have the other part of the equality pair removed
			}
		}
	}
	
	public function addCollisionListener(a:Actor, func:(Collision, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if(a == null)
		{				
			trace("Error in " + wrapper.classname +": Cannot add listener function to null actor.");
			return;
		}
		
		addListener(a.whenCollided, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	//Only used for type/group type/group collisions
	public function addSceneCollisionListener(groupTypeID:Int, groupTypeID2:Int, func:(Collision, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListenerWithKey2(engine.whenCollidedEvents, groupTypeID, groupTypeID2, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addWhenTypeGroupCreatedListener(obj:Dynamic, func:(Actor, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListenerWithKey(engine.whenTypeGroupCreatedEvents, obj, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addWhenTypeGroupKilledListener(obj:Dynamic, func:(Actor, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListenerWithKey(engine.whenTypeGroupKilledEvents, obj, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addSoundListener(obj:Dynamic, func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		if (Std.isOfType(obj, Sound))
		{
			addListenerWithKey(engine.whenSoundEndedEvents, obj, func.bind(null) #if debug_event_dispatch , posInfo #end);
		}
		else
		{
			addListenerWithKey(engine.whenChannelEndedEvents, obj, func.bind(null) #if debug_event_dispatch , posInfo #end);
		}
	}
	
	public function addFocusChangeListener(func:(Bool, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenFocusChanged, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addPauseListener(func:(Bool, Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{						
		addListener(engine.whenPaused, func.bind(_, null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addFullscreenListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenFullscreenChanged, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addGameScaleListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenGameScaleChanged, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	public function addScreenSizeListener(func:(Array<Dynamic>)->Void #if debug_event_dispatch , ?posInfo:haxe.PosInfos #end)
	{
		addListener(engine.whenScreenSizeChanged, func.bind(null) #if debug_event_dispatch , posInfo #end);
	}
	
	//*-----------------------------------------------
	//* Regions
	//*-----------------------------------------------
	
	public static function getLastCreatedRegion():Region
	{
		return lastCreatedRegion;
	}
	
	public static function getAllRegions():Array<Region>
	{
		var regions = new Array<Region>();
		
		for(r in engine.regions)
		{
			if(r == null) continue;
			regions.push(r);
		}
		
		return regions;
	}
	
	public static function getRegion(regionID:Int):Region
	{
		return engine.getRegion(regionID);
	}
	
	public static function removeRegion(regionID:Int)
	{
		engine.removeRegion(regionID);
	}
		
	public static function createBoxRegion(x:Float, y:Float, w:Float, h:Float):Region
	{
		return lastCreatedRegion = engine.createBoxRegion(x, y, w, h);
	}
			
	public static function createCircularRegion(x:Float, y:Float, r:Float):Region
	{
		return lastCreatedRegion = engine.createCircularRegion(x, y, r);
	}
			
	public static function isInRegion(a:Actor, r:Region):Bool
	{
		return engine.isInRegion(a, r);
	}
	
	public static function getActorsInRegion(r:Region):Array<Actor>
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
	//* Behavior Status
	//*-----------------------------------------------
	
	/**
	 * Check if the current scene contains the given Behavior (by name)
	 *
	 * @param	behaviorName	The display name of the <code>Behavior</code>
	 * 
	 * @return	True if the scene contains the Behavior
	 */
	public static function sceneHasBehavior(behaviorName:String):Bool
	{
		return engine.behaviors.hasBehavior(behaviorName);
	}
	
	/**
	 * Enable the given Behavior (by name) for the current scene
	 *
	 * @param	behaviorName	The display name of the <code>Behavior</code>
	 */
	public static function enableBehaviorForScene(behaviorName:String)
	{
		engine.behaviors.enableBehavior(behaviorName);
	}
	
	/**
	 * Disable the given Behavior (by name) for the current scene
	 *
	 * @param	behaviorName	The display name of the <code>Behavior</code>
	 */
	public static function disableBehaviorForScene(behaviorName:String)
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
	public static function isBehaviorEnabledForScene(behaviorName:String):Bool
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
	public static function getValueForScene(behaviorName:String, attributeName:String):Dynamic
	{
		return engine.getValue(behaviorName, attributeName);
	}
	
	/**
	 * Set the value for an attribute of a behavior in the scene.
	 */
	public static function setValueForScene(behaviorName:String, attributeName:String, value:Dynamic)
	{
		engine.setValue(behaviorName, attributeName, value);
	}
	
	/**
	 * Send a messege to this scene with optional arguments.
	 */
	public static function shoutToScene(msg:String, args:Array<Dynamic> = null):Dynamic
	{
		return engine.shout(msg, args);
	}
	
	/**
	 * Send a messege to a behavior in this scene with optional arguments.
	 */		
	public static function sayToScene(behaviorName:String, msg:String, args:Array<Dynamic> = null):Dynamic
	{
		return engine.say(behaviorName, msg, args);
	}
	
	//*-----------------------------------------------
	//* Game Attributes
	//*-----------------------------------------------
	
	/**
	 * Set a game attribute (pass a Number/Text/Boolean/List)
	 */		
	public static function setGameAttribute(name:String, value:Dynamic)
	{
		engine.setGameAttribute(name, value);
	}
	
	/**
	 * Get a game attribute (Returns a Number/Text/Boolean/List)
	 */	
	public static function getGameAttribute(name:String):Dynamic
	{
		return engine.getGameAttribute(name);
	}
	
	public static function setSavable(name:String, value:Bool)
	{
		engine.savableAttributes.set(name, value);
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
	public static function runLater(delay:Float, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
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
	public static function runPeriodically(interval:Float, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
	{
		var t:TimedTask = new TimedTask(toExecute, Std.int(interval), true, actor);
		engine.addTask(t);
		
		return t;
	}
	
	public static function getStepSize():Int
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
	public static function getScene():Scene
	{
		return engine.scene;
	}
	
	/**
	 * Get the ID of the current scene.
	 *
	 * @return The ID current scene
	 */
	public static function getCurrentScene():Int
	{
		return getScene().ID;
	}
	
	/**
	 * Get the ID of a scene by name.
	 *
	 * @return The ID current scene or -1 if it doesn't exist.
	 */
	public static function getIDForScene(sceneName:String):Int
	{
		for(s in GameModel.get().scenes)
		{
			if(sceneName == s.name)
			{
				return s.ID;	
			}
		}
		
		return -1;
	}
	
	/**
	 * Get the name of the current scene.
	 *
	 * @return The name of the current scene
	 */
	public static function getCurrentSceneName():String
	{
		return getScene().name;
	}
	
	/**
	 * Get the width (in pixels) of the current scene.
	 *
	 * @return width (in pixels) of the current scene
	 */
	public static function getSceneWidth():Int
	{
		return getScene().sceneWidth;
	}
	
	/**
	 * Get the height (in pixels) of the current scene.
	 *
	 * @return height (in pixels) of the current scene
	 */
	public static function getSceneHeight():Int
	{
		return getScene().sceneHeight;
	}
	
	/**
	 * Get the width (in tiles) of the current scene.
	 *
	 * @return width (in tiles) of the current scene
	 */
	public static function getTileWidth():Int
	{
		return getScene().tileWidth;
	}
	
	/**
	 * Get the height (in tiles) of the current scene.
	 *
	 * @return height (in tiles) of the current scene
	 */
	public static function getTileHeight():Int
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
	public static function reloadCurrentScene(leave:Transition=null, enter:Transition=null)
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
	public static function switchScene(sceneID:Int, leave:Transition=null, enter:Transition=null)
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
	public static function createPixelizeOut(duration:Float, pixelSize:Int = 15):Transition
	{
		pixelSize = 15; // added because color is being sent as pixel size
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
	public static function createPixelizeIn(duration:Float, pixelSize:Int = 15):Transition
	{
		pixelSize = 15; // added because color is being sent as pixel size
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
	public static function createBubblesOut(duration:Float, color:Int=0xff000000):Transition
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
	public static function createBubblesIn(duration:Float, color:Int=0xff000000):Transition
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
	public static function createBlindsOut(duration:Float, color:Int=0xff000000):Transition
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
	public static function createBlindsIn(duration:Float, color:Int=0xff000000):Transition
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
	public static function createRectangleOut(duration:Float, color:Int=0xff000000):Transition
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
	public static function createRectangleIn(duration:Float, color:Int=0xff000000):Transition
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
	public static function createSlideTransition(duration:Float, direction:String):Transition
	{
		return new com.stencyl.graphics.transitions.SlideTransition(engine.master, engine.colorLayer, duration, direction);
	}
		
	//These are for SW's convenience.		
	public static function createSlideUpTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_UP);
	}
		
	public static function createSlideDownTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_DOWN);
	}
		
	public static function createSlideLeftTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_LEFT);
	}
		
	public static function createSlideRightTransition(duration:Float):Transition
	{
		return createSlideTransition(duration, com.stencyl.graphics.transitions.SlideTransition.SLIDE_RIGHT);
	}
		
	public static function createCrossfadeTransition(duration:Float):Transition
	{
		return new com.stencyl.graphics.transitions.CrossfadeTransition(engine.root, duration);
	}
	
	public static function createFadeOut(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.FadeOutTransition(duration, color);
	}
	
	public static function createFadeIn(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.FadeInTransition(duration, color);
	}
	
	public static function createCircleOut(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.CircleTransition(Transition.OUT, duration, color);
	}
		
	public static function createCircleIn(duration:Float, color:Int=0xff000000):Transition
	{
		return new com.stencyl.graphics.transitions.CircleTransition(Transition.IN, duration, color);
	}
	
	//*-----------------------------------------------
	//* Tile Layers
	//*-----------------------------------------------
	
	public static function setBlendModeForLayer(layer:RegularLayer, mode:openfl.display.BlendMode)
    {
		layer.blendMode = mode;
		
		if (Std.isOfType(layer, Layer))
		{
			cast(layer, Layer).tiles.blendMode = mode;
		}
    }
	
	/**
	 * Force the given layer to show.
	 *
	 * @param	refType		0 to get layer by ID, 1 for name
	 * @param	ref			The ID or name of the layer as a String
	 */
	public static function showTileLayer(layer:RegularLayer)
	{
		layer.alpha = 1;
	}
	
	/**
	 * Force the given layer to become invisible.
	 *
	 * @param	refType		0 to get layer by ID, 1 for name
	 * @param	ref			The ID or name of the layer as a String
	 */
	public static function hideTileLayer(layer:RegularLayer)
	{
		layer.alpha = 0;
	}
	
	/**
	 * Force the given layer to fade to the given opacity over time, applying the easing function.
	 *
	 * @param	layer			The layer to tween
	 * @param	alphaPct		the opacity (0-1) to fade to
	 * @param	duration		the duration of the fading (in milliseconds)
	 * @param	easing			easing function to apply. Linear (no smoothing) is the default.
	 */
	public static function fadeTileLayerTo(layer:RegularLayer, alphaPct:Float, duration:Float, easing:EasingFunction = null)
	{
		if(layer.alphaTween == null)
			layer.alphaTween = cast new TweenFloat().doOnUpdate(function() {layer.alpha = layer.alphaTween.value;});
		
		layer.alphaTween.tween(layer.alpha, alphaPct, easing, Std.int(duration*1000));
	}

	/**
	 * Get the opacity of the given layer.
	 *
	 * @param	refType		0 to get layer by ID, 1 for name
	 * @param	ref			The ID or name of the layer as a String
	 */
	public static function getTileLayerOpacity(layer:RegularLayer):Float
	{
		return layer.alpha * 100;
	}
	
	//*-----------------------------------------------
	//* Drawing Layer
	//*-----------------------------------------------
	
	public static function setDrawingLayer(layer:RegularLayer)
	{
		if(Std.isOfType(layer, Layer))
		{
			var l:Layer = cast layer;
			Engine.engine.g.graphics = l.overlay.graphics;
		}
	}
	
	public static function setDrawingLayerToActorLayer(a:Actor)
	{
		if(a != null)
		{
			Engine.engine.g.graphics = a.layer.overlay.graphics;
		}
	}
	
	public static function setDrawingLayerToSceneLayer()
	{
		Engine.engine.g.graphics = Engine.engine.transitionLayer.graphics;
	}
	
	//*-----------------------------------------------
	//* Camera
	//*-----------------------------------------------
	
	/**
	 * x-position of the camera
	 *
	 * @return The x-position of the camera
	 */
	public static function getScreenX():Float
	{
		return Engine.cameraX / Engine.SCALE;
	}
	
	/**
	 * y-position of the camera
	 *
	 * @return The y-position of the camera
	 */
	public static function getScreenY():Float
	{
		return Engine.cameraY / Engine.SCALE;
	}
	
	/**
	 * x-center position of the camera
	 *
	 * @return The x-position of the camera
	 */
	public static function getScreenXCenter():Float
	{
		return Engine.cameraX / Engine.SCALE + Engine.screenWidth / 2;
	}
	
	/**
	 * y-center position of the camera
	 *
	 * @return The y-position of the camera
	 */
	public static function getScreenYCenter():Float
	{
		return Engine.cameraY / Engine.SCALE + Engine.screenHeight / 2;
	}
	
	/**
	 * Returns the actor that represents the camera
	 *
	 * @return The actor representing the camera
	 */
	public static function getCamera():Actor
	{
		return engine.camera;
	}
	
	//*-----------------------------------------------
	//* Input
	//*-----------------------------------------------
	
	//Programmers: Use the Input class directly. It's much nicer.
	//We're keeping this API around for compatibility for now.
	
	public static function isCtrlDown():Bool
	{
		return Input.check(Engine.INTERNAL_CTRL) || Input.check(Engine.INTERNAL_COMMAND);
	}
	
	public static function isShiftDown():Bool
	{
		return Input.check(Engine.INTERNAL_SHIFT);
	}
	
	public static function simulateKeyPress(abstractKey:String)
	{
		Input.simulateKeyPress(abstractKey);
	}
	
	public static function simulateKeyRelease(abstractKey:String)
	{
		Input.simulateKeyRelease(abstractKey);
	}

	public static function isKeyDown(abstractKey:String):Bool
	{
		return Input.check(abstractKey);
	}

	public static function isKeyPressed(abstractKey:String):Bool
	{
		return Input.pressed(abstractKey);
	}
	
	public static function isKeyReleased(abstractKey:String):Bool
	{
		return Input.released(abstractKey);
	}
	
	public static function isMouseDown():Bool
	{
		return Input.mouseDown;
	}
	
	public static function isMousePressed():Bool
	{
		return Input.mousePressed;
	}

	public static function isMouseReleased():Bool
	{
		return Input.mouseReleased;
	}
	
	public static function getMouseX():Float
	{
		return Input.mouseX / Engine.SCALE;
	}

	public static function getMouseY():Float
	{
		return Input.mouseY / Engine.SCALE;
	}
	
	public static function getMouseWorldX():Float
	{
		return Input.mouseX / Engine.SCALE + Engine.cameraX;
	}
	
	public static function getMouseWorldY():Float
	{
		return Input.mouseY / Engine.SCALE + Engine.cameraY;
	}
	
	public static function getMousePressedX():Float
	{
		return mpx;
	}
	
	public static function getMousePressedY():Float
	{
		return mpy;
	}

	public static function getMouseReleasedX():Float
	{
		return mrx;
	}
	
	public static function getMouseReleasedY():Float
	{
		return mry;
	}
	
	public static function showCursor()
	{
		Mouse.show();
	}

	public static function hideCursor()
	{
		Mouse.hide();
	}
	
	public static function charFromCharCode(code:Int):String
	{
		if (code < 32 || (code > 126 && code < 160))
		{
			return "";
		}
		else
		{
			return String.fromCharCode(code);
		}
	}
	
	//*-----------------------------------------------
	//* Actor Creation
	//*-----------------------------------------------
	
	public static function getLastCreatedActor():Actor
	{
		return lastCreatedActor;
	}
	
	public static function createActor(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		var a:Actor = engine.createActorOfType(type, x, y, layerConst);
		lastCreatedActor = a;
		return a;
	}
	
	public static function createRecycledActor(type:ActorType, x:Float, y:Float, layerConst:Int):Actor
	{
		var a:Actor = engine.getRecycledActorOfType(type, x, y, layerConst);
		lastCreatedActor = a;
		return a;
	}

	public static function createRecycledActorOnLayer(type:ActorType, x:Float, y:Float, layer:RegularLayer):Actor
	{
		var a:Actor = engine.getRecycledActorOfTypeOnLayer(type, x, y, layer.ID);
		lastCreatedActor = a;
		return a;
	}
	
	public static function recycleActor(a:Actor)
	{
		engine.recycleActor(a);
	}
	
	public static function createActorInNextScene(type:ActorType, x:Float, y:Float, layerConst:Int)
	{
		engine.createActorInNextScene(type, x, y, layerConst);
	}
	
	//*-----------------------------------------------
	//* Actor-Related Getters
	//*-----------------------------------------------
	
	/**
	 * Returns an ActorType by name
	 */
	public static function getActorTypeByName(typeName:String):ActorType
	{
		return cast Data.get().resourceMap.get(typeName);
	}
	
	/**
	* Returns an ActorType by ID
	*/
	public static function getActorType(actorTypeID:Int):ActorType
	{
		return cast Data.get().resources.get(actorTypeID);
	}
	
	/**
	* Returns an array of all ActorTypes in the game
	*/
	public static function getAllActorTypes():Array<ActorType>
	{
		return Data.get().getAllActorTypes();
	}
	
	/**
	* Returns an array of all Actors of the given type in the scene
	*/
	public static function getActorsOfType(type:ActorType):Array<Actor>
	{
		return engine.getActorsOfType(type);
	}
	
	/**
	* Returns an actor in the scene by ID
	*/
	public static function getActor(actorID:Int):Actor
	{
		return engine.getActor(actorID);
	}
	
	/**
	* Returns an ActorGroup by ID
	*/
	public static function getActorGroup(groupID:Int):Group
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
	
	public static function setGravity(x:Float, y:Float)
	{
		engine.gravityX = x;
		engine.gravityY = y;

		if(engine.world != null)
		{
			engine.world.setGravity(new B2Vec2(x, y));
		}
	}

	public static function getGravity():B2Vec2
	{
		if(engine.world == null)
		{
			dummyVec.x = engine.gravityX;
			dummyVec.y = engine.gravityY;
			
			return dummyVec;
		}
		
		else
		{
			return engine.world.getGravity();
		}
	}

	public static function enableContinuousCollisions()
	{
		B2World.m_continuousPhysics = true;
	}
		
	public static function toPhysicalUnits(value:Float):Float
	{
		return Engine.toPhysicalUnits(value);
	}

	public static function toPixelUnits(value:Float):Float
	{
		return Engine.toPixelUnits(value);
	}
	
	// Enable continuous collision detection
	public static function makeActorNotPassThroughTerrain(actor:Actor)
	{
		if (Engine.NO_PHYSICS)
		{
			if (actor != null && actor.physicsMode == SIMPLE_PHYSICS)
			{
				actor.continuousCollision = true;
			}
			return;
		}
		
		B2World.m_continuousPhysics = true;
		
		if(actor != null && actor.physicsMode == NORMAL_PHYSICS)
		{
			actor.body.setBullet(true);
		}
	}
	
	// Disable continuous collision detection
	public static function makeActorPassThroughTerrain(actor:Actor)
	{
		if (Engine.NO_PHYSICS)
		{
			if (actor != null && actor.physicsMode == SIMPLE_PHYSICS)
			{
				actor.continuousCollision = false;
			}
			return;
		}
		
		if(actor != null && actor.physicsMode == NORMAL_PHYSICS)
		{
			actor.body.setBullet(false);
			
			// If no actors have CCD enabled, set global CCD to false too.
			var actorCCD = false;
			for (a in engine.allActors)
			{
				if (a.body != null && a.body.isBullet())
				{
					actorCCD = true;
					break;
				}
			}
			
			if (!actorCCD)
			{
				B2World.m_continuousPhysics = false;
			}
		}
	}
	
	//*-----------------------------------------------
	//* Sounds
	//*-----------------------------------------------
	
	public static function mute()
	{
		//FlxG.mute = true;
	}
	
	public static function unmute()
	{
		//FlxG.mute = false;
	}
	
	/**
	* Returns a SoundClip resource by ID
	*/
	public static function getSound(soundID:Int):Sound
	{
		return cast Data.get().resources.get(soundID);
	}
	
	/**
	* Returns a SoundClip resource by Name
	*/
	public static function getSoundByName(soundName:String):Sound
	{
		return cast Data.get().resourceMap.get(soundName);
	}
	
	/**
	* Play a specific SoundClip resource once (use loopSound() to play a looped version)
	*/
	public static function playSound(clip:Sound)
	{
		if(clip != null)
		{				
			for(i in 0...CHANNELS)
			{
				var sc = engine.channels[i];
				
				if(sc.currentSound == null)
				{
					//trace("Play sound on channel: " + i);
					sc.playSound(clip);
					sc.setVolume(1);
					sc.setPanning(0);
					return;
				}
			}
			
			trace("No channels available to play sound");
		}			
	}
	
	/**
	* Loop a specific SoundClip resource (use playSound() to play only once)
	*/
	public static function loopSound(clip:Sound)
	{
		if(clip != null)
		{				
			for(i in 0...CHANNELS)
			{
				var sc = engine.channels[i];
				
				if(sc.currentSound == null)
				{
					//trace("Loop sound on channel: " + i);
					sc.loopSound(clip);
					sc.setVolume(1);
					sc.setPanning(0);
					return;
				}
			}
			
			trace("No channels available to loop sound");
		}			
	}
	
	/**
	* Play a specific SoundClip resource once on a specific channel (use loopSoundOnChannel() to play a looped version)
	*/
	public static function playSoundOnChannel(clip:Sound, channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];		
		sc.playSound(clip);
		sc.setVolume(1);
		sc.setPanning(0);
	}
	
	/**
	* Play a specific SoundClip resource looped on a specific channel (use playSoundOnChannel() to play once)
	*/
	public static function loopSoundOnChannel(clip:Sound, channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];	
		sc.loopSound(clip);
		sc.setVolume(1);
		sc.setPanning(0);
	}
	
	/**
	* Stop all sound on a specific channel (use pauseSoundOnChannel() to just pause)
	*/
	public static function stopSoundOnChannel(channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];
		sc.stopSound();
	}
	
	/**
	* Pause all sound on a specific channel (use stopSoundOnChannel() to stop it)
	*/
	public static function pauseSoundOnChannel(channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];	
		sc.setPause(true);			
	}
	
	/**
	* Resume all sound on a specific channel (must have been paused with pauseSoundOnChannel())
	*/
	public static function resumeSoundOnChannel(channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];		
		sc.setPause(false);			
	}
	
	/**
	* Set the volume of all sound on a specific channel (use decimal volume such as .5)
	*/
	public static function setVolumeForChannel(volume:Float, channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];		
		sc.setVolume(volume);
	}
	
	public static function setPanningForChannel(pan:Float, channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];		
		sc.setPanning(pan);
	}
	
	/**
	* Stop all the sounds currently playing (use mute() to mute the game).
	*/
	public static function stopAllSounds()
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
	public static function setVolumeForAllSounds(volume:Float)
	{
		SoundChannel.masterVolume = volume;
		
		for(i in 0...CHANNELS)
		{
			var sc:SoundChannel = engine.channels[i];
			sc.setVolume(sc.volume);
		}
	}
	
	/**
	* Fade a specific channel's audio in over time (milliseconds)
	*/
	public static function fadeInSoundOnChannel(channelNum:Int, time:Float)
	{
		var sc:SoundChannel = engine.channels[channelNum];
		sc.fadeInSound(time);			
	}
	
	/**
	* Fade a specific channel's audio out over time (milliseconds)
	*/
	public static function fadeOutSoundOnChannel(channelNum:Int, time:Float)
	{
		var sc:SoundChannel = engine.channels[channelNum];
		sc.fadeOutSound(time);			
	}
	
	public static function fadeSoundOnChannel(channelNum:Int, time:Float, percent:Float)
	{
		var sc:SoundChannel = engine.channels[channelNum];
		sc.fadeSound(time, percent / 100);			
	}
	
	/**
	* Fade all audio in over time (milliseconds)
	*/
	public static function fadeInForAllSounds(time:Float)
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
	public static function fadeOutForAllSounds(time:Float)
	{
		for(i in 0...CHANNELS)
		{
			var sc:SoundChannel = engine.channels[i];	
			sc.fadeOutSound(time);
		}
	}
	
	public static function fadeForAllSounds(time:Float, percent:Float)
	{
		for(i in 0...CHANNELS)
		{
			var sc:SoundChannel = engine.channels[i];	
			sc.fadeSound(time, percent / 100);
		}
	}
	
	/**
	* Gets the current position for the given channel in milliseconds.
	* If not playing, will return the last point it was played at.
	*/
	public static function getPositionForChannel(channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];	
		
		if(sc != null && sc.currentSound != null)
		{
			if(sc.paused) return sc.position;
			
			return sc.currentSound.position;
		}
		
		else
		{
			return 0;
		}
	}
	
	/**
	* Sets the current position for the given channel in milliseconds.
	*/
	public static function setPositionForChannel(channelNum:Int, position:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];
		
		if(sc != null && sc.currentSound != null)
		{
			if(sc.paused)
				sc.position = position;
			else
			{
				if(sc.looping)
					sc.loopSound(sc.currentClip, position);
				else
					sc.playSound(sc.currentClip, position);
			}
		}
	}
	
	/**
	* Gets the length for the given channel in milliseconds.
	*/
	public static function getSoundLengthForChannel(channelNum:Int)
	{
		var sc:SoundChannel = engine.channels[channelNum];		
		
		if(sc != null && sc.currentSource != null)
		{
			return sc.currentSource.length;
		}
		
		else
		{
			return 0;
		}
	}
	
	/**
	* Gets the length of the given sound in milliseconds.
	*/
	public static function getSoundLength(clip:Sound)
	{
		if(clip != null && clip.src != null)
		{
			return clip.src.length;
		}
		
		else
		{
			return 0;
		}
	}
	
	
	//*-----------------------------------------------
	//* Background Manipulation
	//*-----------------------------------------------
	
	/**
	* Set the solid or gradient color background
	*/
	public static function setColorBackground(c:Int, c2:Int = -2 /*ColorBackground.TRANSPARENT*/)
	{
		engine.colorLayer.graphics.clear();

		if(c != ColorBackground.TRANSPARENT)
		{
			if(c2 == ColorBackground.TRANSPARENT)
			{
				engine.setColorBackground(new ColorBackground(c));
			}
			else
			{
				engine.setColorBackground(new GradientBackground(c, c2));
			}
		}
	}

	/**
	* Set the speed of all scrolling backgrounds (Backgrounds must already be set to scrolling)
	*/
	public static function setScrollSpeedForBackground(layer:RegularLayer, xSpeed:Float, ySpeed:Float)
	{
		if(layer == null)
		{
			for(layer in Engine.engine.backgroundLayers)
			{
				layer.setScrollSpeed(xSpeed, ySpeed);
			}
		}
		else
		{
			if(Std.isOfType(layer, BackgroundLayer))
			{
				cast(layer, BackgroundLayer).setScrollSpeed(xSpeed, ySpeed);
			}
		}
	}

	/**
	* Set the parallax factor of a background or tilelayer
	*/
	public static function setScrollFactorForLayer(layer:RegularLayer, scrollFactorX:Float, scrollFactorY:Float)
	{
		if(Std.isOfType(layer, BackgroundLayer))
		{
			cast(layer, BackgroundLayer).setScrollFactor(scrollFactorX, scrollFactorY);
		}
		else if(Std.isOfType(layer, Layer))
		{
			layer.scrollFactorX = scrollFactorX;
			layer.scrollFactorY = scrollFactorY;
		}
	}
	
	/**
	* Switches one background for another
	*/
	public static function changeBackground(layer:RegularLayer, newBackName:String)
	{
		var bg:ImageBackground = cast Data.get().resourceMap.get(newBackName);
		
		if(bg == null)
			return;

		if(Std.isOfType(layer, BackgroundLayer))
		{
			cast(layer, BackgroundLayer).reload(bg.ID);
		}
	}

	/**
	* Change a background's image
	*/
	public static function changeBackgroundImage(layer:RegularLayer, newImg:BitmapData)
	{
		if(newImg == null)
			return;

		if(Std.isOfType(layer, BackgroundLayer))
		{
			cast(layer, BackgroundLayer).setImage(newImg);
		}
	}

	public static function addBackground(backgroundName:String, layerName:String, order:Int)
	{
		var bg = Data.get().resourceMap.get(backgroundName);
		var layer = new BackgroundLayer(engine.getNextLayerID(), layerName, order, 0, 0, 1, BlendMode.NORMAL, bg.ID, false);
		layer.load();
		engine.insertLayer(layer, order);
	}

	public static function addBackgroundFromImage(image:BitmapData, tiled:Bool, layerName:String, order:Int)
	{
		var layer = new BackgroundLayer(engine.getNextLayerID(), layerName, order, 0, 0, 1, BlendMode.NORMAL, -1, false);
		layer.loadFromImg(image, tiled);
		engine.insertLayer(layer, order);
	}
	
	public static function addTileLayer(layerName:String, order:Int)
	{
		var cols = Std.int(engine.scene.sceneWidth / engine.scene.tileWidth);
		var rows = Std.int(engine.scene.sceneHeight / engine.scene.tileHeight);
		var ID = engine.getNextLayerID();
		
		var tileLayer = new TileLayer(ID, engine.scene, cols, rows);
		tileLayer.name = layerName;
		
		var layer:Layer = new Layer(ID, layerName, order, 1.0, 1.0, 1.0, BlendMode.NORMAL, tileLayer #if use_actor_tilemap, engine.scene.sceneWidth, engine.scene.sceneHeight #end);
		
		engine.insertLayer(layer, order);
	}

	//*-----------------------------------------------
	//* Image API
	//*-----------------------------------------------
	
	public static var dummyRect = new openfl.geom.Rectangle(0, 0, 1, 1);
	public static var dummyPoint = new openfl.geom.Point(0, 0);
	
	public static function newImage(width:Int, height:Int):BitmapData
	{
		if(!imageApiAutoscale)
			return new BitmapData(width, height, true, 0);
		else
			return new BitmapData(Std.int(width * Engine.SCALE), Std.int(height * Engine.SCALE), true, 0);
	}
	
	public static function captureScreenshot():BitmapData
	{
		//var img:BitmapData = new BitmapData(Std.int(getScreenWidth() * Engine.SCALE) , Std.int(getScreenHeight() * Engine.SCALE));

		// The old method seems to just be grabbing the SCENE width and height and multiplying it by the scale
		// The new method grabs the actual screen height and width and goes from there.

		var img:BitmapData = new BitmapData(Std.int(getStageWidth()) , Std.int(getStageHeight()));
		img.draw(openfl.Lib.current.stage, null, null, null, null, Config.antialias);
		return img;
	}
	
	public static function getImageForActor(a:Actor):BitmapData
	{
		return a.getCurrentImage();
	}

	//Example path: "sample.png" - stick into the "extras" folder for your game - see: http://community.stencyl.com/index.php/topic,24729.0.html
	public static function getExternalImage(path:String):BitmapData
	{
		return Assets.getBitmapData("assets/data/" + path, false);
	}
	
	//TODO: See - http://www.onegiantmedia.com/as3--load-a-remote-image-from-any-url--domain-with-no-stupid-security-sandbox-errors
	public static function loadImageFromURL(URL:String, onComplete:BitmapData->Void)
	{
		#if flash
		var lc = new flash.system.LoaderContext();
		lc.checkPolicyFile = false;
		lc.securityDomain = flash.system.SecurityDomain.currentDomain;
		lc.applicationDomain = flash.system.ApplicationDomain.currentDomain; 
    	#end
		
		var handler = function(event:FlashEvent):Void
		{
			var bitmapData = cast(cast(event.currentTarget, LoaderInfo).content, Bitmap).bitmapData;
    		onComplete(bitmapData);
		}
	
		var loader:Loader = new Loader();
    	loader.contentLoaderInfo.addEventListener(FlashEvent.COMPLETE, handler);
    	loader.load(new URLRequest(URL));
	}
	
	public static function getSubImage(img:BitmapData, x:Int, y:Int, width:Int, height:Int):BitmapData
	{
		if(imageApiAutoscale)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
			width = Std.int(width * Engine.SCALE);
			height = Std.int(height * Engine.SCALE);
		}
		
		if(img != null && x >= 0 && y >= 0 && width > 0 && height > 0 && x < img.width && y < img.height)
		{
			var newImg:BitmapData = new BitmapData(width, height);
			
			dummyRect.x = x;
			dummyRect.y = y;
			dummyRect.width = width;
			dummyRect.height = height;
			
			dummyPoint.x = 0;
			dummyPoint.y = 0;
			
			newImg.copyPixels(img, dummyRect, dummyPoint);
			
			return newImg;
		}
		
		return new BitmapData(1, 1);
	}
	
	public static function setOrderForImage(img:BitmapWrapper, order:Int)
	{
		if(img != null && img.parent != null)
		{
			#if !use_actor_tilemap
			if(order >= 0 && order < img.parent.numChildren)
			{
				img.parent.setChildIndex(img, order);
			}
			#else
			if(order >= 0 && order < img.parent.numTiles)
			{
				img.parent.setTileIndex(img, order);
			}
			#end
		}
	}

	public static function getOrderForImage(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			#if !use_actor_tilemap
			return img.parent.getChildIndex(img);
			#else
			return img.parent.getTileIndex(img);
			#end
		}
		
		return -1;
	}
	
	public static function bringImageBack(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			#if !use_actor_tilemap
			setOrderForImage(img, img.parent.getChildIndex(img) - 1);
			#else
			setOrderForImage(img, img.parent.getTileIndex(img) - 1);
			#end
		}
	}
	
	public static function bringImageForward(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			#if !use_actor_tilemap
			setOrderForImage(img, img.parent.getChildIndex(img) + 1);
			#else
			setOrderForImage(img, img.parent.getTileIndex(img) + 1);
			#end
		}
	}
	
	public static function bringImageToBack(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			setOrderForImage(img, 0);
		}
	}
	
	public static function bringImageToFront(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			#if !use_actor_tilemap
			setOrderForImage(img, img.parent.numChildren - 1);
			#else
			setOrderForImage(img, img.parent.numTiles - 1);
			#end
		}
	}
	
	public static function attachImageToActor(img:BitmapWrapper, a:Actor, x:Int, y:Int, pos:Int = 1)
	{
		if(img != null)
		{
			if(img.parent != null) removeImage(img);
			
			//Behind the Actor - Send to the very back.
			if(pos == 2)
			{
				#if !use_actor_tilemap
				a.addChild(img);
				a.setChildIndex(img, 0);
				#else
				a.addTile(img);
				a.setTileIndex(img, 0);
				#end
			}
		
			else
			{
				#if !use_actor_tilemap
				a.addChild(img);
				#else
				a.addTile(img);
				#end
			}
			
			img.cacheParentAnchor = a.cacheAnchor;
			img.imgX = x;
			img.imgY = y;
			img.smoothing = Config.antialias;

			a.attachedImages.push(img);
		}
	}
	
	//Will be "fixed" like an HUD
	public static function attachImageToHUD(img:BitmapWrapper, x:Int, y:Int)
	{
		if(img != null)
		{
			if(img.parent != null) removeImage(img);
			
			#if !use_actor_tilemap
			engine.hudLayer.addChild(img);
			#else
			engine.hudLayer.getFrontImageLayer().addTile(img);
			#end
			engine.hudLayer.attachedImages.push(img);
			img.imgX = x;
			img.imgY = y;
			img.smoothing = Config.antialias;
		}
	}
	
	public static function attachImageToLayer(img:BitmapWrapper, layer:Layer, x:Int, y:Int, pos:Int = 1)
	{
		if(img != null)
		{
			if(img.parent != null) removeImage(img);
			
			//Behind all Actors & Tiles in this layer.
			if(pos == 2)
			{
				#if !use_actor_tilemap
				layer.addChildAt(img, 0);
				#else
				layer.getBackImageLayer().addTileAt(img, 0);
				#end
			}
			else
			{
				#if !use_actor_tilemap
				layer.addChild(img);
				#else
				layer.getFrontImageLayer().addTile(img);
				#end
			}
			
			if (layer.attachedImages.indexOf(img) == -1)
			{
				layer.attachedImages.push(img);
			}
			
			img.imgX = x;
			img.imgY = y;
			img.smoothing = Config.antialias;
		}
	}
	
	public static function removeImage(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			if(Std.isOfType(img.parent, Actor))
				cast(img.parent, Actor).attachedImages.remove(img);
			else if(Std.isOfType(img.parent, Layer))
				cast(img.parent, Layer).attachedImages.remove(img);
			#if (use_actor_tilemap)
			img.parent.removeTile(img);
			#else
			img.parent.removeChild(img);
			#end
		}
	}
	
	//This returns a new BitmapData. It isn't possible to actually resize a BitmapData without creating a new one.
	public static function resizeImage(img:BitmapData, xScale:Float = 1.0, yScale:Float = 1.0, smoothing:Bool = true):BitmapData
	{
		var matrix:Matrix = new Matrix();
		matrix.scale(xScale, yScale);
		
		var toReturn:BitmapData = new BitmapData(Std.int(img.width * xScale), Std.int(img.height * yScale), true, 0x000000);
		toReturn.draw(img, matrix, null, null, null, smoothing);
		
		return toReturn;
	}
	
	public static function drawImageOnImage(source:BitmapData, dest:BitmapData, x:Int, y:Int, blendMode:BlendMode)
	{
		if(imageApiAutoscale)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
		}
		
		if(source != null && dest != null)
		{
			dummyPoint.x = x;
			dummyPoint.y = y;
			
			if(blendMode == BlendMode.NORMAL)
			{
				dest.copyPixels(source, source.rect, dummyPoint, null, null, true);
			}
			
			else
			{
				var drawMatrix = new Matrix();
				drawMatrix.identity();
				drawMatrix.translate(x, y);
				dest.draw(source, drawMatrix, null, blendMode);
			}
		}
	}
	
	public static function drawTextOnImage(img:BitmapData, text:String, x:Int, y:Int, font:Font)
	{
		if(imageApiAutoscale)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
		}
		
		if(img != null)
		{
			var fontScale = font.fontScale;
			
			#if !use_tilemap
			var fontData = G.fontCache.get(font.ID);
				
			if(fontData == null)
			{
				fontData = font.font.getPreparedGlyphs(font.fontScale, 0x000000, false);
				G.fontCache.set(font.ID, fontData);
			}

			font.font.render(img, fontData, text, 0x000000, 1, x, y, fontScale, 0);
			#else
			font.font.renderToImg(img, text, 0x000000, 1, x, y, fontScale, 0, false);
			#end
		}
	}
	
	public static function clearImagePartially(img:BitmapData, x:Int, y:Int, width:Int, height:Int)
	{
		if(imageApiAutoscale)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
			width = Std.int(width * Engine.SCALE);
			height = Std.int(height * Engine.SCALE);
		}
		
		if(img != null)
		{
			dummyRect.x = x;
			dummyRect.y = y;
			dummyRect.width = width;
			dummyRect.height = height;
		
			img.fillRect(dummyRect, 0x00000000);
		}
	}
	
	public static function clearImage(img:BitmapData)
	{
		if(img != null)
		{
			img.fillRect(img.rect, 0x00000000);
		}
	}
	
	public static function clearImageUsingMask(dest:BitmapData, mask:BitmapData, x:Int, y:Int)
	{
		if(imageApiAutoscale)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
		}
		
		#if flash
		
		//Inspired by http://franto.com/inverse-masking-disclosed/
		var temp = new Sprite();
		var bmpDest = new Bitmap(dest);
		var bmpMask = new Bitmap(mask);
		bmpMask.x = x;
		bmpMask.y = y;
		bmpDest.blendMode = BlendMode.LAYER;
		bmpMask.blendMode = BlendMode.ERASE;
		temp.addChild(bmpDest);
		temp.addChild(bmpMask);
		
		var result = new BitmapData(dest.width, dest.height, true, 0);
		result.draw(temp);
		
		dummyPoint.x = 0;
		dummyPoint.y = 0;
		
		dest.copyPixels(result, dest.rect, dummyPoint);
		
		#else
		
		var w:Int = mask.width;
		var h:Int = mask.height;
		var maskX = 0;
		var maskY = 0;

		if (x < 0)
		{
			if (x > dest.width - w)
			{
				w = dest.width;
			}
			else
			{
				w = w + x;
			}
			
			maskX = maskX - x;
			x = 0;
		}
		else if (x > dest.width - w)
		{
			w = w - (x - (dest.width - w));
			x = dest.width - w;
		}
		
		if (y < 0)
		{
			if (y > dest.height - h)
			{
				h = dest.height;
			}
			else
			{
				h = h + y;
			}
		
			maskY = maskY - y;
			y = 0;
		}
		else if (y > dest.height - h)
		{
			h = h - (y - (dest.height - h));
			y = dest.height - h;
		}

		if (w <= 0 || h <= 0)
		{
			return;
		}
		
		var maskRect = new Rectangle(maskX, maskY, w, h);
		var maskPixels = mask.getPixels(maskRect);
		var destRect = new Rectangle(x, y, w, h);
		var destPixels = dest.getPixels(destRect);
		var maskAlpha:Int;
		var destAlpha:Int;
		var finalAlpha:Int;

		for (i in 0...(w * h))
		{
			maskPixels.position = i * 4;
			destPixels.position = i * 4;
			maskAlpha = maskPixels.readUnsignedByte();
			destAlpha = destPixels.readUnsignedByte();
			finalAlpha = ((256 - maskAlpha) * destAlpha) >> 8;
			destPixels.position = i * 4;
			destPixels.writeByte(finalAlpha);
		}
		maskPixels.position = 0;
		destPixels.position = 0;
		dest.setPixels(destRect, destPixels);
		
		#end
	}
	
	public static function retainImageUsingMask(dest:BitmapData, mask:BitmapData, x:Int, y:Int)
	{
		if(imageApiAutoscale)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
		}
		
		dummyPoint.x = x;
		dummyPoint.y = y;

		dest.copyChannel(mask, mask.rect, dummyPoint, openfl.display.BitmapDataChannel.ALPHA, openfl.display.BitmapDataChannel.ALPHA);
	}
	
	public static function fillImage(img:BitmapData, color:Int)
	{
		if(img != null)
		{
			img.fillRect(img.rect, (255 << 24) | color);
		}
	}
	
	public static function filterImage(img:BitmapData, filter:BitmapFilter)
	{
		if(img != null)
		{
			dummyPoint.x = 0;
			dummyPoint.y = 0;
		
			img.applyFilter(img, img.rect, dummyPoint, filter);
		}
	}
	
	public static function imageSetPixel(img:BitmapData, x:Int, y:Int, color:Int)
	{
		if(img != null)
		{
			if(imageApiAutoscale && Engine.SCALE != 1)
			{
				var x2 = Std.int((x+1) * Engine.SCALE);
				var y2 = Std.int((y+1) * Engine.SCALE);
				x = Std.int(x * Engine.SCALE);
				y = Std.int(y * Engine.SCALE);
				
				for(j in x...x2)
				{
					for(k in y...y2)
					{
						img.setPixel32(j, k, color | 0xFF000000);
					}
				}
			}
			else
			{
				img.setPixel32(x, y, color | 0xFF000000);
			}
		}
	}
	
	public static function imageGetPixel(img:BitmapData, x:Int, y:Int):Int
	{
		if(img != null)
		{
			if(imageApiAutoscale)
			{
				x = Std.int(x * Engine.SCALE);
				y = Std.int(y * Engine.SCALE);
			}
			
			return img.getPixel(x, y);
		}
		
		return 0;
	}
	
	public static function imageSwapColor(img:BitmapData, originalColor:Int, newColor:Int)
	{
		if(img != null)
		{
			dummyPoint.x = 0;
			dummyPoint.y = 0;
			
			originalColor = (255 << 24) | originalColor;
			newColor = (255 << 24) | newColor;
			
			img.threshold(img, img.rect, dummyPoint, "==", originalColor, newColor, 0xffffffff, true);
		}
	}
	
	//TODO: Can we do this "in place" without the extra objects?
	public static function flipImageHorizontal(img:BitmapData)
	{
		var matrix:Matrix = new Matrix();
		matrix.scale(-1, 1);
		matrix.translate(img.width, 0);
		
		var result = new BitmapData(img.width, img.height, true, 0);
		result.draw(img, matrix);
		
		dummyPoint.x = 0;
		dummyPoint.y = 0;
		
		img.copyPixels(result, result.rect, dummyPoint);
	}
	
	//TODO: Can we do this "in place" without the extra objects?
	public static function flipImageVertical(img:BitmapData)
	{
		var matrix:Matrix = new Matrix();
		matrix.scale(1, -1);
		matrix.translate(0, img.height);
		
		var result = new BitmapData(img.width, img.height, true, 0);
		result.draw(img, matrix);
		
		dummyPoint.x = 0;
		dummyPoint.y = 0;
		
		img.copyPixels(result, result.rect, dummyPoint);
	}
	
	public static function setXForImage(img:BitmapWrapper, value:Float)
	{
		if(img != null)
		{
			img.imgX = value;
		}
	}
	
	public static function setYForImage(img:BitmapWrapper, value:Float)
	{
		if(img != null)
		{
			img.imgY = value;
		}
	}
	
	public static function fadeImageTo(img:BitmapWrapper, value:Float, duration:Float = 1, easing:EasingFunction = null)
	{
		img.tweenProps.alpha.tween(img.alpha, value, easing, Std.int(duration*1000));
	}

	public static function setOriginForImage(img:BitmapWrapper, x:Float, y:Float)
	{
		img.setOrigin(x, y);
	}
	
	public static function growImageTo(img:BitmapWrapper, scaleX:Float = 1, scaleY:Float = 1, duration:Float = 1, easing:EasingFunction = null)
	{
		img.tweenProps.scaleXY.tween(img.scaleX, scaleX, img.scaleY, scaleY, easing, Std.int(duration*1000));
	}
	
	//In degrees
	public static function spinImageTo(img:BitmapWrapper, angle:Float, duration:Float = 1, easing:EasingFunction = null)
	{
		img.tweenProps.angle.tween(img.rotation, angle, easing, Std.int(duration*1000));
	}

	public static function moveImageTo(img:BitmapWrapper, x:Float, y:Float, duration:Float = 1, easing:EasingFunction = null)
	{
		img.tweenProps.xy.tween(img.imgX, x, img.imgY, y, easing, Std.int(duration*1000));
	}
	
	//In degrees
	public static function spinImageBy(img:BitmapWrapper, angle:Float, duration:Float = 1, easing:EasingFunction = null)
	{
		spinImageTo(img, img.rotation + angle, duration, easing);
	}
	
	public static function moveImageBy(img:BitmapWrapper, x:Float, y:Float, duration:Float = 1, easing:EasingFunction = null)
	{
		moveImageTo(img, img.imgX + x, img.imgY + y, duration, easing);
	}
	
	public static function setFilterForImage(img:BitmapWrapper, filter:BitmapFilter)
	{
		#if !use_actor_tilemap
		if(img != null)
		{
			img.filters = img.filters.concat([filter]);
		}
		#end
	}
	
	public static function clearFiltersForImage(img:BitmapWrapper)
	{
		#if !use_actor_tilemap
		if(img != null)
		{
			img.filters = [];
		}
		#end
	}
	
	//Base64 encodes raw image data. Does NOT convert to a PNG.
	public static function imageToText(img:BitmapData):String
	{
		var bytes = img.getPixels(img.rect);
		
		return img.width + ";" + img.height + ";" + toBase64(Bytes.ofData(bytes));
	}
	
	//This is extremely slow. Tried this (https://github.com/underscorediscovery/gameapi-haxe/blob/master/playtomic/Encode.hx) 
	//but that didn't work. May try again in the future.
	public static function imageFromText(text:String):BitmapData
	{
		var parts = text.split(";");
		var width = Std.parseInt(parts[0]);
		var height = Std.parseInt(parts[1]);
		var bytes = fromBase64(parts[2]);
		
		var data = new ByteArray();

		for(n in 0...bytes.length)
		{
			data.writeByte(bytes.get(n));
		}
		
		data.position = 0;
		data.endian = BIG_ENDIAN;
		
		var img = new BitmapData(width, height, true, 0);
		img.setPixels(img.rect, data);
		return img;
	}
	
	private static inline var BASE_64_ENCODINGS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	private static inline var BASE_64_PADDING = "=";
	
	private static function toBase64(bytes:Bytes):String 
	{
		var encodings = Bytes.ofString(BASE_64_ENCODINGS);
		var base64 = new BaseCode(encodings).encodeBytes(bytes).toString();
		
		var remainder = base64.length % 4;

		if(remainder > 1) 
		{
			base64 += BASE_64_PADDING;
		}

		if(remainder == 2) 
		{
			base64 += BASE_64_PADDING;
		}
		
		return base64;
	}

	private static function fromBase64(base64:String):Bytes 
	{
		var paddingSize = -1;
		
		if(base64.charAt(base64.length - 2) == BASE_64_PADDING) 
		{
			paddingSize = 2;
		}
		
		else if(base64.charAt(base64.length - 1) == BASE_64_PADDING)
		{
			paddingSize = 1;
		}
		
		if(paddingSize != -1) 
		{
			base64 = base64.substr(0, base64.length - paddingSize);
		}
		
		var encodings = Bytes.ofString(BASE_64_ENCODINGS);
		return new BaseCode(encodings).decodeBytes(Bytes.ofString(base64));
	}

	//*-----------------------------------------------
	//* Eye Candy
	//*-----------------------------------------------
	
	/**
	* Begin screen shake
	*/
	public static function startShakingScreen(intensity:Float=0.05, duration:Float=0.5)
	{
		engine.shakeScreen(intensity, duration);
	}
	
	/**
	* End screen shake
	*/
	public static function stopShakingScreen()
	{
		engine.stopShakingScreen();
	}
	
	//*-----------------------------------------------
	//* Terrain Changer (Tile API)
	//*-----------------------------------------------
	
	/**
	* Get the top terrain layer
	*/
	public static function getTopLayer():Int
	{
		return engine.getTopLayer();
	}
	
	/**
	* Get the bottom terrain layer
	*/
	public static function getBottomLayer():Int
	{
		return engine.getBottomLayer();
	}
	
	/**
	* Get the middle terrain layer
	*/
	public static function getMiddleLayer():Int
	{
		return engine.getMiddleLayer();
	}

	public static function getTileLayerAt(layer:RegularLayer):TileLayer
	{
		if(layer == null || !Std.isOfType(layer, Layer))
			return null;
		return cast(layer, Layer).tiles;
	}

	public static function getTilesetIDByName(tilesetName:String):Int
	{
		var r = Data.get().resourceMap.get(tilesetName);
		if(Std.isOfType(r, Tileset))
		{
			return r.ID;
		}
		return -1;
	}

	public static function setTileAt(row:Int, col:Int, layer:RegularLayer, tilesetID:Int, tileID:Int)
	{
		if(layer == null || !Std.isOfType(layer, Layer))
		{
			return;
		}
		
		removeTileAt(row, col, layer);
		
		var tlayer = cast(layer, Layer).tiles;

		var tset = cast Data.get().resources.get(tilesetID);
		var tile:Tile = tset.tiles[tileID];
		
		//add the Tile to the TileLayer
		tlayer.setTileAt(row, col, tile);    
		
		//If animated tile and not already in update list, add to update list
		if (tile != null && tile.pixels != null && !(Utils.contains(engine.animatedTiles, tile)))
		{
			if(tile.durations.length > 1)
			{
				engine.animatedTiles.push(tile);
			}
		}
		
		//Now add the shape as a body
		if(tile != null && tile.collisionID != -1)
		{
			// Copy the default shape into a new one that can be scaled to fit the tile size.
			var refTileShape = GameModel.get().shapes.get(tile.collisionID);
			var vertices = refTileShape.getVertices();
			var vertexCount = refTileShape.getVertexCount();
			var tileShape = B2PolygonShape.asArray(vertices,vertexCount);
			
			// Adjust the collison shape based on the tile size.
			for(vec in tileShape.getVertices())
			{
			vec.x *= (engine.scene.tileWidth/32);
			vec.y *= (engine.scene.tileHeight/32);
			}
			
			var x = col * engine.scene.tileWidth;
			var y = row * engine.scene.tileHeight;
			
			if(!Engine.NO_PHYSICS && tileShape != null)
			{
				createDynamicTile(tileShape, x, y, layer.ID, engine.scene.tileWidth, engine.scene.tileHeight);
			}
			else if (tileShape != null)
			{
				getTileLayerAt(layer).grid.setTile(col, row);
			}
		}
		
		engine.tileUpdated = true;
	}
	
	public static function tileExistsAt(row:Int, col:Int, layer:RegularLayer):Bool
	{
		return getTileAt(row, col, layer) != null;
	}
	
	//tileCollisionAt function added to return True if ANY collision shape exists, or False for no tile or collision shape
	//if the user gives it a null value for the layer, it will loop through all layers instead of a specific one
	public static function tileCollisionAt(row:Int, col:Int, layer:RegularLayer):Bool
	{
		if(layer == null)
		{
			for (layer in engine.interactiveLayers)
			{
				var tile = layer.tiles.getTileAt(row, col);
				if((tile == null) || (tile.collisionID == -1))
				{
					continue;
				}
				else
				{
					return true;
				}
			}
			return false;
		}
		else
		{
			var tile = getTileAt(row, col, layer);
			if((tile == null) || (tile.collisionID == -1))
			{
				return false;
			}
			else
			{
				return true;
			}
		}
	}

	//to easily get a column or row coordinate at a given X or Y coordinate
	public static function getTilePosition(axis:Dynamic, val:Float):Int
	{
		var tileH = engine.scene.tileHeight;
		var tileW = engine.scene.tileWidth;
		if(axis == 0)
		{
			return Math.floor(val / tileW);
		}
		else
		{
			return Math.floor(val / tileH);
		}
	}

	public static function getTileIDAt(row:Int, col:Int, layer:RegularLayer):Int
	{
		var tile = getTileAt(row, col, layer);
		
		if(tile == null)
		{
			return -1;
		}
		
		return tile.tileID;
	}
	
	public static function getTileColIDAt(row:Int, col:Int, layer:RegularLayer):Int
    {
    	var tile = getTileAt(row, col, layer);
                       
        if(tile == null)
        {
        	return -1;
        }
                       
        return tile.collisionID;
    }

	public static function getTileDataAt(row:Int, col:Int, layer:RegularLayer):String
    {
    	var tile = getTileAt(row, col, layer);
        
        if(tile == null)
        {
        	return "";
        }
        
        return tile.metadata;
    }
	
	public static function getTilesetIDAt(row:Int, col:Int, layer:RegularLayer):Int
	{
		var tile = getTileAt(row, col, layer);
		
		if(tile == null)
		{
			return -1;
		}
		
		return tile.parent.ID;
	}
	
	public static function getTileAt(row:Int, col:Int, layer:RegularLayer):Tile
	{
		var tlayer = getTileLayerAt(layer);
		
		if(tlayer == null)
		{
			return null;
		}
		
		return tlayer.getTileAt(row, col);
	}
	
	public static function removeTileAt(row:Int, col:Int, layer:RegularLayer)
	{
		if(layer == null || !Std.isOfType(layer, Layer))
		{
			return;
		}
		var tlayer = cast(layer, Layer).tiles;
		
		//grab the tile to get the shape
		var tile:Tile = getTileAt(row, col, layer);
		
		//If we find a tile in this location
		if(tile != null)
		{
			//Remove the collision box
			if(!Engine.NO_PHYSICS && tile.collisionID != -1)
			{
				var x = col * engine.scene.tileWidth;
				var y = row * engine.scene.tileHeight;
				var key = "ID" + "-" + x + "-" + y + "-" + layer.ID;
				var a = engine.dynamicTiles.get(key);
				
				if(a != null)
				{
					engine.removeActor(a);
					engine.dynamicTiles.remove(key);
				}
			}
			
			else if (tile.collisionID != -1)
			{
				tlayer.grid.clearTile(col, row);
			}
			
			//Remove the tile image
			tlayer.setTileAt(row, col, null);
			
			engine.tileUpdated = true;
		}
	}

	public static function getTileForCollision(event:Collision, point:CollisionPoint):Tile
	{
		if (event.thisCollidedWithTile || event.otherCollidedWithTile)
		{
			var xNormal:Int = Math.round(Engine.toPixelUnits(point.normalX));
			var yNormal:Int = Math.round(Engine.toPixelUnits(point.normalY));
			var x:Int = Math.round(Engine.toPixelUnits(point.x));
			var y:Int = Math.round(Engine.toPixelUnits(point.y));
		
			if(event.thisCollidedWithTile)
			{
				xNormal = -xNormal;
				yNormal = -yNormal;
			}
	
			if(xNormal < 0 && (x % engine.scene.tileWidth == 0))
				x -= 1;
			if(yNormal < 0 && (y % engine.scene.tileHeight == 0))
				y -= 1;
	
			x = getTilePosition(0, x);
			y = getTilePosition(1, y);
	
			for(layer in engine.interactiveLayers)
			{
				var tile = layer.tiles.getTileAt(y, x);
				if((tile == null) || (tile.collisionID == -1))
					continue;
				return tile;
			}
		}
		return null;
	}

	public static function getTileDataForCollision(event:Collision, point:CollisionPoint):String
	{
		var t:Tile = getTileForCollision(event, point);
		if(t != null)
			return t.metadata;
		else
			return "";
	}
	
	public static function getTilePositionForCollision(axis:Dynamic, event:Collision, point:CollisionPoint):Int
	{
		if (event.thisCollidedWithTile || event.otherCollidedWithTile)
		{
			var xNormal:Int = Math.round(Engine.toPixelUnits(point.normalX));
			var yNormal:Int = Math.round(Engine.toPixelUnits(point.normalY));
			var x:Int = Math.round(Engine.toPixelUnits(point.x));
			var y:Int = Math.round(Engine.toPixelUnits(point.y));
		
			if(event.thisCollidedWithTile)
			{
				xNormal = -xNormal;
				yNormal = -yNormal;
			}
	
			if(xNormal < 0 && (x % engine.scene.tileWidth == 0))
				x -= 1;
			if(yNormal < 0 && (y % engine.scene.tileHeight == 0))
				y -= 1;
	
			x = getTilePosition(0, x);
			y = getTilePosition(1, y);
			
			if(axis == 0)
			{
				return x;
			}
			else
			{
				return y;
			}
		}
		return -1;
	}
	
	//TODO: For simple physics, we stick in either a box or nothing at all - maybe it autohandles this?
	private static function createDynamicTile(shape:B2Shape, x:Float, y:Float, layerID:Int, width:Float, height:Float)
	{
		var a:Actor = new Actor
		(
			engine, 
			Utils.INTEGER_MAX,
			GameModel.TERRAIN_ID,
			x, 
			y, 
			layerID,
			width, 
			height, 
			null, //sprite
			null, //behavior values
			null, //actor type
			null, //body def
			false, //sensor?
			true, //stationary?
			false, //kinematic?
			false, //rotates?
			shape, //terrain shape
			false, //is lightweight?
			false //autoscale?
		);
		
		a.name = "Terrain";
		a.visible = false;
		
		var key = "ID" + "-" + x + "-" + y + "-" + layerID;

		engine.dynamicTiles.set(key, a);
	}
	
	//*-----------------------------------------------
	//* Fonts
	//*-----------------------------------------------
	
	public static function getFont(fontID:Int):Font
	{
		return cast Data.get().resources.get(fontID);
	}
	
	//*-----------------------------------------------
	//* Global
	//*-----------------------------------------------
	
	public static function pause()
	{
		engine.pause();
	}
	
	public static function unpause()
	{
		engine.unpause();
	}
	
	public static function toggleFullScreen()
	{
		Engine.engine.toggleFullScreen();
	}
		
	/**
	* Pause the game
	*/
	public static function pauseAll()
	{
		Engine.paused = true;
	}
	
	/**
	* Unpause the game
	*/
	public static function unpauseAll()
	{
		Engine.paused = false;
	}
	
	/**
	* Get the screen width in pixels
	*/
	public static function getScreenWidth():Int
	{
		return Engine.screenWidth;
	}

	/**
	* Get the screen height in pixels
	*/
	public static function getScreenHeight():Int
	{
		return Engine.screenHeight;
	}

	/**
	* Get the stage width in pixels
	*/
    public static function getStageWidth()
	{
    	//return openfl.system.Capabilities.screenResolutionX;
		return Engine.stage.stageWidth;
	}

	/**
	* Get the stage height in pixels
	*/
	public static function getStageHeight()
	{
		//return openfl.system.Capabilities.screenResolutionY;
		return Engine.stage.stageHeight;
	}
		
	/**
	* Sets the distance an actor can travel offscreen before being deleted.
	*/
	public static function setOffscreenTolerance(top:Int, left:Int, bottom:Int, right:Int)
	{
		engine.setOffscreenTolerance(top, left, bottom, right);
	}
	
	/**
	* Returns true if the scene is transitioning
	*/
	public static function isTransitioning():Bool
	{
		return engine.isTransitioning();
	}
	
	/**
	* Adjust how fast or slow time should pass in the game; default is 1.0. 
	*/
	public static function setTimeScale(scale:Float)
	{
		Engine.timeScale = scale;
	}
	
	/**
	 * Generates a random float between 0 and 1. Deterministic, meaning safe to use if you want to record replays in random environments
	 */
	public static function randomFloat():Float
	{
		return Math.random();
	}

	/**
	 * Generates a random float between the low and high values.
	 */
	public static function randomFloatBetween(low:Float, high:Float):Float
	{
		if (low <= high)
		{
			return low + Math.random() * (high - low);
		}
		else
		{
			return high + Math.random() * (low - high);
		}
	}
		
	/**
	 * Generates a random integer between the low and high values.
	 */
	public static function randomInt(low:Int, high:Int):Int
	{
		if (low <= high)
		{
			return low + Math.floor(Math.random() * (high - low + 1));
		}
		else
		{
			return high + Math.floor(Math.random() * (low - high + 1));
		}
	}
	
	/**
	* Change a Number to another specific Number over time  
	*/
	public function tweenNumber(attributeName:String, value:Float, duration:Float = 1, easing:EasingFunction = null) 
	{
		var attributeTween = attributeTweens.get(attributeName);
		if(attributeTween == null)
		{
			attributeTween = new TweenFloat();
			attributeTween.doOnUpdate(function() {
				Reflect.setField(this, attributeName, attributeTween.value);
			});
			attributeTweens.set(attributeName, attributeTween);
		}
		attributeTween.tween(Reflect.field(this, attributeName), value, easing, Std.int(duration*1000));
	}
	
	/**
	* Stops a tween 
	*/
	public function abortTweenNumber(attributeName:String)
	{
		var attributeTween = attributeTweens.get(attributeName);
		if(attributeTween != null)
		{
			TweenManager.cancel(attributeTween);
		}
	}
	
	public function pauseTweens()
	{
		for(value in attributeTweens)
			value.paused = true;
	}
	
	public function unpauseTweens()
	{
		for(value in attributeTweens)
			value.paused = false;
	}
	
	//*-----------------------------------------------
	//* Saving
	//*-----------------------------------------------
	
	/**
	 * Saves a game (i.e. save all game attributes to a SharedObject)
	 *
	 * Callback = function(success:Boolean):void
	 */
	public static function saveGame(fileName:String, onComplete:Bool->Void=null):Void
	{
		var localPath = Application.current.meta.get("localSavePath");
		var so:SharedObject = SharedObject.getLocal(fileName, localPath);
		
		for(key in engine.gameAttributes.keys())
		{
			if (engine.savableAttributes.get(key) == false)
			{
				continue;
			}
		
			Utils.saveToSharedObject(so, key, engine.gameAttributes.get(key));
		}	

		Utils.flushSharedObject(so, onComplete);
	}
	
	/**
  	 * Load a saved game (i.e. load all values from the SharedObject as game attributes)
	 *
	 * Callback = function(success:Boolean):void
	 */
	public static function loadGame(fileName:String, onComplete:Bool->Void=null):Void
	{
		var localPath = Application.current.meta.get("localSavePath");
		var so:SharedObject = SharedObject.getLocal(fileName, localPath);
		
		for(key in Reflect.fields(so.data))
		{
			engine.gameAttributes.set(key, Utils.loadFromSharedObject(so, key));
		}
		
		if (onComplete != null)
			onComplete(true);
	}
	
	public static function saveData(fileName:String, name:String, value:Dynamic, onComplete:Bool->Void=null):Void
	{
		var localPath = Application.current.meta.get("localSavePath");
		var so:SharedObject = SharedObject.getLocal(fileName, localPath);
	
		Utils.saveToSharedObject(so, name, value);
		
		Utils.flushSharedObject(so, onComplete);
	}

	public static function loadData(fileName:String, name:String, onComplete:Bool->Void=null):Dynamic
	{
		var localPath = Application.current.meta.get("localSavePath");
		var so:SharedObject = SharedObject.getLocal(fileName, localPath);
	
		var value:Dynamic = Utils.loadFromSharedObject(so, name);
		
		if (onComplete != null)
			onComplete(true);
		
		return value;
	}
	
	public static function checkData(fileName:String, name:String):Dynamic
	{	
		var localPath = Application.current.meta.get("localSavePath");
		var so:SharedObject = SharedObject.getLocal(fileName, localPath);
		
		return Reflect.field(so.data, name) != null;
	}
	
	//*-----------------------------------------------
	//* Web Services
	//*-----------------------------------------------
	
	private static function defaultURLHandler(event:FlashEvent)
	{
		var loader:URLLoader = new URLLoader(cast event.target);
		trace("Visited URL: " + loader.data);
	}
	
	#if flash
	private static function defaultURLError(event:IOErrorEvent)
	{
		trace("Could not visit URL");
	}
	#end
	
	public static function openURLInBrowser(URL:String)
	{
		Lib.getURL(new URLRequest(URL));
	}
		
	/**
	* Attempts to connect to a URL
	*/
	public static function visitURL(URL:String, fn:FlashEvent->Void = null)
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
			loader.addEventListener(FlashEvent.COMPLETE, fn);
			
			#if flash
			loader.addEventListener(IOErrorEvent.NETWORK_ERROR, defaultURLError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, defaultURLError);
			#elseif android
			//making sure the connection closes after 0.5 secs so the game doesn't freeze
		    runLater(500, function(timeTask:TimedTask):Void
			{
				loader.close();
			});
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
	public static function postToURL(URL:String, data:String = null, fn:FlashEvent->Void = null)
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
			loader.addEventListener(FlashEvent.COMPLETE, fn);
			
			#if flash
			loader.addEventListener(IOErrorEvent.NETWORK_ERROR, defaultURLError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, defaultURLError);
			#else
			//making sure the connection closes after 0.5 secs so the game doesn't freeze
		    runLater(500, function(timeTask:TimedTask):Void
			{
				loader.close();
			});
			#end
		} 
		
		catch(error:String) 
		{
			trace("Cannot open URL.");
		}		
	}
	
	//Does nothing. Previously: http://community.stencyl.com/index.php/topic,30954.0.html
	public static function convertToPseudoUnicode(internationalText:String):String
	{
		return internationalText;
	}
	
	//*-----------------------------------------------
	//* Social Media
	//*-----------------------------------------------
	
	/**
	* Send a Tweet (GameURL is the twitter account that it will be posted to)
	*/
	public static function simpleTweet(message:String, gameURL:String)
	{
		openURLInBrowser("http://twitter.com/home?status=" + StringTools.urlEncode(message + " " + gameURL));
	}
	
	//*-----------------------------------------------
	//* Mobile
	//*-----------------------------------------------
	
	//Atlases
	
	//Like the prior implementation, this is a HINT to the engine to load a new atlas UPON CHANGING SCENES
	//Does not happen immediately.
	public static function loadAtlas(atlasID:Int)
	{
		engine.atlasesToLoad.set(atlasID, atlasID);
	}
	
	public static function unloadAtlas(atlasID:Int)
	{
		engine.atlasesToUnload.set(atlasID, atlasID);
	}
	
	public static function atlasIsLoaded(atlasID:Int):Bool
	{
		#if flash
		return true;
		#else
		var atlas = GameModel.get().atlases.get(atlasID);
		return (atlas != null && atlas.active);
		#end
	}
	
	
	//*-----------------------------------------------
	//* Native
	//*-----------------------------------------------
	
	public static function showAlert(title:String, msg:String)
	{
		#if mobile
		Native.showAlert(title, msg);
		#end
	}
	
	public static function vibrate(time:Float = 1)
	{
		#if mobile
		Native.vibrate(time);
		#end
	}
	
	public static function showKeyboard()
	{
		#if mobile
		Native.showKeyboard();
		#end
	}
	
	public static function hideKeyboard()
	{
		#if mobile
		Native.hideKeyboard();
		#end
	}
	
	public static function setKeyboardText(text:String)
	{
		#if mobile
		Native.setKeyboardText(text);
		#end
	}
	
	public static function setIconBadgeNumber(n:Int)
	{
		#if mobile
		Native.setIconBadgeNumber(n);
		#end
	}
	
	//*-----------------------------------------------
	//* Debug
	//*-----------------------------------------------
	
	public static function enableDebugDrawing()
	{
		Engine.DEBUG_DRAW = true;
		
		if (!Engine.NO_PHYSICS)
		{
			Engine.debugDrawer.m_sprite.graphics.clear();
		}
	}

	public static function disableDebugDrawing()
	{
		Engine.DEBUG_DRAW = false;
		
		if (!Engine.NO_PHYSICS)
		{
			Engine.debugDrawer.m_sprite.graphics.clear();
		}
	}
	
	
	//*-----------------------------------------------
	//* Advanced
	//*-----------------------------------------------
	
	public static function gameURL():String
	{
		#if flash
		return Lib.current.loaderInfo.url;
		#else
		return "";
		#end
	}
	
	public static function exitGame()
	{
		#if flash
		try
		{
			Lib.fscommand("quit");
		}
		catch(e:SecurityError)
		{
			trace("Could not exit game: " + e.message); 
		}
		#elseif sys
		Sys.exit(0);
		#end
	}
	
	
	//*-----------------------------------------------
	//* Utilities
	//*-----------------------------------------------
	
	public static function createGrayscaleFilter():ColorMatrixFilter
	{
		var matrix:Array<Float> = new Array<Float>();
		
		matrix = matrix.concat([0.5,0.5,0.5,0,0]);
		matrix = matrix.concat([0.5,0.5,0.5,0,0]);
		matrix = matrix.concat([0.5,0.5,0.5,0,0]);
		matrix = matrix.concat([0,0,0,1,0]);
		
		return new ColorMatrixFilter(matrix);
	}
	
	/**
	* Returns a ColorMatrixFilter that is sepia colored 
	*/
	public static function createSepiaFilter():ColorMatrixFilter
	{
		var matrix:Array<Float> = new Array<Float>();
		
		matrix = matrix.concat([0.34, 0.33, 0.33, 0.00, 30.00]);
		matrix = matrix.concat([0.33, 0.34, 0.33, 0.00, 20.00]);
		matrix = matrix.concat([0.33, 0.33, 0.34, 0.00, 0.00]);
		matrix = matrix.concat([0.00, 0.00, 0.00, 1.00, 0.00]);
		
		return new ColorMatrixFilter(matrix);
	}
	
	/**
	* Returns a ColorMatrixFilter that is a negative
	*/
	public static function createNegativeFilter():ColorMatrixFilter
	{
		var matrix:Array<Float> = new Array<Float>();
		
		matrix = matrix.concat([-1, 0, 0, 0, 255]);
		matrix = matrix.concat([0, -1, 0, 0, 255]);
		matrix = matrix.concat([0, 0, -1, 0, 255]);
		matrix = matrix.concat([0, 0, 0, 1, 0]);
		
		return new ColorMatrixFilter(matrix);
	}
	
	/**
	* Returns a ColorMatrixFilter that is a specific color
	*/
	public static function createTintFilter(color:Int, amount:Float = 1):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.colorize(color, amount);

		return cm.getFilter();
	}
	
	/**
	* Returns a ColorMatrixFilter that adjusts hue (in relative degrees) 
	*/
	public static function createHueFilter(h:Float):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.adjustHue(h);
		cm.adjustSaturation(1);
		
		return cm.getFilter();
	}
	
	/**
	* Returns a ColorMatrixFilter that adjusts saturation (measured 0 - 2 with 1 being normal) 
	*/
	public static function createSaturationFilter(s:Float):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.adjustSaturation(s/100);
		
		return cm.getFilter();
	}
	
	/**
	* Returns a ColorMatrixFilter that adjusts brightness (in relative degrees, 0-100) 
	*/
	public static function createBrightnessFilter(b:Float):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.adjustBrightness(b/100);
		
		return cm.getFilter();
	}
}
