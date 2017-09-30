package com.stencyl.io.mbs.scene.physics;

import com.stencyl.io.mbs.scene.physics.MbsJoint;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsSlidingJoint extends MbsJoint
{
	public static var limit:MbsField;
	public static var motor:MbsField;
	public static var lower:MbsField;
	public static var upper:MbsField;
	public static var force:MbsField;
	public static var speed:MbsField;
	public static var x:MbsField;
	public static var y:MbsField;
	
	public static var MBS_SLIDING_JOINT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_SLIDING_JOINT != null) return;
		MbsJoint.initializeType();
		
		MBS_SLIDING_JOINT = new ComposedType("MbsSlidingJoint");
		MBS_SLIDING_JOINT.setInstantiator(function(data) return new MbsSlidingJoint(data));
		MBS_SLIDING_JOINT.inherit(MbsJoint.MBS_JOINT);
		
		limit = MBS_SLIDING_JOINT.createField("limit", BOOLEAN);
		motor = MBS_SLIDING_JOINT.createField("motor", BOOLEAN);
		lower = MBS_SLIDING_JOINT.createField("lower", FLOAT);
		upper = MBS_SLIDING_JOINT.createField("upper", FLOAT);
		force = MBS_SLIDING_JOINT.createField("force", FLOAT);
		speed = MBS_SLIDING_JOINT.createField("speed", FLOAT);
		x = MBS_SLIDING_JOINT.createField("x", FLOAT);
		y = MBS_SLIDING_JOINT.createField("y", FLOAT);
		
	}
	
	public static function new_MbsSlidingJoint_list(data:MbsIO):MbsList<MbsSlidingJoint>
	{
		return new MbsList<MbsSlidingJoint>(data, MBS_SLIDING_JOINT, new MbsSlidingJoint(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_SLIDING_JOINT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_SLIDING_JOINT.getSize()));
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
	
	public function getForce():Float
	{
		return data.readFloat(address + force.address);
	}
	
	public function setForce(_val:Float):Void
	{
		data.writeFloat(address + force.address, _val);
	}
	
	public function getSpeed():Float
	{
		return data.readFloat(address + speed.address);
	}
	
	public function setSpeed(_val:Float):Void
	{
		data.writeFloat(address + speed.address, _val);
	}
	
	public function getX():Float
	{
		return data.readFloat(address + x.address);
	}
	
	public function setX(_val:Float):Void
	{
		data.writeFloat(address + x.address, _val);
	}
	
	public function getY():Float
	{
		return data.readFloat(address + y.address);
	}
	
	public function setY(_val:Float):Void
	{
		data.writeFloat(address + y.address, _val);
	}
	
}
