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

package box2D.dynamics.joints;


import box2D.common.B2Settings;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;


/**
* The base joint class. Joints are used to constraint two bodies together in
* various fashions. Some joints also feature limits and motors.
* @see b2JointDef
*/
class B2Joint
{
	/**
	* Get the type of the concrete joint.
	*/
	public function getType():Int{
		return m_type;
	}
	
	/**
	* Get the anchor point on bodyA in world coordinates.
	*/
	public function getAnchorA():B2Vec2 { return null; }
	/**
	* Get the anchor point on bodyB in world coordinates.
	*/
	public function getAnchorB():B2Vec2 { return null; }
	
	/**
	* Get the reaction force on body2 at the joint anchor in Newtons.
	*/
	public function getReactionForce(inv_dt:Float):B2Vec2 { return null; }
	/**
	* Get the reaction torque on body2 in N*m.
	*/
	public function getReactionTorque(inv_dt:Float):Float { return 0.0; }
	
	/**
	* Get the first body attached to this joint.
	*/
	public function getBodyA():B2Body
	{
		return m_bodyA;
	}
	
	/**
	* Get the second body attached to this joint.
	*/
	public function getBodyB():B2Body
	{
		return m_bodyB;
	}

	/**
	* Get the next joint the world joint list.
	*/
	public function getNext():B2Joint{
		return m_next;
	}

	/**
	* Get the user data pointer.
	*/
	public function getUserData():Dynamic{
		return m_userData;
	}

	/**
	* Set the user data pointer.
	*/
	public function setUserData(data:Dynamic):Void{
		m_userData = data;
	}

	/**
	 * Short-cut function to determine if either body is inactive.
	 * @return
	 */
	public function isActive():Bool {
		return m_bodyA.isActive() && m_bodyB.isActive();
	}
	
	//--------------- Internals Below -------------------

	static public function create(def:B2JointDef, allocator:Dynamic):B2Joint{
		var joint:B2Joint = null;
		
		switch (def.type)
		{
		case e_distanceJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2DistanceJoint));
				joint = new B2DistanceJoint(cast (def, B2DistanceJointDef));
			}
		
		case e_mouseJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2MouseJoint));
				joint = new B2MouseJoint(cast (def, B2MouseJointDef));
			}
		
		case e_prismaticJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2PrismaticJoint));
				joint = new B2PrismaticJoint(cast (def, B2PrismaticJointDef));
			}
		
		case e_revoluteJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2RevoluteJoint));
				joint = new B2RevoluteJoint(cast (def, B2RevoluteJointDef));
			}
		
		case e_pulleyJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2PulleyJoint));
				joint = new B2PulleyJoint(cast (def, B2PulleyJointDef));
			}
		
		case e_gearJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2GearJoint));
				joint = new B2GearJoint(cast (def, B2GearJointDef));
			}
		
		case e_lineJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2LineJoint));
				joint = new B2LineJoint(cast (def, B2LineJointDef));
			}
			
		case e_weldJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2WeldJoint));
				joint = new B2WeldJoint(cast (def, B2WeldJointDef));
			}
			
		case e_frictionJoint:
			{
				//void* mem = allocator->Allocate(sizeof(b2FrictionJoint));
				joint = new B2FrictionJoint(cast (def, B2FrictionJointDef));
			}
			
		default:
			//b2Settings.b2Assert(false);
		}
		
		return joint;
	}
	
	static public function destroy(joint:B2Joint, allocator:Dynamic) : Void{
		/*joint->~b2Joint();
		switch (joint.m_type)
		{
		case e_distanceJoint:
			allocator->Free(joint, sizeof(b2DistanceJoint));
			break;
		
		case e_mouseJoint:
			allocator->Free(joint, sizeof(b2MouseJoint));
			break;
		
		case e_prismaticJoint:
			allocator->Free(joint, sizeof(b2PrismaticJoint));
			break;
		
		case e_revoluteJoint:
			allocator->Free(joint, sizeof(b2RevoluteJoint));
			break;
		
		case e_pulleyJoint:
			allocator->Free(joint, sizeof(b2PulleyJoint));
			break;
		
		case e_gearJoint:
			allocator->Free(joint, sizeof(b2GearJoint));
			break;
		
		case e_lineJoint:
			allocator->Free(joint, sizeof(b2LineJoint));
			break;
			
		case e_weldJoint:
			allocator->Free(joint, sizeof(b2WeldJoint));
			break;
			
		case e_frictionJoint:
			allocator->Free(joint, sizeof(b2FrictionJoint));
			break;
		
		default:
			b2Assert(false);
			break;
		}*/
	}

	/** @private */
	public function new (def:B2JointDef) {
		
		m_edgeA = new B2JointEdge();
		m_edgeB = new B2JointEdge();
		m_localCenterA = new B2Vec2();
		m_localCenterB = new B2Vec2();
		
		B2Settings.b2Assert(def.bodyA != def.bodyB);
		m_type = def.type;
		m_prev = null;
		m_next = null;
		m_bodyA = def.bodyA;
		m_bodyB = def.bodyB;
		m_collideConnected = def.collideConnected;
		m_islandFlag = false;
		m_userData = def.userData;
	}
	//virtual ~b2Joint() {}

	public function initVelocityConstraints(step:B2TimeStep) : Void{}
	public function solveVelocityConstraints(step:B2TimeStep) : Void { }
	public function finalizeVelocityConstraints() : Void{}

	// This returns true if the position errors are within tolerance.
	public function solvePositionConstraints(baumgarte:Float):Bool { return false; }

	public var m_type:Int;
	public var m_prev:B2Joint;
	public var m_next:B2Joint;
	public var m_edgeA:B2JointEdge;
	public var m_edgeB:B2JointEdge;
	public var m_bodyA:B2Body;
	public var m_bodyB:B2Body;

	public var m_islandFlag:Bool;
	public var m_collideConnected:Bool;

	private var m_userData:Dynamic;
	
	// Cache here per time step to reduce cache misses.
	public var m_localCenterA:B2Vec2;
	public var m_localCenterB:B2Vec2;
	public var m_invMassA:Float;
	public var m_invMassB:Float;
	public var m_invIA:Float;
	public var m_invIB:Float;
	
	// ENUMS
	
	// enum b2JointType
	static public var e_unknownJoint:Int = 0;
	static public var e_revoluteJoint:Int = 1;
	static public var e_prismaticJoint:Int = 2;
	static public var e_distanceJoint:Int = 3;
	static public var e_pulleyJoint:Int = 4;
	static public var e_mouseJoint:Int = 5;
	static public var e_gearJoint:Int = 6;
	static public var e_lineJoint:Int = 7;
	static public var e_weldJoint:Int = 8;
	static public var e_frictionJoint:Int = 9;

	// enum b2LimitState
	static public var e_inactiveLimit:Int = 0;
	static public var e_atLowerLimit:Int = 1;
	static public var e_atUpperLimit:Int = 2;
	static public var e_equalLimits:Int = 3;
	
	//Stencyl
	public var ID:Int;
}