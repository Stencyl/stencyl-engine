package com.stencyl.models;

import com.stencyl.models.Actor;

import box2D.collision.shapes.B2Shape;

class Region extends Actor
{
	public var isCircle:Bool;
	
	//???
	private var flag:Bool;
	
	///All Hash sets of Integers
	private var containedActors:IntHash<Int>;

	private var copy:B2Shape;
	
	private var originalWidth:Float;
	private var originalHeight:Float;
			
	public var whenActorEntersListeners:Array<Dynamic>;
	public var whenActorExitsListeners:Array<Dynamic>;
	
	private var justAdded:Array<Dynamic>;
	private var justRemoved:Array<Dynamic>;
	
	public function new(game:Engine, x:Float, y:Float, shapes:Array<B2Shape>)
	{
		super(game, 0, -2, x, y, game.getTopLayer(), 1, 1, null, null, null, null, false, false, false, false, shapes[0], true);
	
		(
		engine:Engine, 
		ID:Int,
		groupID:Int,
		x:Float=0, 
		y:Float=0, 
		layerID:Int=0,
		width:Int=32, 
		height:Int=32,
		sprite:com.stencyl.models.actor.Sprite=null,
		behaviorValues:Hash<Dynamic>=null,
		actorType:ActorType=null,
		bodyDef:B2BodyDef=null,
		isSensor:Bool=false,
		isStationary:Bool=false,
		isKinematic:Bool=false,
		canRotate:Bool=false,
		shape:B2Shape=null, //Used only for terrain.
		typeID:Int = 0,
		isLightweight:Bool=false,
		autoScale:Bool=true
	)
	
		/*flag = false;
	
		var shape:b2Shape = shapes[0];
		super(game, 0, -2, x, y, game.getTopLayer(), 1, 1, null, null, null, null, false, false, false, false, shape, true);
		
		alwaysSimulate = true;
		isRegion = true;
		
		copy = shape;
		
		whenActorEntersListeners = new Array();
		whenActorExitsListeners = new Array();
		
		justAdded = new Array();
		justRemoved = new Array();
		
		body.SetSleepingAllowed(true);
		body.SetAwake(false);
		body.SetIgnoreGravity(true);
		
		var lowerXBound:Number = 0;
		var upperXBound:Number = 0;
		var lowerYBound:Number = 0;
		var upperYBound:Number = 0;
		
		if(shape is b2PolygonShape)
		{
			isCircle = false;
			var trans:XF = new XF();
			trans.setIdentity();
			
			var aabb:AABB = new AABB();
			
			(shape as b2PolygonShape).ComputeAABB(aabb, trans);
			
			lowerXBound = aabb.lowerBound.x;
			upperXBound = aabb.upperBound.x;
			lowerYBound = aabb.lowerBound.y;
			upperYBound = aabb.upperBound.y;
			
			for (var i:int = 0; i < shapes.length; i++)
			{
				var fixture:b2FixtureDef = new b2FixtureDef();
				fixture.isSensor = true;
				fixture.userData = this;
				fixture.shape = shapes[i];
				fixture.friction = 1.0;
				fixture.density = 0.1;
				fixture.restitution = 0;
				fixture.groupID = -1000;

				body.CreateFixture(fixture);
				
				(shapes[i] as b2PolygonShape).ComputeAABB(aabb, trans);
				lowerXBound = Math.min(lowerXBound, aabb.lowerBound.x);
				upperXBound = Math.max(upperXBound, aabb.upperBound.x);
				lowerYBound = Math.min(lowerYBound, aabb.lowerBound.y);
				upperYBound = Math.max(upperYBound, aabb.upperBound.y);
			}
			
			this.originalWidth = this.width = this.frameWidth = Math.round(GameState.toPixelUnits(Math.abs(lowerXBound - upperXBound)));
			this.originalHeight = this.height = this.frameHeight = Math.round(GameState.toPixelUnits(Math.abs(lowerYBound - upperYBound)));
		}
			
		else if(shape is b2CircleShape)
		{
			isCircle = true;
			
			this.originalWidth = this.width = this.frameWidth = GameState.toPixelUnits((shape as b2CircleShape).m_radius * 2);
			this.originalHeight = this.height = this.frameHeight = GameState.toPixelUnits((shape as b2CircleShape).m_radius * 2);
		}*/
	}
	
