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

package box2D.dynamics;


import box2D.collision.B2AABB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.collision.IBroadPhase;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.B2Color;
import box2D.common.B2Settings;
import box2D.common.math.B2Math;
import box2D.common.math.B2Sweep;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;
import box2D.dynamics.contacts.B2ContactSolver;
import box2D.dynamics.controllers.B2Controller;
import box2D.dynamics.controllers.B2ControllerEdge;
import box2D.dynamics.joints.B2Joint;
import box2D.dynamics.joints.B2JointDef;
import box2D.dynamics.joints.B2JointEdge;
import box2D.dynamics.joints.B2PulleyJoint;


/**
* The world class manages all physics entities, dynamic simulation,
* and asynchronous queries. 
*/
class B2World
{
	
	// Construct a world object.
	/**
	* @param gravity the world gravity vector.
	* @param doSleep improve performance by not simulating inactive bodies.
	*/
	public function new (gravity:B2Vec2, doSleep:Bool){
		
		s_stack = new Array <B2Body>();
		m_contactManager = new B2ContactManager();
		m_contactSolver = new B2ContactSolver();
		m_island = new B2Island();
		
		m_destructionListener = null;
		m_debugDraw = null;
		
		m_bodyList = null;
		m_contactList = null;
		m_jointList = null;
		m_controllerList = null;
		
		m_bodyCount = 0;
		m_contactCount = 0;
		m_jointCount = 0;
		m_controllerCount = 0;
		
		m_warmStarting = true;
		m_continuousPhysics = false;
		
		m_allowSleep = doSleep;
		m_gravity = gravity;
		
		m_inv_dt0 = 0.0;
		
		m_contactManager.m_world = this;
		
		var bd:B2BodyDef = new B2BodyDef();
		m_groundBody = createBody(bd);
	}

	/**
	* Destruct the world. All physics entities are destroyed and all heap memory is released.
	*/
	//~b2World();

	/**
	* Register a destruction listener.
	*/
	public function setDestructionListener(listener:B2DestructionListener) : Void{
		m_destructionListener = listener;
	}

	/**
	* Register a contact filter to provide specific control over collision.
	* Otherwise the default filter is used (b2_defaultFilter).
	*/
	public function setContactFilter(filter:B2ContactFilter) : Void{
		m_contactManager.m_contactFilter = filter;
	}

	/**
	* Register a contact event listener
	*/
	public function setContactListener(listener:B2ContactListener) : Void{
		m_contactManager.m_contactListener = listener;
	}

	/**
	* Register a routine for debug drawing. The debug draw functions are called
	* inside the b2World::Step method, so make sure your renderer is ready to
	* consume draw commands when you call Step().
	*/
	public function setDebugDraw(debugDraw:B2DebugDraw) : Void{
		m_debugDraw = debugDraw;
	}
	
	/**
	 * Use the given object as a broadphase.
	 * The old broadphase will not be cleanly emptied.
	 * @warning It is not recommended you call this except immediately after constructing the world.
	 * @warning This function is locked during callbacks.
	 */
	public function setBroadPhase(broadPhase:IBroadPhase) : Void {
		var oldBroadPhase:IBroadPhase = m_contactManager.m_broadPhase;
		m_contactManager.m_broadPhase = broadPhase;
		var b:B2Body = m_bodyList;
		while (b != null)
		{
			var f:B2Fixture = b.m_fixtureList;
			while (f != null)
			{
				f.m_proxy = broadPhase.createProxy(oldBroadPhase.getFatAABB(f.m_proxy), f);
				f = f.m_next;
			}
			b = b.m_next;
		}
	}
	
	/**
	* Perform validation of internal data structures.
	*/
	public function validate() : Void
	{
		m_contactManager.m_broadPhase.validate();
	}
	
	/**
	* Get the number of broad-phase proxies.
	*/
	public function getProxyCount() : Int
	{
		return m_contactManager.m_broadPhase.getProxyCount();
	}
	
	/**
	* Create a rigid body given a definition. No reference to the definition
	* is retained.
	* @warning This function is locked during callbacks.
	*/
	public function createBody(def:B2BodyDef) : B2Body{
		
		//b2Settings.b2Assert(m_lock == false);
		if (isLocked() == true)
		{
			return null;
		}
		
		//void* mem = m_blockAllocator.Allocate(sizeof(b2Body));
		var b:B2Body = new B2Body(def, this);
		
		// Add to world doubly linked list.
		b.m_prev = null;
		b.m_next = m_bodyList;
		if (m_bodyList != null)
		{
			m_bodyList.m_prev = b;
		}
		m_bodyList = b;
		++m_bodyCount;
		
		return b;
		
	}

	/**
	* Destroy a rigid body given a definition. No reference to the definition
	* is retained. This function is locked during callbacks.
	* @warning This automatically deletes all associated shapes and joints.
	* @warning This function is locked during callbacks.
	*/
	public function destroyBody(b:B2Body) : Void{
		
		//b2Settings.b2Assert(m_bodyCount > 0);
		//b2Settings.b2Assert(m_lock == false);
		if (isLocked() == true)
		{
			return;
		}
		
		// Delete the attached joints.
		var jn:B2JointEdge = b.m_jointList;
		while (jn != null)
		{
			var jn0:B2JointEdge = jn;
			jn = jn.next;
			
			if (m_destructionListener != null)
			{
				m_destructionListener.sayGoodbyeJoint(jn0.joint);
			}
			
			destroyJoint(jn0.joint);
		}
		
		// Detach controllers attached to this body
		var coe:B2ControllerEdge = b.m_controllerList;
		while (coe != null)
		{
			var coe0:B2ControllerEdge = coe;
			coe = coe.nextController;
			coe0.controller.removeBody(b);
		}
		
		// Delete the attached contacts.
		var ce:B2ContactEdge = b.m_contactList;
		while (ce != null)
		{
			var ce0:B2ContactEdge = ce;
			ce = ce.next;
			m_contactManager.destroy(ce0.contact);
		}
		b.m_contactList = null;
		
		// Delete the attached fixtures. This destroys broad-phase
		// proxies.
		var f:B2Fixture = b.m_fixtureList;
		while (f != null)
		{
			var f0:B2Fixture = f;
			f = f.m_next;
			
			if (m_destructionListener != null)
			{
				m_destructionListener.sayGoodbyeFixture(f0);
			}
			
			f0.destroyProxy(m_contactManager.m_broadPhase);
			f0.destroy();
			//f0->~b2Fixture();
			//m_blockAllocator.Free(f0, sizeof(b2Fixture));
			
		}
		b.m_fixtureList = null;
		b.m_fixtureCount = 0;
		
		// Remove world body list.
		if (b.m_prev != null)
		{
			b.m_prev.m_next = b.m_next;
		}
		
		if (b.m_next != null)
		{
			b.m_next.m_prev = b.m_prev;
		}
		
		if (b == m_bodyList)
		{
			m_bodyList = b.m_next;
		}
		
		--m_bodyCount;
		//b->~b2Body();
		//m_blockAllocator.Free(b, sizeof(b2Body));
		
	}

