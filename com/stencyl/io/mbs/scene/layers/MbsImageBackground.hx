package com.stencyl.io.mbs.scene.layers;

import com.stencyl.io.mbs.scene.layers.MbsLayer;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsImageBackground extends MbsLayer
{
	public static var resourceID:MbsField;
	public static var customScroll:MbsField;
	
	public static var MBS_IMAGE_BACKGROUND:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_IMAGE_BACKGROUND != null) return;
		MbsLayer.initializeType();
		
		MBS_IMAGE_BACKGROUND = new ComposedType("MbsImageBackground");
		MBS_IMAGE_BACKGROUND.setInstantiator(function(data) return new MbsImageBackground(data));
		MBS_IMAGE_BACKGROUND.inherit(MbsLayer.MBS_LAYER);
		
		resourceID = MBS_IMAGE_BACKGROUND.createField("resourceID", INTEGER);
		customScroll = MBS_IMAGE_BACKGROUND.createField("customScroll", BOOLEAN);
		
	}
	
	public static function new_MbsImageBackground_list(data:MbsIO):MbsList<MbsImageBackground>
	{
		return new MbsList<MbsImageBackground>(data, MBS_IMAGE_BACKGROUND, new MbsImageBackground(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_IMAGE_BACKGROUND;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_IMAGE_BACKGROUND.getSize()));
	}
	
	public function getResourceID():Int
	{
		return data.readInt(address + resourceID.address);
	}
	
	public function setResourceID(_val:Int):Void
	{
		data.writeInt(address + resourceID.address, _val);
	}
	
	public function getCustomScroll():Bool
	{
		return data.readBool(address + customScroll.address);
	}
	
	public function setCustomScroll(_val:Bool):Void
	{
		data.writeBool(address + customScroll.address, _val);
	}
	
}
