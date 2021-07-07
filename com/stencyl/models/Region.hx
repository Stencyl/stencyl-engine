package com.stencyl.models;

import com.stencyl.models.Actor;
import com.stencyl.utils.Utils;

import box2D.collision.B2AABB;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;

import openfl.geom.Rectangle;

class Region extends Actor
{
	public inline static var UNSET_ID = -1;

	public var isCircle:Bool;
	
	///All Hash sets of Integers
	private var containedActors:Map<Int,Int>;

	private var copy:B2Shape;
	
	//Strictly used in non-Box2D mode
	public var simpleBounds:Rectangle;

	public var regionWidth:Float;
	public var regionHeight:Float;
	
	private var originalWidth:Float;
	private var originalHeight:Float;
			
	public var whenActorEntersListeners:Array<Dynamic>;
	public var whenActorExitsListeners:Array<Dynamic>;
	
	private var justAdded:Array<Dynamic>;
	private var justRemoved:Array<Dynamic>;

	public function new(game:Engine, x:Float, y:Float, shapes:Array<B2Shape>, simpleBounds:Rectangle = null)
	{
		super(game, UNSET_ID, -2, x, y, -1, Engine.NO_PHYSICS ? simpleBounds.width : 1, Engine.NO_PHYSICS ? simpleBounds.height : 1, 
		      null, null, null, null, 
		      false, false, false, false, 
		      Engine.NO_PHYSICS ? null : shapes[0],
		      Engine.NO_PHYSICS
		      );
	
		alwaysSimulate = true;
		isRegion = true;
		isTerrainRegion = false;
		solid = false;
		
		name = "Region";
		
		this.simpleBounds = simpleBounds;
		copy = shapes[0];
		
		containedActors = new Map<Int,Int>();
		whenActorEntersListeners = new Array<Dynamic>();
		whenActorExitsListeners = new Array<Dynamic>();
		
		justAdded = new Array<Dynamic>();
		justRemoved = new Array<Dynamic>();
		
		if(!Engine.NO_PHYSICS)
		{
			body.setSleepingAllowed(true);
			body.setAwake(false);
			body.setIgnoreGravity(true);
		}
		
		var lowerXBound:Float = 0;
		var upperXBound:Float = 0;
		var lowerYBound:Float = 0;
		var upperYBound:Float = 0;
		
		if(Engine.NO_PHYSICS)
		{
			upperXBound = simpleBounds.width;
			upperYBound = simpleBounds.height;
					
			cacheWidth = originalWidth = regionWidth = Math.round(Math.abs(lowerXBound - upperXBound));
			cacheHeight = originalHeight = regionHeight = Math.round(Math.abs(lowerYBound - upperYBound));
			
			currOffset.x = -(cacheWidth / 2);
			currOffset.y = -(cacheHeight / 2);
			resetReal(x, y);
		}
		
		else
		{
			if(Std.isOfType(shapes[0], B2PolygonShape))
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
					fixture.isSensor = true;
					fixture.userData = this;
					fixture.shape = shapes[i];
					fixture.friction = 1.0;
					fixture.density = 0.1;
					fixture.restitution = 0;
					fixture.groupID = GameModel.INHERIT_ID;
	
					body.createFixture(fixture);

					cast(shapes[i], B2PolygonShape).computeAABB(aabb, trans);
					lowerXBound = Math.min(lowerXBound, aabb.lowerBound.x);
					upperXBound = Math.max(upperXBound, aabb.upperBound.x);
					lowerYBound = Math.min(lowerYBound, aabb.lowerBound.y);
					upperYBound = Math.max(upperYBound, aabb.upperBound.y);
				}
				
				cacheWidth = originalWidth = regionWidth = Math.round(Engine.toPixelUnits(Math.abs(lowerXBound - upperXBound)));
				cacheHeight = originalHeight = regionHeight = Math.round(Engine.toPixelUnits(Math.abs(lowerYBound - upperYBound)));
			}
				
