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
	

import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;


/**
* This structure is used to report contact points.
*/
class B2ContactPoint
{
	
	public function new () {
		
		position = new B2Vec2();
		velocity = new B2Vec2();
		normal = new B2Vec2();
		id = new B2ContactID();
		
	}
	
	/** The first shape */
	public var shape1:B2Shape;
	/** The second shape */
	public var shape2:B2Shape;
	/** Position in world coordinates */
	public var position:B2Vec2;
	/** Velocity of point on body2 relative to point on body1 (pre-solver) */
	public var velocity:B2Vec2;
	/** Points from shape1 to shape2 */
	public var normal:B2Vec2;
	/** The separation is negative when shapes are touching */
	public var separation:Float;
	/** The combined friction coefficient */
	public var friction:Float;
	/** The combined restitution coefficient */
	public var restitution:Float;
	/** The contact id identifies the features in contact */
	public var id:B2ContactID;
}