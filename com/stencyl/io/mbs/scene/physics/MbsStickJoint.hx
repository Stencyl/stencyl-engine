package com.stencyl.io.mbs.scene.physics;

import com.stencyl.io.mbs.scene.physics.MbsJoint;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsStickJoint extends MbsJoint
{
	public static var damping:MbsField;
	public static var frequency:MbsField;
	
	public static var MBS_STICK_JOINT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_STICK_JOINT != null) return;
		MbsJoint.initializeType();
		
		MBS_STICK_JOINT = new ComposedType("MbsStickJoint");
		MBS_STICK_JOINT.setInstantiator(function(data) return new MbsStickJoint(data));
		MBS_STICK_JOINT.inherit(MbsJoint.MBS_JOINT);
		
		damping = MBS_STICK_JOINT.createField("damping", FLOAT);
		frequency = MBS_STICK_JOINT.createField("frequency", FLOAT);
		
	}
	
	public static function new_MbsStickJoint_list(data:MbsIO):MbsList<MbsStickJoint>
	{
		return new MbsList<MbsStickJoint>(data, MBS_STICK_JOINT, new MbsStickJoint(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_STICK_JOINT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_STICK_JOINT.getSize()));
	}
	
	public function getDamping():Float
	{
		return data.readFloat(address + damping.address);
	}
	
	public function setDamping(_val:Float):Void
	{
		data.writeFloat(address + damping.address, _val);
	}
	
	public function getFrequency():Float
	{
		return data.readFloat(address + frequency.address);
	}
	
	public function setFrequency(_val:Float):Void
	{
		data.writeFloat(address + frequency.address, _val);
	}
	
}
