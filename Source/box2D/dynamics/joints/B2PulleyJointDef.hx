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
* Pulley joint definition. This requires two ground anchors,
* two dynamic body anchor points, max lengths for each side,
* and a pulley ratio.
* @see b2PulleyJoint
*/

class B2PulleyJointDef extends B2JointDef
{
	public function new()
	{
		super ();
		groundAnchorA = new B2Vec2();
		groundAnchorB = new B2Vec2();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		
		type = B2Joint.e_pulleyJoint;
		groundAnchorA.set(-1.0, 1.0);
		groundAnchorB.set(1.0, 1.0);
		localAnchorA.set(-1.0, 0.0);
		localAnchorB.set(1.0, 0.0);
		lengthA = 0.0;
		maxLengthA = 0.0;
		lengthB = 0.0;
		maxLengthB = 0.0;
		ratio = 1.0;
		collideConnected = true;
	}
	
	public function initialize(bA:B2Body, bB:B2Body,
				gaA:B2Vec2, gaB:B2Vec2,
				anchorA:B2Vec2, anchorB:B2Vec2,
				r:Float) : Void
	{
		bodyA = bA;
		bodyB = bB;
		groundAnchorA.setV( gaA );
		groundAnchorB.setV( gaB );
		localAnchorA = bodyA.getLocalPoint(anchorA);
		localAnchorB = bodyB.getLocalPoint(anchorB);
		//b2Vec2 d1 = anchorA - gaA;
		var d1X:Float = anchorA.x - gaA.x;
		var d1Y:Float = anchorA.y - gaA.y;
		//length1 = d1.Length();
		lengthA = Math.sqrt(d1X*d1X + d1Y*d1Y);
		
		//b2Vec2 d2 = anchor2 - ga2;
		var d2X:Float = anchorB.x - gaB.x;
		var d2Y:Float = anchorB.y - gaB.y;
		//length2 = d2.Length();
		lengthB = Math.sqrt(d2X*d2X + d2Y*d2Y);
		
		ratio = r;
		//b2Settings.b2Assert(ratio > Number.MIN_VALUE);
		var C:Float = lengthA + ratio * lengthB;
		maxLengthA = C - ratio * B2PulleyJoint.b2_minPulleyLength;
		maxLengthB = (C - B2PulleyJoint.b2_minPulleyLength) / ratio;
	}

	/**
	* The first ground anchor in world coordinates. This point never moves.
	*/
	public var groundAnchorA:B2Vec2;
	
	/**
	* The second ground anchor in world coordinates. This point never moves.
	*/
	public var groundAnchorB:B2Vec2;
	
	/**
	* The local anchor point relative to bodyA's origin.
	*/
	public var localAnchorA:B2Vec2;
	
	/**
	* The local anchor point relative to bodyB's origin.
	*/
	public var localAnchorB:B2Vec2;
	
	/**
	* The a reference length for the segment attached to bodyA.
	*/
	public var lengthA:Float;
	
	/**
	* The maximum length of the segment attached to bodyA.
	*/
	public var maxLengthA:Float;
	
	/**
	* The a reference length for the segment attached to bodyB.
	*/
	public var lengthB:Float;
	
	/**
	* The maximum length of the segment attached to bodyB.
	*/
	public var maxLengthB:Float;
	
	/**
	* The pulley ratio, used to simulate a block-and-tackle.
	*/
	public var ratio:Float;
	
}