	/**
	* Create a joint to constrain bodies together. No reference to the definition
	* is retained. This may cause the connected bodies to cease colliding.
	* @warning This function is locked during callbacks.
	*/
	public function createJoint(def:B2JointDef) : B2Joint{
		
		//b2Settings.b2Assert(m_lock == false);
		
		var j:B2Joint = B2Joint.create(def, null);
		
		// Connect to the world list.
		j.m_prev = null;
		j.m_next = m_jointList;
		if (m_jointList != null)
		{
			m_jointList.m_prev = j;
		}
		m_jointList = j;
		++m_jointCount;
		
		// Connect to the bodies' doubly linked lists.
		j.m_edgeA.joint = j;
		j.m_edgeA.other = j.m_bodyB;
		j.m_edgeA.prev = null;
		j.m_edgeA.next = j.m_bodyA.m_jointList;
		if (j.m_bodyA.m_jointList != null) j.m_bodyA.m_jointList.prev = j.m_edgeA;
		j.m_bodyA.m_jointList = j.m_edgeA;
		
		j.m_edgeB.joint = j;
		j.m_edgeB.other = j.m_bodyA;
		j.m_edgeB.prev = null;
		j.m_edgeB.next = j.m_bodyB.m_jointList;
		if (j.m_bodyB.m_jointList != null) j.m_bodyB.m_jointList.prev = j.m_edgeB;
		j.m_bodyB.m_jointList = j.m_edgeB;
		
		var bodyA:B2Body = def.bodyA;
		var bodyB:B2Body = def.bodyB;
		
		// If the joint prevents collisions, then flag any contacts for filtering.
		if (def.collideConnected == false )
		{
			var edge:B2ContactEdge = bodyB.getContactList();
			while (edge != null)
			{
				if (edge.other == bodyA)
				{
					// Flag the contact for filtering at the next time step (where either
					// body is awake).
					edge.contact.flagForFiltering();
				}

				edge = edge.next;
			}
		}
		
		// Note: creating a joint doesn't wake the bodies.
		
		return j;
		
	}

	/**
	* Destroy a joint. This may cause the connected bodies to begin colliding.
	* @warning This function is locked during callbacks.
	*/
	public function destroyJoint(j:B2Joint) : Void{
		
		//b2Settings.b2Assert(m_lock == false);
		
		var collideConnected:Bool = j.m_collideConnected;
		
		// Remove from the doubly linked list.
		if (j.m_prev != null)
		{
			j.m_prev.m_next = j.m_next;
		}
		
		if (j.m_next != null)
		{
			j.m_next.m_prev = j.m_prev;
		}
		
		if (j == m_jointList)
		{
			m_jointList = j.m_next;
		}
		
		// Disconnect from island graph.
		var bodyA:B2Body = j.m_bodyA;
		var bodyB:B2Body = j.m_bodyB;
		
		// Wake up connected bodies.
		bodyA.setAwake(true);
		bodyB.setAwake(true);
		
		// Remove from body 1.
		if (j.m_edgeA.prev != null)
		{
			j.m_edgeA.prev.next = j.m_edgeA.next;
		}
		
		if (j.m_edgeA.next != null)
		{
			j.m_edgeA.next.prev = j.m_edgeA.prev;
		}
		
		if (j.m_edgeA == bodyA.m_jointList)
		{
			bodyA.m_jointList = j.m_edgeA.next;
		}
		
		j.m_edgeA.prev = null;
		j.m_edgeA.next = null;
		
		// Remove from body 2
		if (j.m_edgeB.prev != null)
		{
			j.m_edgeB.prev.next = j.m_edgeB.next;
		}
		
		if (j.m_edgeB.next != null)
		{
			j.m_edgeB.next.prev = j.m_edgeB.prev;
		}
		
		if (j.m_edgeB == bodyB.m_jointList)
		{
			bodyB.m_jointList = j.m_edgeB.next;
		}
		
		j.m_edgeB.prev = null;
		j.m_edgeB.next = null;
		
		B2Joint.destroy(j, null);
		
		//b2Settings.b2Assert(m_jointCount > 0);
		--m_jointCount;
		
		// If the joint prevents collisions, then flag any contacts for filtering.
		if (collideConnected == false)
		{
			var edge:B2ContactEdge = bodyB.getContactList();
			while (edge != null)
			{
				if (edge.other == bodyA)
				{
					// Flag the contact for filtering at the next time step (where either
					// body is awake).
					edge.contact.flagForFiltering();
				}

				edge = edge.next;
			}
		}
		
	}
	
	/**
	 * Add a controller to the world list
	 */
	public function addController(c:B2Controller) : B2Controller
	{
		c.m_next = m_controllerList;
		c.m_prev = null;
		m_controllerList = c;
		
		c.m_world = this;
		
		m_controllerCount++;
		
		return c;
	}
	
	public function removeController(c:B2Controller) : Void
	{
		//TODO: Remove bodies from controller
		if (c.m_prev != null)
			c.m_prev.m_next = c.m_next;
		if (c.m_next != null)
			c.m_next.m_prev = c.m_prev;
		if (m_controllerList == c)
			m_controllerList = c.m_next;
			
		m_controllerCount--;
	}

