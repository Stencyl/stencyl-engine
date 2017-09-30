package com.stencyl.io.mbs.scene.physics;

import com.stencyl.io.mbs.scene.physics.MbsJoint;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsHingeJoint extends MbsJoint
{
	public static var limit:MbsField;
	public static var motor:MbsField;
	public static var lower:MbsField;
	public static var upper:MbsField;
	public static var torque:MbsField;
	public static var speed:MbsField;
	
	public static var MBS_HINGE_JOINT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_HINGE_JOINT != null) return;
		MbsJoint.initializeType();
		
		MBS_HINGE_JOINT = new ComposedType("MbsHingeJoint");
		MBS_HINGE_JOINT.setInstantiator(function(data) return new MbsHingeJoint(data));
		MBS_HINGE_JOINT.inherit(MbsJoint.MBS_JOINT);
		
		limit = MBS_HINGE_JOINT.createField("limit", BOOLEAN);
		motor = MBS_HINGE_JOINT.createField("motor", BOOLEAN);
		lower = MBS_HINGE_JOINT.createField("lower", FLOAT);
		upper = MBS_HINGE_JOINT.createField("upper", FLOAT);
		torque = MBS_HINGE_JOINT.createField("torque", FLOAT);
		speed = MBS_HINGE_JOINT.createField("speed", FLOAT);
		
	}
	
	public static function new_MbsHingeJoint_list(data:MbsIO):MbsList<MbsHingeJoint>
	{
		return new MbsList<MbsHingeJoint>(data, MBS_HINGE_JOINT, new MbsHingeJoint(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_HINGE_JOINT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_HINGE_JOINT.getSize()));
	}
	
	public function getLimit():Bool
	{
		return data.readBool(address + limit.address);
	}
	
	public function setLimit(_val:Bool):Void
	{
		data.writeBool(address + limit.address, _val);
	}
	
	public function getMotor():Bool
	{
		return data.readBool(address + motor.address);
	}
	
	public function setMotor(_val:Bool):Void
	{
		data.writeBool(address + motor.address, _val);
	}
	
	public function getLower():Float
	{
		return data.readFloat(address + lower.address);
	}
	
	public function setLower(_val:Float):Void
	{
		data.writeFloat(address + lower.address, _val);
	}
	
	public function getUpper():Float
	{
		return data.readFloat(address + upper.address);
	}
	
	public function setUpper(_val:Float):Void
	{
		data.writeFloat(address + upper.address, _val);
	}
	
	public function getTorque():Float
	{
		return data.readFloat(address + torque.address);
	}
	
	public function setTorque(_val:Float):Void
	{
		data.writeFloat(address + torque.address, _val);
	}
	
	public function getSpeed():Float
	{
		return data.readFloat(address + speed.address);
	}
	
	public function setSpeed(_val:Float):Void
	{
		data.writeFloat(address + speed.address, _val);
	}
	
}
