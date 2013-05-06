/*
* Copyright (c) 2009 Erin Catto http://www.gphysics.com
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

/**
 * Specifies a segment for use with RayCast functions.
 */
package box2D.collision;

import box2D.common.math.B2Vec2;

class B2RayCastInput 
{
	public function new (p1:B2Vec2 = null, p2:B2Vec2 = null, maxFraction:Float = 1)
	{
		
		this.p1 = new B2Vec2();
		this.p2 = new B2Vec2();
		
		if (p1 != null)
			this.p1.setV(p1);
		if (p2 != null)
			this.p2.setV(p2);
		this.maxFraction = maxFraction;
	}
	/**
	 * The start point of the ray
	 */
	public var p1:B2Vec2;
	/**
	 * The end point of the ray
	 */
	public var p2:B2Vec2;
	/**
	 * Truncate the ray to reach up to this fraction from p1 to p2
	 */
	public var maxFraction:Float;
}