	public function createController(controller:B2Controller):B2Controller
	{
		if (controller.m_world != this)
			throw "Controller can only be a member of one world";
			//throw new Error("Controller can only be a member of one world");
		
		controller.m_next = m_controllerList;
		controller.m_prev = null;
		if (m_controllerList != null)
			m_controllerList.m_prev = controller;
		m_controllerList = controller;
		++m_controllerCount;
		
		controller.m_world = this;
		
		return controller;
	}
	
	public function destroyController(controller:B2Controller):Void
	{
		//b2Settings.b2Assert(m_controllerCount > 0);
		controller.clear();
		if (controller.m_next != null)
			controller.m_next.m_prev = controller.m_prev;
		if (controller.m_prev != null)
			controller.m_prev.m_next = controller.m_next;
		if (controller == m_controllerList)
			m_controllerList = controller.m_next;
		--m_controllerCount;
	}
	
	/**
	* Enable/disable warm starting. For testing.
	*/
	public function setWarmStarting(flag: Bool) : Void { m_warmStarting = flag; }

	/**
	* Enable/disable continuous physics. For testing.
	*/
	public function setContinuousPhysics(flag: Bool) : Void { m_continuousPhysics = flag; }
	
	/**
	* Get the number of bodies.
	*/
	public function getBodyCount() : Int
	{
		return m_bodyCount;
	}
	
	/**
	* Get the number of joints.
	*/
	public function getJointCount() : Int
	{
		return m_jointCount;
	}
	
	/**
	* Get the number of contacts (each may have 0 or more contact points).
	*/
	public function getContactCount() : Int
	{
		return m_contactCount;
	}
	
	/**
	* Change the global gravity vector.
	*/
	public function setGravity(gravity: B2Vec2): Void
	{
		m_gravity = gravity;
	}

	/**
	* Get the global gravity vector.
	*/
	public function getGravity():B2Vec2{
		return m_gravity;
	}

	/**
	* The world provides a single static ground body with no collision shapes.
	* You can use this to simplify the creation of joints and static shapes.
	*/
	public function getGroundBody() : B2Body{
		return m_groundBody;
	}

	private static var s_timestep2:B2TimeStep = new B2TimeStep();
	/**
	* Take a time step. This performs collision detection, integration,
	* and constraint solution.
	* @param timeStep the amount of time to simulate, this should not vary.
	* @param velocityIterations for the velocity constraint solver.
	* @param positionIterations for the position constraint solver.
	*/
	public function step(dt:Float, velocityIterations:Int, positionIterations:Int) : Void{
		B2Vec2.freePool();
		
		if ((m_flags & e_newFixture) != 0)
		{
			m_contactManager.findNewContacts();
			m_flags &= ~e_newFixture;
		}
		
		m_flags |= e_locked;
		
		var step:B2TimeStep = s_timestep2;
		step.dt = dt;
		step.velocityIterations = velocityIterations;
		step.positionIterations = positionIterations;
		if (dt > 0.0)
		{
			step.inv_dt = 1.0 / dt;
		}
		else
		{
			step.inv_dt = 0.0;
		}
		
		step.dtRatio = m_inv_dt0 * dt;
		
		step.warmStarting = m_warmStarting;
		
		// Update contacts.
		m_contactManager.collide();
		
		// Integrate velocities, solve velocity constraints, and integrate positions.
		if (step.dt > 0.0)
		{
			solve(step);
		}
		
		// Handle TOI events.
		if (m_continuousPhysics && step.dt > 0.0)
		{
			solveTOI(step);
		}
		
		if (step.dt > 0.0)
		{
			m_inv_dt0 = step.inv_dt;
		}
		m_flags &= ~e_locked;
	}
	
	/**
	 * Call this after you are done with time steps to clear the forces. You normally
	 * call this after each call to Step, unless you are performing sub-steps.
	 */
	public function clearForces() : Void
	{
		var body:B2Body = m_bodyList;
		while (body != null)
		{
			body.m_force.setZero();
			body.m_torque = 0.0;
			body = body.m_next;
		}
	}
	
	static private var s_xf:B2Transform = new B2Transform();
	/**
	 * Call this to draw shapes and other debug draw data.
	 */
	public function drawDebugData() : Void{
		if (m_debugDraw == null)
		{
			return;
		}
		
		m_debugDraw.m_sprite.graphics.clear();
		
		var flags:Int = m_debugDraw.getFlags();
		
		var i:Int;
		var b:B2Body;
		var f:B2Fixture;
		var s:B2Shape;
		var j:B2Joint;
		var bp:IBroadPhase;
		var invQ:B2Vec2 = new B2Vec2 ();
		var x1:B2Vec2 = new B2Vec2 ();
		var x2:B2Vec2 = new B2Vec2 ();
		var xf:B2Transform;
		var b1:B2AABB = new B2AABB();
		var b2:B2AABB = new B2AABB();
		var vs:Array <B2Vec2> = [new B2Vec2(), new B2Vec2(), new B2Vec2(), new B2Vec2()];
		
		// Store color here and reuse, to reduce allocations
		var color:B2Color = new B2Color(0, 0, 0);
			
		if ((flags & B2DebugDraw.e_shapeBit) != 0)
		{
			b = m_bodyList;
			while (b != null)
			{
				xf = b.m_xf;
				f = b.getFixtureList();
				while (f != null)
				{
					s = f.getShape();
					if (b.isActive() == false)
					{
						color.set(0.5, 0.5, 0.3);
						drawShape(s, xf, color);
					}
					else if (b.getType() == B2Body.b2_staticBody)
					{
						color.set(0.5, 0.9, 0.5);
						drawShape(s, xf, color);
					}
					else if (b.getType() == B2Body.b2_kinematicBody)
					{
						color.set(0.5, 0.5, 0.9);
						drawShape(s, xf, color);
					}
					else if (b.isAwake() == false)
					{
						color.set(0.6, 0.6, 0.6);
						drawShape(s, xf, color);
					}
					else
					{
						color.set(0.9, 0.7, 0.7);
						drawShape(s, xf, color);
					}
					f = f.m_next;
				}
				b = b.m_next;
			}
		}
		
		if ((flags & B2DebugDraw.e_jointBit) != 0)
		{
			j = m_jointList;
			while (j != null)
			{
				drawJoint(j);
				j = j.m_next;
			}
		}
		
		if ((flags & B2DebugDraw.e_controllerBit) != 0)
		{
			var c:B2Controller = m_controllerList;
			while (c != null)
			{
				c.draw(m_debugDraw);
				c = c.m_next;
			}
		}
		
		if ((flags & B2DebugDraw.e_pairBit) != 0)
		{
			color.set(0.3, 0.9, 0.9);
			var contact:B2Contact = m_contactManager.m_contactList;
			while (contact != null)
			{
				var fixtureA:B2Fixture = contact.getFixtureA();
				var fixtureB:B2Fixture = contact.getFixtureB();

				var cA:B2Vec2 = fixtureA.getAABB().getCenter();
				var cB:B2Vec2 = fixtureB.getAABB().getCenter();

				m_debugDraw.drawSegment(cA, cB, color);
				contact = contact.getNext();
			}
		}
		
		if ((flags & B2DebugDraw.e_aabbBit) != 0)
		{
			bp = m_contactManager.m_broadPhase;
			
			vs = [new B2Vec2(),new B2Vec2(),new B2Vec2(),new B2Vec2()];
			
			b= m_bodyList;
			while (b != null)
			{
				if (b.isActive() == false)
				{
					b = b.getNext();
					continue;
				}
				f = b.getFixtureList();
				while (f != null)
				{
					var aabb:B2AABB = bp.getFatAABB(f.m_proxy);
					vs[0].set(aabb.lowerBound.x, aabb.lowerBound.y);
					vs[1].set(aabb.upperBound.x, aabb.lowerBound.y);
					vs[2].set(aabb.upperBound.x, aabb.upperBound.y);
					vs[3].set(aabb.lowerBound.x, aabb.upperBound.y);

					m_debugDraw.drawPolygon(vs, 4, color);
					f = f.getNext();
				}
				b = b.getNext();
			}
		}
		
		if ((flags & B2DebugDraw.e_centerOfMassBit) != 0)
		{
			b = m_bodyList;
			while (b != null)
			{
				xf = s_xf;
				xf.R = b.m_xf.R;
				xf.position = b.getWorldCenter();
				m_debugDraw.drawTransform(xf);
				b = b.m_next;
			}
		}
	}

