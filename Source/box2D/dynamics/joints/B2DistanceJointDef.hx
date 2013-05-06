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

	
import box2D.dynamics.B2Body;
import box2D.common.math.B2Vec2;


/**
* Distance joint definition. This requires defining an
* anchor point on both bodies and the non-zero length of the
* distance joint. The definition uses local anchor points
* so that the initial configuration can violate the constraint
* slightly. This helps when saving and loading a game.
* @warning Do not use a zero or short length.
* @see b2DistanceJoint
*/
class B2DistanceJointDef extends B2JointDef
{
	public function new ()
	{
		super ();
		localAnchorA = new B2Vec2 ();
		localAnchorB = new B2Vec2 ();
		
		type = B2Joint.e_distanceJoint;
		//localAnchor1.Set(0.0, 0.0);
		//localAnchor2.Set(0.0, 0.0);
		length = 1.0;
		frequencyHz = 0.0;
		dampingRatio = 0.0;
	}
	
	/**
	* Initialize the bodies, anchors, and length using the world
	* anchors.
	*/
	public function initialize(bA:B2Body, bB:B2Body,
								anchorA:B2Vec2, anchorB:B2Vec2) : Void
	{
		bodyA = bA;
		bodyB = bB;
		localAnchorA.setV( bodyA.getLocalPoint(anchorA));
		localAnchorB.setV( bodyB.getLocalPoint(anchorB));
		var dX:Float = anchorB.x - anchorA.x;
		var dY:Float = anchorB.y - anchorA.y;
		length = Math.sqrt(dX*dX + dY*dY);
		frequencyHz = 0.0;
		dampingRatio = 0.0;
	}

	/**
	* The local anchor point relative to body1's origin.
	*/
	public var localAnchorA:B2Vec2;

	/**
	* The local anchor point relative to body2's origin.
	*/
	public var localAnchorB:B2Vec2;

	/**
	* The natural length between the anchor points.
	*/
	public var length:Float;

	/**
	* The mass-spring-damper frequency in Hertz.
	*/
	public var frequencyHz:Float;

	/**
	* The damping ratio. 0 = no damping, 1 = critical damping.
	*/
	public var dampingRatio:Float;
}