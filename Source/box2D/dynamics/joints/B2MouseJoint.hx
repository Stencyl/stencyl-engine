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
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;


// p = attached point, m = mouse point
// C = p - m
// Cdot = v
//      = v + cross(w, r)
// J = [I r_skew]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

/**
* A mouse joint is used to make a point on a body track a
* specified world point. This a soft constraint with a maximum
* force. This allows the constraint to stretch and without
* applying huge forces.
* Note: this joint is not fully documented as it is intended primarily
* for the testbed. See that for more instructions.
* @see b2MouseJointDef
*/

class B2MouseJoint extends B2Joint
{
	/** @inheritDoc */
	public override function getAnchorA():B2Vec2{
		return m_target;
	}
	/** @inheritDoc */
	public override function getAnchorB():B2Vec2{
		return m_bodyB.getWorldPoint(m_localAnchor);
	}
	/** @inheritDoc */
	public override function getReactionForce(inv_dt:Float):B2Vec2
	{
		return new B2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}
	/** @inheritDoc */
	public override function getReactionTorque(inv_dt:Float):Float
	{
		return 0.0;
	}
	
	public function getTarget():B2Vec2
	{
		return m_target;
	}
	
	/**
	 * Use this to update the target point.
	 */
	public function setTarget(target:B2Vec2) : Void{
		if (m_bodyB.isAwake() == false){
			m_bodyB.setAwake(true);
		}
		m_target = target;
	}

	/// Get the maximum force in Newtons.
	public function getMaxForce():Float
	{
		return m_maxForce;
	}
	
	/// Set the maximum force in Newtons.
	public function setMaxForce(maxForce:Float):Void
	{
		m_maxForce = maxForce;
	}
	
	/// Get frequency in Hz
	public function getFrequency():Float
	{
		return m_frequencyHz;
	}
	
	/// Set the frequency in Hz
	public function setFrequency(hz:Float):Void
	{
		m_frequencyHz = hz;
	}
	
	/// Get damping ratio
	public function getDampingRatio():Float
	{
		return m_dampingRatio;
	}
	
