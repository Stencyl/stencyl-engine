package com.stencyl.io.mbs.snippet;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsMapElement extends MbsObject
{
	public static var key:MbsField;
	public static var value:MbsField;
	
	public static var MBS_MAP_ELEMENT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_MAP_ELEMENT != null) return;
		MBS_MAP_ELEMENT = new ComposedType("MbsMapElement");
		MBS_MAP_ELEMENT.setInstantiator(function(data) return new MbsMapElement(data));
		
		key = MBS_MAP_ELEMENT.createField("key", STRING);
		value = MBS_MAP_ELEMENT.createField("value", DYNAMIC);
		
	}
	
	public static function new_MbsMapElement_list(data:MbsIO):MbsList<MbsMapElement>
	{
		return new MbsList<MbsMapElement>(data, MBS_MAP_ELEMENT, new MbsMapElement(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_MAP_ELEMENT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_MAP_ELEMENT.getSize()));
	}
	
	public function getKey():String
	{
		return data.readString(address + key.address);
	}
	
	public function setKey(_val:String):Void
	{
		data.writeString(address + key.address, _val);
	}
	
	public function getValue():Dynamic
	{
		return MbsDynamicHelper.readDynamic(data, address + value.address);
	}
	
	public function setValue(_val:Dynamic):Void
	{
		MbsDynamicHelper.writeDynamic(data, address + value.address, _val);
	}
	
}
