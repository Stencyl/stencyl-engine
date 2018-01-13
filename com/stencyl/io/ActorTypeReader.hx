package com.stencyl.io;

import com.stencyl.utils.Utils;

import com.stencyl.models.PhysicsMode;
import com.stencyl.models.Resource;
import com.stencyl.models.actor.ActorType;
import com.stencyl.io.mbs.actortype.MbsActorType;
import com.stencyl.io.mbs.actortype.MbsActorType.*;
import com.stencyl.behavior.BehaviorInstance;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;

class ActorTypeReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == MBS_ACTOR_TYPE.getName();
	}
	
	public function read(obj:Dynamic):Resource
	{
		//trace("Reading ActorType (" + ID + ") - " + name);
		
		var r:MbsActorType = cast obj;

		var id = r.getId();
		var atlasID = r.getAtlasID();
		var name = r.getName();

		var bodyDef = new B2BodyDef();
		
		bodyDef.fixedRotation = r.getFixedRotation();
		
		bodyDef.type = switch(r.getBodyType())
		{
			case 0: B2Body.b2_staticBody;
			case 1: B2Body.b2_kinematicBody;
			default: B2Body.b2_dynamicBody;
		}
		
		bodyDef.linearDamping = r.getLinearDamping();
		bodyDef.angularDamping = r.getAngularDamping();
		
		bodyDef.friction = r.getFriction();
		bodyDef.bounciness = r.getRestitution();
		bodyDef.mass = r.getMass();
		bodyDef.aMass = r.getInertia();
		
		bodyDef.active = true;
		bodyDef.bullet = false;
		bodyDef.allowSleep = false;
		bodyDef.awake = true;
		bodyDef.ignoreGravity = r.getIgnoreGravity();
		bodyDef.bullet = r.getContinuous();

		var spriteID:Int = r.getSprite();
		var groupID:Int = r.getGroupID();
		var physicsMode:PhysicsMode = r.getPhysicsMode();
		var autoScale:Bool = r.getAutoScale();
		var pausable:Bool = r.getPausable();
		var ignoreGravity:Bool = bodyDef.ignoreGravity || bodyDef.type == B2Body.b2_staticBody || bodyDef.type == B2Body.b2_kinematicBody;
		
		//These are more like behavior instances
		//They reference the Behavior + Map of instance values
		var behaviorValues = AttributeValues.readBehaviors(r.getSnippets());
		
		var eventID:Int = r.getEventSnippetID();
		
		if(eventID > -1)
		{
			behaviorValues.set(""+eventID, new BehaviorInstance(eventID, new Map<String,Dynamic>()));
		}
		
		return new ActorType(id, atlasID, name, groupID, spriteID, behaviorValues, bodyDef, physicsMode, autoScale, pausable, ignoreGravity);
	}
}
