package com.stencyl.io.mbs.scene;

import com.stencyl.io.mbs.snippet.MbsSnippet;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsActorInstance extends MbsObject
{
	public static var angle:MbsField;
	public static var aid:MbsField;
	public static var customized:MbsField;
	public static var groupID:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	public static var scaleX:MbsField;
	public static var scaleY:MbsField;
	public static var x:MbsField;
	public static var y:MbsField;
	public static var z:MbsField;
	public static var snippets:MbsField;
	
	public static var MBS_ACTOR_INSTANCE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_ACTOR_INSTANCE != null) return;
		MBS_ACTOR_INSTANCE = new ComposedType("MbsActorInstance");
		MBS_ACTOR_INSTANCE.setInstantiator(function(data) return new MbsActorInstance(data));
		
		angle = MBS_ACTOR_INSTANCE.createField("angle", FLOAT);
		aid = MBS_ACTOR_INSTANCE.createField("aid", INTEGER);
		customized = MBS_ACTOR_INSTANCE.createField("customized", BOOLEAN);
		groupID = MBS_ACTOR_INSTANCE.createField("groupID", INTEGER);
		id = MBS_ACTOR_INSTANCE.createField("id", INTEGER);
		name = MBS_ACTOR_INSTANCE.createField("name", STRING);
		scaleX = MBS_ACTOR_INSTANCE.createField("scaleX", FLOAT);
		scaleY = MBS_ACTOR_INSTANCE.createField("scaleY", FLOAT);
		x = MBS_ACTOR_INSTANCE.createField("x", INTEGER);
		y = MBS_ACTOR_INSTANCE.createField("y", INTEGER);
		z = MBS_ACTOR_INSTANCE.createField("z", INTEGER);
		snippets = MBS_ACTOR_INSTANCE.createField("snippets", LIST);
		
	}
	
	public static function new_MbsActorInstance_list(data:MbsIO):MbsList<MbsActorInstance>
	{
		return new MbsList<MbsActorInstance>(data, MBS_ACTOR_INSTANCE, new MbsActorInstance(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_ACTOR_INSTANCE;
	}
	
	private var _snippets:MbsList<MbsSnippet>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_snippets = new MbsList<MbsSnippet>(data, MbsSnippet.MBS_SNIPPET, new MbsSnippet(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_ACTOR_INSTANCE.getSize()));
	}
	
	public function getAngle():Float
	{
		return data.readFloat(address + angle.address);
	}
	
	public function setAngle(_val:Float):Void
	{
		data.writeFloat(address + angle.address, _val);
	}
	
	public function getAid():Int
	{
		return data.readInt(address + aid.address);
	}
	
	public function setAid(_val:Int):Void
	{
		data.writeInt(address + aid.address, _val);
	}
	
	public function getCustomized():Bool
	{
		return data.readBool(address + customized.address);
	}
	
	public function setCustomized(_val:Bool):Void
	{
		data.writeBool(address + customized.address, _val);
	}
	
	public function getGroupID():Int
	{
		return data.readInt(address + groupID.address);
	}
	
	public function setGroupID(_val:Int):Void
	{
		data.writeInt(address + groupID.address, _val);
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
	
	public function getScaleX():Float
	{
		return data.readFloat(address + scaleX.address);
	}
	
	public function setScaleX(_val:Float):Void
	{
		data.writeFloat(address + scaleX.address, _val);
	}
	
	public function getScaleY():Float
	{
		return data.readFloat(address + scaleY.address);
	}
	
	public function setScaleY(_val:Float):Void
	{
		data.writeFloat(address + scaleY.address, _val);
	}
	
	public function getX():Int
	{
		return data.readInt(address + x.address);
	}
	
	public function setX(_val:Int):Void
	{
		data.writeInt(address + x.address, _val);
	}
	
	public function getY():Int
	{
		return data.readInt(address + y.address);
	}
	
	public function setY(_val:Int):Void
	{
		data.writeInt(address + y.address, _val);
	}
	
	public function getZ():Int
	{
		return data.readInt(address + z.address);
	}
	
	public function setZ(_val:Int):Void
	{
		data.writeInt(address + z.address, _val);
	}
	
	public function getSnippets():MbsList<MbsSnippet>
	{
		_snippets.setAddress(address + snippets.address);
		return _snippets;
	}
	
	public function createSnippets(_length:Int):MbsList<MbsSnippet>
	{
		_snippets.allocateNew(_length);
		data.writeInt(address + snippets.address, _snippets.getAddress());
		return _snippets;
	}
	
}
