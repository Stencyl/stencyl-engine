package com.stencyl.io;

import com.stencyl.behavior.BehaviorInstance;
import com.stencyl.io.mbs.snippet.*;

import mbs.core.MbsField;
import mbs.core.MbsTypes;
import mbs.core.MbsTypes.*;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsDynamicList;

class AttributeValues
{
	public static function readBehaviors(listReader:MbsList<MbsSnippet>):Map<String,BehaviorInstance>
	{
		var toReturn:Map<String,BehaviorInstance> = new Map<String,BehaviorInstance>();
		
		for(i in 0...listReader.length())
		{
			var snipReader = listReader.getNextObject();
			
			if(!snipReader.getEnabled())
			{
				continue;
			}
			
			var ID = snipReader.getId();
			var map = readBehaviorProperties(snipReader.getProperties());
			toReturn.set(""+ID, new BehaviorInstance(ID, map));
		}
		
		return toReturn;
	}
	
	public static function readBehaviorProperties(listReader:MbsList<MbsAttribute>):Map<String,Dynamic>
	{
		var map:Map<String,Dynamic> = new Map<String,Dynamic>();
		
		for(i in 0...listReader.length())
		{
			var attrReader = listReader.getNextObject();

			var id = attrReader.getId();
			var type = attrReader.getType();

			map.set(""+id, readAttribute(type, attrReader));
		}
		
		return map;
	}

    public static function readAttribute(type:String, r:MbsAttribute):Dynamic
    {
        return switch(type)
        {
            case "list": readList(cast r.getValue());
            case "map": readMap(cast r.getValue());
            default: r.getValue();
        };
    }

	public static function readAttributeDef(type:String, r:MbsAttributeDef):Dynamic
    {
        return switch(type)
        {
            case "list": readList(cast r.getDefaultValue());
            case "map": readMap(cast r.getDefaultValue());
            default: r.getDefaultValue();
        };
    }
	
	public static function readList(listReader:MbsDynamicList):Array<Dynamic>
	{
		if(listReader == null)
			return null;

		var map:Array<Dynamic> = new Array<Dynamic>();
		
		for(i in 0...listReader.length())
		{
			map[i] = listReader.readObject();
		}
		
		return map;	
	}
	
	public static function readMap(mapReader:MbsList<MbsMapElement>):Map<String,Dynamic>
	{
		if(mapReader == null)
			return null;
		
		var map:Map<String,Dynamic> = new Map<String,Dynamic>();
		
		for(i in 0...mapReader.length())
		{
			var mapElement = mapReader.getNextObject();
			var key = mapElement.getKey();
			var val:Dynamic = mapElement.getValue();

			if(Std.is(val, MbsDynamicList))
			{
				var mdl:MbsDynamicList = cast val;
				val = [for(i in 0...mdl.length()) mdl.readObject()];
			}
			else if(Std.is(val, MbsList))
			{
				val = readMap(cast val);
			}

			map.set(key, val);
		}

		return map;	
	}
}