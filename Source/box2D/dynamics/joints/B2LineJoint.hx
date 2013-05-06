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
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;


// Linear constraint (point-to-line)
// d = p2 - p1 = x2 + r2 - x1 - r1
// C = dot(perp, d)
// Cdot = dot(d, cross(w1, perp)) + dot(perp, v2 + cross(w2, r2) - v1 - cross(w1, r1))
//      = -dot(perp, v1) - dot(cross(d + r1, perp), w1) + dot(perp, v2) + dot(cross(r2, perp), v2)
// J = [-perp, -cross(d + r1, perp), perp, cross(r2,perp)]
//
// K = J * invM * JT
//
// J = [-a -s1 a s2]
// a = perp
// s1 = cross(d + r1, a) = cross(p2 - x1, a)
// s2 = cross(r2, a) = cross(p2 - x2, a)


// Motor/Limit linear constraint
// C = dot(ax1, d)
// Cdot = = -dot(ax1, v1) - dot(cross(d + r1, ax1), w1) + dot(ax1, v2) + dot(cross(r2, ax1), v2)
// J = [-ax1 -cross(d+r1,ax1) ax1 cross(r2,ax1)]

// Block Solver
// We develop a block solver that includes the joint limit. This makes the limit stiff (inelastic) even
// when the mass has poor distribution (leading to large torques about the joint anchor points).
//
// The Jacobian has 3 rows:
// J = [-uT -s1 uT s2] // linear
//     [-vT -a1 vT a2] // limit
//
// u = perp
// v = axis
// s1 = cross(d + r1, u), s2 = cross(r2, u)
// a1 = cross(d + r1, v), a2 = cross(r2, v)

// M * (v2 - v1) = JT * df
// J * v2 = bias
//
// v2 = v1 + invM * JT * df
// J * (v1 + invM * JT * df) = bias
// K * df = bias - J * v1 = -Cdot
// K = J * invM * JT
// Cdot = J * v1 - bias
//
// Now solve for f2.
// df = f2 - f1
// K * (f2 - f1) = -Cdot
// f2 = invK * (-Cdot) + f1
//
// Clamp accumulated limit impulse.
// lower: f2(2) = max(f2(2), 0)
// upper: f2(2) = min(f2(2), 0)
//
// Solve for correct f2(1)
// K(1,1) * f2(1) = -Cdot(1) - K(1,2) * f2(2) + K(1,1:2) * f1
//                = -Cdot(1) - K(1,2) * f2(2) + K(1,1) * f1(1) + K(1,2) * f1(2)
// K(1,1) * f2(1) = -Cdot(1) - K(1,2) * (f2(2) - f1(2)) + K(1,1) * f1(1)
// f2(1) = invK(1,1) * (-Cdot(1) - K(1,2) * (f2(2) - f1(2))) + f1(1)
//
// Now compute impulse to be applied:
// df = f2 - f1

/**
 * A line joint. This joint provides one degree of freedom: translation
 * along an axis fixed in body1. You can use a joint limit to restrict
 * the range of motion and a joint motor to drive the motion or to
 * model joint friction.
 * @see b2LineJointDef
 */
