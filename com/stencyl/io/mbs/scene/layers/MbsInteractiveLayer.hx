package com.stencyl.io.mbs.scene.layers;

import com.stencyl.io.mbs.scene.layers.MbsLayer;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsInteractiveLayer extends MbsLayer
{
	public static var color:MbsField;
	
	public static var MBS_INTERACTIVE_LAYER:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_INTERACTIVE_LAYER != null) return;
		MbsLayer.initializeType();
		
		MBS_INTERACTIVE_LAYER = new ComposedType("MbsInteractiveLayer");
		MBS_INTERACTIVE_LAYER.setInstantiator(function(data) return new MbsInteractiveLayer(data));
		MBS_INTERACTIVE_LAYER.inherit(MbsLayer.MBS_LAYER);
		
		color = MBS_INTERACTIVE_LAYER.createField("color", INTEGER);
		
	}
	
	public static function new_MbsInteractiveLayer_list(data:MbsIO):MbsList<MbsInteractiveLayer>
	{
		return new MbsList<MbsInteractiveLayer>(data, MBS_INTERACTIVE_LAYER, new MbsInteractiveLayer(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_INTERACTIVE_LAYER;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_INTERACTIVE_LAYER.getSize()));
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
