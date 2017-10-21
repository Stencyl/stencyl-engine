package com.stencyl.io.mbs.game;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsCollisionPair extends MbsObject
{
	public static var group1:MbsField;
	public static var group2:MbsField;
	
	public static var MBS_COLLISION_PAIR:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_COLLISION_PAIR != null) return;
		MBS_COLLISION_PAIR = new ComposedType("MbsCollisionPair");
		MBS_COLLISION_PAIR.setInstantiator(function(data) return new MbsCollisionPair(data));
		
		group1 = MBS_COLLISION_PAIR.createField("group1", INTEGER);
		group2 = MBS_COLLISION_PAIR.createField("group2", INTEGER);
		
	}
	
	public static function new_MbsCollisionPair_list(data:MbsIO):MbsList<MbsCollisionPair>
	{
		return new MbsList<MbsCollisionPair>(data, MBS_COLLISION_PAIR, new MbsCollisionPair(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_COLLISION_PAIR;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_COLLISION_PAIR.getSize()));
	}
	
	public function getGroup1():Int
	{
		return data.readInt(address + group1.address);
	}
	
	public function setGroup1(_val:Int):Void
	{
		data.writeInt(address + group1.address, _val);
	}
	
	public function getGroup2():Int
	{
		return data.readInt(address + group2.address);
	}
	
	public function setGroup2(_val:Int):Void
	{
		data.writeInt(address + group2.address, _val);
	}
	
}
