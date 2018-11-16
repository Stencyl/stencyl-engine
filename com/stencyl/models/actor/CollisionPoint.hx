package com.stencyl.models.actor;

import com.stencyl.models.Actor;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;

class CollisionPoint 
{
	public var x:Float;
	public var y:Float;
	public var normalX:Float;
	public var normalY:Float;
	
	public function new(x:Float, y:Float, normalX:Float, normalY:Float)
	{
		this.x = x;
		this.y = y;
		this.normalX = normalX;
		this.normalY = normalY;
	}
	
	private static var freedCollisionPoints = new Array<CollisionPoint>();
	
	public static function resetStatics()
	{
		freedCollisionPoints = new Array<CollisionPoint>();
	}
	
	public static function get(x:Float, y:Float, normalX:Float, normalY:Float)
	{
		if(freedCollisionPoints.length > 0)
		{
			var cp = freedCollisionPoints.pop();
			cp.x = x;
			cp.y = y;
			cp.normalX = normalX;
			cp.normalY = normalY;
			return cp;
		}
		else
		{
			return new CollisionPoint(x, y, normalX, normalY);
		}
	}
	
	public static function free(cp:CollisionPoint)
	{
		freedCollisionPoints.push(cp);
	}
}
