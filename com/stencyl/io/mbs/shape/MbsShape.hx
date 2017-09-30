package com.stencyl.io.mbs.shape;

import mbs.core.ComposedType;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsShape extends MbsObject
{
	
	public static var MBS_SHAPE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_SHAPE != null) return;
		MBS_SHAPE = new ComposedType("MbsShape");
		MBS_SHAPE.setInstantiator(function(data) return new MbsShape(data));
		
	}
	
	public static function new_MbsShape_list(data:MbsIO):MbsList<MbsShape>
	{
		return new MbsList<MbsShape>(data, MBS_SHAPE, new MbsShape(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_SHAPE;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_SHAPE.getSize()));
	}
	
}