	/**
	 * Query the world for all fixtures that potentially overlap the
	 * provided AABB.
	 * @param callback a user implemented callback class. It should match signature
	 * <code>function Callback(fixture:B2Fixture):Bool</code>
	 * Return true to continue to the next fixture.
	 * @param aabb the query box.
	 */
	public function queryAABB(callbackMethod:B2Fixture -> Dynamic, aabb:B2AABB):Void
	{
		var broadPhase:IBroadPhase = m_contactManager.m_broadPhase;
		function worldQueryWrapper(proxy:Dynamic):Bool
		{
			return callbackMethod(broadPhase.getUserData(proxy));
		}
		broadPhase.query(worldQueryWrapper, aabb);
	}
	/**
	 * Query the world for all fixtures that precisely overlap the
	 * provided transformed shape.
	 * @param callback a user implemented callback class. It should match signature
	 * <code>function Callback(fixture:B2Fixture):Bool</code>
	 * Return true to continue to the next fixture.
	 * @asonly
	 */
	public function queryShape(callbackMethod:B2Fixture -> Dynamic, shape:B2Shape, transform:B2Transform = null):Void
	{
		if (transform == null)
		{
			transform = new B2Transform();
			transform.setIdentity();
		}
		var broadPhase:IBroadPhase = m_contactManager.m_broadPhase;
		function worldQueryWrapper(proxy:Dynamic):Bool
		{
			var fixture:B2Fixture = cast (broadPhase.getUserData(proxy), B2Fixture);
			if(B2Shape.testOverlap(shape, transform, fixture.getShape(), fixture.getBody().getTransform()))
				return callbackMethod(fixture);
			return true;
		}
		var aabb:B2AABB = new B2AABB();
		shape.computeAABB(aabb, transform);
		broadPhase.query(worldQueryWrapper, aabb);
	}
	
	/**
	 * Query the world for all fixtures that contain a point.
	 * @param callback a user implemented callback class. It should match signature
	 * <code>function Callback(fixture:B2Fixture):Bool</code>
	 * Return true to continue to the next fixture.
	 * @asonly
	 */
	public function queryPoint(callbackMethod:B2Fixture -> Dynamic, p:B2Vec2):Void
	{
		var broadPhase:IBroadPhase = m_contactManager.m_broadPhase;
		function worldQueryWrapper(proxy:Dynamic):Bool
		{
			var fixture:B2Fixture = cast (broadPhase.getUserData(proxy), B2Fixture);
			if(fixture.testPoint(p))
				return callbackMethod(fixture);
			return true;
		}
		// Make a small box.
		var aabb:B2AABB = new B2AABB();
		aabb.lowerBound.set(p.x - B2Settings.b2_linearSlop, p.y - B2Settings.b2_linearSlop);
		aabb.upperBound.set(p.x + B2Settings.b2_linearSlop, p.y + B2Settings.b2_linearSlop);
		broadPhase.query(worldQueryWrapper, aabb);
	}
	
	/**
	 * Ray-cast the world for all fixtures in the path of the ray. Your callback
	 * Controls whether you get the closest point, any point, or n-points
	 * The ray-cast ignores shapes that contain the starting point
	 * @param callback A callback function which must be of signature:
	 * <code>function Callback(fixture:B2Fixture,    // The fixture hit by the ray
	 * point:B2Vec2,         // The point of initial intersection
	 * normal:B2Vec2,        // The normal vector at the point of intersection
	 * fraction:Float       // The fractional length along the ray of the intersection
	 * ):Float
	 * </code>
	 * Callback should return the new length of the ray as a fraction of the original length.
	 * By returning 0, you immediately terminate.
	 * By returning 1, you continue wiht the original ray.
	 * By returning the current fraction, you proceed to find the closest point.
	 * @param point1 the ray starting point
	 * @param point2 the ray ending point
	 */
	public function rayCast(callbackMethod:B2Fixture -> B2Vec2 -> B2Vec2 -> Float -> Dynamic, point1:B2Vec2, point2:B2Vec2):Void
	{
		var broadPhase:IBroadPhase = m_contactManager.m_broadPhase;
		var output:B2RayCastOutput = new B2RayCastOutput ();
		function rayCastWrapper(input:B2RayCastInput, proxy:Dynamic):Float
		{
			var userData:Dynamic = broadPhase.getUserData(proxy);
			var fixture:B2Fixture = cast (userData, B2Fixture);
			var hit:Bool = fixture.rayCast(output, input);
			if (hit)
			{
				var fraction:Float = output.fraction;
				var point:B2Vec2 = new B2Vec2(
					(1.0 - fraction) * point1.x + fraction * point2.x,
					(1.0 - fraction) * point1.y + fraction * point2.y);
				return callbackMethod(fixture, point, output.normal, fraction);
			}
			return input.maxFraction;
		}
		var input:B2RayCastInput = new B2RayCastInput(point1, point2);
		broadPhase.rayCast(rayCastWrapper, input);
	}
	
