package behavior;

public class BehaviorManager
{
	public var behaviors:Array;
	public var preDrawBehaviors:Array;
	public var postDrawBehaviors:Array;
	public var collisionHandlers:Array;
	
	public var cache:Object;
	
	//*-----------------------------------------------
	//* Init
	//*-----------------------------------------------
	
	public function new()
	{
		behaviors = new Array();
		preDrawBehaviors = new Array();
		postDrawBehaviors = new Array();
		collisionHandlers = new Array();
		
		cache = new Object();
	}
	
	public function destroy():void
	{
		behaviors = null;
		preDrawBehaviors = null;
		postDrawBehaviors = null;
		collisionHandlers = null;
		
		cache = null;
	}
	
	//*-----------------------------------------------
	//* Ops
	//*-----------------------------------------------
	
	public function add(b:Behavior):void
	{
		if(b.drawable)
		{
			if(b.drawOrder >= 0)
			{
				postDrawBehaviors.push(b);
			}
			
			else
			{
				preDrawBehaviors.push(b);
			}
		}
		
		cache[b.name] = b;
		behaviors.push(b);
	}
	
	public function hasBehavior(b:String):Boolean
	{
		if(cache == null)
		{
			return false;
		}
		
		return cache[b] != null;
	}
	
	public function enableBehavior(b:String):void
	{
		if(hasBehavior(b))
		{
			(cache[b] as Behavior).enabled = true;
		}
	}
	
	public function disableBehavior(b:String):void
	{
		if(hasBehavior(b))
		{
			(cache[b] as Behavior).enabled = false;
		}
	}
	
	public function isBehaviorEnabled(b:String):Boolean
	{
		if(hasBehavior(b))
		{
			return (cache[b] as Behavior).enabled;
		}
		
		return false;
	}
	
	//*-----------------------------------------------
	//* Events
	//*-----------------------------------------------
	
	public function initScripts():void
	{
		for(var i:Number = 0; i < behaviors.length; i++)
		{
			var b:Behavior = behaviors[i];
			
			b.initScript(!b.enabled);
		}	
	}
	
	public function update():void
	{
		for(var i:Number = 0; i < behaviors.length; i++)
		{
			var b:Behavior = behaviors[i];
			
			if(b.enabled)
			{
				try
				{
					b.update();	
				}
				
				catch(e:Error)
				{
					FlxG.log("Error in always for behavior: " + b.name);
					FlxG.log(e.getStackTrace());
				}
			}
		}	
	}
	
	public function draw(g:Graphics, x:Number, y:Number, screen:Boolean=false):void
	{
		var b:Behavior = null;
		var i:Number;
		
		for(i = 0; i < behaviors.length; i++)
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
				
				catch(e:Error)
				{
					FlxG.log("Error in draw for behavior: " + b.name);
					FlxG.log(e.getStackTrace());
				}
				
				g.setBlendMode(blend);
			}
		}
	}
	
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
    public function drawLayer(g:Graphics, x:Number, y:Number, layerID:int):void
    {
        var b:Behavior = null;
        var i:Number;
        
        for(i = 0; i < behaviors.length; i++)
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
	
	public function registerCollisionHandler(b:Behavior):void
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
	}
	
	//*-----------------------------------------------
	//* Messaging
	//*-----------------------------------------------
	
	public function getAttribute(behaviorName:String, attributeName:String):Object
	{
		var b:Behavior = cache[behaviorName];
		
		if(b != null && b.script != null)
		{
			// convert the attribute name to its internal name
			attributeName = b.script.toInternalName(attributeName);
			
			if(b.script.hasOwnProperty(attributeName))
			{
				return b.script[attributeName];
			}
			
			else
			{
				FlxG.log("Warning: Attribute " + attributeName + " does not exist for " + behaviorName);		
			}
		}
		
		FlxG.log("Warning: Behavior does not exist - " + behaviorName);
		
		return null;
	}
	
	public function setAttribute(behaviorName:String, attributeName:String, value:Object):void
	{
		var b:Behavior = cache[behaviorName];
		
		if(b != null && b.script != null)
		{
			if(b.script.hasOwnProperty(attributeName))
			{
				b.script[attributeName] = value;
			}
			
			else
			{
				FlxG.log("Warning: Attribute " + attributeName + " does not exist for " + behaviorName);
			}
		}
		
		else
		{
			FlxG.log("Warning: Behavior does not exist - " + behaviorName);
			
		}
	}
	
	public function call(msg:String, args:Array):Object
	{
		if(cache == null)
		{
			return null;
		}
		
		var toReturn:Object = null;
		
		for(var i:Number = 0; i < behaviors.length; i++)
		{
			var item:Behavior = behaviors[i];
			if (!item.enabled) continue;
			var f:Function = item.script[msg] as Function;
			
			if(f != null)
			{
				if(args.length == 0)
				{
					toReturn = f.call(item.script);
				}
					
				else
				{
					toReturn = f.apply(item.script, args);
					//toReturn = f.call(item.script, args);
				}
			}
			
			else
			{
				item.script.forwardMessage(msg);
			}
		}
		
		return toReturn;
	}
	
	public function call2(behaviorName:String, msg:String, args:Array):Object
	{
		if(cache == null)
		{
			return null;
		}
		
		var toReturn:Object = null;
		var item:Behavior = cache[behaviorName];
		
		if (item != null)
		{
			if (!item.enabled) return toReturn;
			var f:Function = item.script[msg] as Function;
			
			if(f != null)
			{
				if(args.length == 0)
				{
					toReturn = f.call(item.script);
				}
					
				else
				{
					//FlxG.log(args);
					//toReturn = f.call(item.script, args);
					toReturn = f.apply(item.script, args);
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