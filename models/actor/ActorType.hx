package models.actor;

import models.Resource;

class ActorType extends Resource
{
	public var groupID:Int;
	public var spriteID:Int;
	public var behaviorValues:Hash<Dynamic>;
	//public var bodyDef:b2BodyDef;
	public var isLightweight:Bool;
	public var autoScale:Bool;
	public var pausable:Bool;
	
	public function new
	(
		ID:Int, 
		name:String, 
		groupID:Int, 
		spriteID:Int, 
		behaviorValues:Hash<Dynamic>, 
		//bodyDef:b2BodyDef, 
		isLightweight:Bool, 
		autoScale:Bool,
		pausable:Bool
	)
	{
		super(ID, name);
		
		this.groupID = groupID;
		this.spriteID = spriteID;
		this.behaviorValues = behaviorValues;
		//this.bodyDef = bodyDef;
		this.isLightweight = isLightweight;
		this.autoScale = autoScale;
		this.pausable = pausable;
	}
}