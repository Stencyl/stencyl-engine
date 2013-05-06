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
import box2D.common.math.B2Mat33;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Vec3;
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
 * A weld joint essentially glues two bodies together. A weld joint may
 * distort somewhat because the island constraint solver is approximate.
 */
class B2WeldJoint extends B2Joint
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
		return new B2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}

	/** @inheritDoc */
	public override function getReactionTorque(inv_dt:Float):Float
	{
		return inv_dt * m_impulse.z;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public function new (def:B2WeldJointDef){
		super(def);
		
		m_localAnchorA = new B2Vec2();
		m_localAnchorB = new B2Vec2();
		m_impulse = new B2Vec3();
		m_mass = new B2Mat33();
	
		
		m_localAnchorA.setV(def.localAnchorA);
		m_localAnchorB.setV(def.localAnchorB);
		m_referenceAngle = def.referenceAngle;

		m_impulse.setZero();
		m_mass = new B2Mat33();
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
		
		m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB;
		m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB;
		m_mass.col3.x = -rAY * iA - rBY * iB;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB;
		m_mass.col3.y = rAX * iA + rBX * iB;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = iA + iB;
		
		if (step.warmStarting)
		{
			// Scale impulses to support a variable time step.
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_impulse.z *= step.dtRatio;

			bA.m_linearVelocity.x -= mA * m_impulse.x;
			bA.m_linearVelocity.y -= mA * m_impulse.y;
			bA.m_angularVelocity -= iA * (rAX * m_impulse.y - rAY * m_impulse.x + m_impulse.z);

			bB.m_linearVelocity.x += mB * m_impulse.x;
			bB.m_linearVelocity.y += mB * m_impulse.y;
			bB.m_angularVelocity += iB * (rBX * m_impulse.y - rBY * m_impulse.x + m_impulse.z);
		}
		else
		{
			m_impulse.setZero();
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

		
		// Solve point-to-point constraint
		var Cdot1X:Float = vB.x - wB * rBY - vA.x + wA * rAY;
		var Cdot1Y:Float = vB.y + wB * rBX - vA.y - wA * rAX;
		var Cdot2:Float = wB - wA;
		var impulse:B2Vec3 = new B2Vec3();
		m_mass.solve33(impulse, -Cdot1X, -Cdot1Y, -Cdot2);
		
		m_impulse.add(impulse);
		
		vA.x -= mA * impulse.x;
		vA.y -= mA * impulse.y;
		wA -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z);

		vB.x += mB * impulse.x;
		vB.y += mB * impulse.y;
		wB += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z);

		// References has made some sets unnecessary
		//bA->m_linearVelocity = vA;
		bA.m_angularVelocity = wA;
		//bB->m_linearVelocity = vB;
		bB.m_angularVelocity = wB;

	}
	
	public override function solvePositionConstraints(baumgarte:Float):Bool
	{
		//B2_NOT_USED(baumgarte);
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
		
		//b2Vec2 C1 =  bB->m_sweep.c + rB - bA->m_sweep.c - rA;
		var C1X:Float =  bB.m_sweep.c.x + rBX - bA.m_sweep.c.x - rAX;
		var C1Y:Float =  bB.m_sweep.c.y + rBY - bA.m_sweep.c.y - rAY;
		var C2:Float = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle;

		// Handle large detachment.
		var k_allowedStretch:Float = 10.0 * B2Settings.b2_linearSlop;
		var positionError:Float = Math.sqrt(C1X * C1X + C1Y * C1Y);
		var angularError:Float = B2Math.abs(C2);
		if (positionError > k_allowedStretch)
		{
			iA *= 1.0;
			iB *= 1.0;
		}
		
		m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB;
		m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB;
		m_mass.col3.x = -rAY * iA - rBY * iB;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB;
		m_mass.col3.y = rAX * iA + rBX * iB;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = iA + iB;
		
		var impulse:B2Vec3 = new B2Vec3();
		m_mass.solve33(impulse, -C1X, -C1Y, -C2);
		

		bA.m_sweep.c.x -= mA * impulse.x;
		bA.m_sweep.c.y -= mA * impulse.y;
		bA.m_sweep.a -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z);

		bB.m_sweep.c.x += mB * impulse.x;
		bB.m_sweep.c.y += mB * impulse.y;
		bB.m_sweep.a += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z);

		bA.synchronizeTransform();
		bB.synchronizeTransform();

		return positionError <= B2Settings.b2_linearSlop && angularError <= B2Settings.b2_angularSlop;

	}

	private var m_localAnchorA:B2Vec2;
	private var m_localAnchorB:B2Vec2;
	private var m_referenceAngle:Float;
	
	private var m_impulse:B2Vec3;
	private var m_mass:B2Mat33;
}