			else if(Std.isOfType(shapes[0], B2CircleShape))
			{
				isCircle = true;
				
				cacheWidth = originalWidth = regionWidth = Engine.toPixelUnits(cast(shapes[0], B2CircleShape).m_radius * 2);
				cacheHeight = originalHeight = regionHeight = Engine.toPixelUnits(cast(shapes[0], B2CircleShape).m_radius * 2);
			}
		}
	}
	
	public function containsActor(actor:Actor):Bool
	{
		if(actor != null)
		{
			return containedActors.exists(actor.ID);
		}
		
		else
		{
			return false;
		}
	}
	
	public function getContainedActors():Map<Int,Int>
	{
		return containedActors;
	}
	
	public function addActor(actor:Actor)
	{
		if(actor == null)
		{
			return;	
		}
		
		if(actor.ID != -1 && !containedActors.exists(actor.ID))
		{
			containedActors.set(actor.ID, actor.ID);
			
			var index = Utils.indexOf(justRemoved, actor);
			
			if(index == -1)
			{
				justAdded.push(actor);					
			}
			
			else 
			{
				justRemoved.splice(index, 1);
			}
		}
	}
	
	public function removeActor(actor:Actor)
	{
		if(actor == null)
		{
			return;	
		}
		
		if(actor.ID != -1)
		{
			var index = Utils.indexOf(justRemoved, actor);
			
			if(index == -1)
			{
				containedActors.remove(actor.ID);
				justRemoved.push(actor);
			}
		}
	}
	
	override public function follow(actor:Actor)
	{
		var x = actor.realX + actor.cacheWidth / 2;
		var y = actor.realY + actor.cacheHeight / 2;
		
		setX(x);
		setY(y);
		
		//TODO: technically we should clear/re-check containedActors...
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
		fixture.groupID = GameModel.INHERIT_ID;
		
		if(body != null && body.getFixtureList() != null)
		{
			while(body.m_fixtureCount > 0)
			{
				body.DestroyFixture(body.getFixtureList());
			}
			
			body.createFixture(fixture);
			
			cacheWidth = regionWidth = Engine.toPixelUnits(width);
			cacheHeight = regionHeight = Engine.toPixelUnits(height);
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
	
	override public function isMouseOver():Bool
	{
		var mx = (Input.mouseX + Engine.cameraX) / Engine.SCALE;
		var my = (Input.mouseY + Engine.cameraY) / Engine.SCALE;
		
		var xPos:Float = getX();
		var yPos:Float = getY();

		var inBoundingBox = (mx >= xPos &&
		    my >= yPos &&
		    mx < xPos + regionWidth &&
		    my < yPos + regionHeight);

		if (!inBoundingBox) {
			return false;
		}

		var fixtureList = body.getFixtureList();
		var shape = fixtureList.getShape();
		if (Std.is(shape, B2PolygonShape)) {
			while (fixtureList != null) {
				shape = fixtureList.getShape();
				var polygonShape:B2PolygonShape = cast(shape, B2PolygonShape);
				// Points inside the vertices list are local AND around the center of the polygon, so we need to translate our coordinates before calling `pointInsidePolygon`
				var result = pointInsidePolygon(mx - xPos - regionWidth / 2, my - yPos - regionHeight / 2, polygonShape.getVertices());
				if (result) {
					return true;
				}
				fixtureList = fixtureList.getNext();
			}
		} else if (Std.is(shape, B2CircleShape)) {
			var radius = regionWidth/2;

			var x1 = mx - (xPos+radius);
			var y1 = my - (yPos+radius);

			// Pythagorean theorem: `d = Math.sqrt((x_p - x_c)^2 + (y_p - y_c)^2)` where xy_p is the point to search for and xy_c is the center of the circle
			return x1*x1 + y1*y1 < radius*radius;
		} else {
			return true;
		}
		return false;
	}

	/**
	 * Basic raytrace algorithm to find a point inside a polygon. From http://alienryderflex.com/polygon/
	 *
	 * We're guaranteed to be calling this on convex polygons, so this can be improved/simplified (the current algorithm works with concave/convex polygons)
	 **/
	private static function pointInsidePolygon(pixelX: Float, pixelY: Float, points: Array<B2Vec2>): Bool {
		var length = points.length;
		if (length <= 0) {
			return false;
		}
		var prevPoint = points[length - 1];
		var oddNodes = false;

		// Points inside `points` are in physical units
		var x = Engine.toPhysicalUnits(pixelX);
		var y = Engine.toPhysicalUnits(pixelY);

		for (i in 0...length) {
			var currentPoint = points[i];

			if ((currentPoint.y < y && prevPoint.y >= y || prevPoint.y < y && currentPoint.y >= y) && (currentPoint.x <= x || prevPoint.x <= x)) {
				if (currentPoint.x + (y - currentPoint.y) / (prevPoint.y - currentPoint.y) * (prevPoint.x - currentPoint.x) < x) {
					oddNodes = !oddNodes;
				}
			}

			prevPoint = currentPoint;
		}

		return oddNodes;
	}
	
	override public function innerUpdate(elapsedTime:Float, hudCheck:Bool)
	{		
		clearCollisionInfoList();
		
		if(Engine.NO_PHYSICS)
		{
			for(id in containedActors)
			{
				var a = Engine.engine.getActor(id);

				if(HITBOX != null && a != null && !HITBOX.collide(a.HITBOX))
				{
					removeActor(a);
				}
			}
		}
							
		while(justAdded != null && justAdded.length > 0)
		{				
			var a = cast(justAdded.pop(), Actor);
			Engine.invokeListeners2(whenActorEntersListeners, a);
		}
		
		while(justRemoved != null && justRemoved.length > 0)
		{
			var a = cast(justRemoved.pop(), Actor);
			Engine.invokeListeners2(whenActorExitsListeners, a);
		}
		
		if(mouseOverListeners != null && mouseOverListeners.length > 0)
		{
			//Previously was checkMouseState() - inlined for performance. See Actor:innerUpdate for other instance.
			var mouseOver:Bool = isMouseOver();
			
			if(mouseOver)
			{
				if(mouseState <= 0)
				{
					//Just Entered
					mouseState = 1;
					Engine.invokeListeners2(mouseOverListeners, mouseState);
				}
				else
				{
					//Over
					mouseState = 2;
				}
				
				if(Input.mousePressed)
				{
					//Clicked On
					mouseState = 3;
					Engine.invokeListeners2(mouseOverListeners, mouseState);
				}
				
				else if(Input.mouseDown)
				{
					//Dragged
					mouseState = 4;
					Engine.invokeListeners2(mouseOverListeners, mouseState);
				}
				
				if(Input.mouseReleased)
				{
					//Released
					mouseState = 5;
					Engine.invokeListeners2(mouseOverListeners, mouseState);
				}
			}
			
			else
			{
				if(mouseState > 0)
				{
					//Just Exited
					mouseState = -1;
					Engine.invokeListeners2(mouseOverListeners, mouseState);
				}
				
				else if(mouseState == -1)
				{
					mouseState = 0;
				}
			}
		}
	}
}