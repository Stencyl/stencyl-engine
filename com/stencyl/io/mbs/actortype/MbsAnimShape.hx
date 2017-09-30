package com.stencyl.io.mbs.actortype;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsAnimShape extends MbsObject
{
	public static var shape:MbsField;
	public static var density:MbsField;
	public static var friction:MbsField;
	public static var groupID:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	public static var restitution:MbsField;
	public static var sensor:MbsField;
	
	public static var MBS_ANIM_SHAPE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_ANIM_SHAPE != null) return;
		MBS_ANIM_SHAPE = new ComposedType("MbsAnimShape");
		MBS_ANIM_SHAPE.setInstantiator(function(data) return new MbsAnimShape(data));
		
		shape = MBS_ANIM_SHAPE.createField("shape", DYNAMIC);
		density = MBS_ANIM_SHAPE.createField("density", FLOAT);
		friction = MBS_ANIM_SHAPE.createField("friction", FLOAT);
		groupID = MBS_ANIM_SHAPE.createField("groupID", INTEGER);
		id = MBS_ANIM_SHAPE.createField("id", INTEGER);
		name = MBS_ANIM_SHAPE.createField("name", STRING);
		restitution = MBS_ANIM_SHAPE.createField("restitution", FLOAT);
		sensor = MBS_ANIM_SHAPE.createField("sensor", BOOLEAN);
		
	}
	
	public static function new_MbsAnimShape_list(data:MbsIO):MbsList<MbsAnimShape>
	{
		return new MbsList<MbsAnimShape>(data, MBS_ANIM_SHAPE, new MbsAnimShape(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_ANIM_SHAPE;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_ANIM_SHAPE.getSize()));
	}
	
	public function getShape():Dynamic
	{
		return MbsDynamicHelper.readDynamic(data, address + shape.address);
	}
	
	public function setShape(_val:Dynamic):Void
	{
		MbsDynamicHelper.writeDynamic(data, address + shape.address, _val);
	}
	
	public function getDensity():Float
	{
		return data.readFloat(address + density.address);
	}
	
	public function setDensity(_val:Float):Void
	{
		data.writeFloat(address + density.address, _val);
	}
	
	public function getFriction():Float
	{
		return data.readFloat(address + friction.address);
	}
	
	public function setFriction(_val:Float):Void
	{
		data.writeFloat(address + friction.address, _val);
	}
	
	public function getGroupID():Int
	{
		return data.readInt(address + groupID.address);
	}
	
	public function setGroupID(_val:Int):Void
	{
		data.writeInt(address + groupID.address, _val);
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
	
	public function getRestitution():Float
	{
		return data.readFloat(address + restitution.address);
	}
	
	public function setRestitution(_val:Float):Void
	{
		data.writeFloat(address + restitution.address, _val);
	}
	
	public function getSensor():Bool
	{
		return data.readBool(address + sensor.address);
	}
	
	public function setSensor(_val:Bool):Void
	{
		data.writeBool(address + sensor.address, _val);
	}
	
}
