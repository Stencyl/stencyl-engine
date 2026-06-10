package com.stencyl.io.mbs.bitmapfont;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsInfo extends MbsObject
{
	public static var face:MbsField;
	public static var size:MbsField;
	public static var bold:MbsField;
	public static var italic:MbsField;
	public static var charset:MbsField;
	public static var unicode:MbsField;
	public static var stretchH:MbsField;
	public static var smooth:MbsField;
	public static var aa:MbsField;
	public static var padding:MbsField;
	public static var xSpacing:MbsField;
	public static var ySpacing:MbsField;
	
	public static var MBS_INFO:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_INFO != null) return;
		MBS_INFO = new ComposedType("MbsInfo");
		MBS_INFO.setInstantiator(function(data) return new MbsInfo(data));
		
		face = MBS_INFO.createField("face", STRING);
		size = MBS_INFO.createField("size", INTEGER);
		bold = MBS_INFO.createField("bold", BOOLEAN);
		italic = MBS_INFO.createField("italic", BOOLEAN);
		charset = MBS_INFO.createField("charset", STRING);
		unicode = MBS_INFO.createField("unicode", BOOLEAN);
		stretchH = MBS_INFO.createField("stretchH", INTEGER);
		smooth = MBS_INFO.createField("smooth", BOOLEAN);
		aa = MBS_INFO.createField("aa", BOOLEAN);
		padding = MBS_INFO.createField("padding", STRING);
		xSpacing = MBS_INFO.createField("xSpacing", INTEGER);
		ySpacing = MBS_INFO.createField("ySpacing", INTEGER);
		
	}
	
	public static function new_MbsInfo_list(data:MbsIO):MbsList<MbsInfo>
	{
		return new MbsList<MbsInfo>(data, MBS_INFO, new MbsInfo(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_INFO;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_INFO.getSize()));
	}
	
	public function getFace():String
	{
		return data.readString(address + face.address);
	}
	
	public function setFace(_val:String):Void
	{
		data.writeString(address + face.address, _val);
	}
	
	public function getSize():Int
	{
		return data.readInt(address + size.address);
	}
	
	public function setSize(_val:Int):Void
	{
		data.writeInt(address + size.address, _val);
	}
	
	public function getBold():Bool
	{
		return data.readBool(address + bold.address);
	}
	
	public function setBold(_val:Bool):Void
	{
		data.writeBool(address + bold.address, _val);
	}
	
	public function getItalic():Bool
	{
		return data.readBool(address + italic.address);
	}
	
	public function setItalic(_val:Bool):Void
	{
		data.writeBool(address + italic.address, _val);
	}
	
	public function getCharset():String
	{
		return data.readString(address + charset.address);
	}
	
	public function setCharset(_val:String):Void
	{
		data.writeString(address + charset.address, _val);
	}
	
	public function getUnicode():Bool
	{
		return data.readBool(address + unicode.address);
	}
	
	public function setUnicode(_val:Bool):Void
	{
		data.writeBool(address + unicode.address, _val);
	}
	
	public function getStretchH():Int
	{
		return data.readInt(address + stretchH.address);
	}
	
	public function setStretchH(_val:Int):Void
	{
		data.writeInt(address + stretchH.address, _val);
	}
	
	public function getSmooth():Bool
	{
		return data.readBool(address + smooth.address);
	}
	
	public function setSmooth(_val:Bool):Void
	{
		data.writeBool(address + smooth.address, _val);
	}
	
	public function getAa():Bool
	{
		return data.readBool(address + aa.address);
	}
	
	public function setAa(_val:Bool):Void
	{
		data.writeBool(address + aa.address, _val);
	}
	
	public function getPadding():String
	{
		return data.readString(address + padding.address);
	}
	
	public function setPadding(_val:String):Void
	{
		data.writeString(address + padding.address, _val);
	}
	
	public function getXSpacing():Int
	{
		return data.readInt(address + xSpacing.address);
	}
	
	public function setXSpacing(_val:Int):Void
	{
		data.writeInt(address + xSpacing.address, _val);
	}
	
	public function getYSpacing():Int
	{
		return data.readInt(address + ySpacing.address);
	}
	
	public function setYSpacing(_val:Int):Void
	{
		data.writeInt(address + ySpacing.address, _val);
	}
	
}
