package com.stencyl.behavior;

import com.stencyl.utils.Utils;

import openfl.display.Graphics;
import haxe.ds.StringMap;
import haxe.CallStack;
import haxe.Constraints.IMap;

class Behavior 
{	
	public var parent:Dynamic;
	public var engine:Engine;
	
	public var enabled:Bool;
	public var drawable:Bool;
	public var isEvent:Bool;
	
	public var ID:Int;
	public var name:String;
	public var type:String;
	
	public var classname:String;
	public var script:Script;
	
	public var attributes:Map<String,Attribute>;

	public function new
	(
		parent:Dynamic,
		engine:Engine,
		ID:Int,
		name:String,
		classname:String, 
		enabled:Bool, 
		drawable:Bool,
		attributes:Map<String,Attribute>,
		type:String,
		isEvent:Bool
	)
	{
		this.isEvent = isEvent;
		this.parent = parent;
		this.engine = engine;
		this.classname = classname;
	
		this.enabled = enabled;
		this.drawable = drawable;

		this.ID = ID;
		this.name = name;
		this.type = type;
		
		this.attributes = attributes;
	}	

	public function initScript(initJustScript:Bool = false)
	{
		script = BehaviorLoader.createInstance(name, type, classname, parent);
		
		script.wrapper = this;
		initAttributes();
		
		#if stencyltools
		var reboundFunctions = Callable.namedFunctionTemplates.get(classname);
		if(reboundFunctions != null)
		{
			script.initHscript();
			for(functionName in reboundFunctions.keys())
			{
				var functionTemplate = reboundFunctions.get(functionName);
				Reflect.setField(script, functionName, script.interp.asFunction(functionTemplate.expr));
			}
		}
		#end
		
		if(!initJustScript)
		{
			try
			{
				script.init();
				script.scriptInit = true;
			}
			
			catch(e:String)
			{
				trace
				(
					"Error in when created for behavior: " + name + "\n" + e + Utils.printExceptionstackIfAvailable()
				);
			}
		}
	}
	
	private function initAttributes()
	{
		for(a in attributes)
		{
			try
			{
				//don't init hidden attributes, they are initialized with the default value in the constructor		
				if (a.hidden)
				{
					continue;
				}
				
				if(a.type == "actor" && a.fieldName == "actor" && Std.is(script, ActorScript))
				{
					continue;
				}
				
				var attributeName = script.toInternalName(a.fieldName);
				
				if(a.type == "actor" || a.type == "joint" || a.type == "region")
				{
					var eID:Int = Std.parseInt("" + a.getRealValue());
					
					if(a.type == "actor")
					{
						Reflect.setField(script, attributeName, engine.getActor(eID));
					}
					
					else if(a.type == "joint")
					{
						//TODO:
						//Reflect.setField(script, attributeName, engine.getJoint(eID));
					}
					
					else if(a.type == "region")
					{
						Reflect.setField(script, attributeName, engine.getRegion(eID));
					}
					
					else if (a.type == "terrainregion")
					{
						//TODO:
						//Reflect.setField(script, attributeName, engine.getTerrainRegion(eID));
					}
				}
				
				else if(a.type == "actorgroup")
				{
					var groupID:Int = Std.parseInt("" + a.getRealValue());
					Reflect.setField(script, attributeName, engine.getGroup(groupID));
				}
				
				else
				{
					var realValue:Dynamic = a.getRealValue();
					
					//trace("Set att(" + a.fieldName + ") to " + realValue);

					if(a.type == "list")
					{
						var list:Array<Dynamic> = null;
						
						if(realValue != null)
						{
							list = cast(realValue, Array<Dynamic>);
							list = [for (item in list) item];
						}
						
						else
						{
							list = [];
						}
		
						Reflect.setField(script, attributeName, list);
					}
					
					else if(a.type == "map")
					{
						var map:Map<String, Dynamic> = null;
						
						if(realValue != null)
						{
							var realMap:IMap<String,Dynamic> = realValue;
							map = new Map<String, Dynamic>();
							
							for (key in realMap.keys())
							{
								map.set(key, realMap.get(key));
							}
						}
						
						else
						{
							map = new StringMap<Dynamic>();
						}
		
						Reflect.setField(script, attributeName, map);
					}
					
					else
					{
						Reflect.setField(script, attributeName, realValue);
					}
				}
			}
			
			catch(e:String)
			{
				trace("Could not init attribute: " + a.fieldName + " - " + e + Utils.printExceptionstackIfAvailable());
			}
		}
	}
}
