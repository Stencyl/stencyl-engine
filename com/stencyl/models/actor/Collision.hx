package com.stencyl.models.actor;

import com.stencyl.models.Actor;
import com.stencyl.models.collision.Mask;

import box2D.common.math.B2Vec2;
import box2D.collision.B2Manifold;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.contacts.B2Contact;

import openfl.geom.Rectangle;


class Collision 
{
	private static var recycledCollisions:Array<Collision> = new Array<Collision>();
	public static var collisionResponses:Map < Int, Map < Int, String >> = new Map < Int, Map < Int, String >> ();
	
	public static function resetStatics():Void
	{
		recycledCollisions = new Array<Collision>();
		collisionResponses = new Map < Int, Map < Int, String >> ();
	}

	public var thisFromTop:Bool;
	public var thisFromLeft:Bool;
	public var thisFromBottom:Bool;
	public var thisFromRight:Bool;
	
	public var thisCollidedWithActor:Bool;
	public var thisCollidedWithTile:Bool;
	public var thisCollidedWithSensor:Bool;
	public var thisCollidedWithTerrain:Bool;
	
	public var otherFromTop:Bool;
	public var otherFromLeft:Bool;
	public var otherFromBottom:Bool;
	public var otherFromRight:Bool;
	
	public var otherCollidedWithActor:Bool;
	public var otherCollidedWithTile:Bool;
	public var otherCollidedWithSensor:Bool;
	public var otherCollidedWithTerrain:Bool;

	public var points:Array<CollisionPoint>;
	
	public var thisActor:Actor;
	public var otherActor:Actor;
	
	public var thisShape:B2Fixture;
	public var otherShape:B2Fixture;
	
	public var actorA:Actor;
	public var actorB:Actor;
	
	//Simple Physics
	public var maskA:Mask;
	public var maskB:Mask;
	
	public var groupA:Int;
	public var groupB:Int;
	
	public var bounds:Rectangle;
	public var useBounds:Bool;
	public var remove:Bool;
	
	public var solidCollision:Bool;
	public var linkedCollision:Collision;
	
	public static function addResponse(firstObject:Dynamic, secondObject:Dynamic, response:String)
	{
		var groupID1:Int = -1;
		var groupID2:Int = -1;
	
		if (Std.is(firstObject, ActorType))
		{
			groupID1 = firstObject.groupID;
		}
		else if (Std.is(firstObject, Group))
		{
			groupID1 = firstObject.ID;
		}
		
		if (Std.is(secondObject, ActorType))
		{
			groupID2 = secondObject.groupID;
		}
		else if (Std.is(secondObject, Group))
		{
			groupID2 = secondObject.ID;
		}
	
		if (collisionResponses.get(groupID1) == null)
		{
			collisionResponses.set(groupID1, new Map<Int,String>());
		}
		
		if (collisionResponses.get(groupID2) == null)
		{
			collisionResponses.set(groupID2, new Map<Int,String>());
		}
		
		collisionResponses.get(groupID1).set(groupID2, response);
		collisionResponses.get(groupID2).set(groupID1, response);
	}
	
	public static function preSolve(contact:B2Contact, oldManifold:B2Manifold):Void
	{
		var groupID1:Int = contact.getFixtureA().getBody().groupID;
		var groupID2:Int = contact.getFixtureB().getBody().groupID;
		
		if (collisionResponses.get(groupID1) != null)
		{
			var response:String = collisionResponses.get(groupID1).get(groupID2);
			
			if (response == "sensor")
			{
				contact.setEnabled(false);
			}
		}
	}
	
	public function new()
	{
		points = new Array<CollisionPoint>();
		bounds = new Rectangle();
		
		clear();
	}
	
	public static function get():Collision
	{
		if (recycledCollisions.length > 0)
		{
			return recycledCollisions.pop();
		}
		
		return new Collision();
	}
	
	public static function recycle(c:Collision)
	{
		c.clear();
		recycledCollisions.push(c);
	}
	
	public function clear()
	{
		while (points.length > 0)
		{
			points.pop();
		}
		
		thisFromTop = false;
		thisFromLeft = false;
		thisFromBottom = false;
		thisFromRight = false;
		
		thisCollidedWithActor = false;
		thisCollidedWithTile = false;
		thisCollidedWithSensor = false;
		thisCollidedWithTerrain = false;
		
		otherFromTop = false;
		otherFromLeft = false;
		otherFromBottom = false;
		otherFromRight = false;
		
		otherCollidedWithActor = false;
		otherCollidedWithTile = false;
		otherCollidedWithSensor = false;
		otherCollidedWithTerrain = false;
		
		useBounds = false; 
		solidCollision = false;
		remove = false;
	
		thisActor = null;
		otherActor = null;
		
		thisShape = null;
		otherShape = null;
		
		actorA = null;
		actorB = null;
		
		maskA = maskB = null;
		linkedCollision = null;
		
		bounds.setEmpty();
		
	}
	
	public function switchData(c:Collision):Collision
	{		
		if (c == null) return null;
		
		c.thisActor = otherActor;
		c.thisShape = otherShape;
		c.thisFromTop = otherFromTop;
		c.thisFromLeft = otherFromLeft;
		c.thisFromBottom = otherFromBottom;
		c.thisFromRight = otherFromRight;
		c.thisCollidedWithActor = otherCollidedWithActor;
		c.thisCollidedWithTile = otherCollidedWithTile;
		c.thisCollidedWithSensor = otherCollidedWithSensor;
		c.thisCollidedWithTerrain = otherCollidedWithTerrain;

		c.otherActor = thisActor;
		c.otherShape = thisShape;
		c.otherFromTop = thisFromTop;
		c.otherFromLeft = thisFromLeft;
		c.otherFromBottom = thisFromBottom;
		c.otherFromRight = thisFromRight;			
		c.otherCollidedWithActor = thisCollidedWithActor;
		c.otherCollidedWithTile = thisCollidedWithTile;
		c.otherCollidedWithSensor = thisCollidedWithSensor;
		c.otherCollidedWithTerrain = thisCollidedWithTerrain;						
		
		c.actorA = actorA;
		c.actorB = actorB;
		c.points = points;
		
		c.useBounds = useBounds;
		c.maskA = maskA;
		c.maskB = maskB;		
		c.solidCollision = solidCollision;
		
		c.groupA = groupA;
		c.groupB = groupB;
		
		c.linkedCollision = this;
		this.linkedCollision = c;		
		
		return c;
	}	
}
