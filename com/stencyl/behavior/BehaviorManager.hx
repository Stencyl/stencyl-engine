package com.stencyl.behavior;

class BehaviorManager
{
	public var behaviors:Array<Behavior>;
	public var drawBehaviors:Array<Behavior>;
	public var collisionHandlers:Array<Behavior>;
	
	public var cache:Hash<Behavior>;
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------
	
	public function new()
	{
		behaviors = new Array<Behavior>();
		drawBehaviors = new Array<Behavior>();
		collisionHandlers = new Array<Behavior>();
		
		cache = new Hash<Behavior>();
	}
	
	public function destroy()
	{
		behaviors = null;
		drawBehaviors = null;
		collisionHandlers = null;
		
		cache = null;
	}
	
	//*-----------------------------------------------
	//* Ops
	//*-----------------------------------------------
	
	public function add(b:Behavior)
	{
		if(b.drawable)
		{
			drawBehaviors.push(b);
		}
		
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
	
	/*public function draw(g:Graphics, x:Number, y:Number, screen:Boolean=false):void
	{
		var b:Behavior = null;
		var i:Number;
		
		for(i in 0...behaviors.length)
		{
			b = behaviors[i];
			
			if(b.drawable && b.enabled && b.visible)
			{
				if(screen)
				{
					g.translateToScreen();
				}
				
				var blend:String = g.getBlendMode();
				
				try
				{
					b.draw(g, x, y);
				}
				
				catch(e:String)
				{
					FlxG.log("Error in draw for behavior: " + b.name);
					FlxG.log(e.getStackTrace());
				}
				
				g.setBlendMode(blend);
			}
		}
	}*/
	
	/**
     * Draws on a specific layer. 
     * Automatically called by the engine when a <code>Layer<code> is drawn.
     * Must call doesCustomDrawing() for this to happen.
     *
     * @param   g       A <code>Graphics</code> context
     * @param   x       The screen x-position.
     * @param   y       The screen y-position.
     * @param   layerID The ID of the layer to draw on.
     */
    /*public function drawLayer(g:Graphics, x:Number, y:Number, layerID:int)
    {
        var b:Behavior = null;
        var i:Number;
        
        for(i in 0...behaviors.length)
        {
            b = behaviors[i];
            
            if(b.drawable && b.enabled && b.visible)
            {
                g.translateToScreen();
                
                var blend:String = g.getBlendMode();
                
                try
                {
                    b.drawLayer(g, x, y, layerID);
                }
                
                catch(e:Error)
                {
                    FlxG.log("Error in draw for behavior: " + b.name);
                    FlxG.log(e.getStackTrace());
                }
                
                g.setBlendMode(blend);
            }
        }
    }
	
	public function registerCollisionHandler(b:Behavior)
	{
		for(var key:String in collisionHandlers)
		{
			var item:Behavior = collisionHandlers[key];
			
			if(item.ID == b.ID)
			{
				return;
			}
		}

		collisionHandlers.push(b);
	}*/
	
	//*-----------------------------------------------
	//* Messaging
	//*-----------------------------------------------
	
	public function getAttribute(behaviorName:String, attributeName:String):Dynamic
	{
		var b:Behavior = cache.get(behaviorName);
		
		if(b != null && b.script != null)
		{
			attributeName = b.script.toInternalName(attributeName);

			if(Reflect.hasField(b.script, attributeName))
			{
				return Reflect.field(b.script, attributeName);
			}
			
			else
			{
				trace("Warning: Attribute " + attributeName + " does not exist for " + behaviorName);		
			}
		}
		
		trace("Warning: Behavior does not exist - " + behaviorName);
		
		return null;
	}
	
	public function setAttribute(behaviorName:String, attributeName:String, value:Dynamic)
	{
		var b:Behavior = cache.get(behaviorName);
		
		if(b != null && b.script != null)
		{
			if(Reflect.hasField(b.script, attributeName))
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
			
			if(Reflect.hasField(item.script, msg))
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
			
			else
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
			
			if(Reflect.hasField(item.script, msg))
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
			
			else
			{
				item.script.forwardMessage(msg);
			}
		}

		return toReturn;
	}
}