package com.stencyl.io.mbs.game.autotile;

import com.stencyl.io.mbs.shape.MbsPoint;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsCorners extends MbsObject
{
	public static var topLeft:MbsField;
	public static var topRight:MbsField;
	public static var bottomLeft:MbsField;
	public static var bottomRight:MbsField;
	
	public static var MBS_CORNERS:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_CORNERS != null) return;
		MBS_CORNERS = new ComposedType("MbsCorners");
		MBS_CORNERS.setInstantiator(function(data) return new MbsCorners(data));
		
		topLeft = MBS_CORNERS.createField("topLeft", MbsPoint.MBS_POINT);
		topRight = MBS_CORNERS.createField("topRight", MbsPoint.MBS_POINT);
		bottomLeft = MBS_CORNERS.createField("bottomLeft", MbsPoint.MBS_POINT);
		bottomRight = MBS_CORNERS.createField("bottomRight", MbsPoint.MBS_POINT);
		
	}
	
	public static function new_MbsCorners_list(data:MbsIO):MbsList<MbsCorners>
	{
		return new MbsList<MbsCorners>(data, MBS_CORNERS, new MbsCorners(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_CORNERS;
	}
	
	private var _topLeft:MbsPoint;
	private var _topRight:MbsPoint;
	private var _bottomLeft:MbsPoint;
	private var _bottomRight:MbsPoint;
	
	public function new(data:MbsIO)
	{
		super(data);
		_topLeft = new MbsPoint(data);
		_topRight = new MbsPoint(data);
		_bottomLeft = new MbsPoint(data);
		_bottomRight = new MbsPoint(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_CORNERS.getSize()));
	}
	
	public function getTopLeft():MbsPoint
	{
		_topLeft.setAddress(address + topLeft.address);
		return _topLeft;
	}
	
	public function getTopRight():MbsPoint
	{
		_topRight.setAddress(address + topRight.address);
		return _topRight;
	}
	
	public function getBottomLeft():MbsPoint
	{
		_bottomLeft.setAddress(address + bottomLeft.address);
		return _bottomLeft;
	}
	
	public function getBottomRight():MbsPoint
	{
		_bottomRight.setAddress(address + bottomRight.address);
		return _bottomRight;
	}
	
}
