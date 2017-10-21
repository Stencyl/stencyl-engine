package com.stencyl.io.mbs.game;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsCollisionGroup extends MbsObject
{
	public static var id:MbsField;
	public static var name:MbsField;
	
	public static var MBS_COLLISION_GROUP:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_COLLISION_GROUP != null) return;
		MBS_COLLISION_GROUP = new ComposedType("MbsCollisionGroup");
		MBS_COLLISION_GROUP.setInstantiator(function(data) return new MbsCollisionGroup(data));
		
		id = MBS_COLLISION_GROUP.createField("id", INTEGER);
		name = MBS_COLLISION_GROUP.createField("name", STRING);
		
	}
	
	public static function new_MbsCollisionGroup_list(data:MbsIO):MbsList<MbsCollisionGroup>
	{
		return new MbsList<MbsCollisionGroup>(data, MBS_COLLISION_GROUP, new MbsCollisionGroup(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_COLLISION_GROUP;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_COLLISION_GROUP.getSize()));
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
