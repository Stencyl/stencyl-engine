package com.stencyl.io.mbs.shape;

import com.stencyl.io.mbs.shape.MbsPolygon;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsWireframe extends MbsPolygon
{
	public static var position:MbsField;
	
	public static var MBS_WIREFRAME:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_WIREFRAME != null) return;
		MbsPolygon.initializeType();
		
		MBS_WIREFRAME = new ComposedType("MbsWireframe");
		MBS_WIREFRAME.setInstantiator(function(data) return new MbsWireframe(data));
		MBS_WIREFRAME.inherit(MbsPolygon.MBS_POLYGON);
		
		position = MBS_WIREFRAME.createField("position", MbsPoint.MBS_POINT);
		
	}
	
	public static function new_MbsWireframe_list(data:MbsIO):MbsList<MbsWireframe>
	{
		return new MbsList<MbsWireframe>(data, MBS_WIREFRAME, new MbsWireframe(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_WIREFRAME;
	}
	
	private var _position:MbsPoint;
	
	public function new(data:MbsIO)
	{
		super(data);
		_position = new MbsPoint(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_WIREFRAME.getSize()));
	}
	
	public function getPosition():MbsPoint
	{
		_position.setAddress(address + position.address);
		return _position;
	}
	
}
