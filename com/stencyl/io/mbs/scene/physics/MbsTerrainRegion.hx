package com.stencyl.io.mbs.scene.physics;

import com.stencyl.io.mbs.scene.physics.MbsRegion;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsTerrainRegion extends MbsRegion
{
	public static var groupID:MbsField;
	
	public static var MBS_TERRAIN_REGION:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_TERRAIN_REGION != null) return;
		MbsRegion.initializeType();
		
		MBS_TERRAIN_REGION = new ComposedType("MbsTerrainRegion");
		MBS_TERRAIN_REGION.setInstantiator(function(data) return new MbsTerrainRegion(data));
		MBS_TERRAIN_REGION.inherit(MbsRegion.MBS_REGION);
		
		groupID = MBS_TERRAIN_REGION.createField("groupID", INTEGER);
		
	}
	
	public static function new_MbsTerrainRegion_list(data:MbsIO):MbsList<MbsTerrainRegion>
	{
		return new MbsList<MbsTerrainRegion>(data, MBS_TERRAIN_REGION, new MbsTerrainRegion(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_TERRAIN_REGION;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_TERRAIN_REGION.getSize()));
	}
	
	public function getGroupID():Int
	{
		return data.readInt(address + groupID.address);
	}
	
	public function setGroupID(_val:Int):Void
	{
		data.writeInt(address + groupID.address, _val);
	}
	
}
