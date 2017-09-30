package com.stencyl.io.mbs.scene.layers;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsGradientBackground extends MbsObject
{
	public static var color1:MbsField;
	public static var color2:MbsField;
	
	public static var MBS_GRADIENT_BACKGROUND:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_GRADIENT_BACKGROUND != null) return;
		MBS_GRADIENT_BACKGROUND = new ComposedType("MbsGradientBackground");
		MBS_GRADIENT_BACKGROUND.setInstantiator(function(data) return new MbsGradientBackground(data));
		
		color1 = MBS_GRADIENT_BACKGROUND.createField("color1", INTEGER);
		color2 = MBS_GRADIENT_BACKGROUND.createField("color2", INTEGER);
		
	}
	
	public static function new_MbsGradientBackground_list(data:MbsIO):MbsList<MbsGradientBackground>
	{
		return new MbsList<MbsGradientBackground>(data, MBS_GRADIENT_BACKGROUND, new MbsGradientBackground(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_GRADIENT_BACKGROUND;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_GRADIENT_BACKGROUND.getSize()));
	}
	
	public function getColor1():Int
	{
		return data.readInt(address + color1.address);
	}
	
	public function setColor1(_val:Int):Void
	{
		data.writeInt(address + color1.address, _val);
	}
	
	public function getColor2():Int
	{
		return data.readInt(address + color2.address);
	}
	
	public function setColor2(_val:Int):Void
	{
		data.writeInt(address + color2.address, _val);
	}
	
}
