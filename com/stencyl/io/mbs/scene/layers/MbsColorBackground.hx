package com.stencyl.io.mbs.scene.layers;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsColorBackground extends MbsObject
{
	public static var color:MbsField;
	
	public static var MBS_COLOR_BACKGROUND:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_COLOR_BACKGROUND != null) return;
		MBS_COLOR_BACKGROUND = new ComposedType("MbsColorBackground");
		MBS_COLOR_BACKGROUND.setInstantiator(function(data) return new MbsColorBackground(data));
		
		color = MBS_COLOR_BACKGROUND.createField("color", INTEGER);
		
	}
	
	public static function new_MbsColorBackground_list(data:MbsIO):MbsList<MbsColorBackground>
	{
		return new MbsList<MbsColorBackground>(data, MBS_COLOR_BACKGROUND, new MbsColorBackground(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_COLOR_BACKGROUND;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_COLOR_BACKGROUND.getSize()));
	}
	
	public function getColor():Int
	{
		return data.readInt(address + color.address);
	}
	
	public function setColor(_val:Int):Void
	{
		data.writeInt(address + color.address, _val);
	}
	
}
