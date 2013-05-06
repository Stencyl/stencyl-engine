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
// C = p2 - p1
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

// Motor constraint
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

/**
* A revolute joint constrains to bodies to share a common point while they
* are free to rotate about the point. The relative rotation about the shared
* point is the joint angle. You can limit the relative rotation with
* a joint limit that specifies a lower and upper angle. You can use a motor
* to drive the relative rotation about the shared point. A maximum motor torque
* is provided so that infinite forces are not generated.
* @see b2RevoluteJointDef
*/
class B2RevoluteJoint extends B2Joint
{
	/** @inheritDoc */
	public override function getAnchorA() :B2Vec2{
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}
	/** @inheritDoc */
	public override function getAnchorB() :B2Vec2{
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}

	/** @inheritDoc */
	public override function getReactionForce(inv_dt:Float) :B2Vec2{
		return new B2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}
	/** @inheritDoc */
	public override function getReactionTorque(inv_dt:Float) :Float{
		return inv_dt * m_impulse.z;
	}

	/**
	* Get the current joint angle in radians.
	*/
	public function getJointAngle() :Float{
		//b2Body* bA = m_bodyA;
		//b2Body* bB = m_bodyB;
		return m_bodyB.m_sweep.a - m_bodyA.m_sweep.a - m_referenceAngle;
	}

	/**
	* Get the current joint angle speed in radians per second.
	*/
	public function getJointSpeed() :Float{
		//b2Body* bA = m_bodyA;
		//b2Body* bB = m_bodyB;
		return m_bodyB.m_angularVelocity - m_bodyA.m_angularVelocity;
	}

	/**
	* Is the joint limit enabled?
	*/
	public function isLimitEnabled() :Bool{
		return m_enableLimit;
	}

	/**
	* Enable/disable the joint limit.
	*/
	public function enableLimit(flag:Bool) :Void{
		m_enableLimit = flag;
	}

	/**
	* Get the lower joint limit in radians.
	*/
	public function getLowerLimit() :Float{
		return m_lowerAngle;
	}

	/**
	* Get the upper joint limit in radians.
	*/
	public function getUpperLimit() :Float{
		return m_upperAngle;
	}

	/**
	* Set the joint limits in radians.
	*/
	public function setLimits(lower:Float, upper:Float) : Void{
		//b2Settings.b2Assert(lower <= upper);
		m_lowerAngle = lower;
		m_upperAngle = upper;
	}

	/**
	* Is the joint motor enabled?
	*/
	public function isMotorEnabled() :Bool {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		return m_enableMotor;
	}

	/**
	* Enable/disable the joint motor.
	*/
	public function enableMotor(flag:Bool) :Void{
		m_enableMotor = flag;
	}

	/**
	* Set the motor speed in radians per second.
	*/
	public function setMotorSpeed(speed:Float) : Void {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_motorSpeed = speed;
	}

	/**
	* Get the motor speed in radians per second.
	*/
	public function getMotorSpeed() :Float{
		return m_motorSpeed;
	}

	/**
	* Set the maximum motor torque, usually in N-m.
	*/
	public function setMaxMotorTorque(torque:Float) : Void{
		m_maxMotorTorque = torque;
	}

	/**
	* Get the current motor torque, usually in N-m.
	*/
	public function getMotorTorque() :Float{
		return m_maxMotorTorque;
	}

	//--------------- Internals Below -------------------

	/** @private */
	public function new (def:B2RevoluteJointDef){
		super(def);
		
		K = new B2Mat22();
		K1 = new B2Mat22();
		K2 = new B2Mat22();
		K3 = new B2Mat22();
		
		impulse3 = new B2Vec3();
		impulse2 = new B2Vec2();
		reduced = new B2Vec2();
		
		m_localAnchor1 = new B2Vec2();
		m_localAnchor2 = new B2Vec2();
		m_impulse = new B2Vec3();
		m_mass = new B2Mat33();
		
		
		//m_localAnchor1 = def->localAnchorA;
		m_localAnchor1.setV(def.localAnchorA);
		//m_localAnchor2 = def->localAnchorB;
		m_localAnchor2.setV(def.localAnchorB);
		
		m_referenceAngle = def.referenceAngle;
		
		m_impulse.setZero();
		m_motorImpulse = 0.0;
		
		m_lowerAngle = def.lowerAngle;
		m_upperAngle = def.upperAngle;
		m_maxMotorTorque = def.maxMotorTorque;
		m_motorSpeed = def.motorSpeed;
		m_enableLimit = def.enableLimit;
		m_enableMotor = def.enableMotor;
		m_limitState = B2Joint.e_inactiveLimit;
	}

