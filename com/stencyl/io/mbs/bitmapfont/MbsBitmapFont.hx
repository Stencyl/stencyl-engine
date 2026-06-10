package com.stencyl.io.mbs.bitmapfont;

import com.stencyl.io.mbs.bitmapfont.MbsChar;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsBitmapFont extends MbsObject
{
	public static var info:MbsField;
	public static var common:MbsField;
	public static var chars:MbsField;
	
	public static var MBS_BITMAP_FONT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_BITMAP_FONT != null) return;
		MBS_BITMAP_FONT = new ComposedType("MbsBitmapFont");
		MBS_BITMAP_FONT.setInstantiator(function(data) return new MbsBitmapFont(data));
		
		info = MBS_BITMAP_FONT.createField("info", MbsInfo.MBS_INFO);
		common = MBS_BITMAP_FONT.createField("common", MbsCommon.MBS_COMMON);
		chars = MBS_BITMAP_FONT.createField("chars", LIST);
		
	}
	
	public static function new_MbsBitmapFont_list(data:MbsIO):MbsList<MbsBitmapFont>
	{
		return new MbsList<MbsBitmapFont>(data, MBS_BITMAP_FONT, new MbsBitmapFont(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_BITMAP_FONT;
	}
	
	private var _info:MbsInfo;
	private var _common:MbsCommon;
	private var _chars:MbsList<MbsChar>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_info = new MbsInfo(data);
		_common = new MbsCommon(data);
		_chars = new MbsList<MbsChar>(data, MbsChar.MBS_CHAR, new MbsChar(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_BITMAP_FONT.getSize()));
	}
	
	public function getInfo():MbsInfo
	{
		_info.setAddress(address + info.address);
		return _info;
	}
	
	public function getCommon():MbsCommon
	{
		_common.setAddress(address + common.address);
		return _common;
	}
	
	public function getChars():MbsList<MbsChar>
	{
		_chars.setAddress(data.readInt(address + chars.address));
		return _chars;
	}
	
	public function createChars(_length:Int):MbsList<MbsChar>
	{
		_chars.allocateNew(_length);
		data.writeInt(address + chars.address, _chars.getAddress());
		return _chars;
	}
	
}