	public function containsActor(actor:Actor):Bool
	{
		/*if(actor != null)
		{
			return contains.has(actor.getID());
		}
		
		else
		{
			return false;
		}*/
		
		return false;
	}
	
	public function getContainedActors():IntHash<Int>
	{
		return null;
		//return containedActors;
	}
	
	public function addActor(actor:Actor)
	{
		/*if(actor == null)
		{
			return;	
		}
		
		if(actor.getID() != -1 && !containedActors.has(actor.getID()))
		{
			containedActors.add(actor.getID());
			
			if (justRemoved.indexOf(actor) == -1)
			{
				justAdded.push(actor);					
			}
			
			else 
			{
				justRemoved.splice(justRemoved.indexOf(actor), 1);
			}
		}*/
	}
	
	public function removeActor(actor:Actor)
	{
		/*if(actor == null)
		{
			return;	
		}
		
		if(actor.getID() != -1)
		{
			containedActors.remove(actor.getID());
			justRemoved.push(actor);				
		}/*
	}
	
	override public function follow(actor:Actor)
	{
		/*var x:Number = actor.getX() + actor.getWidth() / 2;
		var y:Number = actor.getY() + actor.getHeight() / 2;
		
		setX(x);
		setY(y);*/
		
		//technically we should clear containedActors...
	}
	
	public function resetSize()
	{
		//setRegionSize(originalWidth, originalHeight);
	}
	
	public function setRegionDiameter(diameter:Float)
	{
		//setRegionSize(diameter, diameter);
	}
	
	public function setRegionSize(width:Float, height:Float)
	{
		/*var oldWidth:Number = this.width;
		var oldHeight:Number = this.height;
		
		width = GameState.toPhysicalUnits(width);
		height = GameState.toPhysicalUnits(height);
		
		var shape:b2Shape;
		
		if(isCircle)
		{
			var s:b2CircleShape = new b2CircleShape();
			s.m_radius = width / 2;
			shape = s;
		}
			
		else
		{
			var s2:b2PolygonShape = new b2PolygonShape();
			s2.SetAsBox(width/2, height/2);
			shape = s2;
		}
		
		var fixture:b2FixtureDef = new b2FixtureDef();
		fixture.isSensor = true;
		fixture.userData = this;
		fixture.shape = shape;
		
		if(getBody() != null && getBody().GetFixtureList() != null)
		{
			while(getBody().m_fixtureCount > 0)
			{
				getBody().DestroyFixture(getBody().GetFixtureList());
			}
			
			getBody().CreateFixture(fixture);
			
			this.width = GameState.toPixelUnits(width);
			this.height = GameState.toPixelUnits(height);
		}
		
		var dw:Number = (this.width - oldWidth);
		var dh:Number = (this.height - oldHeight);
		
		//Back up
		setLocation(getX() + (dw)/2, getY() + (dh)/2);*/
	}
	
	override public function setLocation(x:Float, y:Float)
	{
		//setX(x + width / 2);
		//setY(y + height / 2);
	}
	
	override public function getWidth():Float
	{
		return width;
	}
	
	override public function getHeight():Float
	{
		return height;
	}
	
	override public function innerUpdate(elapsedTime:Float, hudCheck:Bool)
	{					
		/*while (justAdded.length > 0)
		{				
			var a:Actor = justAdded.pop() as Actor;
			
			for (var r:int = 0; r < whenActorEntersListeners.length; r++)
			{
				try
				{						
					var f:Function = whenActorEntersListeners[r] as Function;
					f(whenActorEntersListeners, a);
					
					if (whenActorEntersListeners.indexOf(f) == -1)
					{
						r--;
					}
				}
				catch (e:Error)
				{
					FlxG.log(e.getStackTrace());
				}
			}
		}
		
		while (justRemoved.length > 0)
		{
			var a:Actor = justRemoved.pop() as Actor;
			
			for (var r:int = 0; r < whenActorExitsListeners.length; r++)
			{
				try
				{
					var f:Function = whenActorExitsListeners[r] as Function;
					f(whenActorExitsListeners, a);
					
					if (whenActorExitsListeners.indexOf(f) == -1)
					{
						r--;
					}
				}
				catch (e:Error)
				{
					FlxG.log(e.getStackTrace());
				}
			}
		}
		
		if (mouseOverListeners.length > 0)
		{
			checkMouseState();
		}*/
	}
}