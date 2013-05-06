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
 * Line joint definition. This requires defining a line of
 * motion using an axis and an anchor point. The definition uses local
 * anchor points and a local axis so that the initial configuration
 * can violate the constraint slightly. The joint translation is zero
 * when the local anchor points coincide in world space. Using local
 * anchors and a local axis helps when saving and loading a game.
 * @see b2LineJoint
 */
class B2LineJointDef extends B2JointDef
{
	public function new()
	{
		super ();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		localAxisA = new B2Vec2();
		
		type = B2Joint.e_lineJoint;
		//localAnchor1.SetZero();
		//localAnchor2.SetZero();
		localAxisA.set(1.0, 0.0);
		enableLimit = false;
		lowerTranslation = 0.0;
		upperTranslation = 0.0;
		enableMotor = false;
		maxMotorForce = 0.0;
		motorSpeed = 0.0;
	}
	
	public function initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2, axis:B2Vec2) : Void
	{
		bodyA = bA;
		bodyB = bB;
		localAnchorA = bodyA.getLocalPoint(anchor);
		localAnchorB = bodyB.getLocalPoint(anchor);
		localAxisA = bodyA.getLocalVector(axis);
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
	* The local translation axis in bodyA.
	*/
	public var localAxisA:B2Vec2;

	/**
	* Enable/disable the joint limit.
	*/
	public var enableLimit:Bool;

	/**
	* The lower translation limit, usually in meters.
	*/
	public var lowerTranslation:Float;

	/**
	* The upper translation limit, usually in meters.
	*/
	public var upperTranslation:Float;

	/**
	* Enable/disable the joint motor.
	*/
	public var enableMotor:Bool;

	/**
	* The maximum motor torque, usually in N-m.
	*/
	public var maxMotorForce:Float;

	/**
	* The desired motor speed in radians per second.
	*/
	public var motorSpeed:Float;

	
}