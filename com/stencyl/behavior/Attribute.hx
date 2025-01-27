package com.stencyl.behavior;

import com.stencyl.models.GameModel;

#if (haxe_ver >= 4.1)
import Std.isOfType as isOfType;
#else
import Std.is as isOfType;
#end

class Attribute 
{	
	public var ID:Int;
	public var fieldName:String;
	public var fullName:String;
	public var type:String;
	
	public var defaultValue:String;
	public var value:Any;
	
	public var realValue:Any;

	public var hidden:Bool;
	
	public function new(ID:Int, fieldName:String, fullName:String, value:Any, type:String, /* old */ parent:Dynamic, hidden:Bool)
	{
		this.ID = ID;
		this.fieldName = fieldName;
		this.fullName = fullName;
		this.type = type;

		this.value = value;
		realValue = null;
		
		this.hidden = hidden;
	}

	public function getRealValue():Any
	{
		if(realValue == null)
		{
			if(type == "int")
			{
				realValue = (value:Int);
			}
			
			else if(type == "float" || type == "number")
			{
				realValue = (value:Float);
			}
			
			else if(type == "bool" || type == "boolean")
			{
				realValue = (value:Bool);
			}
			
			else if(type == "color")
			{
				realValue = (value:Int);
			}
			
			else if(type == "sound" || type == "actortype" || type == "font")
			{
				if((value:Int) == -1)
				{
					realValue = null;
				}
				
				else
				{
					realValue = Data.get().resources.get((value:Int));
				}
				
				if(type == "font" && !isOfType(realValue, com.stencyl.models.Font))
				{
					realValue = null;
				}
				
				if(type == "sound" && !isOfType(realValue, com.stencyl.models.Sound))
				{
					realValue = null;
				}
				
				if(type == "actortype" && !isOfType(realValue, com.stencyl.models.actor.ActorType))
				{
					realValue = null;
				}
			}
			
			else if(type == "actorgroup")
			{
				//Script will pull the right group. Keep as int.
				realValue = (value:Int);
			}
			
			else if(type == "control")
			{
				realValue = (value:String);
			}
			
			else if(type == "animation")
			{
				realValue = (value:String);
			}
			
			else if(type == "game-attribute")
			{
				realValue = (value:String);
			}
			
			else if(type == "scene")
			{
				realValue = GameModel.get().scenes.get((value:Int));
			}
			
			else if(type == "text") 
			{
				realValue = (value:String);
			}
			
			else if(type == "list")
			{
				realValue = (value:Array<Dynamic>);
				
				if(value == null)
				{
					realValue = new Array<Dynamic>();
				}	
			}
			
			else if (type == "map")
			{
				realValue = (value:Map<String,Dynamic>);
				
				if (value == null)
				{
					realValue = new Map<String, Dynamic>();
				}
			}
			
			else if(value != null && type == "actor")
			{
				realValue = (value:Int);
			}
			
			else if(value != null && type == "joint")
			{
				realValue = (value:Int);
			}
			
			else if(value != null && type == "region")
			{
				realValue = (value:Int);
			}
		}
		
		return realValue;
	}
}
