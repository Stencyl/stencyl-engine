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
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;

	
/**
* The pulley joint is connected to two bodies and two fixed ground points.
* The pulley supports a ratio such that:
* length1 + ratio * length2 <= constant
* Yes, the force transmitted is scaled by the ratio.
* The pulley also enforces a maximum length limit on both sides. This is
* useful to prevent one side of the pulley hitting the top.
* @see b2PulleyJointDef
*/
class B2PulleyJoint extends B2Joint
{
	/** @inheritDoc */
	public override function getAnchorA():B2Vec2{
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}
	/** @inheritDoc */
	public override function getAnchorB():B2Vec2{
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}

	/** @inheritDoc */
	public override function getReactionForce(inv_dt:Float) :B2Vec2
	{
		//b2Vec2 P = m_impulse * m_u2;
		//return inv_dt * P;
		return new B2Vec2(inv_dt * m_impulse * m_u2.x, inv_dt * m_impulse * m_u2.y);
	}

	/** @inheritDoc */
	public override function getReactionTorque(inv_dt:Float) :Float
	{
		//B2_NOT_USED(inv_dt);
		return 0.0;
	}

	/**
	 * Get the first ground anchor.
	 */
	public function getGroundAnchorA() :B2Vec2
	{
		//return m_ground.m_xf.position + m_groundAnchor1;
		var a:B2Vec2 = m_ground.m_xf.position.copy();
		a.add(m_groundAnchor1);
		return a;
	}

	/**
	 * Get the second ground anchor.
	 */
	public function getGroundAnchorB() :B2Vec2
	{
		//return m_ground.m_xf.position + m_groundAnchor2;
		var a:B2Vec2 = m_ground.m_xf.position.copy();
		a.add(m_groundAnchor2);
		return a;
	}

	/**
	 * Get the current length of the segment attached to body1.
	 */
	public function getLength1() :Float
	{
		var p:B2Vec2 = m_bodyA.getWorldPoint(m_localAnchor1);
		//b2Vec2 s = m_ground->m_xf.position + m_groundAnchor1;
		var sX:Float = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var sY:Float = m_ground.m_xf.position.y + m_groundAnchor1.y;
		//b2Vec2 d = p - s;
		var dX:Float = p.x - sX;
		var dY:Float = p.y - sY;
		//return d.Length();
		return Math.sqrt(dX*dX + dY*dY);
	}

	/**
	 * Get the current length of the segment attached to body2.
	 */
	public function getLength2() :Float
	{
		var p:B2Vec2 = m_bodyB.getWorldPoint(m_localAnchor2);
		//b2Vec2 s = m_ground->m_xf.position + m_groundAnchor2;
		var sX:Float = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var sY:Float = m_ground.m_xf.position.y + m_groundAnchor2.y;
		//b2Vec2 d = p - s;
		var dX:Float = p.x - sX;
		var dY:Float = p.y - sY;
		//return d.Length();
		return Math.sqrt(dX*dX + dY*dY);
	}

	/**
	 * Get the pulley ratio.
	 */
	public function getRatio():Float{
		return m_ratio;
	}

	//--------------- Internals Below -------------------

	/** @private */
	public function new (def:B2PulleyJointDef){
		
		// parent
		super(def);
		
		
		m_groundAnchor1 = new B2Vec2();
		m_groundAnchor2 = new B2Vec2();
		m_localAnchor1 = new B2Vec2();
		m_localAnchor2 = new B2Vec2();

		m_u1 = new B2Vec2();
		m_u2 = new B2Vec2();
	
		
		var tMat:B2Mat22;
		var tX:Float;
		var tY:Float;
		
		m_ground = m_bodyA.m_world.m_groundBody;
		//m_groundAnchor1 = def->groundAnchorA - m_ground->m_xf.position;
		m_groundAnchor1.x = def.groundAnchorA.x - m_ground.m_xf.position.x;
		m_groundAnchor1.y = def.groundAnchorA.y - m_ground.m_xf.position.y;
		//m_groundAnchor2 = def->groundAnchorB - m_ground->m_xf.position;
		m_groundAnchor2.x = def.groundAnchorB.x - m_ground.m_xf.position.x;
		m_groundAnchor2.y = def.groundAnchorB.y - m_ground.m_xf.position.y;
		//m_localAnchor1 = def->localAnchorA;
		m_localAnchor1.setV(def.localAnchorA);
		//m_localAnchor2 = def->localAnchorB;
		m_localAnchor2.setV(def.localAnchorB);
		
		//b2Settings.b2Assert(def.ratio != 0.0);
		m_ratio = def.ratio;
		
		m_constant = def.lengthA + m_ratio * def.lengthB;
		
		m_maxLength1 = B2Math.min(def.maxLengthA, m_constant - m_ratio * b2_minPulleyLength);
		m_maxLength2 = B2Math.min(def.maxLengthB, (m_constant - b2_minPulleyLength) / m_ratio);
		
		m_impulse = 0.0;
		m_limitImpulse1 = 0.0;
		m_limitImpulse2 = 0.0;
		
	}

