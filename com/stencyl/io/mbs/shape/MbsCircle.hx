package com.stencyl.io.mbs.shape;

import com.stencyl.io.mbs.shape.MbsShape;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsCircle extends MbsShape
{
	public static var position:MbsField;
	public static var radius:MbsField;
	
	public static var MBS_CIRCLE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_CIRCLE != null) return;
		MbsShape.initializeType();
		
		MBS_CIRCLE = new ComposedType("MbsCircle");
		MBS_CIRCLE.setInstantiator(function(data) return new MbsCircle(data));
		MBS_CIRCLE.inherit(MbsShape.MBS_SHAPE);
		
		position = MBS_CIRCLE.createField("position", MbsPoint.MBS_POINT);
		radius = MBS_CIRCLE.createField("radius", FLOAT);
		
	}
	
	public static function new_MbsCircle_list(data:MbsIO):MbsList<MbsCircle>
	{
		return new MbsList<MbsCircle>(data, MBS_CIRCLE, new MbsCircle(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_CIRCLE;
	}
	
	private var _position:MbsPoint;
	
	public function new(data:MbsIO)
	{
		super(data);
		_position = new MbsPoint(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_CIRCLE.getSize()));
	}
	
	public function getPosition():MbsPoint
	{
		_position.setAddress(address + position.address);
		return _position;
	}
	
	public function getRadius():Float
	{
		return data.readFloat(address + radius.address);
	}
	
	public function setRadius(_val:Float):Void
	{
		data.writeFloat(address + radius.address, _val);
	}
	
}
