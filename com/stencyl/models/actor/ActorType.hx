package com.stencyl.models.actor;

import com.stencyl.models.Resource;

import box2D.dynamics.B2BodyDef;

class ActorType extends Resource
{
	public var groupID:Int;
	public var spriteID:Int;
	public var behaviorValues:Map<String,Dynamic>;
	public var bodyDef:B2BodyDef;
	public var physicsMode:Int;
	public var autoScale:Bool;
	public var pausable:Bool;
	public var ignoreGravity:Bool;
	
	public function new
	(
		ID:Int, 
		atlasID:Int,
		name:String, 
		groupID:Int, 
		spriteID:Int, 
		behaviorValues:Map<String,Dynamic>, 
		bodyDef:B2BodyDef, 
		physicsMode:Int, 
		autoScale:Bool,
		pausable:Bool,
		ignoreGravity:Bool
	)
	{
		super(ID, name, atlasID);
		
		this.groupID = groupID;
		this.spriteID = spriteID;
		this.behaviorValues = behaviorValues;
		this.bodyDef = bodyDef;
		this.physicsMode = physicsMode;
		this.autoScale = autoScale;
		this.pausable = pausable;
		this.ignoreGravity = ignoreGravity;
	}
	
	override public function toString():String
	{
		return name;
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