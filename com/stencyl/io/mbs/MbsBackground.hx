package com.stencyl.io.mbs;

import com.stencyl.io.mbs.MbsResource;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsIntList;

class MbsBackground extends MbsResource
{
	public static var durations:MbsField;
	public static var height:MbsField;
	public static var numFrames:MbsField;
	public static var repeats:MbsField;
	public static var resized:MbsField;
	public static var width:MbsField;
	public static var xParallaxFactor:MbsField;
	public static var xVelocity:MbsField;
	public static var yParallaxFactor:MbsField;
	public static var yVelocity:MbsField;
	
	public static var MBS_BACKGROUND:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_BACKGROUND != null) return;
		MbsResource.initializeType();
		
		MBS_BACKGROUND = new ComposedType("MbsBackground");
		MBS_BACKGROUND.setInstantiator(function(data) return new MbsBackground(data));
		MBS_BACKGROUND.inherit(MbsResource.MBS_RESOURCE);
		
		durations = MBS_BACKGROUND.createField("durations", LIST);
		height = MBS_BACKGROUND.createField("height", INTEGER);
		numFrames = MBS_BACKGROUND.createField("numFrames", INTEGER);
		repeats = MBS_BACKGROUND.createField("repeats", BOOLEAN);
		resized = MBS_BACKGROUND.createField("resized", BOOLEAN);
		width = MBS_BACKGROUND.createField("width", INTEGER);
		xParallaxFactor = MBS_BACKGROUND.createField("xParallaxFactor", FLOAT);
		xVelocity = MBS_BACKGROUND.createField("xVelocity", FLOAT);
		yParallaxFactor = MBS_BACKGROUND.createField("yParallaxFactor", FLOAT);
		yVelocity = MBS_BACKGROUND.createField("yVelocity", FLOAT);
		
	}
	
	public static function new_MbsBackground_list(data:MbsIO):MbsList<MbsBackground>
	{
		return new MbsList<MbsBackground>(data, MBS_BACKGROUND, new MbsBackground(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_BACKGROUND;
	}
	
	private var _durations:MbsIntList;
	
	public function new(data:MbsIO)
	{
		super(data);
		_durations = new MbsIntList(data);
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_BACKGROUND.getSize()));
	}
	
	public function getDurations():MbsIntList
	{
		_durations.setAddress(data.readInt(address + durations.address));
		return _durations;
	}
	
	public function createDurations(_length:Int):MbsIntList
	{
		_durations.allocateNew(_length);
		data.writeInt(address + durations.address, _durations.getAddress());
		return _durations;
	}
	
	public function getHeight():Int
	{
		return data.readInt(address + height.address);
	}
	
	public function setHeight(_val:Int):Void
	{
		data.writeInt(address + height.address, _val);
	}
	
	public function getNumFrames():Int
	{
		return data.readInt(address + numFrames.address);
	}
	
	public function setNumFrames(_val:Int):Void
	{
		data.writeInt(address + numFrames.address, _val);
	}
	
	public function getRepeats():Bool
	{
		return data.readBool(address + repeats.address);
	}
	
	public function setRepeats(_val:Bool):Void
	{
		data.writeBool(address + repeats.address, _val);
	}
	
	public function getResized():Bool
	{
		return data.readBool(address + resized.address);
	}
	
	public function setResized(_val:Bool):Void
	{
		data.writeBool(address + resized.address, _val);
	}
	
	public function getWidth():Int
	{
		return data.readInt(address + width.address);
	}
	
	public function setWidth(_val:Int):Void
	{
		data.writeInt(address + width.address, _val);
	}
	
	public function getXParallaxFactor():Float
	{
		return data.readFloat(address + xParallaxFactor.address);
	}
	
	public function setXParallaxFactor(_val:Float):Void
	{
		data.writeFloat(address + xParallaxFactor.address, _val);
	}
	
	public function getXVelocity():Float
	{
		return data.readFloat(address + xVelocity.address);
	}
	
	public function setXVelocity(_val:Float):Void
	{
		data.writeFloat(address + xVelocity.address, _val);
	}
	
	public function getYParallaxFactor():Float
	{
		return data.readFloat(address + yParallaxFactor.address);
	}
	
	public function setYParallaxFactor(_val:Float):Void
	{
		data.writeFloat(address + yParallaxFactor.address, _val);
	}
	
	public function getYVelocity():Float
	{
		return data.readFloat(address + yVelocity.address);
	}
	
	public function setYVelocity(_val:Float):Void
	{
		data.writeFloat(address + yVelocity.address, _val);
	}
	
}
