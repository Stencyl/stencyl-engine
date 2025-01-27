package com.stencyl.behavior;

import com.stencyl.utils.Log;
import com.stencyl.utils.Utils;

class BehaviorManager
{
	#if hl
	private static var noArgs:Array<Dynamic> = [];
	#end

	public var behaviors:Array<Behavior>;

	public var cache:Map<String,Behavior>;

	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------
	
	public function new()
	{
		behaviors = new Array<Behavior>();
		cache = new Map<String,Behavior>();
	}
	
	public function destroy()
	{
		behaviors = null;
		cache = null;
	}
	
	//*-----------------------------------------------
	//* Ops
	//*-----------------------------------------------
	
	public function add(b:Behavior)
	{
		cache.set(b.name, b);
		behaviors.push(b);
	}
	
	public function hasBehavior(b:String):Bool
	{
		if(cache == null)
		{
			return false;
		}
		
		return cache.get(b) != null;
	}
	
	public function enableBehavior(b:String)
	{
		if(hasBehavior(b))
		{
			var bObj:Behavior = cache.get(b);
			
			if(bObj.script != null && !bObj.script.scriptInit)
			{
				try
				{
					bObj.script.init();
					bObj.script.scriptInit = true;
				}
			
				catch(e: #if (haxe_ver >= 4.1) haxe.Exception #else String #end )
				{
					Log.fullError("Error in when created for behavior: " + bObj.name, e);
				}
			}
			
			bObj.enabled = true;
		}
	}
	
	public function disableBehavior(b:String)
	{
		if(hasBehavior(b))
		{
			cache.get(b).enabled = false;
		}
	}
	
	public function isBehaviorEnabled(b:String):Bool
	{
		if(hasBehavior(b))
		{
			return cache.get(b).enabled;
		}
		
		return false;
	}
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------
	
	public function initScripts()
	{
		for(i in 0...behaviors.length)
		{
			var b:Behavior = behaviors[i];
			b.initScript(!b.enabled);
		}	
	}
	
	//*-----------------------------------------------
	//* Messaging
	//*-----------------------------------------------
	
	public function getBehavior(behaviorName:String):Script
	{
		var b:Behavior = cache.get(behaviorName);
		
		if(b != null && b.script != null)
		{
			return b.script;
		}
		
		else
		{
			Log.warn("Warning: Behavior does not exist - " + behaviorName + Utils.printCallstackIfAvailable());
			return null;
		}
	}

	public function getAttribute(behaviorName:String, attributeName:String):Dynamic
	{
		var b:Behavior = cache.get(behaviorName);
		
		if(b != null && b.script != null)
		{
			attributeName = b.script.toInternalName(attributeName);
			
			var field = Reflect.field(b.script, attributeName);

			if(field == null && !ReflectionHelper.hasField(b.script.wrapper.classname, attributeName))
			{
				Log.warn("Get Warning: Attribute " + attributeName + " does not exist for " + behaviorName + Utils.printCallstackIfAvailable());
			}
			
			return field;
		}
		
		else
		{
			Log.warn("Warning: Behavior does not exist - " + behaviorName + Utils.printCallstackIfAvailable());
		}
		
		return null;
	}
	
	public function setAttribute(behaviorName:String, attributeName:String, value:Dynamic)
	{
		var b:Behavior = cache.get(behaviorName);
		
		if(b != null && b.script != null)
		{
			if(ReflectionHelper.hasField(b.script.wrapper.classname, attributeName))
			{
				Reflect.setField(b.script, attributeName, value);
				b.script.propertyChanged(attributeName);
			}
			
			else
			{
				Log.warn("Set Warning: Attribute " + attributeName + " does not exist for " + behaviorName + Utils.printCallstackIfAvailable());
			}
		}
		
		else
		{
			Log.warn("Warning: Behavior does not exist - " + behaviorName + Utils.printCallstackIfAvailable());	
		}
	}

	public function call(msg:String, args:Array<Dynamic>):Dynamic
	{
		if(cache == null)
		{
			return null;
		}

		#if hl
		if(args == null) args = noArgs;
		#end

		var toReturn:Dynamic = null;
		
		for(i in 0...behaviors.length)
		{
			var item:Behavior = behaviors[i];
			
			if(!item.enabled || item.script == null) 
			{
				continue;
			}

			var f = Reflect.field(item.script, msg);
			
			try
			{
				if(f != null)
				{
					toReturn = Reflect.callMethod(item.script, f, args);
				}
				else
				{
					item.script.forwardMessage(msg);
				}
			}
			catch(e: #if (haxe_ver >= 4.1) haxe.Exception #else String #end )
			{
				Log.fullError("Error in " + msg + " for behavior: " + item.name, e);
			}
		}
		
		return toReturn;
	}
	
	public function call2(behaviorName:String, msg:String, args:Array<Dynamic>):Dynamic
	{
		if(cache == null)
		{
			return null;
		}

		#if hl
		if(args == null) args = noArgs;
		#end

		var toReturn:Dynamic = null;
		var item:Behavior = cache.get(behaviorName);

		if(item == null || item.script == null)
		{
			Log.warn("Warning: Behavior does not exist - " + behaviorName + Utils.printCallstackIfAvailable());
			return toReturn;
		}
		
		if(!item.enabled)
		{
			Log.warn("Warning: Behavior is not enabled - " + behaviorName + Utils.printCallstackIfAvailable());
			return toReturn;
		}
		
		var f = Reflect.field(item.script, msg);

		try
		{
			if(f != null)
			{
				toReturn = Reflect.callMethod(item.script, f, args);
			}
			else
			{
				item.script.forwardMessage(msg);
			}
		}
		catch(e: #if (haxe_ver >= 4.1) haxe.Exception #else String #end )
		{
			Log.fullError("Error in " + msg + " for behavior: " + item.name, e);
		}

		return toReturn;
	}
}