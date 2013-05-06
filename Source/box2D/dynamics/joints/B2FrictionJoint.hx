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
	

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;


// Point-to-point constraint
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

// Angle constraint
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

/**
 * Friction joint. This is used for top-down friction.
 * It provides 2D translational friction and angular friction.
 * @see b2FrictionJointDef
 */
class B2FrictionJoint extends B2Joint
{
	/** @inheritDoc */
	public override function getAnchorA():B2Vec2{
		return m_bodyA.getWorldPoint(m_localAnchorA);
	}
	/** @inheritDoc */
	public override function getAnchorB():B2Vec2{
		return m_bodyB.getWorldPoint(m_localAnchorB);
	}
	
	/** @inheritDoc */
	public override function getReactionForce(inv_dt:Float):B2Vec2
	{
		return new B2Vec2(inv_dt * m_linearImpulse.x, inv_dt * m_linearImpulse.y);
	}

	/** @inheritDoc */
	public override function getReactionTorque(inv_dt:Float):Float
	{
		//B2_NOT_USED(inv_dt);
		return inv_dt * m_angularImpulse;
	}
	
	public function setMaxForce(force:Float):Void
	{
		m_maxForce = force;
	}
	
	public function getMaxForce():Float
	{
		return m_maxForce;
	}
	
	public function setMaxTorque(torque:Float):Void
	{
		m_maxTorque = torque;
	}
	
