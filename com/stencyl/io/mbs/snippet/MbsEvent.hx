package com.stencyl.io.mbs.snippet;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsEvent extends MbsObject
{
	public static var displayName:MbsField;
	public static var enabled:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	public static var order:MbsField;
	public static var repeats:MbsField;
	
	public static var MBS_EVENT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_EVENT != null) return;
		MBS_EVENT = new ComposedType("MbsEvent");
		MBS_EVENT.setInstantiator(function(data) return new MbsEvent(data));
		
		displayName = MBS_EVENT.createField("displayName", STRING);
		enabled = MBS_EVENT.createField("enabled", BOOLEAN);
		id = MBS_EVENT.createField("id", INTEGER);
		name = MBS_EVENT.createField("name", STRING);
		order = MBS_EVENT.createField("order", INTEGER);
		repeats = MBS_EVENT.createField("repeats", BOOLEAN);
		
	}
	
	public static function new_MbsEvent_list(data:MbsIO):MbsList<MbsEvent>
	{
		return new MbsList<MbsEvent>(data, MBS_EVENT, new MbsEvent(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_EVENT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_EVENT.getSize()));
	}
	
	public function getDisplayName():String
	{
		return data.readString(address + displayName.address);
	}
	
	public function setDisplayName(_val:String):Void
	{
		data.writeString(address + displayName.address, _val);
	}
	
	public function getEnabled():Bool
	{
		return data.readBool(address + enabled.address);
	}
	
	public function setEnabled(_val:Bool):Void
	{
		data.writeBool(address + enabled.address, _val);
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
	
	public function getRepeats():Bool
	{
		return data.readBool(address + repeats.address);
	}
	
	public function setRepeats(_val:Bool):Void
	{
		data.writeBool(address + repeats.address, _val);
	}
	
}
