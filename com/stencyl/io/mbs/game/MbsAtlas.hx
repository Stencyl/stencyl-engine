package com.stencyl.io.mbs.game;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsIntList;

class MbsAtlas extends MbsObject
{
	public static var id:MbsField;
	public static var name:MbsField;
	public static var members:MbsField;
	public static var allScenes:MbsField;
	
	public static var MBS_ATLAS:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_ATLAS != null) return;
		MBS_ATLAS = new ComposedType("MbsAtlas");
		MBS_ATLAS.setInstantiator(function(data) return new MbsAtlas(data));
		
		id = MBS_ATLAS.createField("id", INTEGER);
		name = MBS_ATLAS.createField("name", STRING);
		members = MBS_ATLAS.createField("members", LIST);
		allScenes = MBS_ATLAS.createField("allScenes", BOOLEAN);
		
	}
	
	public static function new_MbsAtlas_list(data:MbsIO):MbsList<MbsAtlas>
	{
		return new MbsList<MbsAtlas>(data, MBS_ATLAS, new MbsAtlas(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_ATLAS;
	}
	
	private var _members:MbsIntList;
	
	public function new(data:MbsIO)
	{
		super(data);
		_members = new MbsIntList(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_ATLAS.getSize()));
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getMembers():MbsIntList
	{
		_members.setAddress(data.readInt(address + members.address));
		return _members;
	}
	
	public function createMembers(_length:Int):MbsIntList
	{
		_members.allocateNew(_length);
		data.writeInt(address + members.address, _members.getAddress());
		return _members;
	}
	
	public function getAllScenes():Bool
	{
		return data.readBool(address + allScenes.address);
	}
	
	public function setAllScenes(_val:Bool):Void
	{
		data.writeBool(address + allScenes.address, _val);
	}
	
}
