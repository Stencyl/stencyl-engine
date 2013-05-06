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
 * Friction joint defintion
 * @see b2FrictionJoint
 */
class B2FrictionJointDef extends B2JointDef
{
	public function new ()
	{
		super ();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		
		type = B2Joint.e_frictionJoint;
		maxForce = 0.0;
		maxTorque = 0.0;
	}
	
	/**
	 * Initialize the bodies, anchors, axis, and reference angle using the world
	 * anchor and world axis.
	 */
	public function initialize(bA:B2Body, bB:B2Body,
								anchor:B2Vec2) : Void
	{
		bodyA = bA;
		bodyB = bB;
		localAnchorA.setV( bodyA.getLocalPoint(anchor));
		localAnchorB.setV( bodyB.getLocalPoint(anchor));
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
	 * The maximun force in N.
	 */
	public var maxForce:Float;
	
	/**
	 * The maximun friction torque in N-m
	 */
	public var maxTorque:Float;
}