	// internal vars
	private var K:B2Mat22;
	private var K1:B2Mat22;
	private var K2:B2Mat22;
	private var K3:B2Mat22;
	public override function initVelocityConstraints(step:B2TimeStep) : Void{
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		var tX:Float;
		
		if (m_enableMotor || m_enableLimit)
		{
			// You cannot create prismatic joint between bodies that
			// both have fixed rotation.
			//b2Settings.b2Assert(bA.m_invI > 0.0 || bB.m_invI > 0.0);
		}
		
		
		// Compute the effective mass matrix.
		
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var r1X:Float = m_localAnchor1.x - bA.m_sweep.localCenter.x;
		var r1Y:Float = m_localAnchor1.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var r2X:Float = m_localAnchor2.x - bB.m_sweep.localCenter.x;
		var r2Y:Float = m_localAnchor2.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		// J = [-I -r1_skew I r2_skew] 
		// [ 0 -1 0 1]
		// r_skew = [-ry; rx] 
		
		// Matlab
		// K = [ m1+r1y^2*i1+m2+r2y^2*i2, -r1y*i1*r1x-r2y*i2*r2x, -r1y*i1-r2y*i2]
		//     [ -r1y*i1*r1x-r2y*i2*r2x, m1+r1x^2*i1+m2+r2x^2*i2, r1x*i1+r2x*i2] 
		//     [ -r1y*i1-r2y*i2, r1x*i1+r2x*i2, i1+i2] 
		
		var m1:Float = bA.m_invMass;
		var m2:Float = bB.m_invMass;
		var i1:Float = bA.m_invI;
		var i2:Float = bB.m_invI;
		
		m_mass.col1.x = m1 + m2 + r1Y * r1Y * i1 + r2Y * r2Y * i2;
		m_mass.col2.x = -r1Y * r1X * i1 - r2Y * r2X * i2;
		m_mass.col3.x = -r1Y * i1 - r2Y * i2;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = m1 + m2 + r1X * r1X * i1 + r2X * r2X * i2;
		m_mass.col3.y = r1X * i1 + r2X * i2;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = i1 + i2;
		
		
		m_motorMass = 1.0 / (i1 + i2);
		
		if (m_enableMotor == false)
		{
			m_motorImpulse = 0.0;
		}
		
		if (m_enableLimit)
		{
			//float32 jointAngle = bB->m_sweep.a - bA->m_sweep.a - m_referenceAngle;
			var jointAngle:Float = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle;
			if (B2Math.abs(m_upperAngle - m_lowerAngle) < 2.0 * B2Settings.b2_angularSlop)
			{
				m_limitState = B2Joint.e_equalLimits;
			}
			else if (jointAngle <= m_lowerAngle)
			{
				if (m_limitState != B2Joint.e_atLowerLimit)
				{
					m_impulse.z = 0.0;
				}
				m_limitState = B2Joint.e_atLowerLimit;
			}
			else if (jointAngle >= m_upperAngle)
			{
				if (m_limitState != B2Joint.e_atUpperLimit)
				{
					m_impulse.z = 0.0;
				}
				m_limitState = B2Joint.e_atUpperLimit;
			}
			else
			{
				m_limitState = B2Joint.e_inactiveLimit;
				m_impulse.z = 0.0;
			}
		}
		else
		{
			m_limitState = B2Joint.e_inactiveLimit;
		}
		
		// Warm starting.
		if (step.warmStarting)
		{
			//Scale impulses to support a variable time step
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_motorImpulse *= step.dtRatio;
			
			var PX:Float = m_impulse.x;
			var PY:Float = m_impulse.y;
			
			//bA->m_linearVelocity -= m1 * P;
			bA.m_linearVelocity.x -= m1 * PX;
			bA.m_linearVelocity.y -= m1 * PY;
			//bA->m_angularVelocity -= i1 * (b2Cross(r1, P) + m_motorImpulse + m_impulse.z);
			bA.m_angularVelocity -= i1 * ((r1X * PY - r1Y * PX) + m_motorImpulse + m_impulse.z);
			
			//bB->m_linearVelocity += m2 * P;
			bB.m_linearVelocity.x += m2 * PX;
			bB.m_linearVelocity.y += m2 * PY;
			//bB->m_angularVelocity += i2 * (b2Cross(r2, P) + m_motorImpulse + m_impulse.z);
			bB.m_angularVelocity += i2 * ((r2X * PY - r2Y * PX) + m_motorImpulse + m_impulse.z);
		}
		else
		{
			m_impulse.setZero();
			m_motorImpulse = 0.0;
		}
	}
	
