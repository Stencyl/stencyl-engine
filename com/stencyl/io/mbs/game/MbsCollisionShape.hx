package com.stencyl.io.mbs.game;

import com.stencyl.io.mbs.shape.MbsPoint;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsCollisionShape extends MbsObject
{
	public static var id:MbsField;
	public static var points:MbsField;
	
	public static var MBS_COLLISION_SHAPE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_COLLISION_SHAPE != null) return;
		MBS_COLLISION_SHAPE = new ComposedType("MbsCollisionShape");
		MBS_COLLISION_SHAPE.setInstantiator(function(data) return new MbsCollisionShape(data));
		
		id = MBS_COLLISION_SHAPE.createField("id", INTEGER);
		points = MBS_COLLISION_SHAPE.createField("points", LIST);
		
	}
	
	public static function new_MbsCollisionShape_list(data:MbsIO):MbsList<MbsCollisionShape>
	{
		return new MbsList<MbsCollisionShape>(data, MBS_COLLISION_SHAPE, new MbsCollisionShape(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_COLLISION_SHAPE;
	}
	
	private var _points:MbsList<MbsPoint>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_points = new MbsList<MbsPoint>(data, MbsPoint.MBS_POINT, new MbsPoint(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_COLLISION_SHAPE.getSize()));
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
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
