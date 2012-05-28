package com.stencyl.models.actor;

import com.stencyl.models.Actor;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;

class CollisionPoint 
{
	public var point:B2Vec2;
	public var normal:B2Vec2;
	
	public function new(point:B2Vec2, normal:B2Vec2)
	{
		this.point = point;
		this.normal = normal;
	}
}