	public function rayCastOne(point1:B2Vec2, point2:B2Vec2):B2Fixture
	{
		var result:B2Fixture;
		function rayCastOneWrapper(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Float
		{
			result = fixture;
			return fraction;
		}
		rayCast(rayCastOneWrapper, point1, point2);
		return result;
	}
	
	public function rayCastAll(point1:B2Vec2, point2:B2Vec2):Array <B2Fixture>
	{
		var result:Array <B2Fixture> = new Array <B2Fixture>();
		function rayCastAllWrapper(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Float
		{
			result[result.length] = fixture;
			return 1;
		}
		rayCast(rayCastAllWrapper, point1, point2);
		return result;
	}

	/**
	* Get the world body list. With the returned body, use b2Body::GetNext to get
	* the next body in the world list. A NULL body indicates the end of the list.
	* @return the head of the world body list.
	*/
	public function getBodyList() : B2Body{
		return m_bodyList;
	}

	/**
	* Get the world joint list. With the returned joint, use b2Joint::GetNext to get
	* the next joint in the world list. A NULL joint indicates the end of the list.
	* @return the head of the world joint list.
	*/
	public function getJointList() : B2Joint{
		return m_jointList;
	}

	/**
	 * Get the world contact list. With the returned contact, use b2Contact::GetNext to get
	 * the next contact in the world list. A NULL contact indicates the end of the list.
	 * @return the head of the world contact list.
	 * @warning contacts are 
	 */
	public function getContactList():B2Contact
	{
		return m_contactList;
	}
	
	/**
	 * Is the world locked (in the middle of a time step).
	 */
	public function isLocked():Bool
	{
		return (m_flags & e_locked) > 0;
	}

	//--------------- Internals Below -------------------
	// Internal yet public to make life easier.

	// Find islands, integrate and solve constraints, solve position constraints
	private var s_stack:Array <B2Body>;
	public function solve(step:B2TimeStep) : Void{
		var b:B2Body;
		
		// Step all controllers
		var controller:B2Controller= m_controllerList;
		while (controller != null)
		{
			controller.step(step);
			controller = controller.m_next;
		}
		
		// Size the island for the worst case.
		var island:B2Island = m_island;
		island.initialize(m_bodyCount, m_contactCount, m_jointCount, null, m_contactManager.m_contactListener, m_contactSolver);
		
		// Clear all the island flags.
		b = m_bodyList;
		while (b != null)
		{
			b.m_flags &= ~B2Body.e_islandFlag;
			b = b.m_next;
		}
		var c:B2Contact = m_contactList;
		while (c != null)
		{
			c.m_flags &= ~B2Contact.e_islandFlag;
			c = c.m_next;
		}
		var j:B2Joint = m_jointList;
		while (j != null)
		{
			j.m_islandFlag = false;
			j = j.m_next;
		}
		
		// Build and simulate all awake islands.
		var stackSize:Int = m_bodyCount;
		//b2Body** stack = (b2Body**)m_stackAllocator.Allocate(stackSize * sizeof(b2Body*));
		var stack:Array <B2Body> = s_stack;
		var seed:B2Body = m_bodyList;
		while (seed != null)
		{
			if ((seed.m_flags & B2Body.e_islandFlag) != 0)
			{
				seed = seed.m_next;
				continue;
			}
			
			//STENCYL
			if(!seed.isActive() && !seed.isAlwaysActive() && (seed.m_xf.position.x + seed.origin.x + seed.size.x >= m_aabb.lowerBound.x ||
									 seed.m_xf.position.y + seed.origin.y + seed.size.y >= m_aabb.lowerBound.y ||
									 seed.m_xf.position.x + seed.origin.x <= m_aabb.upperBound.x ||
									 seed.m_xf.position.y + seed.origin.y <= m_aabb.upperBound.y))
			{
				seed.setActive(true);
				seed.setAwake(true);
			}
			//END STENCYL
			
			if (seed.isAwake() == false || seed.isActive() == false || seed.isPaused())
			{
				seed = seed.m_next;
				continue;
			}
			
			// The seed can be dynamic or kinematic.
			if (seed.getType() == B2Body.b2_staticBody)
			{
				seed = seed.m_next;
				continue;
			}
			
			//STENCYL
			if(seed.isActive() && !seed.isAlwaysActive() && (seed.m_xf.position.x + seed.origin.x + seed.size.x <= m_aabb.lowerBound.x ||
									seed.m_xf.position.y + seed.origin.y + seed.size.y <= m_aabb.lowerBound.y ||
									seed.m_xf.position.x + seed.origin.x >= m_aabb.upperBound.x ||
									seed.m_xf.position.y + seed.origin.y >= m_aabb.upperBound.y))
			{
				seed.setAwake(false);
				seed.setActive(false);

				seed = seed.m_next;
				continue;
			}
			//END STENCYL
			
			// Reset island and stack.
			island.clear();
			var stackCount:Int = 0;
			stack[stackCount++] = seed;
			seed.m_flags |= B2Body.e_islandFlag;
			
			// Perform a depth first search (DFS) on the constraint graph.
			while (stackCount > 0)
			{
				// Grab the next body off the stack and add it to the island.
				b = stack[--stackCount];
				//b2Assert(b.IsActive() == true);
				island.addBody(b);
				
				// Make sure the body is awake.
				if (b.isAwake() == false)
				{
					b.setAwake(true);
				}
				
				// To keep islands as small as possible, we don't
				// propagate islands across static bodies.
				if (b.getType() == B2Body.b2_staticBody)
				{
					continue;
				}
				
				var other:B2Body;
				// Search all contacts connected to this body.
				var ce:B2ContactEdge = b.m_contactList;
				while (ce != null)
				{
					// Has this contact already been added to an island?
					if ((ce.contact.m_flags & B2Contact.e_islandFlag) != 0)
					{
						ce = ce.next;
						continue;
					}
					
					// Is this contact solid and touching?
					if (ce.contact.isSensor() == true ||
						ce.contact.isEnabled() == false ||
						ce.contact.isTouching() == false)
					{
						ce = ce.next;
						continue;
					}
					
					island.addContact(ce.contact);
					ce.contact.m_flags |= B2Contact.e_islandFlag;
					
					//var other:B2Body = ce.other;
					other = ce.other;
					
					// Was the other body already added to this island?
					if ((other.m_flags & B2Body.e_islandFlag) != 0)
					{
						ce = ce.next;
						continue;
					}
					
					//b2Settings.b2Assert(stackCount < stackSize);
					stack[stackCount++] = other;
					other.m_flags |= B2Body.e_islandFlag;
					ce = ce.next;
				}
				
				// Search all joints connect to this body.
				var jn:B2JointEdge = b.m_jointList;
				while (jn != null)
				{
					if (jn.joint.m_islandFlag == true)
					{
						jn = jn.next;
						continue;
					}
					
					other = jn.other;
					
					// Don't simulate joints connected to inactive bodies.
					if (other.isActive() == false)
					{
						jn = jn.next;
						continue;
					}
					
					island.addJoint(jn.joint);
					jn.joint.m_islandFlag = true;
					
					if ((other.m_flags & B2Body.e_islandFlag) != 0)
					{
						jn = jn.next;
						continue;
					}
					
					//b2Settings.b2Assert(stackCount < stackSize);
					stack[stackCount++] = other;
					other.m_flags |= B2Body.e_islandFlag;
					jn = jn.next;
				}
			}
			island.solve(step, m_gravity, m_allowSleep);
			
			// Post solve cleanup.
			for (i in 0...island.m_bodyCount)
			{
				// Allow static bodies to participate in other islands.
				b = island.m_bodies[i];
				if (b.getType() == B2Body.b2_staticBody)
				{
					b.m_flags &= ~B2Body.e_islandFlag;
				}
			}
			seed = seed.m_next;
		}
		
		//m_stackAllocator.Free(stack);
		for (i in 0...stack.length)
		{
			if (stack[i] == null) break;
			stack[i] = null;
		}
		
		// Synchronize fixutres, check for out of range bodies.
		b = m_bodyList;
		while (b != null)
		{
			if (b.isAwake() == false || b.isActive() == false)
			{
				b = b.m_next;
				continue;
			}
			
			if (b.getType() == B2Body.b2_staticBody)
			{
				b = b.m_next;
				continue;
			}
			
			// Update fixtures (for broad-phase).
			b.synchronizeFixtures();
			b = b.m_next;
		}
		
		// Look for new contacts.
		m_contactManager.findNewContacts();
		
	}
	
	private static var s_backupA:B2Sweep = new B2Sweep();
	private static var s_backupB:B2Sweep = new B2Sweep();
	private static var s_timestep:B2TimeStep = new B2TimeStep();
	private static var s_queue:Array <B2Body> = new Array <B2Body>();
	// Find TOI contacts and solve them.
	public function solveTOI(step:B2TimeStep) : Void{
		
		var b:B2Body;
		var fA:B2Fixture;
		var fB:B2Fixture;
		var bA:B2Body;
		var bB:B2Body;
		var cEdge:B2ContactEdge;
		var j:B2Joint;
		
		// Reserve an island and a queue for TOI island solution.
		var island:B2Island = m_island;
		island.initialize(m_bodyCount, B2Settings.b2_maxTOIContactsPerIsland, B2Settings.b2_maxTOIJointsPerIsland, null, m_contactManager.m_contactListener, m_contactSolver);
		
		//Simple one pass queue
		//Relies on the fact that we're only making one pass
		//through and each body can only be pushed/popped one.
		//To push:
		//  queue[queueStart+queueSize++] = newElement;
		//To pop:
		//  poppedElement = queue[queueStart++];
		//  --queueSize;
		
		var queue:Array <B2Body> = s_queue;
		
		b = m_bodyList;
		while (b != null)
		{
			b.m_flags &= ~B2Body.e_islandFlag;
			b.m_sweep.t0 = 0.0;
			b = b.m_next;
		}
		
		var c:B2Contact = m_contactList;
		while (c != null)
		{
			// Invalidate TOI
			c.m_flags &= ~(B2Contact.e_toiFlag | B2Contact.e_islandFlag);
			c = c.m_next;
		}
		
		j = m_jointList;
		while (j != null)
		{
			j.m_islandFlag = false;
			j = j.m_next;
		}
		
		// Find TOI events and solve them.
		
		
		while (true)
		{
			// Find the first TOI.
			var minContact:B2Contact = null;
			var minTOI:Float = 1.0;
			
			c = m_contactList;
			while (c != null)
			{
				// Can this contact generate a solid TOI contact?
 				if (c.isSensor() == true ||
					c.isEnabled() == false ||
					c.isContinuous() == false)
				{
					c = c.m_next;
					continue;
				}
				
				// TODO_ERIN keep a counter on the contact, only respond to M TOIs per contact.
				
				var toi:Float = 1.0;
				if ((c.m_flags & B2Contact.e_toiFlag) != 0)
				{
					// This contact has a valid cached TOI.
					toi = c.m_toi;
				}
				else
				{
					// Compute the TOI for this contact.
					fA = c.m_fixtureA;
					fB = c.m_fixtureB;
					bA = fA.m_body;
					bB = fB.m_body;
					
					if ((bA.getType() != B2Body.b2_dynamicBody || bA.isAwake() == false) &&
						(bB.getType() != B2Body.b2_dynamicBody || bB.isAwake() == false))
					{
						c = c.m_next;
						continue;
					}
					
					// Put the sweeps onto the same time interval.
					var t0:Float = bA.m_sweep.t0;
					
					if (bA.m_sweep.t0 < bB.m_sweep.t0)
					{
						t0 = bB.m_sweep.t0;
						bA.m_sweep.advance(t0);
					}
					else if (bB.m_sweep.t0 < bA.m_sweep.t0)
					{
						t0 = bA.m_sweep.t0;
						bB.m_sweep.advance(t0);
					}
					
					//b2Settings.b2Assert(t0 < 1.0f);
					
					// Compute the time of impact.
					toi = c.computeTOI(bA.m_sweep, bB.m_sweep);
					B2Settings.b2Assert(0.0 <= toi && toi <= 1.0);
					
					// If the TOI is in range ...
					if (toi > 0.0 && toi < 1.0)
					{
						// Interpolate on the actual range.
						//toi = Math.min((1.0 - toi) * t0 + toi, 1.0);
						toi = (1.0 - toi) * t0 + toi;
						if (toi > 1) toi = 1;
					}
					
					
					c.m_toi = toi;
					c.m_flags |= B2Contact.e_toiFlag;
				}
				
				if (B2Math.MIN_VALUE < toi && toi < minTOI)
				{
					// This is the minimum TOI found so far.
					minContact = c;
					minTOI = toi;
				}
				
				c = c.m_next;
			}
			
			if (minContact == null || 1.0 - 100.0 * B2Math.MIN_VALUE < minTOI)
			{
				// No more TOI events. Done!
				break;
			}
			
			// Advance the bodies to the TOI.
			fA = minContact.m_fixtureA;
			fB = minContact.m_fixtureB;
			bA = fA.m_body;
			bB = fB.m_body;
			s_backupA.set(bA.m_sweep);
			s_backupB.set(bB.m_sweep);
			bA.advance(minTOI);
			bB.advance(minTOI);
			
			// The TOI contact likely has some new contact points.
			minContact.update(m_contactManager.m_contactListener);
			minContact.m_flags &= ~B2Contact.e_toiFlag;
			
			// Is the contact solid?
			if (minContact.isSensor() == true ||
				minContact.isEnabled() == false)
			{
				// Restore the sweeps
				bA.m_sweep.set(s_backupA);
				bB.m_sweep.set(s_backupB);
				bA.synchronizeTransform();
				bB.synchronizeTransform();
				continue;
			}
			
			// Did numerical issues prevent;,ontact pointjrom being generated
			if (minContact.isTouching() == false)
			{
				// Give up on this TOI
				continue;
			}
			
			// Build the TOI island. We need a dynamic seed.
			var seed:B2Body = bA;
			if (seed.getType() != B2Body.b2_dynamicBody)
			{
				seed = bB;
			}
			
			// Reset island and queue.
			island.clear();
			var queueStart:Int = 0;	//start index for queue
			var queueSize:Int = 0;	//elements in queue
			queue[queueStart + queueSize++] = seed;
			seed.m_flags |= B2Body.e_islandFlag;
			
			// Perform a breadth first search (BFS) on the contact graph.
			while (queueSize > 0)
			{
				// Grab the next body off the stack and add it to the island.
				b = queue[queueStart++];
				--queueSize;
				
				island.addBody(b);
				
				// Make sure the body is awake.
				if (b.isAwake() == false)
				{
					b.setAwake(true);
				}
				
				// To keep islands as small as possible, we don't
				// propagate islands across static or kinematic bodies.
				if (b.getType() != B2Body.b2_dynamicBody)
				{
					continue;
				}
				
				// Search all contacts connected to this body.
				cEdge = b.m_contactList;
				var other:B2Body;
				while (cEdge != null)
				{
					// Does the TOI island still have space for contacts?
					if (island.m_contactCount == island.m_contactCapacity)
					{
						cEdge = cEdge.next;
						break;
					}
					
					// Has this contact already been added to an island?
					if ((cEdge.contact.m_flags & B2Contact.e_islandFlag) != 0)
					{
						cEdge = cEdge.next;
						continue;
					}
					
					// Skip sperate, sensor, or disabled contacts.
					if (cEdge.contact.isSensor() == true ||
						cEdge.contact.isEnabled() == false ||
						cEdge.contact.isTouching() == false)
					{
						cEdge = cEdge.next;
						continue;
					}
					
					island.addContact(cEdge.contact);
					cEdge.contact.m_flags |= B2Contact.e_islandFlag;
					
					// Update other body.
					other = cEdge.other;
					
					// Was the other body already added to this island?
					if ((other.m_flags & B2Body.e_islandFlag) != 0)
					{
						cEdge = cEdge.next;
						continue;
					}
					
					// Synchronize the connected body.
					if (other.getType() != B2Body.b2_staticBody)
					{
						other.advance(minTOI);
						other.setAwake(true);
					}
					
					//b2Settings.b2Assert(queueStart + queueSize < queueCapacity);
					queue[queueStart + queueSize] = other;
					++queueSize;
					other.m_flags |= B2Body.e_islandFlag;
					cEdge = cEdge.next;
				}
				
				var jEdge:B2JointEdge = b.m_jointList;
				while (jEdge != null)
				{
					if (island.m_jointCount == island.m_jointCapacity) {
						jEdge = jEdge.next;
						continue;
					}
					
					if (jEdge.joint.m_islandFlag == true) {
						jEdge = jEdge.next;
						continue;
					}
					
					other = jEdge.other;
					if (other.isActive() == false)
					{
						jEdge = jEdge.next;
						continue;
					}
					
					island.addJoint(jEdge.joint);
					jEdge.joint.m_islandFlag = true;
					
					if ((other.m_flags & B2Body.e_islandFlag) != 0) {
						jEdge = jEdge.next;
						continue;
					}
						
					// Synchronize the connected body.
					if (other.getType() != B2Body.b2_staticBody)
					{
						other.advance(minTOI);
						other.setAwake(true);
					}
					
					//b2Settings.b2Assert(queueStart + queueSize < queueCapacity);
					queue[queueStart + queueSize] = other;
					++queueSize;
					other.m_flags |= B2Body.e_islandFlag;
					jEdge = jEdge.next;
				}
			}
			
			var subStep:B2TimeStep = s_timestep;
			subStep.warmStarting = false;
			subStep.dt = (1.0 - minTOI) * step.dt;
			subStep.inv_dt = 1.0 / subStep.dt;
			subStep.dtRatio = 0.0;
			subStep.velocityIterations = step.velocityIterations;
			subStep.positionIterations = step.positionIterations;
			
			island.solveTOI(subStep);
			
			var i:Int;
			// Post solve cleanup.
			for (i in 0...island.m_bodyCount)
			{
				// Allow bodies to participate in future TOI islands.
				b = island.m_bodies[i];
				b.m_flags &= ~B2Body.e_islandFlag;
				
				if (b.isAwake() == false)
				{
					continue;
				}
				
				if (b.getType() != B2Body.b2_dynamicBody)
				{
					continue;
				}
				
				// Update fixtures (for broad-phase).
				b.synchronizeFixtures();
				
				// Invalidate all contact TOIs associated with this body. Some of these
				// may not be in the island because they were not touching.
				cEdge = b.m_contactList;
				while (cEdge != null)
				{
					cEdge.contact.m_flags &= ~B2Contact.e_toiFlag;
					cEdge = cEdge.next;
				}
			}
			
			for (i in 0...island.m_contactCount)
			{
				// Allow contacts to participate in future TOI islands.
				c = island.m_contacts[i];
				c.m_flags &= ~(B2Contact.e_toiFlag | B2Contact.e_islandFlag);
			}
			
			for (i in 0...island.m_jointCount)
			{
				// Allow joints to participate in future TOI islands
				j = island.m_joints[i];
				j.m_islandFlag = false;
			}
			
			// Commit fixture proxy movements to the broad-phase so that new contacts are created.
			// Also, some contacts can be destroyed.
			m_contactManager.findNewContacts();
		}
		
		//m_stackAllocator.Free(queue);
	}
	
	static private var s_jointColor:B2Color = new B2Color(0.5, 0.8, 0.8);
	//
	public function drawJoint(joint:B2Joint) : Void{
		
		var b1:B2Body = joint.getBodyA();
		var b2:B2Body = joint.getBodyB();
		var xf1:B2Transform = b1.m_xf;
		var xf2:B2Transform = b2.m_xf;
		var x1:B2Vec2 = xf1.position;
		var x2:B2Vec2 = xf2.position;
		var p1:B2Vec2 = joint.getAnchorA();
		var p2:B2Vec2 = joint.getAnchorB();
		
		//b2Color color(0.5f, 0.8f, 0.8f);
		var color:B2Color = s_jointColor;
		
		switch (joint.m_type)
		{
		case B2Joint.e_distanceJoint:
			m_debugDraw.drawSegment(p1, p2, color);
		
		case B2Joint.e_pulleyJoint:
			{
				var pulley:B2PulleyJoint = cast (joint, B2PulleyJoint);
				var s1:B2Vec2 = pulley.getGroundAnchorA();
				var s2:B2Vec2 = pulley.getGroundAnchorB();
				m_debugDraw.drawSegment(s1, p1, color);
				m_debugDraw.drawSegment(s2, p2, color);
				m_debugDraw.drawSegment(s1, s2, color);
			}
		
		case B2Joint.e_mouseJoint:
			m_debugDraw.drawSegment(p1, p2, color);
		
		default:
			if (b1 != m_groundBody)
				m_debugDraw.drawSegment(x1, p1, color);
			m_debugDraw.drawSegment(p1, p2, color);
			if (b2 != m_groundBody)
				m_debugDraw.drawSegment(x2, p2, color);
		}
	}
	
	public function drawShape(shape:B2Shape, xf:B2Transform, color:B2Color) : Void{
		
		switch (shape.m_type)
		{
		case B2Shape.e_circleShape:
			{
				var circle:B2CircleShape = cast (shape, B2CircleShape);
				
				var center:B2Vec2 = B2Math.mulX(xf, circle.m_p);
				var radius:Float = circle.m_radius;
				var axis:B2Vec2 = xf.R.col1;
				
				m_debugDraw.drawSolidCircle(center, radius, axis, color);
			}
		
		case B2Shape.e_polygonShape:
			{
				var i:Int;
				var poly:B2PolygonShape = cast (shape, B2PolygonShape);
				var vertexCount:Int = poly.getVertexCount();
				var localVertices:Array <B2Vec2> = poly.getVertices();
				
				var vertices:Array <B2Vec2> = new Array <B2Vec2> ();
				
				for (i in 0...vertexCount)
				{
					vertices[i] = B2Math.mulX(xf, localVertices[i]);
				}
				
				m_debugDraw.drawSolidPolygon(vertices, vertexCount, color);
			}
		
		case B2Shape.e_edgeShape:
			{
				var edge: B2EdgeShape = cast (shape, B2EdgeShape);
				
				m_debugDraw.drawSegment(B2Math.mulX(xf, edge.getVertex1()), B2Math.mulX(xf, edge.getVertex2()), color);
				
			}
		
		}
	}
	
	//STENCYL
	public var m_aabb:B2AABB;
	
	public function setScreenBounds(bounds:B2AABB) {
		m_aabb = bounds;
	}
	
	public function getScreenBounds():B2AABB {
		return m_aabb;
	}
	//END STENCYL
	
	public var m_flags:Int;

	public var m_contactManager:B2ContactManager;
	
	// These two are stored purely for efficiency purposes, they don't maintain
	// any data outside of a call to Step
	private var m_contactSolver:B2ContactSolver;
	private var m_island:B2Island;

	public var m_bodyList:B2Body;
	private var m_jointList:B2Joint;

	public var m_contactList:B2Contact;

	private var m_bodyCount:Int;
	public var m_contactCount:Int;
	private var m_jointCount:Int;
	private var m_controllerList:B2Controller;
	private var m_controllerCount:Int;

	public var m_gravity:B2Vec2;
	public var m_allowSleep:Bool;

	public var m_groundBody:B2Body;

	private var m_destructionListener:B2DestructionListener;
	private var m_debugDraw:B2DebugDraw;

	// This is used to compute the time step ratio to support a variable time step.
	private var m_inv_dt0:Float;

	// This is for debugging the solver.
	static public var m_warmStarting:Bool = true;

	// This is for debugging the solver.
	static public var m_continuousPhysics:Bool = false;
	
	// m_flags
	public static var e_newFixture:Int = 0x0001;
	public static var e_locked:Int = 0x0002;
	
}