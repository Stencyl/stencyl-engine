package com.stencyl.io.mbs;

import com.stencyl.io.mbs.MbsResource;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsMusic extends MbsResource
{
	public static var loop:MbsField;
	public static var pan:MbsField;
	public static var stream:MbsField;
	public static var type:MbsField;
	public static var volume:MbsField;
	
	public static var MBS_MUSIC:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_MUSIC != null) return;
		MbsResource.initializeType();
		
		MBS_MUSIC = new ComposedType("MbsMusic");
		MBS_MUSIC.setInstantiator(function(data) return new MbsMusic(data));
		MBS_MUSIC.inherit(MbsResource.MBS_RESOURCE);
		
		loop = MBS_MUSIC.createField("loop", BOOLEAN);
		pan = MBS_MUSIC.createField("pan", INTEGER);
		stream = MBS_MUSIC.createField("stream", BOOLEAN);
		type = MBS_MUSIC.createField("type", STRING);
		volume = MBS_MUSIC.createField("volume", INTEGER);
		
	}
	
	public static function new_MbsMusic_list(data:MbsIO):MbsList<MbsMusic>
	{
		return new MbsList<MbsMusic>(data, MBS_MUSIC, new MbsMusic(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_MUSIC;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_MUSIC.getSize()));
	}
	
	public function getLoop():Bool
	{
		return data.readBool(address + loop.address);
	}
	
	public function setLoop(_val:Bool):Void
	{
		data.writeBool(address + loop.address, _val);
	}
	
	public function getPan():Int
	{
		return data.readInt(address + pan.address);
	}
	
	public function setPan(_val:Int):Void
	{
		data.writeInt(address + pan.address, _val);
	}
	
	public function getStream():Bool
	{
		return data.readBool(address + stream.address);
	}
	
	public function setStream(_val:Bool):Void
	{
		data.writeBool(address + stream.address, _val);
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
	}
	
	public function getVolume():Int
	{
		return data.readInt(address + volume.address);
	}
	
	public function setVolume(_val:Int):Void
	{
		data.writeInt(address + volume.address, _val);
	}
	
}
