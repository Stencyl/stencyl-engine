package com.stencyl.io.mbs.scene.layers;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsLayer extends MbsObject
{
	public static var id:MbsField;
	public static var name:MbsField;
	public static var order:MbsField;
	public static var opacity:MbsField;
	public static var blendmode:MbsField;
	public static var scrollFactorX:MbsField;
	public static var scrollFactorY:MbsField;
	public static var visible:MbsField;
	public static var locked:MbsField;
	
	public static var MBS_LAYER:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_LAYER != null) return;
		MBS_LAYER = new ComposedType("MbsLayer");
		MBS_LAYER.setInstantiator(function(data) return new MbsLayer(data));
		
		id = MBS_LAYER.createField("id", INTEGER);
		name = MBS_LAYER.createField("name", STRING);
		order = MBS_LAYER.createField("order", INTEGER);
		opacity = MBS_LAYER.createField("opacity", INTEGER);
		blendmode = MBS_LAYER.createField("blendmode", STRING);
		scrollFactorX = MBS_LAYER.createField("scrollFactorX", FLOAT);
		scrollFactorY = MBS_LAYER.createField("scrollFactorY", FLOAT);
		visible = MBS_LAYER.createField("visible", BOOLEAN);
		locked = MBS_LAYER.createField("locked", BOOLEAN);
		
	}
	
	public static function new_MbsLayer_list(data:MbsIO):MbsList<MbsLayer>
	{
		return new MbsList<MbsLayer>(data, MBS_LAYER, new MbsLayer(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_LAYER;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_LAYER.getSize()));
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
	
	public function getOrder():Int
	{
		return data.readInt(address + order.address);
	}
	
	public function setOrder(_val:Int):Void
	{
		data.writeInt(address + order.address, _val);
	}
	
	public function getOpacity():Int
	{
		return data.readInt(address + opacity.address);
	}
	
	public function setOpacity(_val:Int):Void
	{
		data.writeInt(address + opacity.address, _val);
	}
	
	public function getBlendmode():String
	{
		return data.readString(address + blendmode.address);
	}
	
	public function setBlendmode(_val:String):Void
	{
		data.writeString(address + blendmode.address, _val);
	}
	
	public function getScrollFactorX():Float
	{
		return data.readFloat(address + scrollFactorX.address);
	}
	
	public function setScrollFactorX(_val:Float):Void
	{
		data.writeFloat(address + scrollFactorX.address, _val);
	}
	
	public function getScrollFactorY():Float
	{
		return data.readFloat(address + scrollFactorY.address);
	}
	
	public function setScrollFactorY(_val:Float):Void
	{
		data.writeFloat(address + scrollFactorY.address, _val);
	}
	
	public function getVisible():Bool
	{
		return data.readBool(address + visible.address);
	}
	
	public function setVisible(_val:Bool):Void
	{
		data.writeBool(address + visible.address, _val);
	}
	
	public function getLocked():Bool
	{
		return data.readBool(address + locked.address);
	}
	
	public function setLocked(_val:Bool):Void
	{
		data.writeBool(address + locked.address, _val);
	}
	
}
