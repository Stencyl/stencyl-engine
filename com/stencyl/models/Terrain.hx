package com.stencyl.models;

import com.stencyl.models.Actor;
import com.stencyl.utils.Utils;

import box2D.collision.B2AABB;
import box2D.common.math.B2Transform;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;

class Terrain extends Actor
{
	public inline static var UNSET_ID = -1;
	
	public var isCircle:Bool;
	public var fillColor:Int;
	
	private var copy:B2Shape;
	
	private var originalWidth:Float;
	private var originalHeight:Float;
	
	public var regionWidth:Float;
	public var regionHeight:Float;
	
	public function new(game:Engine, x:Float, y:Float, shapes:Array<B2Shape>, groupID:Int, fillColor:Int = 0)
	{
		super(game, UNSET_ID, groupID, x, y, game.getTopLayer(), 1, 1, 
		      null, null, null, null, 
		      false, true, false, false, 
		      shapes[0]);
		
		if (fillColor == 0) fillColor = Utils.getColorRGB(0, 0, 0);
		this.fillColor = fillColor;
		
		alwaysSimulate = true;
		isRegion = false;
		isTerrainRegion = true;
		
		copy = shapes[0];
		
		body.setSleepingAllowed(true);
		body.setAwake(false);
		body.setIgnoreGravity(true);
		
		//var sIndex:Number = 1;
		var lowerXBound:Float = 0;
		var upperXBound:Float = 0;
		var lowerYBound:Float = 0;
		var upperYBound:Float = 0;
		
		if(Std.is(shapes[0], B2PolygonShape))
		{
			isCircle = false;
			var trans = new B2Transform();
			trans.setIdentity();
			
			var aabb = new B2AABB();
			
			cast(shapes[0], B2PolygonShape).computeAABB(aabb, trans);
			
			lowerXBound = aabb.lowerBound.x;
			upperXBound = aabb.upperBound.x;
			lowerYBound = aabb.lowerBound.y;
			upperYBound = aabb.upperBound.y;
			
			for(i in 0...shapes.length)
			{
				var fixture = new B2FixtureDef();
				fixture.isSensor = false;
				fixture.userData = this;
				fixture.shape = shapes[i];
				fixture.friction = 1.0;
				fixture.density = 0.1;
				fixture.restitution = 0;
				fixture.groupID = groupID;

				body.createFixture(fixture);
				
				cast(shapes[i], B2PolygonShape).computeAABB(aabb, trans);
				lowerXBound = Math.min(lowerXBound, aabb.lowerBound.x);
				upperXBound = Math.max(upperXBound, aabb.upperBound.x);
				lowerYBound = Math.min(lowerYBound, aabb.lowerBound.y);
				upperYBound = Math.max(upperYBound, aabb.upperBound.y);
			}
			
			originalWidth = regionWidth = Math.round(Engine.toPixelUnits(Math.abs(lowerXBound - upperXBound)));
			originalHeight = regionHeight = Math.round(Engine.toPixelUnits(Math.abs(lowerYBound - upperYBound)));
		}
			
		else if(Std.is(shapes[0], B2CircleShape))
		{
			isCircle = true;
			
			originalWidth = regionWidth = Engine.toPixelUnits(cast(shapes[0], B2CircleShape).m_radius * 2);
			originalHeight = regionHeight = Engine.toPixelUnits(cast(shapes[0], B2CircleShape).m_radius * 2);
		}
	}
	
	override public function follow(actor:Actor)
	{
		var x = actor.realX + actor.cacheWidth / 2;
		var y = actor.realY + actor.cacheHeight / 2;
		
		setX(x);
		setY(y);
	}
	
	public function resetSize()
	{
		setRegionSize(originalWidth, originalHeight);
	}
	
	public function setRegionDiameter(diameter:Float)
	{
		setRegionSize(diameter, diameter);
	}
	
	public function setRegionSize(width:Float, height:Float)
	{
		var oldWidth:Float = regionWidth;
		var oldHeight:Float = regionHeight;
		
		width = Engine.toPhysicalUnits(width);
		height = Engine.toPhysicalUnits(height);
		
		var shape:B2Shape;
		
		if(isCircle)
		{
			var s = new B2CircleShape();
			s.m_radius = width / 2;
			shape = s;
		}
			
		else
		{
			var s2 = new B2PolygonShape();
			s2.setAsBox(width/2, height/2);
			shape = s2;
		}
		
		var fixture = new B2FixtureDef();
		fixture.isSensor = true;
		fixture.userData = this;
		fixture.shape = shape;
		
		if(body != null && body.getFixtureList() != null)
		{
			while(body.m_fixtureCount > 0)
			{
				body.DestroyFixture(body.getFixtureList());
			}
			
			body.createFixture(fixture);
			
			regionWidth = Engine.toPixelUnits(width);
			regionHeight = Engine.toPixelUnits(height);
		}
		
		var dw = (regionWidth - oldWidth);
		var dh = (regionHeight - oldHeight);
		
		//Back up
		setLocation(getX() + (dw)/2, getY() + (dh)/2);
	}
	
	override public function setLocation(x:Float, y:Float)
	{
		setX(x + regionWidth / 2);
		setY(y + regionHeight / 2);
	}
	
	override public function getWidth():Float
	{
		return regionWidth;
	}
	
	override public function getHeight():Float
	{
		return regionHeight;
	}
	
	public function getFillColor():Int
	{
		return fillColor;
	}
}
