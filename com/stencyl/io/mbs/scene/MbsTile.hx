package com.stencyl.io.mbs.scene;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsIntList;

class MbsTile extends MbsObject
{
	public static var collision:MbsField;
	public static var metadata:MbsField;
	public static var durations:MbsField;
	public static var frames:MbsField;
	public static var id:MbsField;
	public static var order:MbsField;
	public static var autotile:MbsField;
	public static var autotileMerge:MbsField;
	
	public static var MBS_TILE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_TILE != null) return;
		MBS_TILE = new ComposedType("MbsTile");
		MBS_TILE.setInstantiator(function(data) return new MbsTile(data));
		
		collision = MBS_TILE.createField("collision", INTEGER);
		metadata = MBS_TILE.createField("metadata", STRING);
		durations = MBS_TILE.createField("durations", LIST);
		frames = MBS_TILE.createField("frames", INTEGER);
		id = MBS_TILE.createField("id", INTEGER);
		order = MBS_TILE.createField("order", INTEGER);
		autotile = MBS_TILE.createField("autotile", INTEGER);
		autotileMerge = MBS_TILE.createField("autotileMerge", LIST);
		
	}
	
	public static function new_MbsTile_list(data:MbsIO):MbsList<MbsTile>
	{
		return new MbsList<MbsTile>(data, MBS_TILE, new MbsTile(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_TILE;
	}
	
	private var _durations:MbsIntList;
	private var _autotileMerge:MbsIntList;
	
	public function new(data:MbsIO)
	{
		super(data);
		_durations = new MbsIntList(data);
		_autotileMerge = new MbsIntList(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_TILE.getSize()));
	}
	
	public function getCollision():Int
	{
		return data.readInt(address + collision.address);
	}
	
	public function setCollision(_val:Int):Void
	{
		data.writeInt(address + collision.address, _val);
	}
	
	public function getMetadata():String
	{
		return data.readString(address + metadata.address);
	}
	
	public function setMetadata(_val:String):Void
	{
		data.writeString(address + metadata.address, _val);
	}
	
	public function getDurations():MbsIntList
	{
		_durations.setAddress(address + durations.address);
		return _durations;
	}
	
	public function createDurations(_length:Int):MbsIntList
	{
		_durations.allocateNew(_length);
		data.writeInt(address + durations.address, _durations.getAddress());
		return _durations;
	}
	
	public function getFrames():Int
	{
		return data.readInt(address + frames.address);
	}
	
	public function setFrames(_val:Int):Void
	{
		data.writeInt(address + frames.address, _val);
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getOrder():Int
	{
		return data.readInt(address + order.address);
	}
	
	public function setOrder(_val:Int):Void
	{
		data.writeInt(address + order.address, _val);
	}
	
	public function getAutotile():Int
	{
		return data.readInt(address + autotile.address);
	}
	
	public function setAutotile(_val:Int):Void
	{
		data.writeInt(address + autotile.address, _val);
	}
	
	public function getAutotileMerge():MbsIntList
	{
		_autotileMerge.setAddress(address + autotileMerge.address);
		return _autotileMerge;
	}
	
	public function createAutotileMerge(_length:Int):MbsIntList
	{
		_autotileMerge.allocateNew(_length);
		data.writeInt(address + autotileMerge.address, _autotileMerge.getAddress());
		return _autotileMerge;
	}
	
}