	public function getMaxTorque():Float
	{
		return m_maxTorque;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public function new (def:B2FrictionJointDef){
		super(def);
		
		m_localAnchorA = new B2Vec2();
		m_localAnchorB = new B2Vec2();
		m_linearMass = new B2Mat22();
		m_linearImpulse = new B2Vec2();
		
		m_localAnchorA.setV(def.localAnchorA);
		m_localAnchorB.setV(def.localAnchorB);
		
		m_linearMass.setZero();
		m_angularMass = 0.0;
		
		m_linearImpulse.setZero();
		m_angularImpulse = 0.0;
		
		m_maxForce = def.maxForce;
		m_maxTorque = def.maxTorque;
	}

	public override function initVelocityConstraints(step:B2TimeStep) : Void {
		var tMat:B2Mat22;
		var tX:Float;
		
		var bA:B2Body = m_bodyA;
		var bB:B2Body= m_bodyB;

		// Compute the effective mass matrix.
		//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var rAX:Float = m_localAnchorA.x - bA.m_sweep.localCenter.x;
		var rAY:Float = m_localAnchorA.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY);
		rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY);
		rAX = tX;
		//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var rBX:Float = m_localAnchorB.x - bB.m_sweep.localCenter.x;
		var rBY:Float = m_localAnchorB.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY);
		rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY);
		rBX = tX;

		// J = [-I -r1_skew I r2_skew]
		//     [ 0       -1 0       1]
		// r_skew = [-ry; rx]

		// Matlab
		// K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
		//     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
		//     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]

		var mA:Float = bA.m_invMass;
		var mB:Float = bB.m_invMass;
		var iA:Float = bA.m_invI;
		var iB:Float = bB.m_invI;

		var K:B2Mat22 = new B2Mat22();
		K.col1.x = mA + mB;	K.col2.x = 0.0;
		K.col1.y = 0.0;		K.col2.y = mA + mB;

		K.col1.x+=  iA * rAY * rAY;	K.col2.x+= -iA * rAX * rAY;
		K.col1.y+= -iA * rAX * rAY;	K.col2.y+=  iA * rAX * rAX;

		K.col1.x+=  iB * rBY * rBY;	K.col2.x+= -iB * rBX * rBY;
		K.col1.y+= -iB * rBX * rBY;	K.col2.y+=  iB * rBX * rBX;

		K.getInverse(m_linearMass);

		m_angularMass = iA + iB;
		if (m_angularMass > 0.0)
		{
			m_angularMass = 1.0 / m_angularMass;
		}

		if (step.warmStarting)
		{
			// Scale impulses to support a variable time step.
			m_linearImpulse.x *= step.dtRatio;
			m_linearImpulse.y *= step.dtRatio;
			m_angularImpulse *= step.dtRatio;

			var P:B2Vec2 = m_linearImpulse;

			bA.m_linearVelocity.x -= mA * P.x;
			bA.m_linearVelocity.y -= mA * P.y;
			bA.m_angularVelocity -= iA * (rAX * P.y - rAY * P.x + m_angularImpulse);

			bB.m_linearVelocity.x += mB * P.x;
			bB.m_linearVelocity.y += mB * P.y;
			bB.m_angularVelocity += iB * (rBX * P.y - rBY * P.x + m_angularImpulse);
		}
		else
		{
			m_linearImpulse.setZero();
			m_angularImpulse = 0.0;
		}

	}
	
	
	
	public override function solveVelocityConstraints(step:B2TimeStep): Void{
		//B2_NOT_USED(step);
		var tMat:B2Mat22;
		var tX:Float;

		var bA:B2Body = m_bodyA;
		var bB:B2Body= m_bodyB;

		var vA:B2Vec2 = bA.m_linearVelocity;
		var wA:Float = bA.m_angularVelocity;
		var vB:B2Vec2 = bB.m_linearVelocity;
		var wB:Float = bB.m_angularVelocity;

		var mA:Float = bA.m_invMass;
		var mB:Float = bB.m_invMass;
		var iA:Float = bA.m_invI;
		var iB:Float = bB.m_invI;

		//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var rAX:Float = m_localAnchorA.x - bA.m_sweep.localCenter.x;
		var rAY:Float = m_localAnchorA.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY);
		rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY);
		rAX = tX;
		//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var rBX:Float = m_localAnchorB.x - bB.m_sweep.localCenter.x;
		var rBY:Float = m_localAnchorB.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY);
		rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY);
		rBX = tX;
		
		var maxImpulse:Float;

		// Solve angular friction
		{
			var Cdot:Float = wB - wA;
			var impulse:Float = -m_angularMass * Cdot;

			var oldImpulse:Float = m_angularImpulse;
			maxImpulse = step.dt * m_maxTorque;
			m_angularImpulse = B2Math.clamp(m_angularImpulse + impulse, -maxImpulse, maxImpulse);
			impulse = m_angularImpulse - oldImpulse;

			wA -= iA * impulse;
			wB += iB * impulse;
		}

		// Solve linear friction
		{
			//b2Vec2 Cdot = vB + b2Cross(wB, rB) - vA - b2Cross(wA, rA);
			var CdotX:Float = vB.x - wB * rBY - vA.x + wA * rAY;
			var CdotY:Float = vB.y + wB * rBX - vA.y - wA * rAX;

			var impulseV:B2Vec2 = B2Math.mulMV(m_linearMass, new B2Vec2(-CdotX, -CdotY));
			var oldImpulseV:B2Vec2 = m_linearImpulse.copy();
			
			m_linearImpulse.add(impulseV);

			maxImpulse = step.dt * m_maxForce;

			if (m_linearImpulse.lengthSquared() > maxImpulse * maxImpulse)
			{
				m_linearImpulse.normalize();
				m_linearImpulse.multiply(maxImpulse);
			}

			impulseV = B2Math.subtractVV(m_linearImpulse, oldImpulseV);

			vA.x -= mA * impulseV.x;
			vA.y -= mA * impulseV.y;
			wA -= iA * (rAX * impulseV.y - rAY * impulseV.x);

			vB.x += mB * impulseV.x;
			vB.y += mB * impulseV.y;
			wB += iB * (rBX * impulseV.y - rBY * impulseV.x);
		}

		// References has made some sets unnecessary
		//bA->m_linearVelocity = vA;
		bA.m_angularVelocity = wA;
		//bB->m_linearVelocity = vB;
		bB.m_angularVelocity = wB;

	}
	
	public override function solvePositionConstraints(baumgarte:Float):Bool
	{
		//B2_NOT_USED(baumgarte);
		
		return true;
		
	}

	private var m_localAnchorA:B2Vec2;
	private var m_localAnchorB:B2Vec2;
	
	public var m_linearMass:B2Mat22;
	public var m_angularMass:Float;
	
	private var m_linearImpulse:B2Vec2;
	private var m_angularImpulse:Float;
	
	private var m_maxForce:Float;
	private var m_maxTorque:Float;
}