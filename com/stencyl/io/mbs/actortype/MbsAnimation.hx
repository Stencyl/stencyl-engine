package com.stencyl.io.mbs.actortype;

import com.stencyl.io.mbs.actortype.MbsAnimShape;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsIntList;

class MbsAnimation extends MbsObject
{
	public static var across:MbsField;
	public static var down:MbsField;
	public static var durations:MbsField;
	public static var height:MbsField;
	public static var id:MbsField;
	public static var loop:MbsField;
	public static var name:MbsField;
	public static var numFrames:MbsField;
	public static var originX:MbsField;
	public static var originY:MbsField;
	public static var sync:MbsField;
	public static var version:MbsField;
	public static var width:MbsField;
	public static var shapes:MbsField;
	
	public static var MBS_ANIMATION:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_ANIMATION != null) return;
		MBS_ANIMATION = new ComposedType("MbsAnimation");
		MBS_ANIMATION.setInstantiator(function(data) return new MbsAnimation(data));
		
		across = MBS_ANIMATION.createField("across", INTEGER);
		down = MBS_ANIMATION.createField("down", INTEGER);
		durations = MBS_ANIMATION.createField("durations", LIST);
		height = MBS_ANIMATION.createField("height", INTEGER);
		id = MBS_ANIMATION.createField("id", INTEGER);
		loop = MBS_ANIMATION.createField("loop", BOOLEAN);
		name = MBS_ANIMATION.createField("name", STRING);
		numFrames = MBS_ANIMATION.createField("numFrames", INTEGER);
		originX = MBS_ANIMATION.createField("originX", INTEGER);
		originY = MBS_ANIMATION.createField("originY", INTEGER);
		sync = MBS_ANIMATION.createField("sync", BOOLEAN);
		version = MBS_ANIMATION.createField("version", INTEGER);
		width = MBS_ANIMATION.createField("width", INTEGER);
		shapes = MBS_ANIMATION.createField("shapes", LIST);
		
	}
	
	public static function new_MbsAnimation_list(data:MbsIO):MbsList<MbsAnimation>
	{
		return new MbsList<MbsAnimation>(data, MBS_ANIMATION, new MbsAnimation(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_ANIMATION;
	}
	
	private var _durations:MbsIntList;
	private var _shapes:MbsList<MbsAnimShape>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_durations = new MbsIntList(data);
		_shapes = new MbsList<MbsAnimShape>(data, MbsAnimShape.MBS_ANIM_SHAPE, new MbsAnimShape(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_ANIMATION.getSize()));
	}
	
	public function getAcross():Int
	{
		return data.readInt(address + across.address);
	}
	
	public function setAcross(_val:Int):Void
	{
		data.writeInt(address + across.address, _val);
	}
	
	public function getDown():Int
	{
		return data.readInt(address + down.address);
	}
	
	public function setDown(_val:Int):Void
	{
		data.writeInt(address + down.address, _val);
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
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getLoop():Bool
	{
		return data.readBool(address + loop.address);
	}
	
	public function setLoop(_val:Bool):Void
	{
		data.writeBool(address + loop.address, _val);
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getNumFrames():Int
	{
		return data.readInt(address + numFrames.address);
	}
	
	public function setNumFrames(_val:Int):Void
	{
		data.writeInt(address + numFrames.address, _val);
	}
	
	public function getOriginX():Int
	{
		return data.readInt(address + originX.address);
	}
	
	public function setOriginX(_val:Int):Void
	{
		data.writeInt(address + originX.address, _val);
	}
	
	public function getOriginY():Int
	{
		return data.readInt(address + originY.address);
	}
	
	public function setOriginY(_val:Int):Void
	{
		data.writeInt(address + originY.address, _val);
	}
	
	public function getSync():Bool
	{
		return data.readBool(address + sync.address);
	}
	
	public function setSync(_val:Bool):Void
	{
		data.writeBool(address + sync.address, _val);
	}
	
	public function getVersion():Int
	{
		return data.readInt(address + version.address);
	}
	
	public function setVersion(_val:Int):Void
	{
		data.writeInt(address + version.address, _val);
	}
	
	public function getWidth():Int
	{
		return data.readInt(address + width.address);
	}
	
	public function setWidth(_val:Int):Void
	{
		data.writeInt(address + width.address, _val);
	}
	
	public function getShapes():MbsList<MbsAnimShape>
	{
		_shapes.setAddress(data.readInt(address + shapes.address));
		return _shapes;
	}
	
	public function createShapes(_length:Int):MbsList<MbsAnimShape>
	{
		_shapes.allocateNew(_length);
		data.writeInt(address + shapes.address, _shapes.getAddress());
		return _shapes;
	}
	
}