	public override function initVelocityConstraints(step:B2TimeStep) : Void{
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var r1X:Float = m_localAnchor1.x - bA.m_sweep.localCenter.x;
		var r1Y:Float = m_localAnchor1.y - bA.m_sweep.localCenter.y;
		var tX:Float =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var r2X:Float = m_localAnchor2.x - bB.m_sweep.localCenter.x;
		var r2Y:Float = m_localAnchor2.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		//b2Vec2 p1 = bA->m_sweep.c + r1;
		var p1X:Float = bA.m_sweep.c.x + r1X;
		var p1Y:Float = bA.m_sweep.c.y + r1Y;
		//b2Vec2 p2 = bB->m_sweep.c + r2;
		var p2X:Float = bB.m_sweep.c.x + r2X;
		var p2Y:Float = bB.m_sweep.c.y + r2Y;
		
		//b2Vec2 s1 = m_ground->m_xf.position + m_groundAnchor1;
		var s1X:Float = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var s1Y:Float = m_ground.m_xf.position.y + m_groundAnchor1.y;
		//b2Vec2 s2 = m_ground->m_xf.position + m_groundAnchor2;
		var s2X:Float = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var s2Y:Float = m_ground.m_xf.position.y + m_groundAnchor2.y;
		
		// Get the pulley axes.
		//m_u1 = p1 - s1;
		m_u1.set(p1X - s1X, p1Y - s1Y);
		//m_u2 = p2 - s2;
		m_u2.set(p2X - s2X, p2Y - s2Y);
		
		var length1:Float = m_u1.length();
		var length2:Float = m_u2.length();
		
		if (length1 > B2Settings.b2_linearSlop)
		{
			//m_u1 *= 1.0f / length1;
			m_u1.multiply(1.0 / length1);
		}
		else
		{
			m_u1.setZero();
		}
		
		if (length2 > B2Settings.b2_linearSlop)
		{
			//m_u2 *= 1.0f / length2;
			m_u2.multiply(1.0 / length2);
		}
		else
		{
			m_u2.setZero();
		}
		
		var C:Float = m_constant - length1 - m_ratio * length2;
		if (C > 0.0)
		{
			m_state = B2Joint.e_inactiveLimit;
			m_impulse = 0.0;
		}
		else
		{
			m_state = B2Joint.e_atUpperLimit;
		}
		
		if (length1 < m_maxLength1)
		{
			m_limitState1 = B2Joint.e_inactiveLimit;
			m_limitImpulse1 = 0.0;
		}
		else
		{
			m_limitState1 = B2Joint.e_atUpperLimit;
		}
		
		if (length2 < m_maxLength2)
		{
			m_limitState2 = B2Joint.e_inactiveLimit;
			m_limitImpulse2 = 0.0;
		}
		else
		{
			m_limitState2 = B2Joint.e_atUpperLimit;
		}
		
		// Compute effective mass.
		//var cr1u1:Float = b2Cross(r1, m_u1);
		var cr1u1:Float = r1X * m_u1.y - r1Y * m_u1.x;
		//var cr2u2:Float = b2Cross(r2, m_u2);
		var cr2u2:Float = r2X * m_u2.y - r2Y * m_u2.x;
		
		m_limitMass1 = bA.m_invMass + bA.m_invI * cr1u1 * cr1u1;
		m_limitMass2 = bB.m_invMass + bB.m_invI * cr2u2 * cr2u2;
		m_pulleyMass = m_limitMass1 + m_ratio * m_ratio * m_limitMass2;
		//b2Settings.b2Assert(m_limitMass1 > Number.MIN_VALUE);
		//b2Settings.b2Assert(m_limitMass2 > Number.MIN_VALUE);
		//b2Settings.b2Assert(m_pulleyMass > Number.MIN_VALUE);
		m_limitMass1 = 1.0 / m_limitMass1;
		m_limitMass2 = 1.0 / m_limitMass2;
		m_pulleyMass = 1.0 / m_pulleyMass;
		
		if (step.warmStarting)
		{
			// Scale impulses to support variable time steps.
			m_impulse *= step.dtRatio;
			m_limitImpulse1 *= step.dtRatio;
			m_limitImpulse2 *= step.dtRatio;
			
			// Warm starting.
			//b2Vec2 P1 = (-m_impulse - m_limitImpulse1) * m_u1;
			var P1X:Float = (-m_impulse - m_limitImpulse1) * m_u1.x;
			var P1Y:Float = (-m_impulse - m_limitImpulse1) * m_u1.y;
			//b2Vec2 P2 = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2;
			var P2X:Float = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.x;
			var P2Y:Float = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.y;
			//bA.m_linearVelocity += bA.m_invMass * P1;
			bA.m_linearVelocity.x += bA.m_invMass * P1X;
			bA.m_linearVelocity.y += bA.m_invMass * P1Y;
			//bA.m_angularVelocity += bA.m_invI * b2Cross(r1, P1);
			bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X);
			//bB.m_linearVelocity += bB.m_invMass * P2;
			bB.m_linearVelocity.x += bB.m_invMass * P2X;
			bB.m_linearVelocity.y += bB.m_invMass * P2Y;
			//bB.m_angularVelocity += bB.m_invI * b2Cross(r2, P2);
			bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X);
		}
		else
		{
			m_impulse = 0.0;
			m_limitImpulse1 = 0.0;
			m_limitImpulse2 = 0.0;
		}
	}
	
	public override function solveVelocityConstraints(step:B2TimeStep) : Void 
	{
		//B2_NOT_USED(step)
		
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var r1X:Float = m_localAnchor1.x - bA.m_sweep.localCenter.x;
		var r1Y:Float = m_localAnchor1.y - bA.m_sweep.localCenter.y;
		var tX:Float =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var r2X:Float = m_localAnchor2.x - bB.m_sweep.localCenter.x;
		var r2Y:Float = m_localAnchor2.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		// temp vars
		var v1X:Float;
		var v1Y:Float;
		var v2X:Float;
		var v2Y:Float;
		var P1X:Float;
		var P1Y:Float;
		var P2X:Float;
		var P2Y:Float;
		var Cdot:Float;
		var impulse:Float;
		var oldImpulse:Float;
		
		if (m_state == B2Joint.e_atUpperLimit)
		{
			//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1);
			v1X = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y);
			v1Y = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X);
			//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2);
			v2X = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y);
			v2Y = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X);
			
			//Cdot = -b2Dot(m_u1, v1) - m_ratio * b2Dot(m_u2, v2);
			Cdot = -(m_u1.x * v1X + m_u1.y * v1Y) - m_ratio * (m_u2.x * v2X + m_u2.y * v2Y);
			impulse = m_pulleyMass * (-Cdot);
			oldImpulse = m_impulse;
			m_impulse = B2Math.max(0.0, m_impulse + impulse);
			impulse = m_impulse - oldImpulse;
			
			//b2Vec2 P1 = -impulse * m_u1;
			P1X = -impulse * m_u1.x;
			P1Y = -impulse * m_u1.y;
			//b2Vec2 P2 = - m_ratio * impulse * m_u2;
			P2X = -m_ratio * impulse * m_u2.x;
			P2Y = -m_ratio * impulse * m_u2.y;
			//bA.m_linearVelocity += bA.m_invMass * P1;
			bA.m_linearVelocity.x += bA.m_invMass * P1X;
			bA.m_linearVelocity.y += bA.m_invMass * P1Y;
			//bA.m_angularVelocity += bA.m_invI * b2Cross(r1, P1);
			bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X);
			//bB.m_linearVelocity += bB.m_invMass * P2;
			bB.m_linearVelocity.x += bB.m_invMass * P2X;
			bB.m_linearVelocity.y += bB.m_invMass * P2Y;
			//bB.m_angularVelocity += bB.m_invI * b2Cross(r2, P2);
			bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X);
		}
		
		if (m_limitState1 == B2Joint.e_atUpperLimit)
		{
			//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1);
			v1X = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y);
			v1Y = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X);
			
			//float32 Cdot = -b2Dot(m_u1, v1);
			Cdot = -(m_u1.x * v1X + m_u1.y * v1Y);
			impulse = -m_limitMass1 * Cdot;
			oldImpulse = m_limitImpulse1;
			m_limitImpulse1 = B2Math.max(0.0, m_limitImpulse1 + impulse);
			impulse = m_limitImpulse1 - oldImpulse;
			
			//b2Vec2 P1 = -impulse * m_u1;
			P1X = -impulse * m_u1.x;
			P1Y = -impulse * m_u1.y;
			//bA.m_linearVelocity += bA->m_invMass * P1;
			bA.m_linearVelocity.x += bA.m_invMass * P1X;
			bA.m_linearVelocity.y += bA.m_invMass * P1Y;
			//bA.m_angularVelocity += bA->m_invI * b2Cross(r1, P1);
			bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X);
		}
		
		if (m_limitState2 == B2Joint.e_atUpperLimit)
		{
			//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2);
			v2X = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y);
			v2Y = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X);
			
			//float32 Cdot = -b2Dot(m_u2, v2);
			Cdot = -(m_u2.x * v2X + m_u2.y * v2Y);
			impulse = -m_limitMass2 * Cdot;
			oldImpulse = m_limitImpulse2;
			m_limitImpulse2 = B2Math.max(0.0, m_limitImpulse2 + impulse);
			impulse = m_limitImpulse2 - oldImpulse;
			
			//b2Vec2 P2 = -impulse * m_u2;
			P2X = -impulse * m_u2.x;
			P2Y = -impulse * m_u2.y;
			//bB->m_linearVelocity += bB->m_invMass * P2;
			bB.m_linearVelocity.x += bB.m_invMass * P2X;
			bB.m_linearVelocity.y += bB.m_invMass * P2Y;
			//bB->m_angularVelocity += bB->m_invI * b2Cross(r2, P2);
			bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X);
		}
	}
	
	public override function solvePositionConstraints(baumgarte:Float):Bool 
	{
		//B2_NOT_USED(baumgarte)
		
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		
		//b2Vec2 s1 = m_ground->m_xf.position + m_groundAnchor1;
		var s1X:Float = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var s1Y:Float = m_ground.m_xf.position.y + m_groundAnchor1.y;
		//b2Vec2 s2 = m_ground->m_xf.position + m_groundAnchor2;
		var s2X:Float = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var s2Y:Float = m_ground.m_xf.position.y + m_groundAnchor2.y;
		
		// temp vars
		var r1X:Float;
		var r1Y:Float;
		var r2X:Float;
		var r2Y:Float;
		var p1X:Float;
		var p1Y:Float;
		var p2X:Float;
		var p2Y:Float;
		var length1:Float;
		var length2:Float;
		var C:Float;
		var impulse:Float;
		var oldImpulse:Float;
		var oldLimitPositionImpulse:Float;
		
		var tX:Float;
		
		var linearError:Float = 0.0;
		
		if (m_state == B2Joint.e_atUpperLimit)
		{
			//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
			tMat = bA.m_xf.R;
			r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x;
			r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
			r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
			r1X = tX;
			//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
			tMat = bB.m_xf.R;
			r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x;
			r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
			r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
			r2X = tX;
			
			//b2Vec2 p1 = bA->m_sweep.c + r1;
			p1X = bA.m_sweep.c.x + r1X;
			p1Y = bA.m_sweep.c.y + r1Y;
			//b2Vec2 p2 = bB->m_sweep.c + r2;
			p2X = bB.m_sweep.c.x + r2X;
			p2Y = bB.m_sweep.c.y + r2Y;
			
			// Get the pulley axes.
			//m_u1 = p1 - s1;
			m_u1.set(p1X - s1X, p1Y - s1Y);
			//m_u2 = p2 - s2;
			m_u2.set(p2X - s2X, p2Y - s2Y);
			
			length1 = m_u1.length();
			length2 = m_u2.length();
			
			if (length1 > B2Settings.b2_linearSlop)
			{
				//m_u1 *= 1.0f / length1;
				m_u1.multiply( 1.0 / length1 );
			}
			else
			{
				m_u1.setZero();
			}
			
			if (length2 > B2Settings.b2_linearSlop)
			{
				//m_u2 *= 1.0f / length2;
				m_u2.multiply( 1.0 / length2 );
			}
			else
			{
				m_u2.setZero();
			}
			
			C = m_constant - length1 - m_ratio * length2;
			linearError = B2Math.max(linearError, -C);
			C = B2Math.clamp(C + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0.0);
			impulse = -m_pulleyMass * C;
			
			p1X = -impulse * m_u1.x;
			p1Y = -impulse * m_u1.y;
			p2X = -m_ratio * impulse * m_u2.x;
			p2Y = -m_ratio * impulse * m_u2.y;
			
			bA.m_sweep.c.x += bA.m_invMass * p1X;
			bA.m_sweep.c.y += bA.m_invMass * p1Y;
			bA.m_sweep.a += bA.m_invI * (r1X * p1Y - r1Y * p1X);
			bB.m_sweep.c.x += bB.m_invMass * p2X;
			bB.m_sweep.c.y += bB.m_invMass * p2Y;
			bB.m_sweep.a += bB.m_invI * (r2X * p2Y - r2Y * p2X);
			
			bA.synchronizeTransform();
			bB.synchronizeTransform();
		}
		
		if (m_limitState1 == B2Joint.e_atUpperLimit)
		{
			//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
			tMat = bA.m_xf.R;
			r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x;
			r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
			r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
			r1X = tX;
			//b2Vec2 p1 = bA->m_sweep.c + r1;
			p1X = bA.m_sweep.c.x + r1X;
			p1Y = bA.m_sweep.c.y + r1Y;
			
			//m_u1 = p1 - s1;
			m_u1.set(p1X - s1X, p1Y - s1Y);
			
			length1 = m_u1.length();
			
			if (length1 > B2Settings.b2_linearSlop)
			{
				//m_u1 *= 1.0 / length1;
				m_u1.x *= 1.0 / length1;
				m_u1.y *= 1.0 / length1;
			}
			else
			{
				m_u1.setZero();
			}
			
			C = m_maxLength1 - length1;
			linearError = B2Math.max(linearError, -C);
			C = B2Math.clamp(C + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0.0);
			impulse = -m_limitMass1 * C;
			
			//P1 = -impulse * m_u1;
			p1X = -impulse * m_u1.x;
			p1Y = -impulse * m_u1.y;
			
			bA.m_sweep.c.x += bA.m_invMass * p1X;
			bA.m_sweep.c.y += bA.m_invMass * p1Y;
			//bA.m_rotation += bA.m_invI * b2Cross(r1, P1);
			bA.m_sweep.a += bA.m_invI * (r1X * p1Y - r1Y * p1X);
			
			bA.synchronizeTransform();
		}
		
		if (m_limitState2 == B2Joint.e_atUpperLimit)
		{
			//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
			tMat = bB.m_xf.R;
			r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x;
			r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
			r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
			r2X = tX;
			//b2Vec2 p2 = bB->m_position + r2;
			p2X = bB.m_sweep.c.x + r2X;
			p2Y = bB.m_sweep.c.y + r2Y;
			
			//m_u2 = p2 - s2;
			m_u2.set(p2X - s2X, p2Y - s2Y);
			
			length2 = m_u2.length();
			
			if (length2 > B2Settings.b2_linearSlop)
			{
				//m_u2 *= 1.0 / length2;
				m_u2.x *= 1.0 / length2;
				m_u2.y *= 1.0 / length2;
			}
			else
			{
				m_u2.setZero();
			}
			
			C = m_maxLength2 - length2;
			linearError = B2Math.max(linearError, -C);
			C = B2Math.clamp(C + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0.0);
			impulse = -m_limitMass2 * C;
			
			//P2 = -impulse * m_u2;
			p2X = -impulse * m_u2.x;
			p2Y = -impulse * m_u2.y;
			
			//bB.m_sweep.c += bB.m_invMass * P2;
			bB.m_sweep.c.x += bB.m_invMass * p2X;
			bB.m_sweep.c.y += bB.m_invMass * p2Y;
			//bB.m_sweep.a += bB.m_invI * b2Cross(r2, P2);
			bB.m_sweep.a += bB.m_invI * (r2X * p2Y - r2Y * p2X);
			
			bB.synchronizeTransform();
		}
		
		return linearError < B2Settings.b2_linearSlop;
	}
	
	

	private var m_ground:B2Body;
	private var m_groundAnchor1:B2Vec2;
	private var m_groundAnchor2:B2Vec2;
	private var m_localAnchor1:B2Vec2;
	private var m_localAnchor2:B2Vec2;

	private var m_u1:B2Vec2;
	private var m_u2:B2Vec2;
	
	private var m_constant:Float;
	private var m_ratio:Float;
	
	private var m_maxLength1:Float;
	private var m_maxLength2:Float;

	// Effective masses
	private var m_pulleyMass:Float;
	private var m_limitMass1:Float;
	private var m_limitMass2:Float;

	// Impulses for accumulation/warm starting.
	private var m_impulse:Float;
	private var m_limitImpulse1:Float;
	private var m_limitImpulse2:Float;

	private var m_state:Int;
	private var m_limitState1:Int;
	private var m_limitState2:Int;
	
	// static
	static public var b2_minPulleyLength:Float = 2.0;
}