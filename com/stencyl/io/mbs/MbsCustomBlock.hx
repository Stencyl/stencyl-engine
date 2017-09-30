package com.stencyl.io.mbs;

import com.stencyl.io.mbs.MbsBlank;
import com.stencyl.io.mbs.MbsResource;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsCustomBlock extends MbsResource
{
	public static var blocktag:MbsField;
	public static var blocktype:MbsField;
	public static var code:MbsField;
	public static var global:MbsField;
	public static var gui:MbsField;
	public static var message:MbsField;
	public static var returnType:MbsField;
	public static var snippetID:MbsField;
	public static var blanks:MbsField;
	
	public static var MBS_CUSTOM_BLOCK:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_CUSTOM_BLOCK != null) return;
		MbsResource.initializeType();
		
		MBS_CUSTOM_BLOCK = new ComposedType("MbsCustomBlock");
		MBS_CUSTOM_BLOCK.setInstantiator(function(data) return new MbsCustomBlock(data));
		MBS_CUSTOM_BLOCK.inherit(MbsResource.MBS_RESOURCE);
		
		blocktag = MBS_CUSTOM_BLOCK.createField("blocktag", STRING);
		blocktype = MBS_CUSTOM_BLOCK.createField("blocktype", STRING);
		code = MBS_CUSTOM_BLOCK.createField("code", STRING);
		global = MBS_CUSTOM_BLOCK.createField("global", BOOLEAN);
		gui = MBS_CUSTOM_BLOCK.createField("gui", STRING);
		message = MBS_CUSTOM_BLOCK.createField("message", STRING);
		returnType = MBS_CUSTOM_BLOCK.createField("returnType", STRING);
		snippetID = MBS_CUSTOM_BLOCK.createField("snippetID", INTEGER);
		blanks = MBS_CUSTOM_BLOCK.createField("blanks", LIST);
		
	}
	
	public static function new_MbsCustomBlock_list(data:MbsIO):MbsList<MbsCustomBlock>
	{
		return new MbsList<MbsCustomBlock>(data, MBS_CUSTOM_BLOCK, new MbsCustomBlock(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_CUSTOM_BLOCK;
	}
	
	private var _blanks:MbsList<MbsBlank>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_blanks = new MbsList<MbsBlank>(data, MbsBlank.MBS_BLANK, new MbsBlank(data));
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_CUSTOM_BLOCK.getSize()));
	}
	
	public function getBlocktag():String
	{
		return data.readString(address + blocktag.address);
	}
	
	public function setBlocktag(_val:String):Void
	{
		data.writeString(address + blocktag.address, _val);
	}
	
	public function getBlocktype():String
	{
		return data.readString(address + blocktype.address);
	}
	
	public function setBlocktype(_val:String):Void
	{
		data.writeString(address + blocktype.address, _val);
	}
	
	public function getCode():String
	{
		return data.readString(address + code.address);
	}
	
	public function setCode(_val:String):Void
	{
		data.writeString(address + code.address, _val);
	}
	
	public function getGlobal():Bool
	{
		return data.readBool(address + global.address);
	}
	
	public function setGlobal(_val:Bool):Void
	{
		data.writeBool(address + global.address, _val);
	}
	
	public function getGui():String
	{
		return data.readString(address + gui.address);
	}
	
	public function setGui(_val:String):Void
	{
		data.writeString(address + gui.address, _val);
	}
	
	public function getMessage():String
	{
		return data.readString(address + message.address);
	}
	
	public function setMessage(_val:String):Void
	{
		data.writeString(address + message.address, _val);
	}
	
	public function getReturnType():String
	{
		return data.readString(address + returnType.address);
	}
	
	public function setReturnType(_val:String):Void
	{
		data.writeString(address + returnType.address, _val);
	}
	
	public function getSnippetID():Int
	{
		return data.readInt(address + snippetID.address);
	}
	
	public function setSnippetID(_val:Int):Void
	{
		data.writeInt(address + snippetID.address, _val);
	}
	
	public function getBlanks():MbsList<MbsBlank>
	{
		_blanks.setAddress(address + blanks.address);
		return _blanks;
	}
	
	public function createBlanks(_length:Int):MbsList<MbsBlank>
	{
		_blanks.allocateNew(_length);
		data.writeInt(address + blanks.address, _blanks.getAddress());
		return _blanks;
	}
	
}