	/// Set damping ratio
	public function setDampingRatio(ratio:Float):Void
	{
		m_dampingRatio = ratio;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public function new (def:B2MouseJointDef){
		super(def);
		
		K = new B2Mat22();
		K1 = new B2Mat22();
		K2 = new B2Mat22();
		
		m_localAnchor = new B2Vec2();
		m_target = new B2Vec2();
		m_impulse = new B2Vec2();

		m_mass = new B2Mat22();
		m_C = new B2Vec2();
		
		//b2Settings.b2Assert(def.target.IsValid());
		//b2Settings.b2Assert(b2Math.b2IsValid(def.maxForce) && def.maxForce > 0.0);
		//b2Settings.b2Assert(b2Math.b2IsValid(def.frequencyHz) && def.frequencyHz > 0.0);
		//b2Settings.b2Assert(b2Math.b2IsValid(def.dampingRatio) && def.dampingRatio > 0.0);
		
		m_target.setV(def.target);
		//m_localAnchor = b2MulT(m_bodyB.m_xf, m_target);
		var tX:Float = m_target.x - m_bodyB.m_xf.position.x;
		var tY:Float = m_target.y - m_bodyB.m_xf.position.y;
		var tMat:B2Mat22 = m_bodyB.m_xf.R;
		m_localAnchor.x = (tX * tMat.col1.x + tY * tMat.col1.y);
		m_localAnchor.y = (tX * tMat.col2.x + tY * tMat.col2.y);
		
		m_maxForce = def.maxForce;
		m_impulse.setZero();
		
		m_frequencyHz = def.frequencyHz;
		m_dampingRatio = def.dampingRatio;
		
		m_beta = 0.0;
		m_gamma = 0.0;
	}

	// Presolve vars
	private var K:B2Mat22;
	private var K1:B2Mat22;
	private var K2:B2Mat22;
	public override function initVelocityConstraints(step:B2TimeStep): Void{
		var b:B2Body = m_bodyB;
		
		var mass:Float = b.getMass();
		
		// Frequency
		var omega:Float = 2.0 * Math.PI * m_frequencyHz;
		
		// Damping co-efficient
		var d:Float = 2.0 * mass * m_dampingRatio * omega;
		
		// Spring stiffness
		var k:Float = mass * omega * omega;
		
		// magic formulas
		// gamma has units of inverse mass
		// beta hs units of inverse time
		//b2Settings.b2Assert(d + step.dt * k > Number.MIN_VALUE)
		m_gamma = step.dt * (d + step.dt * k);
		m_gamma = m_gamma != 0 ? 1 / m_gamma:0.0;
		m_beta = step.dt * k * m_gamma;
		
		var tMat:B2Mat22;
		
		// Compute the effective mass matrix.
		//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter());
		tMat = b.m_xf.R;
		var rX:Float = m_localAnchor.x - b.m_sweep.localCenter.x;
		var rY:Float = m_localAnchor.y - b.m_sweep.localCenter.y;
		var tX:Float = (tMat.col1.x * rX + tMat.col2.x * rY);
		rY = (tMat.col1.y * rX + tMat.col2.y * rY);
		rX = tX;
		
		// K    = [(1/m1 + 1/m2) * eye(2) - skew(r1) * invI1 * skew(r1) - skew(r2) * invI2 * skew(r2)]
		//      = [1/m1+1/m2     0    ] + invI1 * [r1.y*r1.y -r1.x*r1.y] + invI2 * [r1.y*r1.y -r1.x*r1.y]
		//        [    0     1/m1+1/m2]           [-r1.x*r1.y r1.x*r1.x]           [-r1.x*r1.y r1.x*r1.x]
		var invMass:Float = b.m_invMass;
		var invI:Float = b.m_invI;
		
		//b2Mat22 K1;
		K1.col1.x = invMass;	K1.col2.x = 0.0;
		K1.col1.y = 0.0;		K1.col2.y = invMass;
		
		//b2Mat22 K2;
		K2.col1.x =  invI * rY * rY;	K2.col2.x = -invI * rX * rY;
		K2.col1.y = -invI * rX * rY;	K2.col2.y =  invI * rX * rX;
		
		//b2Mat22 K = K1 + K2;
		K.setM(K1);
		K.addM(K2);
		K.col1.x += m_gamma;
		K.col2.y += m_gamma;
		
		//m_ptpMass = K.GetInverse();
		K.getInverse(m_mass);
		
		//m_C = b.m_position + r - m_target;
		m_C.x = b.m_sweep.c.x + rX - m_target.x;
		m_C.y = b.m_sweep.c.y + rY - m_target.y;
		
		// Cheat with some damping
		b.m_angularVelocity *= 0.98;
		
		// Warm starting.
		m_impulse.x *= step.dtRatio;
		m_impulse.y *= step.dtRatio;
		//b.m_linearVelocity += invMass * m_impulse;
		b.m_linearVelocity.x += invMass * m_impulse.x;
		b.m_linearVelocity.y += invMass * m_impulse.y;
		//b.m_angularVelocity += invI * b2Cross(r, m_impulse);
		b.m_angularVelocity += invI * (rX * m_impulse.y - rY * m_impulse.x);
	}
	
	public override function solveVelocityConstraints(step:B2TimeStep) : Void{
		var b:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		var tX:Float;
		var tY:Float;
		
		// Compute the effective mass matrix.
		//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter());
		tMat = b.m_xf.R;
		var rX:Float = m_localAnchor.x - b.m_sweep.localCenter.x;
		var rY:Float = m_localAnchor.y - b.m_sweep.localCenter.y;
		tX = (tMat.col1.x * rX + tMat.col2.x * rY);
		rY = (tMat.col1.y * rX + tMat.col2.y * rY);
		rX = tX;
		
		// Cdot = v + cross(w, r)
		//b2Vec2 Cdot = b->m_linearVelocity + b2Cross(b->m_angularVelocity, r);
		var CdotX:Float = b.m_linearVelocity.x + (-b.m_angularVelocity * rY);
		var CdotY:Float = b.m_linearVelocity.y + (b.m_angularVelocity * rX);
		//b2Vec2 impulse = - b2Mul(m_mass, Cdot + m_beta * m_C + m_gamma * m_impulse);
		tMat = m_mass;
		tX = CdotX + m_beta * m_C.x + m_gamma * m_impulse.x;
		tY = CdotY + m_beta * m_C.y + m_gamma * m_impulse.y;
		var impulseX:Float = -(tMat.col1.x * tX + tMat.col2.x * tY);
		var impulseY:Float = -(tMat.col1.y * tX + tMat.col2.y * tY);
		
		var oldImpulseX:Float = m_impulse.x;
		var oldImpulseY:Float = m_impulse.y;
		//m_impulse += impulse;
		m_impulse.x += impulseX;
		m_impulse.y += impulseY;
		var maxImpulse:Float = step.dt * m_maxForce;
		if (m_impulse.lengthSquared() > maxImpulse*maxImpulse)
		{
			//m_impulse *= m_maxImpulse / m_impulse.Length();
			m_impulse.multiply(maxImpulse / m_impulse.length());
		}
		//impulse = m_impulse - oldImpulse;
		impulseX = m_impulse.x - oldImpulseX;
		impulseY = m_impulse.y - oldImpulseY;
		
		//b->m_linearVelocity += b->m_invMass * impulse;
		b.m_linearVelocity.x += b.m_invMass * impulseX;
		b.m_linearVelocity.y += b.m_invMass * impulseY;
		//b->m_angularVelocity += b->m_invI * b2Cross(r, P);
		b.m_angularVelocity += b.m_invI * (rX * impulseY - rY * impulseX);
	}

	public override function solvePositionConstraints(baumgarte:Float):Bool { 
		//B2_NOT_USED(baumgarte);
		return true; 
	}

	private var m_localAnchor:B2Vec2;
	private var m_target:B2Vec2;
	private var m_impulse:B2Vec2;

	private var m_mass:B2Mat22;	// effective mass for point-to-point constraint.
	private var m_C:B2Vec2;			// position error
	private var m_maxForce:Float;
	private var m_frequencyHz:Float;
	private var m_dampingRatio:Float;
	private var m_beta:Float;						// bias factor
	private var m_gamma:Float;						// softness
}