package com.stencyl.io.mbs.scene;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsSceneHeader extends MbsObject
{
	public static var id:MbsField;
	public static var name:MbsField;
	public static var description:MbsField;
	public static var format:MbsField;
	
	public static var MBS_SCENE_HEADER:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_SCENE_HEADER != null) return;
		MBS_SCENE_HEADER = new ComposedType("MbsSceneHeader");
		MBS_SCENE_HEADER.setInstantiator(function(data) return new MbsSceneHeader(data));
		
		id = MBS_SCENE_HEADER.createField("id", INTEGER);
		name = MBS_SCENE_HEADER.createField("name", STRING);
		description = MBS_SCENE_HEADER.createField("description", STRING);
		format = MBS_SCENE_HEADER.createField("format", STRING);
		
	}
	
	public static function new_MbsSceneHeader_list(data:MbsIO):MbsList<MbsSceneHeader>
	{
		return new MbsList<MbsSceneHeader>(data, MBS_SCENE_HEADER, new MbsSceneHeader(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_SCENE_HEADER;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_SCENE_HEADER.getSize()));
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
	
	public function getDescription():String
	{
		return data.readString(address + description.address);
	}
	
	public function setDescription(_val:String):Void
	{
		data.writeString(address + description.address, _val);
	}
	
	public function getFormat():String
	{
		return data.readString(address + format.address);
	}
	
	public function setFormat(_val:String):Void
	{
		data.writeString(address + format.address, _val);
	}
	
}
