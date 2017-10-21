package com.stencyl.io.mbs.snippet;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsAttribute extends MbsObject
{
	public static var id:MbsField;
	public static var type:MbsField;
	public static var value:MbsField;
	
	public static var MBS_ATTRIBUTE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_ATTRIBUTE != null) return;
		MBS_ATTRIBUTE = new ComposedType("MbsAttribute");
		MBS_ATTRIBUTE.setInstantiator(function(data) return new MbsAttribute(data));
		
		id = MBS_ATTRIBUTE.createField("id", INTEGER);
		type = MBS_ATTRIBUTE.createField("type", STRING);
		value = MBS_ATTRIBUTE.createField("value", DYNAMIC);
		
	}
	
	public static function new_MbsAttribute_list(data:MbsIO):MbsList<MbsAttribute>
	{
		return new MbsList<MbsAttribute>(data, MBS_ATTRIBUTE, new MbsAttribute(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_ATTRIBUTE;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_ATTRIBUTE.getSize()));
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
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
