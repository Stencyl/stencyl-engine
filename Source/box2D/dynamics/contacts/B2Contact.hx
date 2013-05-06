/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package box2D.dynamics.contacts;


import box2D.collision.B2ContactID;
import box2D.collision.B2Manifold;
import box2D.collision.B2ManifoldPoint;
import box2D.collision.B2TimeOfImpact;
import box2D.collision.B2TOIInput;
import box2D.collision.B2WorldManifold;
import box2D.collision.shapes.B2Shape;
import box2D.common.B2Settings;
import box2D.common.math.B2Sweep;
import box2D.common.math.B2Transform;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.B2Fixture;


//typedef b2Contact* b2ContactCreateFcn(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator);
//typedef void b2ContactDestroyFcn(b2Contact* contact, b2BlockAllocator* allocator);



/**
* The class manages contact between two shapes. A contact exists for each overlapping
* AABB in the broad-phase (except if filtered). Therefore a contact object may exist
* that has no contact points.
*/
class B2Contact
{
	/**
	 * Get the contact manifold. Do not modify the manifold unless you understand the
	 * internals of Box2D
	 */
	public function getManifold():B2Manifold
	{
		return m_manifold;
	}
	
	/**
	 * Get the world manifold
	 */
	public function getWorldManifold(worldManifold:B2WorldManifold):Void
	{
		var bodyA:B2Body = m_fixtureA.getBody();
		var bodyB:B2Body = m_fixtureB.getBody();
		var shapeA:B2Shape = m_fixtureA.getShape();
		var shapeB:B2Shape = m_fixtureB.getShape();
		
		worldManifold.initialize(m_manifold, bodyA.getTransform(), shapeA.m_radius, bodyB.getTransform(), shapeB.m_radius);
	}
	
	/**
	 * Is this contact touching.
	 */
	public function isTouching():Bool
	{
		return (m_flags & e_touchingFlag) == e_touchingFlag; 
	}
	
	/**
	 * Does this contact generate TOI events for continuous simulation
	 */
	public function isContinuous():Bool
	{
		return (m_flags & e_continuousFlag) == e_continuousFlag; 
	}
	
	/**
	 * Change this to be a sensor or-non-sensor contact.
	 */
	public function setSensor(sensor:Bool):Void{
		if (sensor)
		{
			m_flags |= e_sensorFlag;
		}
		else
		{
			m_flags &= ~e_sensorFlag;
		}
	}
	
	/**
	 * Is this contact a sensor?
	 */
	public function isSensor():Bool{
		return (m_flags & e_sensorFlag) == e_sensorFlag;
	}
	
	/**
	 * Enable/disable this contact. This can be used inside the pre-solve
	 * contact listener. The contact is only disabled for the current
	 * time step (or sub-step in continuous collision).
	 */
	public function setEnabled(flag:Bool):Void{
		if (flag)
		{
			m_flags |= e_enabledFlag;
		}
		else
		{
			m_flags &= ~e_enabledFlag;
		}
	}
	
	/**
	 * Has this contact been disabled?
	 * @return
	 */
	public function isEnabled():Bool {
		return (m_flags & e_enabledFlag) == e_enabledFlag;
	}
	
	/**
	* Get the next contact in the world's contact list.
	*/
	public function getNext():B2Contact{
		return m_next;
	}
	
	/**
	* Get the first fixture in this contact.
	*/
	public function getFixtureA():B2Fixture
	{
		return m_fixtureA;
	}
	
	/**
	* Get the second fixture in this contact.
	*/
	public function getFixtureB():B2Fixture
	{
		return m_fixtureB;
	}
	
	/**
	 * Flag this contact for filtering. Filtering will occur the next time step.
	 */
	public function flagForFiltering():Void
	{
		m_flags |= e_filterFlag;
	}

	//--------------- Internals Below -------------------
	
	// m_flags
	// enum
	// This contact should not participate in Solve
	// The contact equivalent of sensors
	static public var e_sensorFlag:Int		= 0x0001;
	// Generate TOI events.
	static public var e_continuousFlag:Int	= 0x0002;
	// Used when crawling contact graph when forming islands.
	static public var e_islandFlag:Int		= 0x0004;
	// Used in SolveTOI to indicate the cached toi value is still valid.
	static public var e_toiFlag:Int		= 0x0008;
	// Set when shapes are touching
	static public var e_touchingFlag:Int	= 0x0010;
	// This contact can be disabled (by user)
	static public var e_enabledFlag:Int	= 0x0020;
	// This contact needs filtering because a fixture filter was changed.
	static public var e_filterFlag:Int		= 0x0040;

	public function new ()
	{
		
		m_nodeA = new B2ContactEdge();
		m_nodeB = new B2ContactEdge();
		m_manifold = new B2Manifold();
		m_oldManifold = new B2Manifold();
		
		// Real work is done in Reset
	}
	
