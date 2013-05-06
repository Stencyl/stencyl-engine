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
	

import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;


/**
* An axis aligned bounding box.
*/
class B2AABB
{
	/**
	* Verify that the bounds are sorted.
	*/
	public function isValid():Bool{
		//b2Vec2 d = upperBound - lowerBound;;
		var dX:Float = upperBound.x - lowerBound.x;
		var dY:Float = upperBound.y - lowerBound.y;
		var valid:Bool = dX >= 0.0 && dY >= 0.0;
		valid = valid && lowerBound.isValid() && upperBound.isValid();
		return valid;
	}
	
	/** Get the center of the AABB. */
	public function getCenter():B2Vec2
	{
		return new B2Vec2( (lowerBound.x + upperBound.x) / 2,
		                   (lowerBound.y + upperBound.y) / 2);
	}
	
	/** Get the extents of the AABB (half-widths). */
	public function getExtents():B2Vec2
	{
		return new B2Vec2( (upperBound.x - lowerBound.x) / 2,
		                   (upperBound.y - lowerBound.y) / 2);
	}
	
	/**
	 * Is an AABB contained within this one.
	 */
	public function contains(aabb:B2AABB):Bool
	{
		var result:Bool = true;
		result = result && (lowerBound.x <= aabb.lowerBound.x);
		result = result && (lowerBound.y <= aabb.lowerBound.y);
		result = result && (aabb.upperBound.x <= upperBound.x);
		result = result && (aabb.upperBound.y <= upperBound.y);
		return result;
	}
	
	// From Real-time Collision Detection, p179.
	/**
	 * Perform a precise raycast against the AABB.
	 */
	public function rayCast(output:B2RayCastOutput, input:B2RayCastInput):Bool
	{
		var tmin:Float = -B2Math.MAX_VALUE;
		var tmax:Float = B2Math.MAX_VALUE;
		
		var pX:Float = input.p1.x;
		var pY:Float = input.p1.y;
		var dX:Float = input.p2.x - input.p1.x;
		var dY:Float = input.p2.y - input.p1.y;
		var absDX:Float = Math.abs(dX);
		var absDY:Float = Math.abs(dY);
		
		var normal:B2Vec2 = output.normal;
		
		var inv_d:Float;
		var t1:Float;
		var t2:Float;
		var t3:Float;
		var s:Float;
		
		//x
		{
			if (absDX < B2Math.MIN_VALUE)
			{
				// Parallel.
				if (pX < lowerBound.x || upperBound.x < pX)
					return false;
			}
			else
			{
				inv_d = 1.0 / dX;
				t1 = (lowerBound.x - pX) * inv_d;
				t2 = (upperBound.x - pX) * inv_d;
				
				// Sign of the normal vector
				s = -1.0;
				
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0;
				}
				
				// Push the min up
				if (t1 > tmin)
				{
					normal.x = s;
					normal.y = 0;
					tmin = t1;
				}
				
				// Pull the max down
				tmax = Math.min(tmax, t2);
				
				if (tmin > tmax)
					return false;
			}
		}
		//y
		{
			if (absDY < B2Math.MIN_VALUE)
			{
				// Parallel.
				if (pY < lowerBound.y || upperBound.y < pY)
					return false;
			}
			else
			{
				inv_d = 1.0 / dY;
				t1 = (lowerBound.y - pY) * inv_d;
				t2 = (upperBound.y - pY) * inv_d;
				
				// Sign of the normal vector
				s = -1.0;
				
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0;
				}
				
				// Push the min up
				if (t1 > tmin)
				{
					normal.y = s;
					normal.x = 0;
					tmin = t1;
				}
				
				// Pull the max down
				tmax = Math.min(tmax, t2);
				
				if (tmin > tmax)
					return false;
			}
		}
		
		output.fraction = tmin;
		return true;
	}
	
	/**
	 * Tests if another AABB overlaps this one.
	 */
	public function testOverlap(other:B2AABB):Bool
	{
		var d1X:Float = other.lowerBound.x - upperBound.x;
		var d1Y:Float = other.lowerBound.y - upperBound.y;
		var d2X:Float = lowerBound.x - other.upperBound.x;
		var d2Y:Float = lowerBound.y - other.upperBound.y;

		if (d1X > 0.0 || d1Y > 0.0)
			return false;

		if (d2X > 0.0 || d2Y > 0.0)
			return false;

		return true;
	}
	
	/** Combine two AABBs into one. */
	/*public static function combine(aabb1:B2AABB, aabb2:B2AABB):B2AABB
	{
		var aabb:B2AABB = new B2AABB();
		aabb.combine(aabb1, aabb2);
		return aabb;
	}*/
	
	/** Combine two AABBs into one. */
	public function combine(aabb1:B2AABB, aabb2:B2AABB):Void
	{
		lowerBound.x = Math.min(aabb1.lowerBound.x, aabb2.lowerBound.x);
		lowerBound.y = Math.min(aabb1.lowerBound.y, aabb2.lowerBound.y);
		upperBound.x = Math.max(aabb1.upperBound.x, aabb2.upperBound.x);
		upperBound.y = Math.max(aabb1.upperBound.y, aabb2.upperBound.y);
	}
	
	public function new () {
		
		lowerBound = new B2Vec2();
		upperBound = new B2Vec2();
		
	}

	/** The lower vertex */
	public var lowerBound:B2Vec2;
	/** The upper vertex */
	public var upperBound:B2Vec2;
}