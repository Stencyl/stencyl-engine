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

package box2D.collision;
	

import box2D.common.math.B2Vec2;


/**
 * A manifold point is a contact point belonging to a contact
 * manifold. It holds details related to the geometry and dynamics
 * of the contact points.
 * The local point usage depends on the manifold type:
 * -e_circles: the local center of circleB
 * -e_faceA: the local center of cirlceB or the clip point of polygonB
 * -e_faceB: the clip point of polygonA
 * This structure is stored across time steps, so we keep it small.
 * Note: the impulses are used for internal caching and may not
 * provide reliable contact forces, especially for high speed collisions.
 */
class B2ManifoldPoint
{
	public function new ()
	{
		m_localPoint = new B2Vec2();
		m_id = new B2ContactID();
		reset();
	}
	public function reset() : Void{
		m_localPoint.setZero();
		m_normalImpulse = 0.0;
		m_tangentImpulse = 0.0;
		m_id.key = 0;
	}
	public function set(m:B2ManifoldPoint) : Void{
		m_localPoint.setV(m.m_localPoint);
		m_normalImpulse = m.m_normalImpulse;
		m_tangentImpulse = m.m_tangentImpulse;
		m_id.set(m.m_id);
	}
	public var m_localPoint:B2Vec2;
	public var m_normalImpulse:Float;
	public var m_tangentImpulse:Float;
	public var m_id:B2ContactID;
}