class B2LineJoint extends B2Joint
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
	public override function getReactionForce(inv_dt:Float) : B2Vec2
	{
		//return inv_dt * (m_impulse.x * m_perp + (m_motorImpulse + m_impulse.y) * m_axis);
		return new B2Vec2(	inv_dt * (m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.y) * m_axis.x),
							inv_dt * (m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.y) * m_axis.y));
	}

	/** @inheritDoc */
	public override function getReactionTorque(inv_dt:Float) : Float
	{
		return inv_dt * m_impulse.y;
	}
	
	/**
	* Get the current joint translation, usually in meters.
	*/
	public function getJointTranslation():Float{
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		
		var p1:B2Vec2 = bA.getWorldPoint(m_localAnchor1);
		var p2:B2Vec2 = bB.getWorldPoint(m_localAnchor2);
		//var d:B2Vec2 = b2Math.SubtractVV(p2, p1);
		var dX:Float = p2.x - p1.x;
		var dY:Float = p2.y - p1.y;
		//b2Vec2 axis = bA->GetWorldVector(m_localXAxis1);
		var axis:B2Vec2 = bA.getWorldVector(m_localXAxis1);
		
		//float32 translation = b2Dot(d, axis);
		var translation:Float = axis.x*dX + axis.y*dY;
		return translation;
	}
	
	/**
	* Get the current joint translation speed, usually in meters per second.
	*/
	public function getJointSpeed():Float{
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
		//var d:B2Vec2 = b2Math.SubtractVV(p2, p1);
		var dX:Float = p2X - p1X;
		var dY:Float = p2Y - p1Y;
		//b2Vec2 axis = bA->GetWorldVector(m_localXAxis1);
		var axis:B2Vec2 = bA.getWorldVector(m_localXAxis1);
		
		var v1:B2Vec2 = bA.m_linearVelocity;
		var v2:B2Vec2 = bB.m_linearVelocity;
		var w1:Float = bA.m_angularVelocity;
		var w2:Float = bB.m_angularVelocity;
		
		//var speed:Float = b2Math.b2Dot(d, b2Math.b2CrossFV(w1, ax1)) + b2Math.b2Dot(ax1, b2Math.SubtractVV( b2Math.SubtractVV( b2Math.AddVV( v2 , b2Math.b2CrossFV(w2, r2)) , v1) , b2Math.b2CrossFV(w1, r1)));
		//var b2D:Float = (dX*(-w1 * ax1Y) + dY*(w1 * ax1X));
		//var b2D2:Float = (ax1X * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + ax1Y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)));
		var speed:Float = (dX*(-w1 * axis.y) + dY*(w1 * axis.x)) + (axis.x * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + axis.y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)));
		
		return speed;
	}
	
	/**
	* Is the joint limit enabled?
	*/
	public function isLimitEnabled() : Bool
	{
		return m_enableLimit;
	}
	/**
	* Enable/disable the joint limit.
	*/
	public function enableLimit(flag:Bool) : Void
	{
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_enableLimit = flag;
	}
	/**
	* Get the lower joint limit, usually in meters.
	*/
	public function getLowerLimit() : Float
	{
		return m_lowerTranslation;
	}
	/**
	* Get the upper joint limit, usually in meters.
	*/
	public function getUpperLimit() : Float
	{
		return m_upperTranslation;
	}
	/**
	* Set the joint limits, usually in meters.
	*/
	public function setLimits(lower:Float, upper:Float) : Void
	{
		//b2Settings.b2Assert(lower <= upper);
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_lowerTranslation = lower;
		m_upperTranslation = upper;
	}
	/**
	* Is the joint motor enabled?
	*/
	public function isMotorEnabled() : Bool
	{
		return m_enableMotor;
	}
	/**
	* Enable/disable the joint motor.
	*/
	public function enableMotor(flag:Bool) : Void
	{
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_enableMotor = flag;
	}
	/**
	* Set the motor speed, usually in meters per second.
	*/
	public function setMotorSpeed(speed:Float) : Void
	{
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_motorSpeed = speed;
	}
	/**
	* Get the motor speed, usually in meters per second.
	*/
	public function getMotorSpeed() :Float
	{
		return m_motorSpeed;
	}
	
	/**
	 * Set the maximum motor force, usually in N.
	 */
	public function setMaxMotorForce(force:Float) : Void
	{
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_maxMotorForce = force;
	}
	
	/**
	 * Get the maximum motor force, usually in N.
	 */
	public function getMaxMotorForce():Float
	{
		return m_maxMotorForce;
	}
	
	/**
	* Get the current motor force, usually in N.
	*/
	public function getMotorForce() : Float
	{
		return m_motorImpulse;
	}
	

	//--------------- Internals Below -------------------

	/** @private */
	public function new (def:B2LineJointDef){
		super(def);
		
		m_localAnchor1 = new B2Vec2();
		m_localAnchor2 = new B2Vec2();
		m_localXAxis1 = new B2Vec2();
		m_localYAxis1 = new B2Vec2();

		m_axis = new B2Vec2();
		m_perp = new B2Vec2();
		
		m_K = new B2Mat22();
		m_impulse = new B2Vec2();
		
		
		var tMat:B2Mat22;
		var tX:Float;
		var tY:Float;
		
		m_localAnchor1.setV(def.localAnchorA);
		m_localAnchor2.setV(def.localAnchorB);
		m_localXAxis1.setV(def.localAxisA);
		
		//m_localYAxis1 = b2Cross(1.0f, m_localXAxis1);
		m_localYAxis1.x = -m_localXAxis1.y;
		m_localYAxis1.y = m_localXAxis1.x;
		
		m_impulse.setZero();
		m_motorMass = 0.0;
		m_motorImpulse = 0.0;
		
		m_lowerTranslation = def.lowerTranslation;
		m_upperTranslation = def.upperTranslation;
		m_maxMotorForce = def.maxMotorForce;
		m_motorSpeed = def.motorSpeed;
		m_enableLimit = def.enableLimit;
		m_enableMotor = def.enableMotor;
		m_limitState = B2Joint.e_inactiveLimit;
		
		m_axis.setZero();
		m_perp.setZero();
	}

	public override function initVelocityConstraints(step:B2TimeStep) : Void{
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var tMat:B2Mat22;
		var tX:Float;
		
		m_localCenterA.setV(bA.getLocalCenter());
		m_localCenterB.setV(bB.getLocalCenter());
		
		var xf1:B2Transform = bA.getTransform();
		var xf2:B2Transform = bB.getTransform();
		
		// Compute the effective masses.
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var r1X:Float = m_localAnchor1.x - m_localCenterA.x;
		var r1Y:Float = m_localAnchor1.y - m_localCenterA.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var r2X:Float = m_localAnchor2.x - m_localCenterB.x;
		var r2Y:Float = m_localAnchor2.y - m_localCenterB.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		//b2Vec2 d = bB->m_sweep.c + r2 - bA->m_sweep.c - r1;
		var dX:Float = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X;
		var dY:Float = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y;
		
		m_invMassA = bA.m_invMass;
		m_invMassB = bB.m_invMass;
		m_invIA = bA.m_invI;
		m_invIB = bB.m_invI;
		
		// Compute motor Jacobian and effective mass.
		{
			m_axis.setV(B2Math.mulMV(xf1.R, m_localXAxis1));
			//m_a1 = b2Math.b2Cross(d + r1, m_axis);
			m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x;
			//m_a2 = b2Math.b2Cross(r2, m_axis);
			m_a2 = r2X * m_axis.y - r2Y * m_axis.x;
			
			m_motorMass = m_invMassA + m_invMassB + m_invIA * m_a1 * m_a1 + m_invIB * m_a2 * m_a2; 
			m_motorMass = m_motorMass > B2Math.MIN_VALUE?1.0 / m_motorMass:0.0;
		}
		
		// Prismatic constraint.
		{
			m_perp.setV(B2Math.mulMV(xf1.R, m_localYAxis1));
			//m_s1 = b2Math.b2Cross(d + r1, m_perp);
			m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x;
			//m_s2 = b2Math.b2Cross(r2, m_perp);
			m_s2 = r2X * m_perp.y - r2Y * m_perp.x;
			
			var m1:Float = m_invMassA;
			var m2:Float = m_invMassB;
			var i1:Float = m_invIA;
			var i2:Float = m_invIB;
			
			m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
 	  	  	m_K.col1.y = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2;
			m_K.col2.x = m_K.col1.y;
 	  	  	m_K.col2.y = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2; 
		}
		
		// Compute motor and limit terms
		if (m_enableLimit)
		{
			//float32 jointTranslation = b2Dot(m_axis, d); 
			var jointTransition:Float = m_axis.x * dX + m_axis.y * dY;
			if (B2Math.abs(m_upperTranslation - m_lowerTranslation) < 2.0 * B2Settings.b2_linearSlop)
			{
				m_limitState = B2Joint.e_equalLimits;
			}
			else if (jointTransition <= m_lowerTranslation)
			{
				if (m_limitState != B2Joint.e_atLowerLimit)
				{
					m_limitState = B2Joint.e_atLowerLimit;
					m_impulse.y = 0.0;
				}
			}
			else if (jointTransition >= m_upperTranslation)
			{
				if (m_limitState != B2Joint.e_atUpperLimit)
				{
					m_limitState = B2Joint.e_atUpperLimit;
					m_impulse.y = 0.0;
				}
			}
			else
			{
				m_limitState = B2Joint.e_inactiveLimit;
				m_impulse.y = 0.0;
			}
		}
		else
		{
			m_limitState = B2Joint.e_inactiveLimit;
		}
		
		if (m_enableMotor == false)
		{
			m_motorImpulse = 0.0;
		}
		
		if (step.warmStarting)
		{
			// Account for variable time step.
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_motorImpulse *= step.dtRatio; 
			
			//b2Vec2 P = m_impulse.x * m_perp + (m_motorImpulse + m_impulse.z) * m_axis;
			var PX:Float = m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.y) * m_axis.x;
			var PY:Float = m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.y) * m_axis.y;
			var L1:Float = m_impulse.x * m_s1     + (m_motorImpulse + m_impulse.y) * m_a1;
			var L2:Float = m_impulse.x * m_s2     + (m_motorImpulse + m_impulse.y) * m_a2; 

			//bA->m_linearVelocity -= m_invMassA * P;
			bA.m_linearVelocity.x -= m_invMassA * PX;
			bA.m_linearVelocity.y -= m_invMassA * PY;
			//bA->m_angularVelocity -= m_invIA * L1;
			bA.m_angularVelocity -= m_invIA * L1;
			
			//bB->m_linearVelocity += m_invMassB * P;
			bB.m_linearVelocity.x += m_invMassB * PX;
			bB.m_linearVelocity.y += m_invMassB * PY;
			//bB->m_angularVelocity += m_invIB * L2;
			bB.m_angularVelocity += m_invIB * L2;
		}
		else
		{
			m_impulse.setZero();
			m_motorImpulse = 0.0;
		}
	}
	
	public override function solveVelocityConstraints(step:B2TimeStep) : Void{
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var v1:B2Vec2 = bA.m_linearVelocity;
		var w1:Float = bA.m_angularVelocity;
		var v2:B2Vec2 = bB.m_linearVelocity;
		var w2:Float = bB.m_angularVelocity;
		
		var PX:Float;
		var PY:Float;
		var L1:Float;
		var L2:Float;
		
		// Solve linear motor constraint
		if (m_enableMotor && m_limitState != B2Joint.e_equalLimits)
		{
			//float32 Cdot = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1; 
			var Cdot:Float = m_axis.x * (v2.x -v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1;
			var impulse:Float = m_motorMass * (m_motorSpeed - Cdot);
			var oldImpulse:Float = m_motorImpulse;
			var maxImpulse:Float = step.dt * m_maxMotorForce;
			m_motorImpulse = B2Math.clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse);
			impulse = m_motorImpulse - oldImpulse;
			
			PX = impulse * m_axis.x;
			PY = impulse * m_axis.y;
			L1 = impulse * m_a1;
			L2 = impulse * m_a2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		
		//Cdot1 = b2Dot(m_perp, v2 - v1) + m_s2 * w2 - m_s1 * w1; 
		var Cdot1:Float = m_perp.x * (v2.x - v1.x) + m_perp.y * (v2.y - v1.y) + m_s2 * w2 - m_s1 * w1; 
		
		if (m_enableLimit && m_limitState != B2Joint.e_inactiveLimit)
		{
			// Solve prismatic and limit constraint in block form
			//Cdot2 = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1; 
			var Cdot2:Float = m_axis.x * (v2.x - v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1; 
			
			var f1:B2Vec2 = m_impulse.copy();
			var df:B2Vec2 = m_K.solve(new B2Vec2(), -Cdot1, -Cdot2);
			
			m_impulse.add(df);
			
			if (m_limitState == B2Joint.e_atLowerLimit)
			{
				m_impulse.y = B2Math.max(m_impulse.y, 0.0);
			}
			else if (m_limitState == B2Joint.e_atUpperLimit)
			{
				m_impulse.y = B2Math.min(m_impulse.y, 0.0);
			}
			
			// f2(1) = invK(1,1) * (-Cdot(1) - K(1,3) * (f2(2) - f1(2))) + f1(1) 
			var b:Float = -Cdot1 - (m_impulse.y - f1.y) * m_K.col2.x;
			var f2r:Float;
			if (m_K.col1.x != 0.0)
			{
				f2r = b / m_K.col1.x + f1.x;
			}else {
				f2r = f1.x;
			}
			m_impulse.x = f2r;
			
			df.x = m_impulse.x - f1.x;
			df.y = m_impulse.y - f1.y;
			
			PX = df.x * m_perp.x + df.y * m_axis.x;
			PY = df.x * m_perp.y + df.y * m_axis.y;
			L1 = df.x * m_s1 + df.y * m_a1;
			L2 = df.x * m_s2 + df.y * m_a2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		else
		{
			// Limit is inactive, just solve the prismatic constraint in block form. 
			var df2:Float;
			if (m_K.col1.x != 0.0)
			{
				df2 = ( -Cdot1) / m_K.col1.x;
			}else {
				df2 = 0.0;
			}
			m_impulse.x += df2;
			
			PX = df2 * m_perp.x;
			PY = df2 * m_perp.y;
			L1 = df2 * m_s1;
			L2 = df2 * m_s2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		
		bA.m_linearVelocity.setV(v1);
		bA.m_angularVelocity = w1;
		bB.m_linearVelocity.setV(v2);
		bB.m_angularVelocity = w2;
	}
	
	public override function solvePositionConstraints(baumgarte:Float ):Bool
	{
		//B2_NOT_USED(baumgarte);
		
		
		var limitC:Float;
		var oldLimitImpulse:Float;
		
		var bA:B2Body = m_bodyA;
		var bB:B2Body = m_bodyB;
		
		var c1:B2Vec2 = bA.m_sweep.c;
		var a1:Float = bA.m_sweep.a;
		
		var c2:B2Vec2 = bB.m_sweep.c;
		var a2:Float = bB.m_sweep.a;
		
		var tMat:B2Mat22;
		var tX:Float;
		
		var m1:Float;
		var m2:Float;
		var i1:Float;
		var i2:Float;
		
		// Solve linear limit constraint
		var linearError:Float = 0.0;
		var angularError:Float = 0.0;
		var active:Bool = false;
		var C2:Float = 0.0;
		
		var R1:B2Mat22 = B2Mat22.fromAngle(a1);
		var R2:B2Mat22 = B2Mat22.fromAngle(a2);
		
		//b2Vec2 r1 = b2Mul(R1, m_localAnchor1 - m_localCenter1);
		tMat = R1;
		var r1X:Float = m_localAnchor1.x - m_localCenterA.x;
		var r1Y:Float = m_localAnchor1.y - m_localCenterA.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(R2, m_localAnchor2 - m_localCenter2);
		tMat = R2;
		var r2X:Float = m_localAnchor2.x - m_localCenterB.x;
		var r2Y:Float = m_localAnchor2.y - m_localCenterB.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		var dX:Float = c2.x + r2X - c1.x - r1X;
		var dY:Float = c2.y + r2Y - c1.y - r1Y;
		
		if (m_enableLimit)
		{
			m_axis = B2Math.mulMV(R1, m_localXAxis1);
			
			//m_a1 = b2Math.b2Cross(d + r1, m_axis);
			m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x;
			//m_a2 = b2Math.b2Cross(r2, m_axis);
			m_a2 = r2X * m_axis.y - r2Y * m_axis.x;
			
			var translation:Float = m_axis.x * dX + m_axis.y * dY;
			if (B2Math.abs(m_upperTranslation - m_lowerTranslation) < 2.0 * B2Settings.b2_linearSlop)
			{
				// Prevent large angular corrections.
				C2 = B2Math.clamp(translation, -B2Settings.b2_maxLinearCorrection, B2Settings.b2_maxLinearCorrection);
				linearError = B2Math.abs(translation);
				active = true;
			}
			else if (translation <= m_lowerTranslation)
			{
				// Prevent large angular corrections and allow some slop.
				C2 = B2Math.clamp(translation - m_lowerTranslation + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0.0);
				linearError = m_lowerTranslation - translation;
				active = true;
			}
			else if (translation >= m_upperTranslation)
			{
				// Prevent large angular corrections and allow some slop.
				C2 = B2Math.clamp(translation - m_upperTranslation + B2Settings.b2_linearSlop, 0.0, B2Settings.b2_maxLinearCorrection);
				linearError = translation - m_upperTranslation;
				active = true;
			}
		}
		
		m_perp = B2Math.mulMV(R1, m_localYAxis1);
		
		//m_s1 = b2Cross(d + r1, m_perp); 
		m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x;
		//m_s2 = b2Cross(r2, m_perp); 
		m_s2 = r2X * m_perp.y - r2Y * m_perp.x;
		
		var impulse:B2Vec2 = new B2Vec2();
		var C1:Float = m_perp.x * dX + m_perp.y * dY;
		
		linearError = B2Math.max(linearError, B2Math.abs(C1));
		angularError = 0.0;
		
		if (active)
		{
			m1 = m_invMassA;
			m2 = m_invMassB;
			i1 = m_invIA;
			i2 = m_invIB;
			
			m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
 	  	  	m_K.col1.y = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2;
			m_K.col2.x = m_K.col1.y;
 	  	  	m_K.col2.y = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2;
			
			m_K.solve(impulse, -C1, -C2);
		}
		else
		{
			m1 = m_invMassA;
			m2 = m_invMassB;
			i1 = m_invIA;
			i2 = m_invIB;
			
			var k11:Float  = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
			
			var impulse1:Float;
			if (k11 != 0.0)
			{
				impulse1 = ( -C1) / k11;
			}else {
				impulse1 = 0.0;
			}
			impulse.x = impulse1;
			impulse.y = 0.0;
		}
		
		var PX:Float = impulse.x * m_perp.x + impulse.y * m_axis.x;
		var PY:Float = impulse.x * m_perp.y + impulse.y * m_axis.y;
		var L1:Float = impulse.x * m_s1 + impulse.y * m_a1;
		var L2:Float = impulse.x * m_s2 + impulse.y * m_a2;
		
		c1.x -= m_invMassA * PX;
		c1.y -= m_invMassA * PY;
		a1 -= m_invIA * L1;
		
		c2.x += m_invMassB * PX;
		c2.y += m_invMassB * PY;
		a2 += m_invIB * L2;
		
		// TODO_ERIN remove need for this
		//bA.m_sweep.c = c1;	//Already done by reference
		bA.m_sweep.a = a1;
		//bB.m_sweep.c = c2;	//Already done by reference
		bB.m_sweep.a = a2;
		bA.synchronizeTransform();
		bB.synchronizeTransform(); 
		
		return linearError <= B2Settings.b2_linearSlop && angularError <= B2Settings.b2_angularSlop;
		
	}

	public var m_localAnchor1:B2Vec2;
	public var m_localAnchor2:B2Vec2;
	public var m_localXAxis1:B2Vec2;
	private var m_localYAxis1:B2Vec2;

	private var m_axis:B2Vec2;
	private var m_perp:B2Vec2;
	private var m_s1:Float;
	private var m_s2:Float;
	private var m_a1:Float;
	private var m_a2:Float;
	
	private var m_K:B2Mat22;
	private var m_impulse:B2Vec2;

	private var m_motorMass:Float;			// effective mass for motor/limit translational constraint.
	private var m_motorImpulse:Float;

	private var m_lowerTranslation:Float;
	private var m_upperTranslation:Float;
	private var m_maxMotorForce:Float;
	private var m_motorSpeed:Float;
	
	private var m_enableLimit:Bool;
	private var m_enableMotor:Bool;
	private var m_limitState:Int;
}