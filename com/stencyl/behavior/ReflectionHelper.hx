package com.stencyl.behavior;

import com.stencyl.utils.Log;
import com.stencyl.utils.Utils;

import openfl.display.Graphics;
import haxe.ds.StringMap;
import haxe.CallStack;
import haxe.Constraints.IMap;

class ReflectionHelper 
{
	//classname -> (field name set)
	public static var fieldMaps:Map<String, Map<String, Bool>> = [];
	
	public static function getFieldMap(classname:String):Map<String, Bool>
	{
		var fieldMap = fieldMaps.get(classname);
		if(fieldMap == null)
		{
			try
			{
				var cls = Type.resolveClass(classname);
				var fieldList = Type.getInstanceFields(cls);
				fieldMap = [for(fieldName in fieldList) fieldName => true];
				fieldMaps.set(classname, fieldMap);
			}
			
			catch(e:String)
			{
				Log.error("Could not load: " + classname);
				Log.error(e);
			}
		}
		return fieldMap;
	}
	
	public static function hasField(classname:String, fieldname:String):Bool
	{
		var fieldMap = getFieldMap(classname);
		if(fieldMap == null) return false;
		return fieldMap.exists(fieldname);
	}
}
