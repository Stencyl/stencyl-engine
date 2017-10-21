package com.stencyl.io.mbs;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsResource extends MbsObject
{
	public static var atlasID:MbsField;
	public static var description:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	
	public static var MBS_RESOURCE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_RESOURCE != null) return;
		MBS_RESOURCE = new ComposedType("MbsResource");
		MBS_RESOURCE.setInstantiator(function(data) return new MbsResource(data));
		
		atlasID = MBS_RESOURCE.createField("atlasID", INTEGER);
		description = MBS_RESOURCE.createField("description", STRING);
		id = MBS_RESOURCE.createField("id", INTEGER);
		name = MBS_RESOURCE.createField("name", STRING);
		
	}
	
	public static function new_MbsResource_list(data:MbsIO):MbsList<MbsResource>
	{
		return new MbsList<MbsResource>(data, MBS_RESOURCE, new MbsResource(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_RESOURCE;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_RESOURCE.getSize()));
	}
	
	public function getAtlasID():Int
	{
		return data.readInt(address + atlasID.address);
	}
	
	public function setAtlasID(_val:Int):Void
	{
		data.writeInt(address + atlasID.address, _val);
	}
	
	public function getDescription():String
	{
		return data.readString(address + description.address);
	}
	
	public function setDescription(_val:String):Void
	{
		data.writeString(address + description.address, _val);
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
	
}
