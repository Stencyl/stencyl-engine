package com.stencyl.io.mbs.snippet;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsBlock extends MbsObject
{
	public static var type:MbsField;
	public static var id:MbsField;
	public static var blockID:MbsField;
	
	public static var MBS_BLOCK:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_BLOCK != null) return;
		MBS_BLOCK = new ComposedType("MbsBlock");
		MBS_BLOCK.setInstantiator(function(data) return new MbsBlock(data));
		
		type = MBS_BLOCK.createField("type", STRING);
		id = MBS_BLOCK.createField("id", INTEGER);
		blockID = MBS_BLOCK.createField("blockID", INTEGER);
		
	}
	
	public static function new_MbsBlock_list(data:MbsIO):MbsList<MbsBlock>
	{
		return new MbsList<MbsBlock>(data, MBS_BLOCK, new MbsBlock(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_BLOCK;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_BLOCK.getSize()));
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getBlockID():Int
	{
		return data.readInt(address + blockID.address);
	}
	
	public function setBlockID(_val:Int):Void
	{
		data.writeInt(address + blockID.address, _val);
	}
	
}
