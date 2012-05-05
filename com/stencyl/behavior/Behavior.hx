package com.stencyl.behavior;

import nme.display.Graphics;

class Behavior 
{	
	public var parent:Dynamic;
	public var engine:Engine;
	
	public var enabled:Bool;
	public var drawable:Bool;
	
	public var ID:Int;
	public var name:String;
	
	public var classname:String;
	public var cls:Class<Dynamic>;
	public var script:Script;
	
	public var attributes:Hash<Attribute>;

	public function new
	(
		parent:Dynamic,
		engine:Engine,
		ID:Int,
		name:String,
		classname:String, 
		enabled:Bool, 
		drawable:Bool,
		attributes:Hash<Attribute>
	)
	{
		this.parent = parent;
		this.engine = engine;
		this.classname = classname;
	
		if(engine != null)
		{
			try
			{
				cls = Type.resolveClass(classname);
			}
			
			catch(e:String)
			{
				trace("Could not load: " + classname);
				trace(e);
			}
		}
		
		this.enabled = enabled;
		this.drawable = drawable;

		this.ID = ID;
		this.name = name;
		
		this.attributes = attributes;
	}	

	public function initScript(initJustScript:Bool = false)
	{
		if(cls == null)
		{
			trace("Could not initialize Script for Behavior: " + name);
			script = new SceneScript(engine);
			return;
		}
		
		script = Type.createInstance(cls, [0, parent, engine]);
		script.wrapper = this;
		initAttributes();
		
		if(!initJustScript)
		{
			try
			{
				script.init();
			}
			
			catch(e:String)
			{
				trace("Error in when created for behavior: " + name);
				trace(e);
			}
		}
	}
	
	private function initAttributes()
	{
		//TODO
		/*
		for each(var a:Attribute in attributes)
		{
			if(a.type == "actor" && a.fieldName == "actor" && script is ActorScript)
			{
				continue;
			}
			
			if(a.type == "actor" || a.type == "joint" || a.type == "region")
			{
				var eID:Number = a.getRealValue();
				
				if(a.type == "actor")
				{
					script[a.fieldName] = game.getActor(eID);
				}
				
				else if(a.type == "joint")
				{
					script[a.fieldName] = game.getJoint(eID);
				}
				
				else if(a.type == "region")
				{
					script[a.fieldName] = game.getRegion(eID);
				}
				
				else if (a.type == "terrainregion")
				{
					script[a.fieldName] = game.getTerrainRegion(eID);
				}
			}
			
			else if(a.type == "actorgroup")
			{
				var groupID:Number = a.getRealValue();
				script[a.fieldName] = game.getGroup(groupID);
			}
			
			else
			{
				var realValue:* = a.getRealValue();
				
				if(a.type == "list")
				{
					//?????
					if(realValue is XMLList)
					{
						var arr:Array = ActorTypeReader.readList(realValue as XMLList);
						script[a.fieldName] = arr;
					}
					
					else
					{
						script[a.fieldName] = realValue;
					}
				}
				
				else
				{
					script[a.fieldName] = realValue;
				}
				
				trace("Set att(" + a.fieldName + ") to " + realValue);
			}
		}*/
	}

	public function update(elapsedTime:Float)
	{
		if(script != null)
		{
			script.update(elapsedTime);
		}
	}
	
	public function draw(g:Graphics, x:Int, y:Int)
	{
		if(script != null)
		{
			script.draw(g, x, y);	
		}
	}
	
	/*public function drawLayer(g:Graphics, x:Int, y:Int, layerID:Int)
	{
		if(script != null && Std.is(script, SceneScript))
		{
			script.drawLayer(g, x, y, layerID);	
		}
	}*/
}
