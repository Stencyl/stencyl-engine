package com.stencyl.utils;

class ConfigUtil
{
	public static function xmlToMap(xml:Access, keyProperty:String, valueProperty:String):Map<String, String>
	{
		var map:Map<String, String> = [];

		for(e in xml.elements)
		{
			map.set(e.att[keyProperty], e.att[valueProperty]);
		}

		return map;
	}

	public static inline function readString(map:Map<String, String>, propertyName:String):String
	{
		return map.get(propertyName);
	}

	public static inline function readInt(map:Map<String, String>, propertyName:String):Int
	{
		return Std.parseInt(map.get(propertyName));
	}

	public static inline function readFloat(map:Map<String, String>, propertyName:String):Int
	{
		return Std.parseFloat(map.get(propertyName));
	}	

	public static inline function readBool(map:Map<String, String>, propertyName:String):Bool
	{
		return map.get(propertyName) == "true";
	}
}