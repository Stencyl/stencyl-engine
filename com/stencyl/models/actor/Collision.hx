package com.stencyl.models.actor;

import com.stencyl.models.Actor;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;


class Collision 
{
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
	
	public function new()
	{
		points = new Array<CollisionPoint>();
		
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
	
		thisActor = null;
		otherActor = null;
		
		thisShape = null;
		otherShape = null;
		
		actorA = null;
		actorB = null;
	}
	
	public function switchData():Collision
	{
		var c:Collision = new Collision();
		
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
		
		return c;
	}	
}
