package io;

import haxe.xml.Fast;
import models.Resource;

class ActorTypeReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == "actor";
	}
	
	public function read(ID:Int, type:String, name:String, xml:Fast):Resource
	{
		trace("Reading ActorType (" + ID + ") - " + name);
		
		//Box2D stuff we don't care about
		
		/*
		
			var bodyDef:b2BodyDef = new b2BodyDef();
			
			bodyDef.fixedRotation = Util.toBoolean(xml.@fixedrot);
			
			if(xml.@static == "true" || xml.@bodytype == 0)
			{
				bodyDef.type = b2Body.b2_staticBody;
			}
			
			else if(xml.@bodytype == 1)
			{
				bodyDef.type = b2Body.b2_kinematicBody;
			}
				
			else
			{
				bodyDef.type = b2Body.b2_dynamicBody;
			}
			
			bodyDef.linearDamping = xml.@ldamp;
			bodyDef.angularDamping = xml.@adamp;
			
			bodyDef.friction = xml.@fric;
			bodyDef.bounciness = xml.@rest;
			bodyDef.mass = xml.@mass;
			bodyDef.aMass = xml.@inertia;
			
			bodyDef.active = true;
			bodyDef.bullet = false;
			bodyDef.allowSleep = false;
			bodyDef.awake = true;
			bodyDef.ignoreGravity = Util.toBoolean(xml.@ignoreg);
			bodyDef.bullet = Util.toBoolean(xml.@continuous);
		
		*/
		
		var spriteID:Int = Std.parseInt(xml.att.sprite);
		var groupID:Int = Std.parseInt(xml.att.gid);
		var isLightweight:Bool = Utils.toBoolean(xml.att.lw);
		var autoScale:Bool = Utils.toBoolean(xml.att.ascale);
		var pausable:Bool = Utisl.toBoolean(xml.att.pausable);
		
		//These are more like behavior instances
		//They reference the Behavior + Map of instance values
		var behaviorValues:Array<BehaviorInstance> = readBehaviors(xml.nodes.snippets);
		
		if(xml.att.eventsnippetid != "")
		{
			var eventID:Int = Std.parseInt(xml.att.eventsnippetid);
			
			if(eventID > -1)
			{
				behaviorValues[eventID] = new BehaviorInstance(eventID, new Array());
			}
		}
			
		return null;
		//return new ActorType(...);
	}
	
	public static function readBehaviors(xml:Fast):Array<BehaviorInstance>
	{
		var toReturn:Array<BehaviorInstance> = new Array<BehaviorInstance>();
			
		for(e in xml.elements)
		{
			var enabled:Boolean = Utils.toBoolean(e.att.enabled);
			
			if(!enabled)
			{
				continue;
			}
			
			toReturn[Std.parseInt(e.att.id)] = readBehavior(e);
		}
		
		return toReturn;
	}
	
	public static function readBehavior(xml:Fast):BehaviorInstance
	{
		var ID:Int = Std.parseInt(xml.att.id);
		var map:Array<Dynamic> = new Array<Dynamic>();
		
		for(e in xml.elements)
		{
			map[Std.parseInt(e.att.id)] = e.att.val;
			
			if(e.elements.length > 0)
			{
				var list:<Dynamic> = readList(e.elements);
				map[Std.parseInt(e.att.id)] = list;
			}
		}
		
		return new BehaviorInstance(ID, map);
	}
	
	public static function readList(list:Fast):Array<Dynamic>
	{
		var map:Array<Dynamic> = new Array<Dynamic>();
			
		for each(var e:XML in list)
		{
			var index:Int = e.att.order;
			var type:String = e.name;
						
			if(type == "number")
			{
				var num:Float = Std.parseFloat(e.att.value);
				map[index] = num;
			}
				
			else if(type == "text")
			{
				var str:String = e.att.value;
				map[index] = str;
			}
				
			else if(type == "bool")
			{
				var bool:Bool = Utils.toBoolean(e.att.value);
				map[index] = bool;
			}
				
			else if(type == "list")
			{
				var value:Array<Dynamic> = new Array<Dynamic>();
				
				for(item in e.elements)
				{	
					var index2:Int = Std.parseInt(item.att.order);
					value[index2] = item.att.value;
				}
				
				map[index] = value;
			}
		}
		
		return map;	
	}
}
