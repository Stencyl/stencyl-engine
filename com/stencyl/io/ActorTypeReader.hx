package com.stencyl.io;

import haxe.xml.Fast;
import com.stencyl.utils.Utils;

import com.stencyl.models.Resource;
import com.stencyl.models.actor.ActorType;
import com.stencyl.behavior.BehaviorInstance;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;

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
		//trace("Reading ActorType (" + ID + ") - " + name);
		
		var bodyDef = new B2BodyDef();
		
		bodyDef.fixedRotation = Utils.toBoolean(xml.att.fixedrot);
		
		if(xml.att.bodytype == "0")
		{
			bodyDef.type = B2Body.b2_staticBody;
		}
		
		else if(xml.att.bodytype == "1")
		{
			bodyDef.type = B2Body.b2_kinematicBody;
		}
			
		else
		{
			bodyDef.type = B2Body.b2_dynamicBody;
		}
		
		bodyDef.linearDamping = Std.parseFloat(xml.att.ldamp);
		bodyDef.angularDamping = Std.parseFloat(xml.att.adamp);
		
		bodyDef.friction = Std.parseFloat(xml.att.fric);
		bodyDef.bounciness = Std.parseFloat(xml.att.rest);
		bodyDef.mass = Std.parseFloat(xml.att.mass);
		bodyDef.aMass = Std.parseFloat(xml.att.inertia);
		
		bodyDef.active = true;
		bodyDef.bullet = false;
		bodyDef.allowSleep = false;
		bodyDef.awake = true;
		bodyDef.ignoreGravity = Utils.toBoolean(xml.att.ignoreg);
		bodyDef.bullet = Utils.toBoolean(xml.att.continuous);

		var spriteID:Int = Std.parseInt(xml.att.sprite);
		var groupID:Int = Std.parseInt(xml.att.gid);
		var isLightweight:Bool = Utils.toBoolean(xml.att.lw);
		var autoScale:Bool = Utils.toBoolean(xml.att.ascale);
		var pausable:Bool = Utils.toBoolean(xml.att.pausable);
		
		//These are more like behavior instances
		//They reference the Behavior + Map of instance values
		var behaviorValues:Hash<BehaviorInstance> = readBehaviors(xml.node.snippets);
		
		if(xml.att.eventsnippetid != "")
		{
			var eventID:Int = Std.parseInt(xml.att.eventsnippetid);
			
			if(eventID > -1)
			{
				behaviorValues.set(xml.att.eventsnippetid, new BehaviorInstance(eventID, new Hash<Dynamic>()));
			}
		}
			
		return new ActorType(ID, name, groupID, spriteID, behaviorValues, bodyDef, isLightweight, autoScale, pausable);
	}
	
	public static function readBehaviors(xml:Fast):Hash<BehaviorInstance>
	{
		var toReturn:Hash<BehaviorInstance> = new Hash<BehaviorInstance>();
			
		for(e in xml.elements)
		{
			var enabled:Bool = Utils.toBoolean(e.att.enabled);
			
			if(!enabled)
			{
				continue;
			}
			
			toReturn.set(e.att.id, readBehavior(e));
		}
		
		return toReturn;
	}
	
	public static function readBehavior(xml:Fast):BehaviorInstance
	{
		var ID:Int = Std.parseInt(xml.att.id);
		var map:Hash<Dynamic> = new Hash<Dynamic>();
		
		for(e in xml.elements)
		{
			map.set(e.att.id, e.att.val);
			
			if(e.elements.hasNext())
			{
				map.set(e.att.id, readList(e));
			}
		}
		
		return new BehaviorInstance(ID, map);
	}
	
	public static function readList(list:Fast):Array<Dynamic>
	{
		var map:Array<Dynamic> = new Array<Dynamic>();
			
		for(e in list.elements)
		{
			var index:Int = Std.parseInt(e.att.order);
			var type:String = e.name;
						
			if(type == "number")
			{
				var num:Float = Std.parseFloat(e.att.value);
				map.insert(index, num);
			}
				
			else if(type == "text")
			{
				var str:String = e.att.value;
				map.insert(index, str);
			}
				
			else if(type == "bool")
			{
				var bool:Bool = Utils.toBoolean(e.att.value);
				map.insert(index, bool);
			}
				
			else if(type == "list")
			{
				var value:Array<Dynamic> = new Array<Dynamic>();
				
				for(item in e.elements)
				{	
					var index2:Int = Std.parseInt(item.att.order);
					value[index2] = item.att.value;
				}
				
				map.insert(index, value);
			}
		}
		
		return map;	
	}
}
