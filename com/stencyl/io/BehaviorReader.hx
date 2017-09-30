package com.stencyl.io;

import com.stencyl.io.mbs.snippet.*;
import com.stencyl.models.Resource;
import com.stencyl.behavior.Behavior;
import com.stencyl.behavior.Attribute;

class BehaviorReader
{
	public function new() 
	{
	}		

	public static function readBehavior(r:MbsSnippetDef):Behavior
	{
		var elementID = r.getId();
		var name = r.getName();
		var classname = r.getClassname();
		var isEvent = r.getAttachedEvent();
		
		var attributes:Map<String,Attribute> = new Map<String,Attribute>();
		var type = r.getType();
	
		var attrList = r.getAttributes();
		for(i in 0...attrList.length())
		{
			var attrReader = attrList.getNextObject();
			attributes.set(""+attrReader.getId(), readAttribute(attrReader, isEvent));
		}
		
		var b:Behavior = new Behavior
		(
			null,
			null,
			elementID,
			name,
			classname, 
			true,
			true,
			attributes,
			type,
			isEvent
		);

		return b;
	}
	
	public static function readAttribute(r:MbsAttributeDef, isEvent:Bool):Attribute
	{
		var ID = r.getId();
		var fieldName = r.getName();
		var fullName = r.getFullname();
		var hidden = isEvent || r.getHidden();
		var type = r.getType();
		var defaultValue = AttributeValues.readAttributeDef(type, r);
		
		return new Attribute(ID, fieldName, fullName, defaultValue, type, null, hidden);
	}
}
