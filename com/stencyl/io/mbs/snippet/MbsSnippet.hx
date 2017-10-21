package com.stencyl.io.mbs.snippet;

import com.stencyl.io.mbs.snippet.MbsAttribute;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsSnippet extends MbsObject
{
	public static var enabled:MbsField;
	public static var id:MbsField;
	public static var properties:MbsField;
	
	public static var MBS_SNIPPET:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_SNIPPET != null) return;
		MBS_SNIPPET = new ComposedType("MbsSnippet");
		MBS_SNIPPET.setInstantiator(function(data) return new MbsSnippet(data));
		
		enabled = MBS_SNIPPET.createField("enabled", BOOLEAN);
		id = MBS_SNIPPET.createField("id", INTEGER);
		properties = MBS_SNIPPET.createField("properties", LIST);
		
	}
	
	public static function new_MbsSnippet_list(data:MbsIO):MbsList<MbsSnippet>
	{
		return new MbsList<MbsSnippet>(data, MBS_SNIPPET, new MbsSnippet(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_SNIPPET;
	}
	
	private var _properties:MbsList<MbsAttribute>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_properties = new MbsList<MbsAttribute>(data, MbsAttribute.MBS_ATTRIBUTE, new MbsAttribute(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_SNIPPET.getSize()));
	}
	
	public function getEnabled():Bool
	{
		return data.readBool(address + enabled.address);
	}
	
	public function setEnabled(_val:Bool):Void
	{
		data.writeBool(address + enabled.address, _val);
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getProperties():MbsList<MbsAttribute>
	{
		_properties.setAddress(data.readInt(address + properties.address));
		return _properties;
	}
	
	public function createProperties(_length:Int):MbsList<MbsAttribute>
	{
		_properties.allocateNew(_length);
		data.writeInt(address + properties.address, _properties.getAddress());
		return _properties;
	}
	
}
