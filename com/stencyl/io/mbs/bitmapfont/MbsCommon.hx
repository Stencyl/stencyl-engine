package com.stencyl.io.mbs.bitmapfont;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsCommon extends MbsObject
{
	public static var lineHeight:MbsField;
	public static var base:MbsField;
	public static var scaleW:MbsField;
	public static var scaleH:MbsField;
	public static var pages:MbsField;
	public static var packed:MbsField;
	
	public static var MBS_COMMON:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_COMMON != null) return;
		MBS_COMMON = new ComposedType("MbsCommon");
		MBS_COMMON.setInstantiator(function(data) return new MbsCommon(data));
		
		lineHeight = MBS_COMMON.createField("lineHeight", INTEGER);
		base = MBS_COMMON.createField("base", INTEGER);
		scaleW = MBS_COMMON.createField("scaleW", INTEGER);
		scaleH = MBS_COMMON.createField("scaleH", INTEGER);
		pages = MBS_COMMON.createField("pages", INTEGER);
		packed = MBS_COMMON.createField("packed", BOOLEAN);
		
	}
	
	public static function new_MbsCommon_list(data:MbsIO):MbsList<MbsCommon>
	{
		return new MbsList<MbsCommon>(data, MBS_COMMON, new MbsCommon(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_COMMON;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_COMMON.getSize()));
	}
	
	public function getLineHeight():Int
	{
		return data.readInt(address + lineHeight.address);
	}
	
	public function setLineHeight(_val:Int):Void
	{
		data.writeInt(address + lineHeight.address, _val);
	}
	
	public function getBase():Int
	{
		return data.readInt(address + base.address);
	}
	
	public function setBase(_val:Int):Void
	{
		data.writeInt(address + base.address, _val);
	}
	
	public function getScaleW():Int
	{
		return data.readInt(address + scaleW.address);
	}
	
	public function setScaleW(_val:Int):Void
	{
		data.writeInt(address + scaleW.address, _val);
	}
	
	public function getScaleH():Int
	{
		return data.readInt(address + scaleH.address);
	}
	
	public function setScaleH(_val:Int):Void
	{
		data.writeInt(address + scaleH.address, _val);
	}
	
	public function getPages():Int
	{
		return data.readInt(address + pages.address);
	}
	
	public function setPages(_val:Int):Void
	{
		data.writeInt(address + pages.address, _val);
	}
	
	public function getPacked():Bool
	{
		return data.readBool(address + packed.address);
	}
	
	public function setPacked(_val:Bool):Void
	{
		data.writeBool(address + packed.address, _val);
	}
	
}
