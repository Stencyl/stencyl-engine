package com.stencyl.behavior;

class BehaviorManager
{
	public var behaviors:Array<Behavior>;

	public var cache:Hash<Behavior>;
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------
	
	public function new()
	{
		behaviors = new Array<Behavior>();
		cache = new Hash<Behavior>();
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
			cache.get(b).enabled = true;
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
	
	public function update(elapsedTime:Float)
	{
		for(i in 0...behaviors.length)
		{
			var b:Behavior = behaviors[i];
			
			if(b.enabled)
			{
				try
				{
					b.update(elapsedTime);	
				}
				
				catch(e:String)
				{
					trace("Error in always for behavior: " + b.name);
					trace(e);
				}
			}
		}	
	}
	
	//*-----------------------------------------------
	//* Messaging
	//*-----------------------------------------------
	
	public function getAttribute(behaviorName:String, attributeName:String):Dynamic
	{
		var b:Behavior = cache.get(behaviorName);
		
		if(b != null && b.script != null)
		{
			attributeName = b.script.toInternalName(attributeName);
			
			var field = Reflect.field(b.script, attributeName);

			if(field == null)
			{
				trace("Warning: Attribute " + attributeName + " does not exist for " + behaviorName);
			}
			
			return field;
		}
		
		else
		{
			trace("Warning: Behavior does not exist - " + behaviorName);
		}
		
		return null;
	}
	
	public function setAttribute(behaviorName:String, attributeName:String, value:Dynamic)
	{
		var b:Behavior = cache.get(behaviorName);
		
		if(b != null && b.script != null)
		{
			var field = Reflect.field(b.script, attributeName);
			
			if(field != null)
			{
				Reflect.setField(b.script, attributeName, value);
			}
			
			else
			{
				trace("Warning: Attribute " + attributeName + " does not exist for " + behaviorName);
			}
		}
		
		else
		{
			trace("Warning: Behavior does not exist - " + behaviorName);	
		}
	}
	
	public function call(msg:String, args:Array<Dynamic>):Dynamic
	{
		if(cache == null)
		{
			return null;
		}
		
		var toReturn:Dynamic = null;
		
		for(i in 0...behaviors.length)
		{
			var item:Behavior = behaviors[i];
			
			if(!item.enabled || item.script == null) 
			{
				continue;
			}
			
			//XXX: Flash works slightly differently from the rest on this... :(
			#if flash
			if(Reflect.hasField(item.script, msg))
			#end
			
			#if (cpp || js)
			try
			#end
			{
				var f = Reflect.field(item.script, msg);
			
				if(f != null)
				{
					toReturn = Reflect.callMethod(item.script, f, args);
				}
				
				else
				{
					item.script.forwardMessage(msg);
				}
			}
			
			#if flash
			else
			#end
			
			#if (cpp || js)
			catch(e:String)
			#end
			{
				item.script.forwardMessage(msg);
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
		
		var toReturn:Dynamic = null;
		var item:Behavior = cache.get(behaviorName);
		
		if(item != null)
		{
			if(!item.enabled || item.script == null)
			{
				return toReturn;
			}
			
			//XXX: Flash works slightly differently from the rest on this... :(
			#if flash
			if(Reflect.hasField(item.script, msg))
			#end
			
			#if (cpp || js)
			try
			#end
			{
				var f = Reflect.field(item.script, msg);
			
				if(f != null)
				{
					toReturn = Reflect.callMethod(item.script, f, args);
				}
				
				else
				{
					item.script.forwardMessage(msg);
				}
			}
			
			#if flash
			else
			#end
			
			#if (cpp || js)
			catch(e:String)
			#end
			{
				item.script.forwardMessage(msg);
			}
		}

		return toReturn;
	}
}