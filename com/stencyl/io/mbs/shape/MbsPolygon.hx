package com.stencyl.io.mbs.shape;

import com.stencyl.io.mbs.shape.MbsPoint;
import com.stencyl.io.mbs.shape.MbsShape;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsPolygon extends MbsShape
{
	public static var points:MbsField;
	
	public static var MBS_POLYGON:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_POLYGON != null) return;
		MbsShape.initializeType();
		
		MBS_POLYGON = new ComposedType("MbsPolygon");
		MBS_POLYGON.setInstantiator(function(data) return new MbsPolygon(data));
		MBS_POLYGON.inherit(MbsShape.MBS_SHAPE);
		
		points = MBS_POLYGON.createField("points", LIST);
		
	}
	
	public static function new_MbsPolygon_list(data:MbsIO):MbsList<MbsPolygon>
	{
		return new MbsList<MbsPolygon>(data, MBS_POLYGON, new MbsPolygon(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_POLYGON;
	}
	
	private var _points:MbsList<MbsPoint>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_points = new MbsList<MbsPoint>(data, MbsPoint.MBS_POINT, new MbsPoint(data));
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_POLYGON.getSize()));
	}
	
	public function getPoints():MbsList<MbsPoint>
	{
		_points.setAddress(data.readInt(address + points.address));
		return _points;
	}
	
	public function createPoints(_length:Int):MbsList<MbsPoint>
	{
		_points.allocateNew(_length);
		data.writeInt(address + points.address, _points.getAddress());
		return _points;
	}
	
}
