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
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;


/**
* A gear joint is used to connect two joints together. Either joint
* can be a revolute or prismatic joint. You specify a gear ratio
* to bind the motions together:
* coordinate1 + ratio * coordinate2 = constant
* The ratio can be negative or positive. If one joint is a revolute joint
* and the other joint is a prismatic joint, then the ratio will have units
* of length or units of 1/length.
* @warning The revolute and prismatic joints must be attached to
* fixed bodies (which must be body1 on those joints).
* @see b2GearJointDef
*/

class B2GearJoint extends B2Joint
{
	/** @inheritDoc */
	public override function getAnchorA():B2Vec2{
		//return m_bodyA->GetWorldPoint(m_localAnchor1);
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}
	/** @inheritDoc */
	public override function getAnchorB():B2Vec2{
		//return m_bodyB->GetWorldPoint(m_localAnchor2);
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}
	/** @inheritDoc */
	public override function getReactionForce(inv_dt:Float):B2Vec2{
		// TODO_ERIN not tested
		// b2Vec2 P = m_impulse * m_J.linear2;
		//return inv_dt * P;
		return new B2Vec2(inv_dt * m_impulse * m_J.linearB.x, inv_dt * m_impulse * m_J.linearB.y);
	}
	/** @inheritDoc */
	public override function getReactionTorque(inv_dt:Float):Float{
		// TODO_ERIN not tested
		//b2Vec2 r = b2Mul(m_bodyB->m_xf.R, m_localAnchor2 - m_bodyB->GetLocalCenter());
		var tMat:B2Mat22 = m_bodyB.m_xf.R;
		var rX:Float = m_localAnchor1.x - m_bodyB.m_sweep.localCenter.x;
		var rY:Float = m_localAnchor1.y - m_bodyB.m_sweep.localCenter.y;
		var tX:Float = tMat.col1.x * rX + tMat.col2.x * rY;
		rY = tMat.col1.y * rX + tMat.col2.y * rY;
		rX = tX;
		//b2Vec2 P = m_impulse * m_J.linearB;
		var PX:Float = m_impulse * m_J.linearB.x;
		var PY:Float = m_impulse * m_J.linearB.y;
		//float32 L = m_impulse * m_J.angularB - b2Cross(r, P);
		//return inv_dt * L;
		return inv_dt * (m_impulse * m_J.angularB - rX * PY + rY * PX);
	}

	/**
	 * Get the gear ratio.
	 */
	public function getRatio():Float{
		return m_ratio;
	}
	
	/**
	 * Set the gear ratio.
	 */
	public function setRatio(ratio:Float):Void {
		//b2Settings.b2Assert(b2Math.b2IsValid(ratio));
		m_ratio = ratio;
	}

	//--------------- Internals Below -------------------

	/** @private */
	public function new (def:B2GearJointDef){
		// parent constructor
		super(def);
		
		m_groundAnchor1 = new B2Vec2();
		m_groundAnchor2 = new B2Vec2();

		m_localAnchor1 = new B2Vec2();
		m_localAnchor2 = new B2Vec2();

		m_J = new B2Jacobian();
		
		
		var type1:Int = def.joint1.m_type;
		var type2:Int = def.joint2.m_type;
		
		//b2Settings.b2Assert(type1 == b2Joint.e_revoluteJoint || type1 == b2Joint.e_prismaticJoint);
		//b2Settings.b2Assert(type2 == b2Joint.e_revoluteJoint || type2 == b2Joint.e_prismaticJoint);
		//b2Settings.b2Assert(def.joint1.GetBodyA().GetType() == b2Body.b2_staticBody);
		//b2Settings.b2Assert(def.joint2.GetBodyA().GetType() == b2Body.b2_staticBody);
		
		m_revolute1 = null;
		m_prismatic1 = null;
		m_revolute2 = null;
		m_prismatic2 = null;
		
		var coordinate1:Float;
		var coordinate2:Float;
		
		m_ground1 = def.joint1.getBodyA();
		m_bodyA = def.joint1.getBodyB();
		if (type1 == B2Joint.e_revoluteJoint)
		{
			m_revolute1 = cast (def.joint1, B2RevoluteJoint);
			m_groundAnchor1.setV( m_revolute1.m_localAnchor1 );
			m_localAnchor1.setV( m_revolute1.m_localAnchor2 );
			coordinate1 = m_revolute1.getJointAngle();
		}
		else
		{
			m_prismatic1 = cast (def.joint1, B2PrismaticJoint);
			m_groundAnchor1.setV( m_prismatic1.m_localAnchor1 );
			m_localAnchor1.setV( m_prismatic1.m_localAnchor2 );
			coordinate1 = m_prismatic1.getJointTranslation();
		}
		
		m_ground2 = def.joint2.getBodyA();
		m_bodyB = def.joint2.getBodyB();
		if (type2 == B2Joint.e_revoluteJoint)
		{
			m_revolute2 = cast (def.joint2, B2RevoluteJoint);
			m_groundAnchor2.setV( m_revolute2.m_localAnchor1 );
			m_localAnchor2.setV( m_revolute2.m_localAnchor2 );
			coordinate2 = m_revolute2.getJointAngle();
		}
		else
		{
			m_prismatic2 = cast (def.joint2, B2PrismaticJoint);
			m_groundAnchor2.setV( m_prismatic2.m_localAnchor1 );
			m_localAnchor2.setV( m_prismatic2.m_localAnchor2 );
			coordinate2 = m_prismatic2.getJointTranslation();
		}
		
		m_ratio = def.ratio;
		
		m_constant = coordinate1 + m_ratio * coordinate2;
		
		m_impulse = 0.0;
		
	}