	private var impulse3:B2Vec3;
	private var impulse2:B2Vec2;
	private var reduced:B2Vec2;
	public override function solveVelocityConstraints(step:B2TimeStep) : Void {
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		var tX:Float;
		
		var newImpulse:Float;
		var r1X:Float;
		var r1Y:Float;
		var r2X:Float;
		var r2Y:Float;
		
		var v1:B2Vec2 = bA.m_linearVelocity;
		var w1:Float = bA.m_angularVelocity;
		var v2:B2Vec2 = bB.m_linearVelocity;
		var w2:Float = bB.m_angularVelocity;
		
		var m1:Float = bA.m_invMass;
		var m2:Float = bB.m_invMass;
		var i1:Float = bA.m_invI;
		var i2:Float = bB.m_invI;
		
		// Solve motor constraint.
		if (m_enableMotor && m_limitState != B2Joint.e_equalLimits)
		{
			var Cdot:Float = w2 - w1 - m_motorSpeed;
			var impulse:Float = m_motorMass * ( -Cdot);
			var oldImpulse:Float = m_motorImpulse;
			var maxImpulse:Float = step.dt * m_maxMotorTorque;
			
			m_motorImpulse = B2Math.clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse);
			impulse = m_motorImpulse - oldImpulse;
			
			w1 -= i1 * impulse;
			w2 += i2 * impulse;
		}
		
		// Solve limit constraint.
		if (m_enableLimit && m_limitState != B2Joint.e_inactiveLimit)
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
			
			// Solve point-to-point constraint
			//b2Vec2 Cdot1 = v2 + b2Cross(w2, r2) - v1 - b2Cross(w1, r1);
			var Cdot1X:Float = v2.x + (-w2 * r2Y) - v1.x - (-w1 * r1Y);
			var Cdot1Y:Float = v2.y + (w2 * r2X) - v1.y - (w1 * r1X);
			var Cdot2:Float  = w2 - w1;
			
			m_mass.solve33(impulse3, -Cdot1X, -Cdot1Y, -Cdot2);
			
			if (m_limitState == B2Joint.e_equalLimits)
			{
				m_impulse.add(impulse3);
			}
			else if (m_limitState == B2Joint.e_atLowerLimit)
			{
				newImpulse = m_impulse.z + impulse3.z;
				if (newImpulse < 0.0)
				{
					m_mass.solve22(reduced, -Cdot1X, -Cdot1Y);
					impulse3.x = reduced.x;
					impulse3.y = reduced.y;
					impulse3.z = -m_impulse.z;
					m_impulse.x += reduced.x;
					m_impulse.y += reduced.y;
					m_impulse.z = 0.0;
				}
			}
			else if (m_limitState == B2Joint.e_atUpperLimit)
			{
				newImpulse = m_impulse.z + impulse3.z;
				if (newImpulse > 0.0)
				{
					m_mass.solve22(reduced, -Cdot1X, -Cdot1Y);
					impulse3.x = reduced.x;
					impulse3.y = reduced.y;
					impulse3.z = -m_impulse.z;
					m_impulse.x += reduced.x;
					m_impulse.y += reduced.y;
					m_impulse.z = 0.0;
				}
			}
			
			v1.x -= m1 * impulse3.x;
			v1.y -= m1 * impulse3.y;
			w1 -= i1 * (r1X * impulse3.y - r1Y * impulse3.x + impulse3.z);
			
