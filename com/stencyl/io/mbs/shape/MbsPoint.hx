package com.stencyl.io.mbs.shape;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsPoint extends MbsObject
{
	public static var x:MbsField;
	public static var y:MbsField;
	
	public static var MBS_POINT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_POINT != null) return;
		MBS_POINT = new ComposedType("MbsPoint");
		MBS_POINT.setInstantiator(function(data) return new MbsPoint(data));
		
		x = MBS_POINT.createField("x", FLOAT);
		y = MBS_POINT.createField("y", FLOAT);
		
	}
	
	public static function new_MbsPoint_list(data:MbsIO):MbsList<MbsPoint>
	{
		return new MbsList<MbsPoint>(data, MBS_POINT, new MbsPoint(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_POINT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_POINT.getSize()));
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
