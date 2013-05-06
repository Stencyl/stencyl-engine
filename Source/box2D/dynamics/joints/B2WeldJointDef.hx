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
 * Weld joint definition. You need to specify local anchor points
 * where they are attached and the relative body angle. The position
 * of the anchor points is important for computing the reaction torque.
 * @see b2WeldJoint
 */
class B2WeldJointDef extends B2JointDef
{
	public function new()
	{
		super ();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		
		type = B2Joint.e_weldJoint;
		referenceAngle = 0.0;
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
	 * The body2 angle minus body1 angle in the reference state (radians).
	 */
	public var referenceAngle:Float;
}