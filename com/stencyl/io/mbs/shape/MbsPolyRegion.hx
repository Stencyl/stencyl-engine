package com.stencyl.io.mbs.shape;

import com.stencyl.io.mbs.shape.MbsPolygon;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsPolyRegion extends MbsPolygon
{
	public static var width:MbsField;
	public static var height:MbsField;
	
	public static var MBS_POLY_REGION:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_POLY_REGION != null) return;
		MbsPolygon.initializeType();
		
		MBS_POLY_REGION = new ComposedType("MbsPolyRegion");
		MBS_POLY_REGION.setInstantiator(function(data) return new MbsPolyRegion(data));
		MBS_POLY_REGION.inherit(MbsPolygon.MBS_POLYGON);
		
		width = MBS_POLY_REGION.createField("width", INTEGER);
		height = MBS_POLY_REGION.createField("height", INTEGER);
		
	}
	
	public static function new_MbsPolyRegion_list(data:MbsIO):MbsList<MbsPolyRegion>
	{
		return new MbsList<MbsPolyRegion>(data, MBS_POLY_REGION, new MbsPolyRegion(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_POLY_REGION;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_POLY_REGION.getSize()));
	}
	
	public function getWidth():Int
	{
		return data.readInt(address + width.address);
	}
	
	public function setWidth(_val:Int):Void
	{
		data.writeInt(address + width.address, _val);
	}
	
	public function getHeight():Int
	{
		return data.readInt(address + height.address);
	}
	
	public function setHeight(_val:Int):Void
	{
		data.writeInt(address + height.address, _val);
	}
	
}
