package com.stencyl.io.mbs.snippet;

import com.stencyl.io.mbs.snippet.MbsAttributeDef;
import com.stencyl.io.mbs.snippet.MbsBlock;
import com.stencyl.io.mbs.snippet.MbsEvent;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsSnippetDef extends MbsObject
{
	public static var attachedEvent:MbsField;
	public static var actorID:MbsField;
	public static var classname:MbsField;
	public static var description:MbsField;
	public static var design:MbsField;
	public static var drawOrder:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	public static var packageName:MbsField;
	public static var sceneID:MbsField;
	public static var type:MbsField;
	public static var attributes:MbsField;
	public static var blocks:MbsField;
	public static var events:MbsField;
	
	public static var MBS_SNIPPET_DEF:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_SNIPPET_DEF != null) return;
		MBS_SNIPPET_DEF = new ComposedType("MbsSnippetDef");
		MBS_SNIPPET_DEF.setInstantiator(function(data) return new MbsSnippetDef(data));
		
		attachedEvent = MBS_SNIPPET_DEF.createField("attachedEvent", BOOLEAN);
		actorID = MBS_SNIPPET_DEF.createField("actorID", INTEGER);
		classname = MBS_SNIPPET_DEF.createField("classname", STRING);
		description = MBS_SNIPPET_DEF.createField("description", STRING);
		design = MBS_SNIPPET_DEF.createField("design", BOOLEAN);
		drawOrder = MBS_SNIPPET_DEF.createField("drawOrder", INTEGER);
		id = MBS_SNIPPET_DEF.createField("id", INTEGER);
		name = MBS_SNIPPET_DEF.createField("name", STRING);
		packageName = MBS_SNIPPET_DEF.createField("packageName", STRING);
		sceneID = MBS_SNIPPET_DEF.createField("sceneID", INTEGER);
		type = MBS_SNIPPET_DEF.createField("type", STRING);
		attributes = MBS_SNIPPET_DEF.createField("attributes", LIST);
		blocks = MBS_SNIPPET_DEF.createField("blocks", LIST);
		events = MBS_SNIPPET_DEF.createField("events", LIST);
		
	}
	
	public static function new_MbsSnippetDef_list(data:MbsIO):MbsList<MbsSnippetDef>
	{
		return new MbsList<MbsSnippetDef>(data, MBS_SNIPPET_DEF, new MbsSnippetDef(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_SNIPPET_DEF;
	}
	
	private var _attributes:MbsList<MbsAttributeDef>;
	private var _blocks:MbsList<MbsBlock>;
	private var _events:MbsList<MbsEvent>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_attributes = new MbsList<MbsAttributeDef>(data, MbsAttributeDef.MBS_ATTRIBUTE_DEF, new MbsAttributeDef(data));
		_blocks = new MbsList<MbsBlock>(data, MbsBlock.MBS_BLOCK, new MbsBlock(data));
		_events = new MbsList<MbsEvent>(data, MbsEvent.MBS_EVENT, new MbsEvent(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_SNIPPET_DEF.getSize()));
	}
	
	public function getAttachedEvent():Bool
	{
		return data.readBool(address + attachedEvent.address);
	}
	
	public function setAttachedEvent(_val:Bool):Void
	{
		data.writeBool(address + attachedEvent.address, _val);
	}
	
	public function getActorID():Int
	{
		return data.readInt(address + actorID.address);
	}
	
	public function setActorID(_val:Int):Void
	{
		data.writeInt(address + actorID.address, _val);
	}
	
	public function getClassname():String
	{
		return data.readString(address + classname.address);
	}
	
	public function setClassname(_val:String):Void
	{
		data.writeString(address + classname.address, _val);
	}
	
	public function getDescription():String
	{
		return data.readString(address + description.address);
	}
	
	public function setDescription(_val:String):Void
	{
		data.writeString(address + description.address, _val);
	}
	
	public function getDesign():Bool
	{
		return data.readBool(address + design.address);
	}
	
	public function setDesign(_val:Bool):Void
	{
		data.writeBool(address + design.address, _val);
	}
	
	public function getDrawOrder():Int
	{
		return data.readInt(address + drawOrder.address);
	}
	
	public function setDrawOrder(_val:Int):Void
	{
		data.writeInt(address + drawOrder.address, _val);
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
	
	public function getPackageName():String
	{
		return data.readString(address + packageName.address);
	}
	
	public function setPackageName(_val:String):Void
	{
		data.writeString(address + packageName.address, _val);
	}
	
	public function getSceneID():Int
	{
		return data.readInt(address + sceneID.address);
	}
	
	public function setSceneID(_val:Int):Void
	{
		data.writeInt(address + sceneID.address, _val);
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
	}
	
	public function getAttributes():MbsList<MbsAttributeDef>
	{
		_attributes.setAddress(data.readInt(address + attributes.address));
		return _attributes;
	}
	
	public function createAttributes(_length:Int):MbsList<MbsAttributeDef>
	{
		_attributes.allocateNew(_length);
		data.writeInt(address + attributes.address, _attributes.getAddress());
		return _attributes;
	}
	
	public function getBlocks():MbsList<MbsBlock>
	{
		_blocks.setAddress(data.readInt(address + blocks.address));
		return _blocks;
	}
	
	public function createBlocks(_length:Int):MbsList<MbsBlock>
	{
		_blocks.allocateNew(_length);
		data.writeInt(address + blocks.address, _blocks.getAddress());
		return _blocks;
	}
	
	public function getEvents():MbsList<MbsEvent>
	{
		_events.setAddress(data.readInt(address + events.address));
		return _events;
	}
	
	public function createEvents(_length:Int):MbsList<MbsEvent>
	{
		_events.allocateNew(_length);
		data.writeInt(address + events.address, _events.getAddress());
		return _events;
	}
	
}
