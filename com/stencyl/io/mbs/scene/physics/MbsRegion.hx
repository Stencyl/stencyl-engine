package com.stencyl.io.mbs.scene.physics;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsRegion extends MbsObject
{
	public static var color:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	public static var shape:MbsField;
	public static var x:MbsField;
	public static var y:MbsField;
	
	public static var MBS_REGION:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_REGION != null) return;
		MBS_REGION = new ComposedType("MbsRegion");
		MBS_REGION.setInstantiator(function(data) return new MbsRegion(data));
		
		color = MBS_REGION.createField("color", INTEGER);
		id = MBS_REGION.createField("id", INTEGER);
		name = MBS_REGION.createField("name", STRING);
		shape = MBS_REGION.createField("shape", DYNAMIC);
		x = MBS_REGION.createField("x", INTEGER);
		y = MBS_REGION.createField("y", INTEGER);
		
	}
	
	public static function new_MbsRegion_list(data:MbsIO):MbsList<MbsRegion>
	{
		return new MbsList<MbsRegion>(data, MBS_REGION, new MbsRegion(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_REGION;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_REGION.getSize()));
	}
	
	public function getColor():Int
	{
		return data.readInt(address + color.address);
	}
	
	public function setColor(_val:Int):Void
	{
		data.writeInt(address + color.address, _val);
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
	
	public function getShape():Dynamic
	{
		return MbsDynamicHelper.readDynamic(data, address + shape.address);
	}
	
	public function setShape(_val:Dynamic):Void
	{
		MbsDynamicHelper.writeDynamic(data, address + shape.address, _val);
	}
	
	public function getX():Int
	{
		return data.readInt(address + x.address);
	}
	
	public function setX(_val:Int):Void
	{
		data.writeInt(address + x.address, _val);
	}
	
	public function getY():Int
	{
		return data.readInt(address + y.address);
	}
	
	public function setY(_val:Int):Void
	{
		data.writeInt(address + y.address, _val);
	}
	
}
