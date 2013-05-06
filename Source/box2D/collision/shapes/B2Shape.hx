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

package box2D.collision.shapes;


import box2D.collision.B2AABB;
import box2D.collision.B2Distance;
import box2D.collision.B2DistanceInput;
import box2D.collision.B2DistanceOutput;
import box2D.collision.B2DistanceProxy;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.collision.B2SimplexCache;
import box2D.common.B2Settings;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;



/**
* A shape is used for collision detection. Shapes are created in b2Body.
* You can use shape for collision detection before they are attached to the world.
* @warning you cannot reuse shapes.
*/
class B2Shape
{
	
	/**
	 * Clone the shape
	 */
	public function copy():B2Shape
	{
		//var s:B2Shape = new B2Shape();
		//s.Set(this);
		//return s;
		return null; // Abstract type
	}
	
	/**
	 * Assign the properties of anther shape to this
	 */
	public function set(other:B2Shape):Void
	{
		//Don't copy m_type?
		//m_type = other.m_type;
		m_radius = other.m_radius;
	}
	
	/**
	* Get the type of this shape. You can use this to down cast to the concrete shape.
	* @return the shape type.
	*/
	public function getType() : Int
	{
		return m_type;
	}

	/**
	* Test a point for containment in this shape. This only works for convex shapes.
	* @param xf the shape world transform.
	* @param p a point in world coordinates.
	*/
	public function testPoint(xf:B2Transform, p:B2Vec2) : Bool { return false; }

	/**
	 * Cast a ray against this shape.
	 * @param output the ray-cast results.
	 * @param input the ray-cast input parameters.
	 * @param transform the transform to be applied to the shape.
	 */
	public function rayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool
	{
		return false;
	}

	/**
	* Given a transform, compute the associated axis aligned bounding box for this shape.
	* @param aabb returns the axis aligned box.
	* @param xf the world transform of the shape.
	*/
	public function computeAABB(aabb:B2AABB, xf:B2Transform) : Void {}

	/**
	* Compute the mass properties of this shape using its dimensions and density.
	* The inertia tensor is computed about the local origin, not the centroid.
	* @param massData returns the mass data for this shape.
	*/
	public function computeMass(massData:B2MassData, density:Float) : Void { }
	
	/**
	 * Compute the volume and centroid of this shape intersected with a half plane
	 * @param normal the surface normal
	 * @param offset the surface offset along normal
	 * @param xf the shape transform
	 * @param c returns the centroid
	 * @return the total volume less than offset along normal
	 */
	public function computeSubmergedArea(
				normal:B2Vec2,
				offset:Float,
				xf:B2Transform,
				c:B2Vec2):Float { return 0; }
				
	public static function testOverlap(shape1:B2Shape, transform1:B2Transform, shape2:B2Shape, transform2:B2Transform):Bool
	{
		var input:B2DistanceInput = new B2DistanceInput ();
		input.proxyA = new B2DistanceProxy ();
		input.proxyA.set(shape1);
		input.proxyB = new B2DistanceProxy();
		input.proxyB.set(shape2);
		input.transformA = transform1;
		input.transformB = transform2;
		input.useRadii = true;
		var simplexCache:B2SimplexCache = new B2SimplexCache();
		simplexCache.count = 0;
		var output:B2DistanceOutput = new B2DistanceOutput();
		B2Distance.distance(output, simplexCache, input);
		return output.distance  < 10.0 * B2Math.MIN_VALUE;
		
		/*distanceInput.proxyA = proxyA;
		distanceInput.proxyA.set(shape1);
		distanceInput.proxyB = proxyB;
		distanceInput.proxyB.set(shape2);
		distanceInput.transformA = transform1;
		distanceInput.transformB = transform2;
		distanceInput.useRadii = true;
		simplexCache.count = 0;
		B2Distance.distance(distanceOutput, simplexCache, distanceInput);
		return distanceOutput.distance  < 10.0 * B2Math.MIN_VALUE;*/
		
		return true;
	}
	
	public static var distanceInput:B2DistanceInput = new B2DistanceInput();
	public static var proxyA:B2DistanceProxy = new B2DistanceProxy();
	public static var proxyB:B2DistanceProxy = new B2DistanceProxy();
	public static var simplexCache:B2SimplexCache = new B2SimplexCache();
	public static var distanceOutput:B2DistanceOutput = new B2DistanceOutput();
	
	
	//--------------- Internals Below -------------------
	/**
	 * @private
	 */
	public function new ()
	{
		m_type = e_unknownShape;
		m_radius = B2Settings.b2_linearSlop;
	}
	
	//virtual ~b2Shape();
	
	public var m_type:Int;
	public var m_radius:Float;
	
	/**
	* The various collision shape types supported by Box2D.
	*/
	//enum b2ShapeType
	//{
		static public var e_unknownShape:Int = 	-1;
		static public var e_circleShape:Int = 	0;
		static public var e_polygonShape:Int = 	1;
		static public var e_edgeShape:Int =       2;
		static public var e_shapeTypeCount:Int = 	3;
	//};
	
	/**
	 * Possible return values for TestSegment
	 */
		/** Return value for TestSegment indicating a hit. */
		static public var e_hitCollide:Int = 1;
		/** Return value for TestSegment indicating a miss. */
		static public var e_missCollide:Int = 0;
		/** Return value for TestSegment indicating that the segment starting point, p1, is already inside the shape. */
		static public var e_startsInsideCollide:Int = -1;
}