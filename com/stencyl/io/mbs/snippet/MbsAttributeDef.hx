package com.stencyl.io.mbs.snippet;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsAttributeDef extends MbsObject
{
	public static var type:MbsField;
	public static var defaultValue:MbsField;
	public static var description:MbsField;
	public static var dropdown:MbsField;
	public static var fullname:MbsField;
	public static var hidden:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	public static var order:MbsField;
	
	public static var MBS_ATTRIBUTE_DEF:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_ATTRIBUTE_DEF != null) return;
		MBS_ATTRIBUTE_DEF = new ComposedType("MbsAttributeDef");
		MBS_ATTRIBUTE_DEF.setInstantiator(function(data) return new MbsAttributeDef(data));
		
		type = MBS_ATTRIBUTE_DEF.createField("type", STRING);
		defaultValue = MBS_ATTRIBUTE_DEF.createField("defaultValue", DYNAMIC);
		description = MBS_ATTRIBUTE_DEF.createField("description", STRING);
		dropdown = MBS_ATTRIBUTE_DEF.createField("dropdown", STRING);
		fullname = MBS_ATTRIBUTE_DEF.createField("fullname", STRING);
		hidden = MBS_ATTRIBUTE_DEF.createField("hidden", BOOLEAN);
		id = MBS_ATTRIBUTE_DEF.createField("id", INTEGER);
		name = MBS_ATTRIBUTE_DEF.createField("name", STRING);
		order = MBS_ATTRIBUTE_DEF.createField("order", INTEGER);
		
	}
	
	public static function new_MbsAttributeDef_list(data:MbsIO):MbsList<MbsAttributeDef>
	{
		return new MbsList<MbsAttributeDef>(data, MBS_ATTRIBUTE_DEF, new MbsAttributeDef(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_ATTRIBUTE_DEF;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_ATTRIBUTE_DEF.getSize()));
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
	}
	
	public function getDefaultValue():Dynamic
	{
		return MbsDynamicHelper.readDynamic(data, address + defaultValue.address);
	}
	
	public function setDefaultValue(_val:Dynamic):Void
	{
		MbsDynamicHelper.writeDynamic(data, address + defaultValue.address, _val);
	}
	
	public function getDescription():String
	{
		return data.readString(address + description.address);
	}
	
	public function setDescription(_val:String):Void
	{
		data.writeString(address + description.address, _val);
	}
	
	public function getDropdown():String
	{
		return data.readString(address + dropdown.address);
	}
	
	public function setDropdown(_val:String):Void
	{
		data.writeString(address + dropdown.address, _val);
	}
	
	public function getFullname():String
	{
		return data.readString(address + fullname.address);
	}
	
	public function setFullname(_val:String):Void
	{
		data.writeString(address + fullname.address, _val);
	}
	
	public function getHidden():Bool
	{
		return data.readBool(address + hidden.address);
	}
	
	public function setHidden(_val:Bool):Void
	{
		data.writeBool(address + hidden.address, _val);
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getOrder():Int
	{
		return data.readInt(address + order.address);
	}
	
	public function setOrder(_val:Int):Void
	{
		data.writeInt(address + order.address, _val);
	}
	
}
