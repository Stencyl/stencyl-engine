package com.stencyl.io.mbs.scene.physics;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsJoint extends MbsObject
{
	public static var id:MbsField;
	public static var name:MbsField;
	public static var actor1:MbsField;
	public static var actor2:MbsField;
	public static var collide:MbsField;
	
	public static var MBS_JOINT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_JOINT != null) return;
		MBS_JOINT = new ComposedType("MbsJoint");
		MBS_JOINT.setInstantiator(function(data) return new MbsJoint(data));
		
		id = MBS_JOINT.createField("id", INTEGER);
		name = MBS_JOINT.createField("name", STRING);
		actor1 = MBS_JOINT.createField("actor1", INTEGER);
		actor2 = MBS_JOINT.createField("actor2", INTEGER);
		collide = MBS_JOINT.createField("collide", BOOLEAN);
		
	}
	
	public static function new_MbsJoint_list(data:MbsIO):MbsList<MbsJoint>
	{
		return new MbsList<MbsJoint>(data, MBS_JOINT, new MbsJoint(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_JOINT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_JOINT.getSize()));
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
	
	public function getActor1():Int
	{
		return data.readInt(address + actor1.address);
	}
	
	public function setActor1(_val:Int):Void
	{
		data.writeInt(address + actor1.address, _val);
	}
	
	public function getActor2():Int
	{
		return data.readInt(address + actor2.address);
	}
	
	public function setActor2(_val:Int):Void
	{
		data.writeInt(address + actor2.address, _val);
	}
	
	public function getCollide():Bool
	{
		return data.readBool(address + collide.address);
	}
	
	public function setCollide(_val:Bool):Void
	{
		data.writeBool(address + collide.address, _val);
	}
	
}
