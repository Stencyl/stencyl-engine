package com.stencyl.behavior;

import openfl.net.SharedObject;

import openfl.ui.Mouse;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.Lib;
import openfl.filters.BitmapFilter;
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

import com.stencyl.utils.Utils;
import com.stencyl.utils.ColorMatrix;
import com.stencyl.event.EventMaster;
import com.stencyl.event.NativeListener;
import com.stencyl.io.SpriteReader;

import motion.Actuate;
import motion.easing.Linear;

import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.joints.B2Joint;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Fixture;

import haxe.ds.ObjectMap;

import flash.utils.ByteArray;
import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import haxe.io.BytesData;

//#if flash
import openfl.filters.ColorMatrixFilter;
//#end

import scripts.MyAssets;

//XXX: For some reason, it wasn't working by importing openfl.net.SharedObjectFlushedStatus
#if js
//typedef JeashSharedObjectFlushStatus = flash.net.SharedObjectFlushedStatus;
#end

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
	
	public static var dummyVec:B2Vec2 = new B2Vec2();
	
	private static var drawData:Array<Float> = new Array<Float>();
	private static var ma:Matrix = new Matrix();

	//*-----------------------------------------------
	//* Behavior
	//*-----------------------------------------------

	public var wrapper:Behavior;

	// Property Change Support
	
	public var propertyChangeListeners:Map<String,Dynamic>;
	public var equalityPairs:ObjectMap<Dynamic, Dynamic>; //hashmap does badly on some platforms when checking key equality (for primitives) - beware
	
	public var checkProperties:Bool;
	
	// Display Names
	
	public var nameMap:Map<String,Dynamic>;
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------
	public var scriptInit:Bool;
	
	public function new()
	{
		scriptInit = false;
		checkProperties = false;
		nameMap = new Map<String,Dynamic>();	
		propertyChangeListeners = new Map<String,Dynamic>();
		equalityPairs = new ObjectMap<Dynamic, Dynamic>();
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
	
	public static inline function asBoolean(o:Dynamic):Bool
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
	
	public static inline function asNumber(o:Dynamic):Float
	{
		if(o == null)
		{
			return 0;
		}
		
		else if(Std.is(o, Float))
		{
			return o;
		}
		
		else if(Std.is(o, Int))
		{
			return o;
		}
		
		else if(Std.is(o, Bool))
		{
			return cast(o, Bool) ? 1 : 0;
		}
		
		else if(Std.is(o, String))
		{
			return Std.parseFloat(o);
		}
		
		//Can't do it - return junk
		else
		{
			trace(o + " is not a number!");
			return 0;
		}
	}
	
	public static inline function hasValue(o:Dynamic):Bool
	{
		if(Std.is(o, Bool))
		{
			return true;
		}
		
		else if(Std.is(o, String))
		{
			return true;
		}
		
		else if(Std.is(o, Float))
		{
			return true;
		}
		
		else if(Std.is(o, Int))
		{
			return true;
		}
		
		else
		{
			return o != null;
		}
	}
	
	public static function isPrimitive(o:Dynamic):Bool
	{
		if(Std.is(o, Bool))
		{
			return true;
		}
		
		else if(Std.is(o, Float))
		{
			return true;
		}
		
		else if(Std.is(o, Int))
		{
			return true;
		}
		
		return false;
	}

	public static inline function getDefaultValue(o:Dynamic):Dynamic
	{
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
		propertyChangeListeners = new Map<String,Dynamic>();
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
						return engine.getGroup(cast(body.getUserData()).groupID);
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
	
	//Native Listeners poll on a special place where events are infrequent. Do NOT attempt to use
	//for anything normal in the engine!
	
	public function addMobileKeyboardListener(type:Int, func:String->Void)
	{
		engine.nativeListeners.push(new NativeListener(EventMaster.TYPE_KEYBOARD, type, func));
	}
	
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
		engine.whenSwipedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenSwipedListeners, func);
		}
	}
	
	public function addMultiTouchStartListener(func:Dynamic->Array<Dynamic>->Void)
	{
		#if(mobile && !air)
		engine.whenMTStartListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenMTStartListeners, func);
		}
		#end
	}
	
	public function addMultiTouchMoveListener(func:Dynamic->Array<Dynamic>->Void)
	{
		#if(mobile && !air)
		engine.whenMTDragListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenMTDragListeners, func);
		}
		#end
	}
	
	public function addMultiTouchEndListener(func:Dynamic->Array<Dynamic>->Void)
	{
		#if(mobile && !air)
		engine.whenMTEndListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenMTEndListeners, func);
		}
		#end
	}
	
	public function addKeyStateListener(key:String, func:Dynamic->Dynamic->Array<Dynamic>->Void)
	{			
		if(engine.whenKeyPressedListeners.get(key) == null)
		{
			engine.whenKeyPressedListeners.set(key, new Array<Dynamic>());
		}
		
		engine.hasKeyPressedListeners = true;
		
		var listeners = engine.whenKeyPressedListeners.get(key);
		listeners.push(func);
								
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(listeners, func);
		}
	}
	
	public function addAnyKeyPressedListener(func:Dynamic->Array<Dynamic>->Void)
	{
		engine.whenAnyKeyPressedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenAnyKeyPressedListeners, func);
		}
	}
	
	public function addAnyKeyReleasedListener(func:Dynamic->Array<Dynamic>->Void)
	{
		engine.whenAnyKeyReleasedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenAnyKeyReleasedListeners, func);
		}
	}

	public function addAnyGamepadPressedListener(func:Dynamic->Array<Dynamic>->Void)
	{
		engine.whenAnyGamepadPressedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenAnyGamepadPressedListeners, func);
		}
	}
	
	public function addAnyGamepadReleasedListener(func:Dynamic->Array<Dynamic>->Void)
	{
		engine.whenAnyGamepadReleasedListeners.push(func);
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.registerListener(engine.whenAnyGamepadReleasedListeners, func);
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
		
		checkProperties = true;
	}
	
	public function propertyChanged(propertyKey:String, property:Dynamic)
	{
		if (checkProperties)
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
								
								equalityPairs.remove(f);
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
			engine.collisionListeners.set(obj, new Map<Int,Dynamic>());									
		}
		
		if(!engine.collisionListeners.exists(obj2))
		{
			engine.collisionListeners.set(obj2, new Map<Int,Dynamic>());
		}	
		
		if(!engine.collisionListeners.get(obj).exists(obj2))
		{				
			engine.collisionListeners.get(obj).set(obj2, new Array<Dynamic>());		
		}
		
		var listeners = cast(engine.collisionListeners.get(obj).get(obj2), Array<Dynamic>);
		listeners.push(func);	
		
		if(Std.is(this, ActorScript))
		{
			cast(this, ActorScript).actor.collisionListenerCount++;
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
	 * @return The ID current scene or 0 if it doesn't exist.
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
		
		return 0;
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
	
	/**
     * @param	refType		0 to get layer by ID, 1 for name
     * @param	ref			The ID or name of the layer as a String
     */
    public static function getLayer(refType:Int, ref:String):RegularLayer
    {
    	return engine.getLayer(refType, ref);
    }
    
    public static function setBlendModeForLayer(refType:Int, ref:String, mode:openfl.display.BlendMode)
    {
    	var layer = getLayer(refType, ref);
		#if (cpp || neko)
		//only implemented for tilelayers on cpp
		if(Std.is(layer, Layer))
		{
			var tileLayer = cast(layer, Layer).tiles;
			tileLayer.blendName = Std.string(mode);
			tileLayer.draw(Std.int(Engine.cameraX * layer.scrollFactorX), Std.int(Engine.cameraY * layer.scrollFactorY));
		}
		#else
		getLayer(refType, ref).blendMode = mode;
		#end
    }
	
	/**
	 * Force the given layer to show.
	 *
	 * @param	refType		0 to get layer by ID, 1 for name
	 * @param	ref			The ID or name of the layer as a String
	 */
	public static function showTileLayer(refType:Int, ref:String)
	{
		engine.getLayer(refType, ref).alpha = 1;
	}
	
	/**
	 * Force the given layer to become invisible.
	 *
	 * @param	refType		0 to get layer by ID, 1 for name
	 * @param	ref			The ID or name of the layer as a String
	 */
	public static function hideTileLayer(refType:Int, ref:String)
	{
		engine.getLayer(refType, ref).alpha = 0;
	}
	
	/**
	 * Force the given layer to fade to the given opacity over time, applying the easing function.
	 *
	 * @param	layerRefType	0 to get layer by ID, 1 for name
	 * @param	layerRef		The ID or name of the layer as a String
	 * @param	alphaPct		the opacity (0-255) to fade to
	 * @param	duration		the duration of the fading (in milliseconds)
	 * @param	easing			easing function to apply. Linear (no smoothing) is the default.
	 */
	public static function fadeTileLayerTo(layerRefType:Int, layerRef:String, alphaPct:Float, duration:Float, easing:Dynamic = null)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
		
		Actuate.tween(getLayer(layerRefType, layerRef), duration, {alpha:alphaPct}).ease(easing);
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
		return Math.abs(Engine.cameraX / Engine.SCALE);
	}
	
	/**
	 * y-position of the camera
	 *
	 * @return The y-position of the camera
	 */
	public static function getScreenY():Float
	{
		return Math.abs(Engine.cameraY / Engine.SCALE);
	}
	
	/**
	 * x-center position of the camera
	 *
	 * @return The x-position of the camera
	 */
	public static function getScreenXCenter():Float
	{
		return Math.abs(Engine.cameraX / Engine.SCALE) + Engine.screenWidth / 2;
	}
	
	/**
	 * y-center position of the camera
	 *
	 * @return The y-position of the camera
	 */
	public static function getScreenYCenter():Float
	{
		return Math.abs(Engine.cameraY / Engine.SCALE) + Engine.screenHeight / 2;
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
		return Input.check(Engine.INTERNAL_CTRL);
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
	
	/*public static function setCursor(graphic:Class=null, xOffset:int=0, yOffset:int=0);
	{
		FlxG.mouse.show(graphic, xOffset, yOffset);
	}*/

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

	public static function createRecycledActorOnLayer(type:ActorType, x:Float, y:Float, layerRefType:Int, layerRef:String):Actor
	{
		var a:Actor = engine.getRecycledActorOfTypeOnLayer(type, x, y, engine.getLayer(layerRefType, layerRef).ID);
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
	public static function getActorType(actorTypeID:Int):ActorType
	{
		return cast(Data.get().resources.get(actorTypeID), ActorType);
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
		if(engine.world == null)
		{
			engine.gravityX = x;
			engine.gravityY = y;
		}
		
		else
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
	
	public static function makeActorNotPassThroughTerrain(actor:Actor)
	{
		if (Engine.NO_PHYSICS)
		{
			if (actor != null && actor.physicsMode == 1)
			{
				actor.continuousCollision = true;
			}
			return;
		}
		
		B2World.m_continuousPhysics = true;
		
		if(actor != null && actor.physicsMode == 0)
		{
			actor.body.setBullet(true);
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
		var temp = Data.get().resources.get(soundID);
		
		if(temp == null)
		{
			return null;
		}
	
		return cast(temp, Sound);
	}
	
	/**
	* Returns a SoundClip resource by Name
	*/
	public static function getSoundByName(soundName:String):Sound
	{
		var sounds = Data.get().getResourcesOfType(Sound);
		
		for(sound in sounds)
		{
			if(sound.name == soundName)
			{
				return sound;
			}
		}
		
		return null;
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
	}
	
	/**
	* Play a specific SoundClip resource looped on a specific channel (use playSoundOnChannel() to play once)
	*/
	public static function loopSoundOnChannel(clip:Sound, channelNum:Int)
	{		
		var sc:SoundChannel = engine.channels[channelNum];	
		sc.loopSound(clip);			
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
	
	/**
	* Gets the current position for the given channel in milliseconds.
	* If not playing, will return the last point it was played at.
	*/
	public static function getPositionForChannel(channelNum:Int)
	{			
		var sc:SoundChannel = engine.channels[channelNum];	
		
		if(sc != null && sc.currentSound != null)
		{
			return sc.currentSound.position;
		}
		
		else
		{
			return 0;
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
	public static function setScrollSpeedForBackground(refType:Int, ref:String, xSpeed:Float, ySpeed:Float)
	{
		var allBackgrounds:Bool = (refType == 0 && ref == "-1");

		if(allBackgrounds)
		{
			for(layer in Engine.engine.backgroundLayers)
			{
				layer.setScrollSpeed(xSpeed, ySpeed);
			}
		}
		else
		{
			var layer = Engine.engine.getLayer(refType, ref);
			if(Std.is(layer, BackgroundLayer))
			{
				cast(layer, BackgroundLayer).setScrollSpeed(xSpeed, ySpeed);
			}
		}
	}

	/**
	* Set the parallax factor of a background or tilelayer
	*/
	public static function setScrollFactorForLayer(refType:Int, ref:String, scrollFactorX:Float, scrollFactorY:Float)
	{
		var layer = Engine.engine.getLayer(refType, ref);
		if(Std.is(layer, BackgroundLayer))
		{
			cast(layer, BackgroundLayer).setScrollFactor(scrollFactorX, scrollFactorY);
		}
		else if(Std.is(layer, Layer))
		{
			layer.scrollFactorX = scrollFactorX;
			layer.scrollFactorY = scrollFactorY;
		}
	}
	
	/**
	* Switches one background for another
	*/
	public static function changeBackground(layerRefType:Int, layerRef:String, newBackName:String)
	{
		var types = Data.get().getResourcesOfType(ImageBackground);
		
		var bg:ImageBackground = null;

		for(type in types)
		{
			if(type.name == newBackName)
			{
				bg = cast(type, ImageBackground);
			}
		}
		
		if(bg == null)
			return;

		var layer = Engine.engine.getLayer(layerRefType, layerRef);
		if(Std.is(layer, BackgroundLayer))
		{
			cast(layer, BackgroundLayer).reload(bg.ID);
		}
	}

	/**
	* Change a background's image
	*/
	public static function changeBackgroundImage(layerRefType:Int, layerRef:String, newImg:BitmapData)
	{
		if(newImg == null)
			return;

		var layer = engine.getLayer(layerRefType, layerRef);
		if(Std.is(layer, BackgroundLayer))
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
	
	public static function removeBackground(layerRefType:Int, layerRef:String)
	{
		var layer = engine.getLayer(layerRefType, layerRef);
		if(Std.is(layer, BackgroundLayer))
			engine.removeLayer(layer);
	}

	//*-----------------------------------------------
	//* Image API
	//*-----------------------------------------------
	
	public static var dummyRect = new flash.geom.Rectangle(0, 0, 1, 1);
	public static var dummyPoint = new flash.geom.Point(0, 0);
	
	public static function captureScreenshot():BitmapData
	{
		//var img:BitmapData = new BitmapData(Std.int(getScreenWidth() * Engine.SCALE) , Std.int(getScreenHeight() * Engine.SCALE));

		// The old method seems to just be grabbing the SCENE width and height and multiplying it by the scale
		// The new method grabs the actual screen height and width and goes from there.

		var img:BitmapData = new BitmapData(Std.int(getStageWidth()) , Std.int(getStageHeight()));
		img.draw(openfl.Lib.current.stage);
		return img;
	}
	
	public static function getImageForActor(a:Actor):BitmapData
	{
		var original:BitmapData = a.getCurrentImage();
		return original.clone();
	}
	
	//Example path: "sample.png" - stick into the "extras" folder for your game - see: http://community.stencyl.com/index.php/topic,24729.0.html
	public static function getExternalImage(path:String):BitmapData
	{
		return openfl.Assets.getBitmapData("assets/data/" + path, false);
	}
	
	//TODO: See - http://www.onegiantmedia.com/as3--load-a-remote-image-from-any-url--domain-with-no-stupid-security-sandbox-errors
	public static function loadImageFromURL(URL:String, onComplete:BitmapData->Void)
	{
		#if flash
		var lc = new flash.system.LoaderContext();
		lc.checkPolicyFile = false;
		lc.securityDomain = flash.system.SecurityDomain.currentDomain;
		lc.applicationDomain = flash.system.ApplicationDomain.currentDomain; 
		
		var handler = function(event:Event):Void
		{
			var bitmapData = cast(event.currentTarget.content, Bitmap).bitmapData;
    		onComplete(bitmapData);
		}
	
		var loader:Loader = new Loader();
    	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handler);
    	loader.load(new URLRequest(URL));
		#else
		var handler = function(event:Event):Void
		{
			var bitmapData = cast(event.currentTarget.content, Bitmap).bitmapData;
    		onComplete(bitmapData);
		}
	
		var loader:Loader = new Loader();
    	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handler);
    	loader.load(new URLRequest(URL));
    	#end
	}
	
	public static function getSubImage(img:BitmapData, x:Int, y:Int, width:Int, height:Int):BitmapData
	{
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		width = Std.int(width * Engine.SCALE);
		height = Std.int(height * Engine.SCALE);
	
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
			if(order >= 0 && order < img.parent.numChildren)
			{
				img.parent.setChildIndex(img, order);
			}
		}
	}

	public static function getOrderForImage(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			return img.parent.getChildIndex(img);
		}
		
		return -1;
	}
	
	public static function bringImageBack(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			setOrderForImage(img, img.parent.getChildIndex(img) - 1);
		}
	}
	
	public static function bringImageForward(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			setOrderForImage(img, img.parent.getChildIndex(img) + 1);
		}
	}
	
	public static function bringImageToBack(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			setOrderForImage(img, 0);
		}
	}
	
	public static function bringImagetoFront(img:BitmapWrapper)
	{
		if(img != null && img.parent != null)
		{
			setOrderForImage(img, img.parent.numChildren - 1);
		}
	}
	
	public static function attachImageToActor(img:BitmapWrapper, a:Actor, x:Int, y:Int, pos:Int = 1)
	{
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		
		if(img != null)
		{
			//Behind the Actor - Send to the very back.
			if(pos == 2)
			{
				a.addChild(img);
				a.setChildIndex(img, 0);
			}
		
			else
			{
				a.addChild(img);
			}

			img.imgX = x - (Engine.SCALE * a.getWidth() * (Engine.SCALE / 2));
			img.imgY = y - (Engine.SCALE * a.getHeight() * (Engine.SCALE / 2));
			
			img.smoothing = scripts.MyAssets.antialias;

			a.attachedImages.push(img);
		}
	}
	
	//Will be "fixed" like an HUD
	public static function attachImageToHUD(img:BitmapWrapper, x:Int, y:Int)
	{
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		
		if(img != null)
		{
			engine.hudLayer.addChild(img);
			img.imgX = x;
			img.imgY = y;
			img.smoothing = scripts.MyAssets.antialias;
		}
	}
	
	public static function attachImageToLayer(img:BitmapWrapper, layerRefType:Int, layerRef:String, x:Int, y:Int, pos:Int = 1)
	{
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		
		if(img != null)
		{
			var layer = engine.getLayer(layerRefType, layerRef);

			//Behind all Actors & Tiles in this layer.
			if(pos == 2)
			{
				layer.addChildAt(img, 0);
			}
			else
			{
				layer.addChild(img);
			}
			
			img.imgX = x;
			img.imgY = y;
			img.smoothing = scripts.MyAssets.antialias;
		}
	}
	
	public static function removeImage(img:BitmapWrapper)
	{
		if(img != null)
		{
			if(Std.is(img.parent, Actor))
				cast(img.parent, Actor).attachedImages.remove(img);
			img.parent.removeChild(img);
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
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		
		if(source != null && dest != null)
		{
			dummyRect.x = 0;
			dummyRect.y = 0;
			dummyRect.width = source.width;
			dummyRect.height = source.height;
			
			dummyPoint.x = x;
			dummyPoint.y = y;
			
			if(blendMode == BlendMode.NORMAL)
			{
				dest.copyPixels(source, dummyRect, dummyPoint, null, null, true);
			}
			
			else
			{
				var drawMatrix = new Matrix();
				drawMatrix.identity();
				drawMatrix.translate(x * Engine.SCALE, y * Engine.SCALE);
				dest.draw(source, drawMatrix, null, blendMode);
			}
		}
	}
	
	public static function drawTextOnImage(img:BitmapData, text:String, x:Int, y:Int, font:Font)
	{
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		
		if(img != null)
		{
			#if(flash || js)
			var fontData = G.fontCache.get(font.ID);
				
			if(fontData == null)
			{
				fontData = font.font.getPreparedGlyphs(font.fontScale, 0x000000, false);
				G.fontCache.set(font.ID, fontData);
			}
		
			font.font.render(img, fontData, text, 0x000000, 1, x, y, 0, 0);
			#else
			BitmapFont.skipFlags = true;
			drawData.splice(0, drawData.length);
			font.font.render(drawData, text, 0x000000, 1, 0, 0, 0, font.fontScale, 0, false);
			var temp = new Sprite();
			font.font.drawText(temp.graphics, drawData, true, 0);
			ma.tx = x;
			ma.ty = y;
			img.draw(temp, ma);
			BitmapFont.skipFlags = false;
			#end
		}
	}
	
	public static function clearImagePartially(img:BitmapData, x:Int, y:Int, width:Int, height:Int)
	{
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		width = Std.int(width * Engine.SCALE);
		height = Std.int(height * Engine.SCALE);
		
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
			dummyRect.x = 0;
			dummyRect.y = 0;
			dummyRect.width = img.width;
			dummyRect.height = img.height;
			
			img.fillRect(dummyRect, 0x00000000);
		}
	}
	
	public static function clearImageUsingMask(dest:BitmapData, mask:BitmapData, x:Int, y:Int)
	{
		x = Std.int(x * Engine.SCALE);
		y = Std.int(y * Engine.SCALE);
		
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
		
		var final = new BitmapData(dest.width, dest.height, true, 0);
		final.draw(temp);
		
		dummyRect.x = 0;
		dummyRect.y = 0;
		dummyRect.width = dest.width;
		dummyRect.height = dest.height;
		
		dummyPoint.x = 0;
		dummyPoint.y = 0;
		
		dest.copyPixels(final, dummyRect, dummyPoint);
	}
	
	public static function retainImageUsingMask(dest:BitmapData, mask:BitmapData, x:Int, y:Int)
	{
		x = Std.int(x * Engine.SCALE);
      	y = Std.int(y * Engine.SCALE);
      
      	dummyRect.x = 0;
      	dummyRect.y = 0;

      	dummyRect.width = mask.width;
      	dummyRect.height = mask.height;
      
      	dummyPoint.x = x;
      	dummyPoint.y = y;
      
      	dest.copyChannel(mask, dummyRect, dummyPoint, openfl.display.BitmapDataChannel.ALPHA, openfl.display.BitmapDataChannel.ALPHA);
	}
	
	public static function fillImage(img:BitmapData, color:Int)
	{
		if(img != null)
		{
			dummyRect.x = 0;
			dummyRect.y = 0;
			dummyRect.width = img.width;
			dummyRect.height = img.height;
			
			img.fillRect(dummyRect, (255 << 24) | color);
		}
	}
	
	#if flash
	//Takes ONE filter at a time.
	public static function filterImage(img:BitmapData, filter:BitmapFilter)
	{
		if(img != null)
		{
			dummyRect.x = 0;
			dummyRect.y = 0;
			dummyRect.width = img.width;
			dummyRect.height = img.height;
			
			dummyPoint.x = 0;
			dummyPoint.y = 0;
		
			img.applyFilter(img, dummyRect, dummyPoint, filter);
		}
	}
	#else
	//Takes ONE filter at a time.
	public static function filterImage(img:BitmapData, filter:Array<Dynamic>)
	{
		if(img != null)
		{
			//TODO: Reuse Actor's setFilter if possible.
		}
	}
	#end
	
	public static function imageSetPixel(img:BitmapData, x:Int, y:Int, color:Int)
	{
		if(img != null)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
		
			img.setPixel(x, y, color);
			
			if(Engine.SCALE == 2)
			{
				img.setPixel(x + 1, y, color);
				img.setPixel(x, y + 1, color);
				img.setPixel(x + 1, y + 1, color);
			}
			
			if(Engine.SCALE == 4)
			{
				img.setPixel(x + 2, y, color);
				img.setPixel(x + 2, y + 1, color);
				img.setPixel(x + 2, y + 2, color);
				
				img.setPixel(x, y + 2, color);
				img.setPixel(x + 1, y + 2, color);
			}
		}
	}
	
	public static function imageGetPixel(img:BitmapData, x:Int, y:Int):Int
	{
		if(img != null)
		{
			x = Std.int(x * Engine.SCALE);
			y = Std.int(y * Engine.SCALE);
		
			return img.getPixel(x, y);
		}
		
		return 0;
	}
	
	public static function imageSwapColor(img:BitmapData, originalColor:Int, newColor:Int)
	{
		if(img != null)
		{
			dummyRect.x = 0;
			dummyRect.y = 0;
			dummyRect.width = img.width;
			dummyRect.height = img.height;
			
			dummyPoint.x = 0;
			dummyPoint.y = 0;
			
			originalColor = (255 << 24) | originalColor;
			newColor = (255 << 24) | newColor;
			
			img.threshold(img, dummyRect, dummyPoint, "==", originalColor, newColor, 0xffffffff, true);
		}
	}
	
	//TODO: Can we do this "in place" without the extra objects?
	public static function flipImageHorizontal(img:BitmapData)
	{
		var matrix:Matrix = new Matrix();
		matrix.scale(-1, 1);
		matrix.translate(img.width, 0);
		
		var final = new BitmapData(img.width, img.height, true, 0);
		final.draw(img, matrix);
		
		dummyRect.x = 0;
		dummyRect.y = 0;
		dummyRect.width = final.width;
		dummyRect.height = final.height;
		
		dummyPoint.x = 0;
		dummyPoint.y = 0;
		
		img.copyPixels(final, dummyRect, dummyPoint);
	}
	
	//TODO: Can we do this "in place" without the extra objects?
	public static function flipImageVertical(img:BitmapData)
	{
		var matrix:Matrix = new Matrix();
		matrix.scale(1, -1);
		matrix.translate(0, img.height);
		
		var final = new BitmapData(img.width, img.height, true, 0);
		final.draw(img, matrix);
		
		dummyRect.x = 0;
		dummyRect.y = 0;
		dummyRect.width = final.width;
		dummyRect.height = final.height;
		
		dummyPoint.x = 0;
		dummyPoint.y = 0;
		
		img.copyPixels(final, dummyRect, dummyPoint);
	}
	
	public static function setXForImage(img:BitmapWrapper, value:Float)
	{
		if(img != null)
		{
			img.imgX = (Engine.SCALE * value);
		}
	}
	
	public static function setYForImage(img:BitmapWrapper, value:Float)
	{
		if(img != null)
		{
			img.imgY = (Engine.SCALE * value);
		}
	}
	
	public static function fadeImageTo(img:BitmapWrapper, value:Float, duration:Float = 1, easing:Dynamic = null)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		Actuate.tween(img, duration, {alpha:value}).ease(easing);
	}

	public static function setOriginForImage(img:BitmapWrapper, x:Float, y:Float)
	{
		img.setOrigin(x, y);
	}
	
	public static function growImageTo(img:BitmapWrapper, scaleX:Float = 1, scaleY:Float = 1, duration:Float = 1, easing:Dynamic = null)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}
	
		Actuate.tween(img, duration, {scaleX:scaleX, scaleY:scaleY}).ease(easing);
	}
	
	//In degrees
	public static function spinImageTo(img:BitmapWrapper, angle:Float, duration:Float = 1, easing:Dynamic = null)
	{
		if(easing == null)
		{
			easing = Linear.easeNone;
		}

		Actuate.tween(img, duration, {rotation:angle}).ease(easing);
	}

	public static function moveImageTo(img:BitmapWrapper, x:Float, y:Float, duration:Float = 1, easing:Dynamic = null)
	{
		x = (x * Engine.SCALE);
		y = (y * Engine.SCALE);
		
		if(easing == null)
		{
			easing = Linear.easeNone;
		}

		Actuate
			.tween(img, duration, {imgX:x, imgY:y}).ease(easing)
			.onUpdate(function()
				{
					//Actuate isn't setting the property with its setter, so do it manually
					img.imgX = img.imgX;
					img.imgY = img.imgY;
				});
	}
	
	//In degrees
	public static function spinImageBy(img:BitmapWrapper, angle:Float, duration:Float = 1, easing:Dynamic = null)
	{
		spinImageTo(img, img.rotation + angle, duration, easing);
	}
	
	public static function moveImageBy(img:BitmapWrapper, x:Float, y:Float, duration:Float = 1, easing:Dynamic = null)
	{
		moveImageTo(img, (img.imgX / Engine.SCALE) + x, (img.imgY / Engine.SCALE) + y, duration, easing);
	}
	
	#if flash
	public static function setFilterForImage(img:BitmapWrapper, filter:BitmapFilter)
	{
		if(img != null)
		{
			img.filters = img.filters.concat([filter]);
		}
	}
	#else
	public static function setFilterForImage(img:BitmapWrapper, filter:Array<Dynamic>)
	{			
		//TODO: Reuse Actor's setFilter if possible.
	}
	#end
	
	public static function clearFiltersForImage(img:BitmapWrapper)
	{
		if(img != null)
		{
			img.filters = [];
		}
	}
	
	//Base64 encodes raw image data. Does NOT convert to a PNG.
	public static function imageToText(img:BitmapData):String
	{
		dummyRect.x = 0;
		dummyRect.y = 0;
		dummyRect.width = img.width;
		dummyRect.height = img.height;
		
		var bytes = img.getPixels(dummyRect);
		
		#if js
		var byteArray = bytes;
		byteArray.position = 0;
		var bytes:Bytes = Bytes.alloc(byteArray.length);
		while (byteArray.bytesAvailable > 0) 
		{
		var position = byteArray.position;
		bytes.set(position, byteArray.readByte()); 
		}
		return img.width + ";" + img.height + ";" + toBase64(bytes);
		#elseif(cpp || neko)
		var b = Bytes.alloc(bytes.length);
		
		for(i in 0...bytes.length)
		{
			b.set(i, bytes[i]);
		}
		
		return img.width + ";" + img.height + ";" + toBase64(b);
		#else
		return img.width + ";" + img.height + ";" + toBase64(Bytes.ofData(bytes));
		#end
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
		
		var img = new BitmapData(width, height, true, 0);
		dummyRect.x = 0;
		dummyRect.y = 0;
		dummyRect.width = width;
		dummyRect.height = height;
		img.setPixels(dummyRect, data);
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

	public static function getTileLayerAt(refType:Int, ref:String):TileLayer
	{
		var layer = engine.getLayer(refType, ref);
		if(layer == null || !Std.is(layer, Layer))
			return null;
		return cast(layer, Layer).tiles;
	}

	public static function getTilesetIDByName(tilesetName:String):Int
	{
		var r = Data.get().resourceMap.get(tilesetName);
		if(Std.is(r, Tileset))
		{
			return r.ID;
		}
		return -1;
	}

	public static function setTileAt(row:Dynamic, col:Dynamic, refType:Int, ref:String, tilesetID:Dynamic, tileID:Dynamic)
	{
		row = Std.int(row);
		col = Std.int(col);
		tilesetID = Std.int(tilesetID);
		tileID = Std.int(tileID);
	
		var layer = engine.getLayer(refType, ref);
		if(layer == null || !Std.is(layer, Layer))
		{
			return;
		}
		var tlayer = cast(layer, Layer).tiles;

		var tset = cast(Data.get().resources.get(tilesetID), Tileset);
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
				createDynamicTile(tileShape, Engine.toPhysicalUnits(x), Engine.toPhysicalUnits(y), layer.ID, engine.scene.tileWidth, engine.scene.tileHeight);
			}
			else if (tileShape != null)
			{
				getTileLayerAt(refType, ref).grid.setTile(col, row);
			}
		}
		
		engine.tileUpdated = true;
	}
	
	public static function tileExistsAt(row:Dynamic, col:Dynamic, refType:Int, ref:String):Bool
	{
		return getTileAt(Std.int(row), Std.int(col), refType, ref) != null;
	}
	
	//tileCollisionAt function added to return True if ANY collision shape exists, or False for no tile or collision shape
	//if the user gives it a negative value for the layer, it will loop through all layers instead of a specific one
	public static function tileCollisionAt(row:Dynamic, col:Dynamic, refType:Int, ref:String):Bool
	{
		if(refType == 0 && Std.parseInt(ref) < 0)
		{
			for (layer in engine.interactiveLayers)
			{
				var tile = layer.tiles.getTileAt(Std.int(row), Std.int(col));
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
			var tile = getTileAt(Std.int(row), Std.int(col), refType, ref);
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
	public static function getTilePosition(axis:Dynamic, val:Dynamic):Int
	{
		var tileH = engine.scene.tileHeight;
		var tileW = engine.scene.tileWidth;
		if(axis == 0)
		{
			return Std.int(Math.floor(val / tileW));
		}
		else
		{
			return Std.int(Math.floor(val / tileH));
		}
	}

	public static function getTileIDAt(row:Dynamic, col:Dynamic, refType:Int, ref:String):Int
	{
		var tile = getTileAt(Std.int(row), Std.int(col), refType, ref);
		
		if(tile == null)
		{
			return -1;
		}
		
		return tile.tileID;
	}
	
	public static function getTileColIDAt(row:Dynamic, col:Dynamic, refType:Int, ref:String):Int
    {
    	var tile = getTileAt(Std.int(row), Std.int(col), refType, ref);
                       
        if(tile == null)
        {
        	return -1;
        }
                       
        return tile.collisionID;
    }

	public static function getTileDataAt(row:Dynamic, col:Dynamic, refType:Int, ref:String):String
    {
    	var tile = getTileAt(Std.int(row), Std.int(col), refType, ref);
        
        if(tile == null)
        {
        	return "";
        }
        
        return tile.metadata;
    }
	
	public static function getTilesetIDAt(row:Dynamic, col:Dynamic, refType:Int, ref:String):Int
	{
		var tile = getTileAt(Std.int(row), Std.int(col), refType, ref);
		
		if(tile == null)
		{
			return -1;
		}
		
		return tile.parent.ID;
	}
	
	public static function getTileAt(row:Dynamic, col:Dynamic, refType:Int, ref:String):Tile
	{
		var tlayer = getTileLayerAt(refType, ref);
		
		if(tlayer == null)
		{
			return null;
		}
		
		return tlayer.getTileAt(Std.int(row), Std.int(col));
	}
	
	public static function removeTileAt(row:Dynamic, col:Dynamic, refType:Int, ref:String)
	{
		row = Std.int(row);
		col = Std.int(col);
		
		var layer = engine.getLayer(refType, ref);
		if(layer == null || !Std.is(layer, Layer))
		{
			return;
		}
		var tlayer = cast(layer, Layer).tiles;
		
		//grab the tile to get the shape
		var tile:Tile = getTileAt(row, col, refType, ref);
		
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
			-1, //typeID?
			false, //is lightweight?
			false //autoscale?
		);
		
		a.name = "Terrain";
		a.visible = false;
		
		engine.moveActorToLayer(a, layerID);

		var key = "ID" + "-" + Engine.toPixelUnits(x) + "-" + Engine.toPixelUnits(y) + "-" + layerID;

		engine.dynamicTiles.set(key, a);
	}
	
	//*-----------------------------------------------
	//* Fonts
	//*-----------------------------------------------
	
	public static function getFont(fontID:Int):Font
	{
		return cast(Data.get().resources.get(fontID), Font);
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
		#if((flash && !air) || (cpp && !mobile) || neko)
		Engine.engine.toggleFullscreen();
		#end
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
	public static function getScreenWidth()
	{
		return Engine.screenWidth;
	}

	/**
	* Get the screen height in pixels
	*/
	public static function getScreenHeight()
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
	public static function setOffscreenTolerance(top:Float, left:Float, bottom:Float, right:Float)
	{
		Engine.paddingTop = Std.int(top);
		Engine.paddingLeft = Std.int(left);
		Engine.paddingRight = Std.int(right);
		Engine.paddingBottom = Std.int(bottom);
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
	 * Generates a random number. Deterministic, meaning safe to use if you want to record replays in random environments
	 */
	public static function randomFloat():Float
	{
		return Math.random();
	}
	
	/**
	 * Generates a random number. Set the lowest and highest values.
	 */
	public static function randomInt(low:Float, high:Float):Int
	{
		if (low <= high)
		{
			return Std.int(low) + Math.floor(randomFloat() * (Std.int(high) - Std.int(low) + 1));
		}
		else
		{
			return Std.int(high) + Math.floor(randomFloat() * (Std.int(low) - Std.int(high) + 1));
		}
	}
	
	/**
	* Change a Number to another specific Number over time  
	*/
	public function tweenNumber(attributeName:String, value:Float, duration:Float = 1, easing:Dynamic = null) 
	{
		/*var params:Object = { time: duration / 1000, transition: easing };
		attributeName = toInternalName(attributeName);
		params[attributeName] = toValue;
		
		return Tweener.addTween(this, params);*/
		
		//TODO
		Actuate.tween(this, duration, {alpha:value}).ease(easing == null ? Linear.easeNone : easing);
	}
	
	/**
	* Stops a tween 
	*/
	public static function abortTween(target:Dynamic)
	{
		//TODO
	}
	
	//*-----------------------------------------------
	//* Saving
	//*-----------------------------------------------
	
	/**
	 * Saves a game to the "StencylSaves/[GameName]/[FileName]" location with an in-game displayTitle
	 *
	 * Callback = function(success:Boolean):void
	 */
	public static function saveGame(fileName:String, onComplete:Bool->Void=null)
	{
		var so = SharedObject.getLocal(fileName);
		
		for(key in engine.gameAttributes.keys())
		{
			Reflect.setField(so.data, key, engine.gameAttributes.get(key));
			
			#if flash
			if (Std.is(engine.gameAttributes.get(key), haxe.ds.StringMap))
			{
				Reflect.setField(so.data, key, "[SerializedStringMap]" + haxe.Serializer.run(engine.gameAttributes.get(key)));
			}
			#end
		}	

		#if flash
		var flushStatus:String = null;
		#else
		var flushStatus:openfl.net.SharedObjectFlushStatus = null;
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
			if(flushStatus == openfl.net.SharedObjectFlushStatus.PENDING)
			{
				//trace('requesting permission to save');
			}
			
			else if(flushStatus == openfl.net.SharedObjectFlushStatus.FLUSHED)
			{
				trace("Saved Game: " + fileName);
		        onComplete(true);
		        //TODO: Event
			}
		}
	}
	
	/**
  	 * Load a saved game
	 *
	 * Callback = function(success:Boolean):void
	 */
	public static function loadGame(fileName:String, onComplete:Bool->Void=null)
	{
		var data = SharedObject.getLocal(fileName);
		
		trace("Loaded Save: " + fileName);
		
		for(key in Reflect.fields(data.data))
		{
			trace(key + " - " + Reflect.field(data.data, key));
			#if flash
			//unserialize maps
			if (Reflect.field(data.data, key) != null && StringTools.startsWith(Reflect.field(data.data, key), "[SerializedStringMap]"))
			{
				var smap:haxe.ds.StringMap<Dynamic> = haxe.Unserializer.run(Reflect.field(data.data, key).substr("[SerializedStringMap]".length));
				engine.gameAttributes.set(key, smap);
			}
			else
			{
				engine.gameAttributes.set(key, Reflect.field(data.data, key));
			}
			#else
			engine.gameAttributes.set(key, Reflect.field(data.data, key));
			#end
		}
		
		onComplete(true);
	}
	
	//*-----------------------------------------------
	//* Web Services
	//*-----------------------------------------------
	
	private static function defaultURLHandler(event:Event)
	{
		var loader:URLLoader = new URLLoader(event.target);
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
	public static function visitURL(URL:String, fn:Event->Void = null)
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
	public static function postToURL(URL:String, data:String = null, fn:Event->Void = null)
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
	
	//Purpose: Support Unicode in downloaded text or text from external files.
	//Author: out2lunch
	//http://community.stencyl.com/index.php/topic,30954.0.html
	public static function convertToPseudoUnicode(internationalText:String):String
	{
		#if flash
		// Not needed in Flash, just return it
		return internationalText;
		#else
		var utf8List:Array<Dynamic> = [];
		var convertedString:String = "";
		var hexAscii = ["A","B","C","D","E","F"];
		var other_bits:Int = 6;
		var realCount = 0;
	
		for (i in 0...internationalText.length)
		{
			if (i < realCount)
			{
				continue;
			}
	
			if (internationalText.charCodeAt(i) < 128)
			{ // Standard character
				convertedString += internationalText.charAt(i);
			}
			else
			{ // Accumulate and convert UTF-8 chars
				Utils.clear(utf8List);
				var utf8count:Int = i;
	
				while (utf8count < internationalText.length)
				{
					if (internationalText.charCodeAt(utf8count) >= 128)
					{ // add UTF-8 to utf8List
						utf8List.push(internationalText.charCodeAt(utf8count));
						realCount += 1;
					}
	
					if ((internationalText.charCodeAt(utf8count) < 128) || (utf8count == (internationalText.length - 1)))
					{ // Convert utf8List now
						while (utf8List.length > 0)
						{
							var charcode:Int = 0;
							var high_bit_mask:Int = (1 << 6) - 1;
							var high_bit_shift:Int = 0;
							var total_bits:Int = 0;
							var character:Int = Std.int(asNumber(utf8List[0]));
							utf8List.splice(0, 1);
	
							// Convert UTF-8 to UTF-32 http://stackoverflow.com/questions/18534494/convert-from-utf-8-to-unicode-c
							while ((character & 0xC0) == 0xC0)
							{
								character <<= 1;
								character &= 0xff;
								total_bits += 6;
								high_bit_mask >>= 1;
								high_bit_shift++;
								charcode <<= other_bits;
								charcode |= Std.int(asNumber(utf8List[0])) & ((1 << other_bits) - 1);
								utf8List.splice(0, 1);
							}
	
							// UTF-32 to Hex String
							var hexString:String = "";
							charcode |= ((character >> high_bit_shift) & high_bit_mask) << total_bits;
							var quotient:Int = charcode;
							while (quotient != 0)
							{
								var temp:Int = quotient % 16;
								if (temp < 10) hexString += ("" + temp);
								else hexString += hexAscii[Std.int(Math.min(Math.max(temp - 10, 0), 5))];
	
								quotient = Std.int(Math.floor(quotient / 16));
							}
	
							// Hex String formatting - first reverse it
							var formattedHexString:String = "";
							var ii:Int = (hexString.length - 1);
							while (ii >= 0)
							{
								formattedHexString += hexString.charAt(ii);
								ii--;
							}
	
							// Then prepend zeroes
							for (jj in 0...(4 - formattedHexString.length))
							{
								formattedHexString = "0" + formattedHexString;
							}
	
							// Then prepend escape sequence and add it
							convertedString += "~x" + formattedHexString;
						}
	
						realCount -= 1;
						break;
					}
	
					utf8count += 1;
				}
			}
	
			realCount += 1;
		}
	
		return convertedString;
		#end
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
	//* Newgrounds
	//*-----------------------------------------------
	
	
	#if(flash)
	private static var medalPopup:com.newgrounds.components.MedalPopup = null;
	private static var clickArea:TextField = null;
	private static var scoreBrowser:com.newgrounds.components.ScoreBrowser = null;
	#end
	
	public static function newgroundsShowAd()
	{
		#if(flash)
		var flashAd = new com.newgrounds.components.FlashAd();
		flashAd.fullScreen = true;
		flashAd.showPlayButton = true;
		flashAd.mouseChildren = true;
		flashAd.mouseEnabled = true;
		Engine.engine.root.parent.addChild(flashAd);
		#end
	}
	
	public static function newgroundsSetMedalPosition(x:Int, y:Int)
	{
		#if(flash)
		if(medalPopup == null)
		{
			medalPopup = new com.newgrounds.components.MedalPopup();
			Engine.engine.root.parent.addChild(medalPopup);
		}
		
		medalPopup.x = x;
		medalPopup.y = y;
		#end
	}
	
	public static function newgroundsUnlockMedal(medalName:String)
	{
		#if(flash)
		if(medalPopup == null)
		{
			medalPopup = new com.newgrounds.components.MedalPopup();
			Engine.engine.root.parent.addChild(medalPopup);
		}
		
		com.newgrounds.API.API.unlockMedal(medalName);
		#end
	}
	
	public static function newgroundsSubmitScore(boardName:String, value:Float)
	{
		#if(flash)
		com.newgrounds.API.API.postScore(boardName, value);
		#end
	}
	
	public static function newgroundsShowScore(boardName:String)
	{
		#if(flash)
		if(scoreBrowser == null)
		{
			scoreBrowser = new com.newgrounds.components.ScoreBrowser();
			scoreBrowser.scoreBoardName = boardName;
			scoreBrowser.period = com.newgrounds.ScoreBoard.ALL_TIME;
			scoreBrowser.loadScores();
			
			scoreBrowser.x = Engine.screenWidth/2*Engine.SCALE*Engine.screenScaleX - scoreBrowser.width/2;
			scoreBrowser.y = Engine.screenHeight/2*Engine.SCALE*Engine.screenScaleY - scoreBrowser.height/2;
			
			var button = new openfl.display.Sprite();
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
				openfl.events.MouseEvent.CLICK,
				newgroundsHelper
			);
		}
		
		Engine.engine.root.parent.addChild(scoreBrowser);
		#end
	}
		
	private static function newgroundsHelper(event:openfl.events.MouseEvent)
	{
		#if(flash)
		Engine.engine.root.parent.removeChild(scoreBrowser);
		#end
	}
	
	//*-----------------------------------------------
	//* Kongregate
	//*-----------------------------------------------

	public static function kongregateInitAPI()
	{
		#if(flash && !air)
		com.stencyl.utils.Kongregate.initAPI();
		#end
	}
	
	public static function kongregateSubmitStat(name:String, stat:Float) 
	{
		#if(flash && !air)
		com.stencyl.utils.Kongregate.submitStat(name, stat);
		#end
	}
	
	public static function kongregateIsGuest():Bool
	{
		#if(flash && !air)
		return com.stencyl.utils.Kongregate.isGuest();
		#else
		return true;
		#end
	}
	
	public static function kongregateGetUsername():String
	{
		#if(flash && !air)
		return com.stencyl.utils.Kongregate.getUsername();
		#else
		return "Guest";
		#end
	}
	
	public static function kongregateGetUserID():Int
	{
		#if(flash && !air)
		return com.stencyl.utils.Kongregate.getUserID();
		#else
		return 0;
		#end
	}
	
	//*-----------------------------------------------
	//* Mobile
	//*-----------------------------------------------
	
	//Atlases
	
	//Like the prior implementation, this is a HINT to the engine to load a new atlas UPON CHANGING SCENES
	//Does not happen immediately.
	public static function loadAtlas(atlasID:Int)
	{
		//#if mobile
		engine.atlasesToLoad.set(atlasID, atlasID);
		//#end
	}
	
	public static function unloadAtlas(atlasID:Int)
	{
		//#if mobile
		engine.atlasesToUnload.set(atlasID, atlasID);
		//#end
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
	
	//Ads
	
	public static function showMobileAd()
	{
		#if (mobile && !android && !air)
		Ads.initialize();
		Ads.showAd(scripts.MyAssets.adPositionBottom);
		#end
		
		#if android
		GoogleAdMob.showAd(scripts.MyAssets.adPositionBottom);
		#end
	}
	
	public static function hideMobileAd()
	{
		#if (mobile && !android && !air)
		Ads.initialize();
		Ads.hideAd();
		#end
		
		#if android
		GoogleAdMob.hideAd();
		#end
	}
	
	//Google Play Services
	public static function initGooglePlayGames()
	{
		#if android
		GooglePlayGames.initGooglePlayGames();
		#end
	}
	
	public static function stopGooglePlayGames()
	{
		#if android
		GooglePlayGames.signOutGooglePlayGames();
		#end
	}
	
	public static function getGPGConnectionInfo(info:Int):Bool
	{
		#if android
		return GooglePlayGames.getConnectionInfo(info);
		#else
		return false;
		#end
	}
	
	public static function showGPGAchievements()
	{
		#if android
		GooglePlayGames.showAchievements();
		#end
	}
	
	public static function showGPGLeaderboards()
	{
		#if android
		GooglePlayGames.showAllLeaderboards();
		#end
	}
	
	public static function showGPGLeaderboard(id:String)
	{
		#if android
		GooglePlayGames.showLeaderboard(id);
		#end
	}
	
	public static function showGPGQuests()
	{
		#if android
		GooglePlayGames.showQuests();
		#end
	}
	
	public static function unlockGPGAchievement(id:String)
	{
		#if android
		GooglePlayGames.unlockAchievement(id);
		#end
	}
	
	public static function incrementGPGAchievement(id:String, amount:Int)
	{
		#if android
		GooglePlayGames.incrementAchievement(id, amount);
		#end
	}
	
	public static function submitGPGScore(id:String, amount:Int)
	{
		#if android
		GooglePlayGames.submitScore(id, amount);
		#end
	}
	
	public static function updateGPGEvent(id:String, amount:Int)
	{
		#if android
		GooglePlayGames.updateEvent(id, amount);
		#end
	}
	
	public static function getCompletedGPGQuests():Array<String>
	{
		#if android
		return GooglePlayGames.getCompletedQuestList();
		#else
		return new Array<String>();
		#end
	}
	
	
	//Game Center
	
	public static function gameCenterInitialize():Void 
	{
		#if (mobile && !android && !air)
			GameCenter.initialize();
		#end	
	}
	
	public static function gameCenterIsAuthenticated():Bool 
	{
		#if (mobile && !android && !air)
			return GameCenter.isAuthenticated();
		#else
			return false;
		#end
	}
	
	public static function gameCenterGetPlayerName():String 
	{
		#if (mobile && !android && !air)
			return GameCenter.getPlayerName();
		#else
			return "None";
		#end
	}
	
	public static function gameCenterGetPlayerID():String 
	{
		#if (mobile && !android && !air)
			return GameCenter.getPlayerID();
		#else
			return "None";
		#end
	}
	
	public static function gameCenterShowLeaderboard(categoryID:String):Void 
	{
		#if (mobile && !android && !air)
			GameCenter.showLeaderboard(categoryID);
		#end	
	}
	
	public static function gameCenterShowAchievements():Void 
	{
		#if (mobile && !android && !air)
			GameCenter.showAchievements();
		#end	
	}
	
	public static function gameCenterSubmitScore(score:Float, categoryID:String):Void 
	{
		#if (mobile && !android && !air)
			GameCenter.reportScore(categoryID, Std.int(score));
		#end	
	}
	
	public static function gameCenterSubmitAchievement(achievementID:String, percent:Float):Void 
	{
		#if (mobile && !android && !air)
			GameCenter.reportAchievement(achievementID, percent);
		#end	
	}
	
	public static function gameCenterResetAchievements():Void 
	{
		#if (mobile && !android && !air)
			GameCenter.resetAchievements();
		#end	
	}
	
	public static function gameCenterShowBanner(title:String, msg:String):Void 
	{
		#if (mobile && !android && !air)
			GameCenter.showAchievementBanner(title, msg);
		#end	
	}
	
	//Google Play Games
	
	
	//Purchases
	
	public static function purchasesAreInitialized():Bool 
	{
		#if (mobile && cpp && !air)
			return Purchases.canBuy();
		#else
			return false;
		#end
	}
	
	public static function purchasesRestore():Void 
	{
		#if (mobile && cpp && !air)
			Purchases.restorePurchases();
		#end	
	}
	
	public static function purchasesBuy(productID:String):Void 
	{
		#if (mobile && cpp)
			Purchases.buy(productID);
		#end	
	}
	
	public static function purchasesHasBought(productID:String):Bool 
	{
		#if (mobile && cpp && !air)
			return Purchases.hasBought(productID);
		#else
			return false;
		#end
	}
	
	public static function purchasesGetTitle(productID:String):String 
	{
		#if (mobile && cpp && !air)
			return Purchases.getTitle(productID);
		#else
			return "";
		#end
	}
	
	public static function purchasesGetDescription(productID:String):String 
	{
		#if (mobile && cpp && !air)
			return Purchases.getDescription(productID);
		#else
			return "";
		#end
	}
	
	public static function purchasesGetPrice(productID:String):String 
	{
		#if (mobile && cpp && !air)
			return Purchases.getPrice(productID);
		#else
			return "";
		#end
	}
	
	public static function purchasesRequestProductInfo(productIDlist:Array<Dynamic>):Void 
  	{
    	#if (mobile && cpp && !air)
      		Purchases.requestProductInfo(productIDlist);
    	#else
      		//Nothing
    	#end
	}
	
	//Consumables
	
	public static function purchasesUse(productID:String):Void 
	{
		#if (mobile && cpp && !air)
			Purchases.use(productID);
		#end	
	}
	
	//For V3 Google IAP
	public static function purchasesGoogleConsume(productID:String):Void 
	{
		#if (mobile && cpp && !air)
			Purchases.consume(productID);
		#end	
	}
	
	public static function purchasesGetQuantity(productID:String):Int 
	{
		#if (mobile && cpp && !air)
			return Purchases.getQuantity(productID);
		#else
			return 0;
		#end
	}
	
	//*-----------------------------------------------
	//* Native
	//*-----------------------------------------------
	
	public static function showAlert(title:String, msg:String)
	{
		#if(mobile && !air)
		Native.showAlert(title, msg);
		#end
	}
	
	public static function vibrate(time:Float = 1)
	{
		#if(mobile && !air)
		Native.vibrate(time);
		#end
	}
	
	public static function showKeyboard()
	{
		#if(mobile && !air)
		Native.showKeyboard();
		#end
	}
	
	public static function hideKeyboard()
	{
		#if(mobile && !air)
		Native.hideKeyboard();
		#end
	}
	
	public static function setKeyboardText(text:String)
	{
		#if(mobile && !air)
		Native.setKeyboardText(text);
		#end
	}
	
	public static function setIconBadgeNumber(n:Int)
	{
		#if(mobile && !air)
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
			Lib.fscommand("exit");
		}
		catch(e:SecurityError)
		{
			trace("Could not exit game: " + e.message); 
		}
		#elseif openfl_legacy
		Lib.exit();
		#elseif !js
		Sys.exit (0);
		#end
	}
	
	
	//*-----------------------------------------------
	//* Utilities
	//*-----------------------------------------------
	
	#if (cpp || neko)
	public static function createGrayscaleFilter():Array<Dynamic>
	{
		var matrix = new Array<Dynamic>();
		matrix[0] = "GrayscaleFilter";
		return matrix;
	}
	
	public static function createSepiaFilter():Array<Dynamic>
	{
		var matrix = new Array<Dynamic>();
		matrix = matrix.concat([0.34, 0.33, 0.33, 0.00, 30.00]);
		matrix = matrix.concat([0.33, 0.34, 0.33, 0.00, 20.00]);
		matrix = matrix.concat([0.33, 0.33, 0.34, 0.00, 0.00]);
		matrix = matrix.concat([0.00, 0.00, 0.00, 1.00, 0.00]);
		matrix.insert(0, "SepiaFilter");
		
		return matrix;
	}
	
	public static function createNegativeFilter():Array<Dynamic>
	{
		var matrix = new Array<Dynamic>();
		matrix[0] = "NegativeFilter";
		return matrix;
	}
	
	public static function createTintFilter(color:Int, amount:Float = 1):Array<Dynamic>
	{
		var matrix = new Array<Dynamic>();
		matrix[0] = "TintFilter";
		matrix[1] = ((color >> 16) & 0xFF) / 255.0;
		matrix[2] = ((color >> 8) & 0xFF) / 255.0;
		matrix[3] = ((color) & 0xFF) / 255.0;
		matrix[4] = amount;
		return matrix;
	}
	
	public static function createHueFilter(h:Float):Array<Dynamic>
	{
		var cm:ColorMatrix = new ColorMatrix();
		cm.adjustHue(h);
		cm.adjustSaturation(1);
		var matrix = cast((cm.toArray(cm.matrix)),(Array<Dynamic>));
		matrix.insert(0, "HueFilter");
		return matrix;
	}

	public static function createSaturationFilter(s:Float):Array<Dynamic>
	{
		var cm:ColorMatrix = new ColorMatrix();
		cm.adjustSaturation(s/100);
		var matrix = cast((cm.toArray(cm.matrix)),(Array<Dynamic>));
		matrix.insert(0, "SaturationFilter");
		return matrix;
	}

	public static function createBrightnessFilter(b:Float):Array<Dynamic>
	{
		var cm:ColorMatrix = new ColorMatrix();
		cm.adjustBrightness(b/100);
		var matrix = cast((cm.toArray(cm.matrix)),(Array<Dynamic>));
		matrix.insert(0, "BrightnessFilter");
		return matrix;
	}
	#end
	
	#if (flash || js)
	public static function createGrayscaleFilter():ColorMatrixFilter
	{
		#if js
		var matrix:Array<Float> = new Array<Float>();
		#else
		var matrix:Array<Dynamic> = new Array<Dynamic>();
		#end
		
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
		#if js
		var matrix:Array<Float> = new Array<Float>();
		#else
		var matrix:Array<Dynamic> = new Array<Dynamic>();
		#end
		
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
		#if js
		var matrix:Array<Float> = new Array<Float>();
		#else
		var matrix:Array<Dynamic> = new Array<Dynamic>();
		#end
		
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
	
	/*
	h is in degrees (RELATIVE)
	s is [0-2 where 1 is reset] (ABSOLUTE)
	b is [0-100] (RELATIVE)
	*/
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
	* Returns a ColorMatrixFilter that adjusts brightness (in relative degrees) 
	*/
	public static function createBrightnessFilter(b:Float):ColorMatrixFilter
	{
		var cm:ColorMatrix = new ColorMatrix();
		
		cm.adjustBrightness(b/100);
		
		return cm.getFilter();
	}
		
	#end	
}
