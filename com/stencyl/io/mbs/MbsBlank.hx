package com.stencyl.io.mbs;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsBlank extends MbsObject
{
	public static var name:MbsField;
	public static var type:MbsField;
	
	public static var MBS_BLANK:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_BLANK != null) return;
		MBS_BLANK = new ComposedType("MbsBlank");
		MBS_BLANK.setInstantiator(function(data) return new MbsBlank(data));
		
		name = MBS_BLANK.createField("name", STRING);
		type = MBS_BLANK.createField("type", STRING);
		
	}
	
	public static function new_MbsBlank_list(data:MbsIO):MbsList<MbsBlank>
	{
		return new MbsList<MbsBlank>(data, MBS_BLANK, new MbsBlank(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_BLANK;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_BLANK.getSize()));
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
	}
	
}