	/** @private */
	public function reset(fixtureA:B2Fixture = null, fixtureB:B2Fixture = null):Void
	{
		m_flags = e_enabledFlag;
		
		if (fixtureA == null || fixtureB == null){
			m_fixtureA = null;
			m_fixtureB = null;
			return;
		}
		
		if (fixtureA.isSensor() || fixtureB.isSensor())
		{
			m_flags |= e_sensorFlag;
		}
		
		var bodyA:B2Body = fixtureA.getBody();
		var bodyB:B2Body = fixtureB.getBody();
		
		if (bodyA.getType() != B2Body.b2_dynamicBody || bodyA.isBullet() || bodyB.getType() != B2Body.b2_dynamicBody || bodyB.isBullet())
		{
			m_flags |= e_continuousFlag;
		}
		
		m_fixtureA = fixtureA;
		m_fixtureB = fixtureB;
		
		m_manifold.m_pointCount = 0;
		
		m_prev = null;
		m_next = null;
		
		m_nodeA.contact = null;
		m_nodeA.prev = null;
		m_nodeA.next = null;
		m_nodeA.other = null;
		
		m_nodeB.contact = null;
		m_nodeB.prev = null;
		m_nodeB.next = null;
		m_nodeB.other = null;
	}
	
	public function update(listener:B2ContactListener) : Void
	{
		// Swap old & new manifold
		var tManifold:B2Manifold = m_oldManifold;
		m_oldManifold = m_manifold;
		m_manifold = tManifold;
		
		// Re-enable this contact
		m_flags |= e_enabledFlag;
		
		var touching:Bool = false;
		var wasTouching:Bool = (m_flags & e_touchingFlag) == e_touchingFlag;
		
		var bodyA:B2Body = m_fixtureA.m_body;
		var bodyB:B2Body = m_fixtureB.m_body;
		
		var aabbOverlap:Bool = m_fixtureA.m_aabb.testOverlap(m_fixtureB.m_aabb);
		
		// Is this contat a sensor?
		if ((m_flags  & e_sensorFlag) != 0)
		{
			if (aabbOverlap)
			{
				var shapeA:B2Shape = m_fixtureA.getShape();
				var shapeB:B2Shape = m_fixtureB.getShape();
				var xfA:B2Transform = bodyA.getTransform();
				var xfB:B2Transform = bodyB.getTransform();
				touching = B2Shape.testOverlap(shapeA, xfA, shapeB, xfB);
			}
			
			// Sensors don't generate manifolds
			m_manifold.m_pointCount = 0;
		}
		else
		{
			// Slow contacts don't generate TOI events.
			if (bodyA.getType() != B2Body.b2_dynamicBody || bodyA.isBullet() || bodyB.getType() != B2Body.b2_dynamicBody || bodyB.isBullet())
			{
				m_flags |= e_continuousFlag;
			}
			else
			{
				m_flags &= ~e_continuousFlag;
			}
			
			if (aabbOverlap)
			{
				evaluate();
				
				touching = m_manifold.m_pointCount > 0;
				
				// Match old contact ids to new contact ids and copy the
				// stored impulses to warm start the solver.
				for (i in 0...m_manifold.m_pointCount)
				{
					var mp2:B2ManifoldPoint = m_manifold.m_points[i];
					mp2.m_normalImpulse = 0.0;
					mp2.m_tangentImpulse = 0.0;
					var id2:B2ContactID = mp2.m_id;

					for (j in 0...m_oldManifold.m_pointCount)
					{
						var mp1:B2ManifoldPoint = m_oldManifold.m_points[j];

						if (mp1.m_id.key == id2.key)
						{
							mp2.m_normalImpulse = mp1.m_normalImpulse;
							mp2.m_tangentImpulse = mp1.m_tangentImpulse;
							break;
						}
					}
				}

			}
			else
			{
				m_manifold.m_pointCount = 0;
			}
			if (touching != wasTouching)
			{
				bodyA.setAwake(true);
				bodyB.setAwake(true);
			}
		}
		
		if (touching)
		{
			m_flags |= e_touchingFlag;
		}
		else
		{
			m_flags &= ~e_touchingFlag;
		}

		if (wasTouching == false && touching == true)
		{
			listener.beginContact(this);
		}

		if (wasTouching == true && touching == false)
		{
			listener.endContact(this);
		}

		if ((m_flags & e_sensorFlag) == 0)
		{
			listener.preSolve(this, m_oldManifold);
		}
	}

	//virtual ~b2Contact() {}

	public function evaluate() : Void{}
	
	private static var s_input:B2TOIInput = new B2TOIInput();
	public function computeTOI(sweepA:B2Sweep, sweepB:B2Sweep):Float
	{
		s_input.proxyA.set(m_fixtureA.getShape());
		s_input.proxyB.set(m_fixtureB.getShape());
		s_input.sweepA = sweepA;
		s_input.sweepB = sweepB;
		s_input.tolerance = B2Settings.b2_linearSlop;
		return B2TimeOfImpact.timeOfImpact(s_input);
	}
	
	public var m_flags:Int;

	// World pool and list pointers.
	public var m_prev:B2Contact;
	public var m_next:B2Contact;

	// Nodes for connecting bodies.
	public var m_nodeA:B2ContactEdge;
	public var m_nodeB:B2ContactEdge;

	public var m_fixtureA:B2Fixture;
	public var m_fixtureB:B2Fixture;

	public var m_manifold:B2Manifold;
	public var m_oldManifold:B2Manifold;
	
	public var m_toi:Float;
	
	//STENCYL
	public var key:Int;
}