	public override function initVelocityConstraints(step:B2TimeStep) : Void{
		var g1:B2Body = m_ground1;
		var g2:B2Body = m_ground2;
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		// temp vars
		var ugX:Float;
		var ugY:Float;
		var rX:Float;
		var rY:Float;
		var tMat:B2Mat22;
		var tVec:B2Vec2;
		var crug:Float;
		var tX:Float;
		
		var K:Float = 0.0;
		m_J.setZero();
		
		if (m_revolute1 != null)
		{
			m_J.angularA = -1.0;
			K += bA.m_invI;
		}
		else
		{
			//b2Vec2 ug = b2MulMV(g1->m_xf.R, m_prismatic1->m_localXAxis1);
			tMat = g1.m_xf.R;
			tVec = m_prismatic1.m_localXAxis1;
			ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
			ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
			//b2Vec2 r = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
			tMat = bA.m_xf.R;
			rX = m_localAnchor1.x - bA.m_sweep.localCenter.x;
			rY = m_localAnchor1.y - bA.m_sweep.localCenter.y;
			tX = tMat.col1.x * rX + tMat.col2.x * rY;
			rY = tMat.col1.y * rX + tMat.col2.y * rY;
			rX = tX;
			
			//var crug:Float = b2Cross(r, ug);
			crug = rX * ugY - rY * ugX;
			//m_J.linearA = -ug;
			m_J.linearA.set(-ugX, -ugY);
			m_J.angularA = -crug;
			K += bA.m_invMass + bA.m_invI * crug * crug;
		}
		
		if (m_revolute2 != null)
		{
			m_J.angularB = -m_ratio;
			K += m_ratio * m_ratio * bB.m_invI;
		}
		else
		{
			//b2Vec2 ug = b2Mul(g2->m_xf.R, m_prismatic2->m_localXAxis1);
			tMat = g2.m_xf.R;
			tVec = m_prismatic2.m_localXAxis1;
			ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
			ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
			//b2Vec2 r = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
			tMat = bB.m_xf.R;
			rX = m_localAnchor2.x - bB.m_sweep.localCenter.x;
			rY = m_localAnchor2.y - bB.m_sweep.localCenter.y;
			tX = tMat.col1.x * rX + tMat.col2.x * rY;
			rY = tMat.col1.y * rX + tMat.col2.y * rY;
			rX = tX;
			
			//float32 crug = b2Cross(r, ug);
			crug = rX * ugY - rY * ugX;
			//m_J.linearB = -m_ratio * ug;
			m_J.linearB.set(-m_ratio*ugX, -m_ratio*ugY);
			m_J.angularB = -m_ratio * crug;
			K += m_ratio * m_ratio * (bB.m_invMass + bB.m_invI * crug * crug);
		}
		
		// Compute effective mass.
		m_mass = K > 0.0?1.0 / K:0.0;
		
		if (step.warmStarting)
		{
			// Warm starting.
			//bA.m_linearVelocity += bA.m_invMass * m_impulse * m_J.linearA;
			bA.m_linearVelocity.x += bA.m_invMass * m_impulse * m_J.linearA.x;
			bA.m_linearVelocity.y += bA.m_invMass * m_impulse * m_J.linearA.y;
			bA.m_angularVelocity += bA.m_invI * m_impulse * m_J.angularA;
			//bB.m_linearVelocity += bB.m_invMass * m_impulse * m_J.linearB;
			bB.m_linearVelocity.x += bB.m_invMass * m_impulse * m_J.linearB.x;
			bB.m_linearVelocity.y += bB.m_invMass * m_impulse * m_J.linearB.y;
			bB.m_angularVelocity += bB.m_invI * m_impulse * m_J.angularB;
		}
		else
		{
			m_impulse = 0.0;
		}
	}
	
