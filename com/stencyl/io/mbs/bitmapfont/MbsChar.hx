package com.stencyl.io.mbs.bitmapfont;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsChar extends MbsObject
{
	public static var id:MbsField;
	public static var x:MbsField;
	public static var y:MbsField;
	public static var width:MbsField;
	public static var height:MbsField;
	public static var xoffset:MbsField;
	public static var yoffset:MbsField;
	public static var xadvance:MbsField;
	public static var page:MbsField;
	public static var chnl:MbsField;
	
	public static var MBS_CHAR:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_CHAR != null) return;
		MBS_CHAR = new ComposedType("MbsChar");
		MBS_CHAR.setInstantiator(function(data) return new MbsChar(data));
		
		id = MBS_CHAR.createField("id", INTEGER);
		x = MBS_CHAR.createField("x", INTEGER);
		y = MBS_CHAR.createField("y", INTEGER);
		width = MBS_CHAR.createField("width", INTEGER);
		height = MBS_CHAR.createField("height", INTEGER);
		xoffset = MBS_CHAR.createField("xoffset", INTEGER);
		yoffset = MBS_CHAR.createField("yoffset", INTEGER);
		xadvance = MBS_CHAR.createField("xadvance", INTEGER);
		page = MBS_CHAR.createField("page", INTEGER);
		chnl = MBS_CHAR.createField("chnl", INTEGER);
		
	}
	
	public static function new_MbsChar_list(data:MbsIO):MbsList<MbsChar>
	{
		return new MbsList<MbsChar>(data, MBS_CHAR, new MbsChar(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_CHAR;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_CHAR.getSize()));
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getX():Int
	{
		return data.readInt(address + x.address);
	}
	
	public function setX(_val:Int):Void
	{
		data.writeInt(address + x.address, _val);
	}
	
	public function getY():Int
	{
		return data.readInt(address + y.address);
	}
	
	public function setY(_val:Int):Void
	{
		data.writeInt(address + y.address, _val);
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
	
	public function getXoffset():Int
	{
		return data.readInt(address + xoffset.address);
	}
	
	public function setXoffset(_val:Int):Void
	{
		data.writeInt(address + xoffset.address, _val);
	}
	
	public function getYoffset():Int
	{
		return data.readInt(address + yoffset.address);
	}
	
	public function setYoffset(_val:Int):Void
	{
		data.writeInt(address + yoffset.address, _val);
	}
	
	public function getXadvance():Int
	{
		return data.readInt(address + xadvance.address);
	}
	
	public function setXadvance(_val:Int):Void
	{
		data.writeInt(address + xadvance.address, _val);
	}
	
	public function getPage():Int
	{
		return data.readInt(address + page.address);
	}
	
	public function setPage(_val:Int):Void
	{
		data.writeInt(address + page.address, _val);
	}
	
	public function getChnl():Int
	{
		return data.readInt(address + chnl.address);
	}
	
	public function setChnl(_val:Int):Void
	{
		data.writeInt(address + chnl.address, _val);
	}
	
}
