package com.stencyl.models.actor;

import com.stencyl.models.Actor;
import com.stencyl.models.collision.Mask;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;

import openfl.geom.Rectangle;


class Collision 
{
	private static var recycledCollisions:Array<Collision> = new Array<Collision>();
	public static var collisionResponses:Map < Int, Map < Int, String >> = new Map < Int, Map < Int, String >> ();
	
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
	
	
	public static function addResponse(firstActor:ActorType, secondActor:ActorType, response:String)
	{
		if (collisionResponses.get(firstActor.groupID) == null)
		{
			collisionResponses.set(firstActor.groupID, new Map<Int,String>());
		}
		
		if (collisionResponses.get(secondActor.groupID) == null)
		{
			collisionResponses.set(secondActor.groupID, new Map<Int,String>());
		}
		
		collisionResponses.get(firstActor.groupID).set(secondActor.groupID, response);
		collisionResponses.get(secondActor.groupID).set(firstActor.groupID, response);
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
