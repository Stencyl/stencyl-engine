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
	

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;


/**
* Revolute joint definition. This requires defining an
* anchor point where the bodies are joined. The definition
* uses local anchor points so that the initial configuration
* can violate the constraint slightly. You also need to
* specify the initial relative angle for joint limits. This
* helps when saving and loading a game.
* The local anchor points are measured from the body's origin
* rather than the center of mass because:
* 1. you might not know where the center of mass will be.
* 2. if you add/remove shapes from a body and recompute the mass,
* the joints will be broken.
* @see b2RevoluteJoint
*/

class B2RevoluteJointDef extends B2JointDef
{
	public function new ()
	{
		super ();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		
		type = B2Joint.e_revoluteJoint;
		localAnchorA.set(0.0, 0.0);
		localAnchorB.set(0.0, 0.0);
		referenceAngle = 0.0;
		lowerAngle = 0.0;
		upperAngle = 0.0;
		maxMotorTorque = 0.0;
		motorSpeed = 0.0;
		enableLimit = false;
		enableMotor = false;
	}

	/**
	* Initialize the bodies, anchors, and reference angle using the world
	* anchor.
	*/
	public function initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2) : Void{
		bodyA = bA;
		bodyB = bB;
		localAnchorA = bodyA.getLocalPoint(anchor);
		localAnchorB = bodyB.getLocalPoint(anchor);
		referenceAngle = bodyB.getAngle() - bodyA.getAngle();
	}

	/**
	* The local anchor point relative to bodyA's origin.
	*/
	public var localAnchorA:B2Vec2;

	/**
	* The local anchor point relative to bodyB's origin.
	*/
	public var localAnchorB:B2Vec2;

	/**
	* The bodyB angle minus bodyA angle in the reference state (radians).
	*/
	public var referenceAngle:Float;

	/**
	* A flag to enable joint limits.
	*/
	public var enableLimit:Bool;

	/**
	* The lower angle for the joint limit (radians).
	*/
	public var lowerAngle:Float;

	/**
	* The upper angle for the joint limit (radians).
	*/
	public var upperAngle:Float;

	/**
	* A flag to enable the joint motor.
	*/
	public var enableMotor:Bool;

	/**
	* The desired motor speed. Usually in radians per second.
	*/
	public var motorSpeed:Float;

	/**
	* The maximum motor torque used to achieve the desired motor speed.
	* Usually in N-m.
	*/
	public var maxMotorTorque:Float;
	
}