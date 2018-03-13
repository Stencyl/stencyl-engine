package com.stencyl.io.mbs.actortype;

import com.stencyl.io.mbs.MbsResource;
import com.stencyl.io.mbs.actortype.MbsAnimation;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsSprite extends MbsResource
{
	public static var defaultAnimation:MbsField;
	public static var readableImages:MbsField;
	public static var height:MbsField;
	public static var width:MbsField;
	public static var animations:MbsField;
	
	public static var MBS_SPRITE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_SPRITE != null) return;
		MbsResource.initializeType();
		
		MBS_SPRITE = new ComposedType("MbsSprite");
		MBS_SPRITE.setInstantiator(function(data) return new MbsSprite(data));
		MBS_SPRITE.inherit(MbsResource.MBS_RESOURCE);
		
		defaultAnimation = MBS_SPRITE.createField("defaultAnimation", INTEGER);
		readableImages = MBS_SPRITE.createField("readableImages", BOOLEAN);
		height = MBS_SPRITE.createField("height", INTEGER);
		width = MBS_SPRITE.createField("width", INTEGER);
		animations = MBS_SPRITE.createField("animations", LIST);
		
	}
	
	public static function new_MbsSprite_list(data:MbsIO):MbsList<MbsSprite>
	{
		return new MbsList<MbsSprite>(data, MBS_SPRITE, new MbsSprite(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_SPRITE;
	}
	
	private var _animations:MbsList<MbsAnimation>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_animations = new MbsList<MbsAnimation>(data, MbsAnimation.MBS_ANIMATION, new MbsAnimation(data));
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_SPRITE.getSize()));
	}
	
	public function getDefaultAnimation():Int
	{
		return data.readInt(address + defaultAnimation.address);
	}
	
	public function setDefaultAnimation(_val:Int):Void
	{
		data.writeInt(address + defaultAnimation.address, _val);
	}
	
	public function getReadableImages():Bool
	{
		return data.readBool(address + readableImages.address);
	}
	
	public function setReadableImages(_val:Bool):Void
	{
		data.writeBool(address + readableImages.address, _val);
	}
	
	public function getHeight():Int
	{
		return data.readInt(address + height.address);
	}
	
	public function setHeight(_val:Int):Void
	{
		data.writeInt(address + height.address, _val);
	}
	
	public function getWidth():Int
	{
		return data.readInt(address + width.address);
	}
	
	public function setWidth(_val:Int):Void
	{
		data.writeInt(address + width.address, _val);
	}
	
	public function getAnimations():MbsList<MbsAnimation>
	{
		_animations.setAddress(data.readInt(address + animations.address));
		return _animations;
	}
	
	public function createAnimations(_length:Int):MbsList<MbsAnimation>
	{
		_animations.allocateNew(_length);
		data.writeInt(address + animations.address, _animations.getAddress());
		return _animations;
	}
	
}
