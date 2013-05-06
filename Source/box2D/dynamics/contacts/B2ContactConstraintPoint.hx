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

package box2D.dynamics.contacts;


import box2D.common.math.B2Vec2;


/**
* @private
*/
class B2ContactConstraintPoint
{
	
	public function new () {
		
		localPoint = new B2Vec2 ();
		rA = new B2Vec2 ();
		rB = new B2Vec2 ();
		
	}
	
	public var localPoint:B2Vec2;
	public var rA:B2Vec2;
	public var rB:B2Vec2;
	public var normalImpulse:Float;
	public var tangentImpulse:Float;
	public var normalMass:Float;
	public var tangentMass:Float;
	public var equalizedMass:Float;
	public var velocityBias:Float;
}