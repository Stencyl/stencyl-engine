package com.stencyl.models.actor;

import com.stencyl.models.Resource;

import box2D.dynamics.B2BodyDef;

class ActorType extends Resource
{
	public var groupID:Int;
	public var spriteID:Int;
	public var behaviorValues:Hash<Dynamic>;
	public var bodyDef:B2BodyDef;
	public var isLightweight:Bool;
	public var autoScale:Bool;
	public var pausable:Bool;
	
	public function new
	(
		ID:Int, 
		atlasID:Int,
		name:String, 
		groupID:Int, 
		spriteID:Int, 
		behaviorValues:Hash<Dynamic>, 
		bodyDef:B2BodyDef, 
		isLightweight:Bool, 
		autoScale:Bool,
		pausable:Bool
	)
	{
		super(ID, name, atlasID);
		
		this.groupID = groupID;
		this.spriteID = spriteID;
		this.behaviorValues = behaviorValues;
		this.bodyDef = bodyDef;
		this.isLightweight = isLightweight;
		this.autoScale = autoScale;
		this.pausable = pausable;
	}
	
	//For Atlases
	
	override public function loadGraphics()
	{
		com.stencyl.Data.get().resources.get(spriteID).loadGraphics();
	}
	
	override public function unloadGraphics()
	{
		com.stencyl.Data.get().resources.get(spriteID).unloadGraphics();
	}
}