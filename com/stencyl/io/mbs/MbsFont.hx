package com.stencyl.io.mbs;

import com.stencyl.io.mbs.MbsResource;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsFont extends MbsResource
{
	public static var readableImages:MbsField;
	public static var prerendered:MbsField;
	
	public static var MBS_FONT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_FONT != null) return;
		MbsResource.initializeType();
		
		MBS_FONT = new ComposedType("MbsFont");
		MBS_FONT.setInstantiator(function(data) return new MbsFont(data));
		MBS_FONT.inherit(MbsResource.MBS_RESOURCE);
		
		readableImages = MBS_FONT.createField("readableImages", BOOLEAN);
		prerendered = MBS_FONT.createField("prerendered", BOOLEAN);
		
	}
	
	public static function new_MbsFont_list(data:MbsIO):MbsList<MbsFont>
	{
		return new MbsList<MbsFont>(data, MBS_FONT, new MbsFont(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_FONT;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_FONT.getSize()));
	}
	
	public function getReadableImages():Bool
	{
		return data.readBool(address + readableImages.address);
	}
	
	public function setReadableImages(_val:Bool):Void
	{
		data.writeBool(address + readableImages.address, _val);
	}
	
	public function getPrerendered():Bool
	{
		return data.readBool(address + prerendered.address);
	}
	
	public function setPrerendered(_val:Bool):Void
	{
		data.writeBool(address + prerendered.address, _val);
	}
	
}
