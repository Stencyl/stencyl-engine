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
	public static var alphabet:MbsField;
	public static var readableImages:MbsField;
	public static var height:MbsField;
	public static var offsets:MbsField;
	public static var prerendered:MbsField;
	public static var rowHeight:MbsField;
	
	public static var MBS_FONT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_FONT != null) return;
		MbsResource.initializeType();
		
		MBS_FONT = new ComposedType("MbsFont");
		MBS_FONT.setInstantiator(function(data) return new MbsFont(data));
		MBS_FONT.inherit(MbsResource.MBS_RESOURCE);
		
		alphabet = MBS_FONT.createField("alphabet", STRING);
		readableImages = MBS_FONT.createField("readableImages", BOOLEAN);
		height = MBS_FONT.createField("height", INTEGER);
		offsets = MBS_FONT.createField("offsets", STRING);
		prerendered = MBS_FONT.createField("prerendered", BOOLEAN);
		rowHeight = MBS_FONT.createField("rowHeight", INTEGER);
		
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
	
	public function getAlphabet():String
	{
		return data.readString(address + alphabet.address);
	}
	
	public function setAlphabet(_val:String):Void
	{
		data.writeString(address + alphabet.address, _val);
	}
	
	public function getReadableImages():Bool
	{
		return data.readBool(address + readableImages.address);
	}
	
	public function setReadableImages(_val:Bool):Void
	{
		data.writeBool(address + readableImages.address, _val);
	}
	
	public function getHeight():Int
	{
		return data.readInt(address + height.address);
	}
	
	public function setHeight(_val:Int):Void
	{
		data.writeInt(address + height.address, _val);
	}
	
	public function getOffsets():String
	{
		return data.readString(address + offsets.address);
	}
	
	public function setOffsets(_val:String):Void
	{
		data.writeString(address + offsets.address, _val);
	}
	
	public function getPrerendered():Bool
	{
		return data.readBool(address + prerendered.address);
	}
	
	public function setPrerendered(_val:Bool):Void
	{
		data.writeBool(address + prerendered.address, _val);
	}
	
	public function getRowHeight():Int
	{
		return data.readInt(address + rowHeight.address);
	}
	
	public function setRowHeight(_val:Int):Void
	{
		data.writeInt(address + rowHeight.address, _val);
	}
	
}
