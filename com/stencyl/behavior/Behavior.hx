package com.stencyl.behavior;

import com.stencyl.utils.Log;
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
	public var cls:Class<Dynamic>;
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
	
		if(engine != null)
		{
			try
			{
				cls = Type.resolveClass(classname);
			}
			
			catch(e: #if (haxe_ver >= 4.1) haxe.Exception #else String #end )
			{
				Log.fullError("Could not load: " + classname, e);
			}
		}
		
		this.enabled = enabled;
		this.drawable = drawable;

		this.ID = ID;
		this.name = name;
		this.type = type;
		
		this.attributes = attributes;
	}	

	public function initScript(initJustScript:Bool = false)
	{
		if(cls == null)
		{
			Log.error("Could not init Behavior: " + name + " with " + classname);
			script = new SceneScript();
			return;
		}
		
		if(type == "actor")
		{
			if (Type.getClass(parent) == Engine)
			{
				Log.error("Actor behavior " + name + " failed to init because parent is scene.  Open and save the scene to resolve this error.");
				script = new SceneScript();
				return;
			}
			script = Type.createInstance(cls, [0, parent, null]);
		}
		else
		{
			if (Type.getClass(parent) == com.stencyl.models.Actor)
			{
				Log.error("Scene behavior " + name + " failed to init because parent is actor.  Open and save the actor to resolve this error.");
				script = new SceneScript();
				return;
			}
			script = Type.createInstance(cls, [0, null]);
		}
		
		script.wrapper = this;
		initAttributes();
		
		if(!initJustScript)
		{
			try
			{
				script.init();
				script.scriptInit = true;
			}
			
			catch(e: #if (haxe_ver >= 4.1) haxe.Exception #else String #end )
			{
				Log.fullError
				(
					"Error in when created for behavior: " + name, e
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
				
				if(a.type == "actor" && a.fieldName == "actor" && Std.isOfType(script, ActorScript))
				{
					continue;
				}
				
				var attributeName = script.toInternalName(a.fieldName);
				
				if(a.type == "actor" || a.type == "joint" || a.type == "region")
				{
					var eID:Int = a.getRealValue();

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
					var groupID:Int = a.getRealValue();
					Reflect.setField(script, attributeName, engine.getGroup(groupID));
				}
				
				else
				{
					var realValue = a.getRealValue();
					
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
			
			catch(e: #if (haxe_ver >= 4.1) haxe.Exception #else String #end )
			{
				Log.fullError("Could not init attribute: " + a.fieldName, e);
			}
		}
	}
}