	public override function solveVelocityConstraints(step:B2TimeStep): Void
	{
		//B2_NOT_USED(step);
		
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var Cdot:Float = m_J.compute(	bA.m_linearVelocity, bA.m_angularVelocity,
										bB.m_linearVelocity, bB.m_angularVelocity);
		
		var impulse:Float = - m_mass * Cdot;
		m_impulse += impulse;
		
		bA.m_linearVelocity.x += bA.m_invMass * impulse * m_J.linearA.x;
		bA.m_linearVelocity.y += bA.m_invMass * impulse * m_J.linearA.y;
		bA.m_angularVelocity  += bA.m_invI * impulse * m_J.angularA;
		bB.m_linearVelocity.x += bB.m_invMass * impulse * m_J.linearB.x;
		bB.m_linearVelocity.y += bB.m_invMass * impulse * m_J.linearB.y;
		bB.m_angularVelocity  += bB.m_invI * impulse * m_J.angularB;
	}
	
	public override function solvePositionConstraints(baumgarte:Float):Bool
	{
		//B2_NOT_USED(baumgarte);
		
		var linearError:Float = 0.0;
		
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var coordinate1:Float;
		var coordinate2:Float;
		if (m_revolute1 != null)
		{
			coordinate1 = m_revolute1.getJointAngle();
		}
		else
		{
			coordinate1 = m_prismatic1.getJointTranslation();
		}
		
		if (m_revolute2 != null)
		{
			coordinate2 = m_revolute2.getJointAngle();
		}
		else
		{
			coordinate2 = m_prismatic2.getJointTranslation();
		}
		
		var C:Float = m_constant - (coordinate1 + m_ratio * coordinate2);
		
		var impulse:Float = -m_mass * C;
		
		bA.m_sweep.c.x += bA.m_invMass * impulse * m_J.linearA.x;
		bA.m_sweep.c.y += bA.m_invMass * impulse * m_J.linearA.y;
		bA.m_sweep.a += bA.m_invI * impulse * m_J.angularA;
		bB.m_sweep.c.x += bB.m_invMass * impulse * m_J.linearB.x;
		bB.m_sweep.c.y += bB.m_invMass * impulse * m_J.linearB.y;
		bB.m_sweep.a += bB.m_invI * impulse * m_J.angularB;
		
		bA.synchronizeTransform();
		bB.synchronizeTransform();
		
		// TODO_ERIN not implemented
		return linearError < B2Settings.b2_linearSlop;
	}

	private var m_ground1:B2Body;
	private var m_ground2:B2Body;

	// One of these is NULL.
	private var m_revolute1:B2RevoluteJoint;
	private var m_prismatic1:B2PrismaticJoint;

	// One of these is NULL.
	private var m_revolute2:B2RevoluteJoint;
	private var m_prismatic2:B2PrismaticJoint;

	private var m_groundAnchor1:B2Vec2;
	private var m_groundAnchor2:B2Vec2;

	private var m_localAnchor1:B2Vec2;
	private var m_localAnchor2:B2Vec2;

	private var m_J:B2Jacobian;

	private var m_constant:Float;
	private var m_ratio:Float;

	// Effective mass
	private var m_mass:Float;

	// Impulse for accumulation/warm starting.
	private var m_impulse:Float;
}