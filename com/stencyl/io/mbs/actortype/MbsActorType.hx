package com.stencyl.io.mbs.actortype;

import com.stencyl.io.mbs.MbsResource;
import com.stencyl.io.mbs.snippet.MbsSnippet;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsActorType extends MbsResource
{
	public static var angularDamping:MbsField;
	public static var autoScale:MbsField;
	public static var bodyType:MbsField;
	public static var continuous:MbsField;
	public static var eventSnippetID:MbsField;
	public static var fixedRotation:MbsField;
	public static var friction:MbsField;
	public static var groupID:MbsField;
	public static var ignoreGravity:MbsField;
	public static var inertia:MbsField;
	public static var linearDamping:MbsField;
	public static var mass:MbsField;
	public static var pausable:MbsField;
	public static var physicsMode:MbsField;
	public static var restitution:MbsField;
	public static var sprite:MbsField;
	public static var isStatic:MbsField;
	public static var snippets:MbsField;
	
	public static var MBS_ACTOR_TYPE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_ACTOR_TYPE != null) return;
		MbsResource.initializeType();
		
		MBS_ACTOR_TYPE = new ComposedType("MbsActorType");
		MBS_ACTOR_TYPE.setInstantiator(function(data) return new MbsActorType(data));
		MBS_ACTOR_TYPE.inherit(MbsResource.MBS_RESOURCE);
		
		angularDamping = MBS_ACTOR_TYPE.createField("angularDamping", FLOAT);
		autoScale = MBS_ACTOR_TYPE.createField("autoScale", BOOLEAN);
		bodyType = MBS_ACTOR_TYPE.createField("bodyType", INTEGER);
		continuous = MBS_ACTOR_TYPE.createField("continuous", BOOLEAN);
		eventSnippetID = MBS_ACTOR_TYPE.createField("eventSnippetID", INTEGER);
		fixedRotation = MBS_ACTOR_TYPE.createField("fixedRotation", BOOLEAN);
		friction = MBS_ACTOR_TYPE.createField("friction", FLOAT);
		groupID = MBS_ACTOR_TYPE.createField("groupID", INTEGER);
		ignoreGravity = MBS_ACTOR_TYPE.createField("ignoreGravity", BOOLEAN);
		inertia = MBS_ACTOR_TYPE.createField("inertia", FLOAT);
		linearDamping = MBS_ACTOR_TYPE.createField("linearDamping", FLOAT);
		mass = MBS_ACTOR_TYPE.createField("mass", FLOAT);
		pausable = MBS_ACTOR_TYPE.createField("pausable", BOOLEAN);
		physicsMode = MBS_ACTOR_TYPE.createField("physicsMode", INTEGER);
		restitution = MBS_ACTOR_TYPE.createField("restitution", FLOAT);
		sprite = MBS_ACTOR_TYPE.createField("sprite", INTEGER);
		isStatic = MBS_ACTOR_TYPE.createField("isStatic", BOOLEAN);
		snippets = MBS_ACTOR_TYPE.createField("snippets", LIST);
		
	}
	
	public static function new_MbsActorType_list(data:MbsIO):MbsList<MbsActorType>
	{
		return new MbsList<MbsActorType>(data, MBS_ACTOR_TYPE, new MbsActorType(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_ACTOR_TYPE;
	}
	
	private var _snippets:MbsList<MbsSnippet>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_snippets = new MbsList<MbsSnippet>(data, MbsSnippet.MBS_SNIPPET, new MbsSnippet(data));
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_ACTOR_TYPE.getSize()));
	}
	
	public function getAngularDamping():Float
	{
		return data.readFloat(address + angularDamping.address);
	}
	
	public function setAngularDamping(_val:Float):Void
	{
		data.writeFloat(address + angularDamping.address, _val);
	}
	
	public function getAutoScale():Bool
	{
		return data.readBool(address + autoScale.address);
	}
	
	public function setAutoScale(_val:Bool):Void
	{
		data.writeBool(address + autoScale.address, _val);
	}
	
	public function getBodyType():Int
	{
		return data.readInt(address + bodyType.address);
	}
	
	public function setBodyType(_val:Int):Void
	{
		data.writeInt(address + bodyType.address, _val);
	}
	
	public function getContinuous():Bool
	{
		return data.readBool(address + continuous.address);
	}
	
	public function setContinuous(_val:Bool):Void
	{
		data.writeBool(address + continuous.address, _val);
	}
	
	public function getEventSnippetID():Int
	{
		return data.readInt(address + eventSnippetID.address);
	}
	
	public function setEventSnippetID(_val:Int):Void
	{
		data.writeInt(address + eventSnippetID.address, _val);
	}
	
	public function getFixedRotation():Bool
	{
		return data.readBool(address + fixedRotation.address);
	}
	
	public function setFixedRotation(_val:Bool):Void
	{
		data.writeBool(address + fixedRotation.address, _val);
	}
	
	public function getFriction():Float
	{
		return data.readFloat(address + friction.address);
	}
	
	public function setFriction(_val:Float):Void
	{
		data.writeFloat(address + friction.address, _val);
	}
	
	public function getGroupID():Int
	{
		return data.readInt(address + groupID.address);
	}
	
	public function setGroupID(_val:Int):Void
	{
		data.writeInt(address + groupID.address, _val);
	}
	
	public function getIgnoreGravity():Bool
	{
		return data.readBool(address + ignoreGravity.address);
	}
	
	public function setIgnoreGravity(_val:Bool):Void
	{
		data.writeBool(address + ignoreGravity.address, _val);
	}
	
	public function getInertia():Float
	{
		return data.readFloat(address + inertia.address);
	}
	
	public function setInertia(_val:Float):Void
	{
		data.writeFloat(address + inertia.address, _val);
	}
	
	public function getLinearDamping():Float
	{
		return data.readFloat(address + linearDamping.address);
	}
	
	public function setLinearDamping(_val:Float):Void
	{
		data.writeFloat(address + linearDamping.address, _val);
	}
	
	public function getMass():Float
	{
		return data.readFloat(address + mass.address);
	}
	
	public function setMass(_val:Float):Void
	{
		data.writeFloat(address + mass.address, _val);
	}
	
	public function getPausable():Bool
	{
		return data.readBool(address + pausable.address);
	}
	
	public function setPausable(_val:Bool):Void
	{
		data.writeBool(address + pausable.address, _val);
	}
	
	public function getPhysicsMode():Int
	{
		return data.readInt(address + physicsMode.address);
	}
	
	public function setPhysicsMode(_val:Int):Void
	{
		data.writeInt(address + physicsMode.address, _val);
	}
	
	public function getRestitution():Float
	{
		return data.readFloat(address + restitution.address);
	}
	
	public function setRestitution(_val:Float):Void
	{
		data.writeFloat(address + restitution.address, _val);
	}
	
	public function getSprite():Int
	{
		return data.readInt(address + sprite.address);
	}
	
	public function setSprite(_val:Int):Void
	{
		data.writeInt(address + sprite.address, _val);
	}
	
	public function getIsStatic():Bool
	{
		return data.readBool(address + isStatic.address);
	}
	
	public function setIsStatic(_val:Bool):Void
	{
		data.writeBool(address + isStatic.address, _val);
	}
	
	public function getSnippets():MbsList<MbsSnippet>
	{
		_snippets.setAddress(data.readInt(address + snippets.address));
		return _snippets;
	}
	
	public function createSnippets(_length:Int):MbsList<MbsSnippet>
	{
		_snippets.allocateNew(_length);
		data.writeInt(address + snippets.address, _snippets.getAddress());
		return _snippets;
	}
	
}