			v2.x += m2 * impulse3.x;
			v2.y += m2 * impulse3.y;
			w2 += i2 * (r2X * impulse3.y - r2Y * impulse3.x + impulse3.z);
		}
		else
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
			
			//b2Vec2 Cdot = v2 + b2Cross(w2, r2) - v1 - b2Cross(w1, r1);
			var CdotX:Float = v2.x + ( -w2 * r2Y) - v1.x - ( -w1 * r1Y);
			var CdotY:Float = v2.y + (w2 * r2X) - v1.y - (w1 * r1X);
			
			m_mass.solve22(impulse2, -CdotX, -CdotY);
			
			m_impulse.x += impulse2.x;
			m_impulse.y += impulse2.y;
			
			v1.x -= m1 * impulse2.x;
			v1.y -= m1 * impulse2.y;
			//w1 -= i1 * b2Cross(r1, impulse2); 
			w1 -= i1 * ( r1X * impulse2.y - r1Y * impulse2.x);
			
			v2.x += m2 * impulse2.x;
			v2.y += m2 * impulse2.y;
			//w2 += i2 * b2Cross(r2, impulse2); 
			w2 += i2 * ( r2X * impulse2.y - r2Y * impulse2.x);
		}
		
		bA.m_linearVelocity.setV(v1);
		bA.m_angularVelocity = w1;
		bB.m_linearVelocity.setV(v2);
		bB.m_angularVelocity = w2;
	}
	
	private static var tImpulse:B2Vec2 = new B2Vec2();
	public override function solvePositionConstraints(baumgarte:Float):Bool{
		
		// TODO_ERIN block solve with limit
		
		var oldLimitImpulse:Float;
		var C:Float;
		
		var tMat:B2Mat22;
		
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var angularError:Float = 0.0;
		var positionError:Float = 0.0;
		
		var tX:Float;
		
		var impulseX:Float;
		var impulseY:Float;
		
		// Solve angular limit constraint.
		if (m_enableLimit && m_limitState != B2Joint.e_inactiveLimit)
		{
			var angle:Float = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle;
			var limitImpulse:Float = 0.0;
			
			if (m_limitState == B2Joint.e_equalLimits)
			{
				// Prevent large angular corrections
				C = B2Math.clamp(angle - m_lowerAngle, -B2Settings.b2_maxAngularCorrection, B2Settings.b2_maxAngularCorrection);
				limitImpulse = -m_motorMass * C;
				angularError = B2Math.abs(C);
			}
			else if (m_limitState == B2Joint.e_atLowerLimit)
			{
				C = angle - m_lowerAngle;
				angularError = -C;
				
				// Prevent large angular corrections and allow some slop.
				C = B2Math.clamp(C + B2Settings.b2_angularSlop, -B2Settings.b2_maxAngularCorrection, 0.0);
				limitImpulse = -m_motorMass * C;
			}
			else if (m_limitState == B2Joint.e_atUpperLimit)
			{
				C = angle - m_upperAngle;
				angularError = C;
				
				// Prevent large angular corrections and allow some slop.
				C = B2Math.clamp(C - B2Settings.b2_angularSlop, 0.0, B2Settings.b2_maxAngularCorrection);
				limitImpulse = -m_motorMass * C;
			}
			
			bA.m_sweep.a -= bA.m_invI * limitImpulse;
			bB.m_sweep.a += bB.m_invI * limitImpulse;
			
			bA.synchronizeTransform();
			bB.synchronizeTransform();
		}
		
		// Solve point-to-point constraint
		{
			//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
			tMat = bA.m_xf.R;
			var r1X:Float = m_localAnchor1.x - bA.m_sweep.localCenter.x;
			var r1Y:Float = m_localAnchor1.y - bA.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
			r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
			r1X = tX;
			//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
			tMat = bB.m_xf.R;
			var r2X:Float = m_localAnchor2.x - bB.m_sweep.localCenter.x;
			var r2Y:Float = m_localAnchor2.y - bB.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
			r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
			r2X = tX;
			
			//b2Vec2 C = bB->m_sweep.c + r2 - bA->m_sweep.c - r1;
			var CX:Float = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X;
			var CY:Float = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y;
			var CLengthSquared:Float = CX * CX + CY * CY;
			var CLength:Float = Math.sqrt(CLengthSquared);
			positionError = CLength;
			
			var invMass1:Float = bA.m_invMass;
			var invMass2:Float = bB.m_invMass;
			var invI1:Float = bA.m_invI;
			var invI2:Float = bB.m_invI;
			
			//Handle large detachment.
			var k_allowedStretch:Float = 10.0 * B2Settings.b2_linearSlop;
			if (CLengthSquared > k_allowedStretch * k_allowedStretch)
			{
				// Use a particle solution (no rotation)
				//b2Vec2 u = C; u.Normalize(); 
				var uX:Float = CX / CLength;
				var uY:Float = CY / CLength;
				var k:Float = invMass1 + invMass2;
				//b2Settings.b2Assert(k>Number.MIN_VALUE)
				var m:Float = 1.0 / k;
				impulseX = m * ( -CX);
				impulseY = m * ( -CY);
				var k_beta:Float = 0.5;
				bA.m_sweep.c.x -= k_beta * invMass1 * impulseX;
				bA.m_sweep.c.y -= k_beta * invMass1 * impulseY;
				bB.m_sweep.c.x += k_beta * invMass2 * impulseX;
				bB.m_sweep.c.y += k_beta * invMass2 * impulseY;
				
				//C = bB->m_sweep.c + r2 - bA->m_sweep.c - r1;
				CX = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X;
				CY = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y;
			}
			
			//b2Mat22 K1;
			K1.col1.x = invMass1 + invMass2;	K1.col2.x = 0.0;
			K1.col1.y = 0.0;					K1.col2.y = invMass1 + invMass2;
			
			//b2Mat22 K2;
			K2.col1.x =  invI1 * r1Y * r1Y;	K2.col2.x = -invI1 * r1X * r1Y;
			K2.col1.y = -invI1 * r1X * r1Y;	K2.col2.y =  invI1 * r1X * r1X;
			
			//b2Mat22 K3;
			K3.col1.x =  invI2 * r2Y * r2Y;		K3.col2.x = -invI2 * r2X * r2Y;
			K3.col1.y = -invI2 * r2X * r2Y;		K3.col2.y =  invI2 * r2X * r2X;
			
			//b2Mat22 K = K1 + K2 + K3;
			K.setM(K1);
			K.addM(K2);
			K.addM(K3);
			//b2Vec2 impulse = K.Solve(-C);
			K.solve(tImpulse, -CX, -CY);
			impulseX = tImpulse.x;
			impulseY = tImpulse.y;
			
			//bA.m_sweep.c -= bA.m_invMass * impulse;
			bA.m_sweep.c.x -= bA.m_invMass * impulseX;
			bA.m_sweep.c.y -= bA.m_invMass * impulseY;
			//bA.m_sweep.a -= bA.m_invI * b2Cross(r1, impulse);
			bA.m_sweep.a -= bA.m_invI * (r1X * impulseY - r1Y * impulseX);
			
			//bB.m_sweep.c += bB.m_invMass * impulse;
			bB.m_sweep.c.x += bB.m_invMass * impulseX;
			bB.m_sweep.c.y += bB.m_invMass * impulseY;
			//bB.m_sweep.a += bB.m_invI * b2Cross(r2, impulse);
			bB.m_sweep.a += bB.m_invI * (r2X * impulseY - r2Y * impulseX);
			
			bA.synchronizeTransform();
			bB.synchronizeTransform();
		}
		
		return positionError <= B2Settings.b2_linearSlop && angularError <= B2Settings.b2_angularSlop;
	}

	public var m_localAnchor1:B2Vec2; // relative
	public var m_localAnchor2:B2Vec2;
	private var m_impulse:B2Vec3;
	private var m_motorImpulse:Float;

	private var m_mass:B2Mat33;		// effective mass for point-to-point constraint.
	private var m_motorMass:Float;	// effective mass for motor/limit angular constraint.
	private var m_enableMotor:Bool;
	private var m_maxMotorTorque:Float;
	private var m_motorSpeed:Float;

	private var m_enableLimit:Bool;
	private var m_referenceAngle:Float;
	private var m_lowerAngle:Float;
	private var m_upperAngle:Float;
	private var m_limitState:Int;
}