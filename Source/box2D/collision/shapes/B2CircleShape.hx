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
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.B2Settings;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;


/**
* A circle shape.
* @see b2CircleDef
*/
class B2CircleShape extends B2Shape
{
	override public function copy():B2Shape 
	{
		var s:B2Shape = new B2CircleShape();
		s.set(this);
		return s;
	}
	
	override public function set(other:B2Shape):Void 
	{
		super.set(other);
		if (Std.is (other, B2CircleShape))
		{
			var other2:B2CircleShape = cast (other, B2CircleShape);
			m_p.setV(other2.m_p);
		}
	}
	
	/**
	* @inheritDoc
	*/
	public override function testPoint(transform:B2Transform, p:B2Vec2) : Bool {
		//b2Vec2 center = transform.position + b2Mul(transform.R, m_p);
		var tMat:B2Mat22 = transform.R;
		var dX:Float = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		var dY:Float = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		//b2Vec2 d = p - center;
		dX = p.x - dX;
		dY = p.y - dY;
		//return b2Dot(d, d) <= m_radius * m_radius;
		return (dX*dX + dY*dY) <= m_radius * m_radius;
	}

	/**
	* @inheritDoc
	*/
	public override function rayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool
	{
		//b2Vec2 position = transform.position + b2Mul(transform.R, m_p);
		var tMat:B2Mat22 = transform.R;
		var positionX:Float = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		var positionY:Float = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		
		//b2Vec2 s = input.p1 - position;
		var sX:Float = input.p1.x - positionX;
		var sY:Float = input.p1.y - positionY;
		//float32 b = b2Dot(s, s) - m_radius * m_radius;
		var b:Float = (sX*sX + sY*sY) - m_radius * m_radius;
		
		/*// Does the segment start inside the circle?
		if (b < 0.0)
		{
			output.fraction = 0;
			output.hit = e_startsInsideCollide;
			return;
		}*/
		
		// Solve quadratic equation.
		//b2Vec2 r = input.p2 - input.p1;
		var rX:Float = input.p2.x - input.p1.x;
		var rY:Float = input.p2.y - input.p1.y;
		//float32 c =  b2Dot(s, r);
		var c:Float =  (sX*rX + sY*rY);
		//float32 rr = b2Dot(r, r);
		var rr:Float = (rX*rX + rY*rY);
		var sigma:Float = c * c - rr * b;
		
		// Check for negative discriminant and short segment.
		if (sigma < 0.0 || rr < B2Math.MIN_VALUE)
		{
			return false;
		}
		
		// Find the point of intersection of the line with the circle.
		var a:Float = -(c + Math.sqrt(sigma));
		
		// Is the intersection point on the segment?
		if (0.0 <= a && a <= input.maxFraction * rr)
		{
			a /= rr;
			output.fraction = a;
			// manual inline of: output.normal = s + a * r;
			output.normal.x = sX + a * rX;
			output.normal.y = sY + a * rY;
			output.normal.normalize();
			return true;
		}
		
		return false;
	}

	/**
	* @inheritDoc
	*/
	public override function computeAABB(aabb:B2AABB, transform:B2Transform) : Void{
		//b2Vec2 p = transform.position + b2Mul(transform.R, m_p);
		var tMat:B2Mat22 = transform.R;
		var pX:Float = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		var pY:Float = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		aabb.lowerBound.set(pX - m_radius, pY - m_radius);
		aabb.upperBound.set(pX + m_radius, pY + m_radius);
	}

	/**
	* @inheritDoc
	*/
	public override function computeMass(massData:B2MassData, density:Float) : Void{
		massData.mass = density * B2Settings.b2_pi * m_radius * m_radius;
		massData.center.setV(m_p);
		
		// inertia about the local origin
		//massData.I = massData.mass * (0.5 * m_radius * m_radius + b2Dot(m_p, m_p));
		massData.I = massData.mass * (0.5 * m_radius * m_radius + (m_p.x*m_p.x + m_p.y*m_p.y));
	}
	
	/**
	* @inheritDoc
	*/
	public override function computeSubmergedArea(
			normal:B2Vec2,
			offset:Float,
			xf:B2Transform,
			c:B2Vec2):Float
	{
		var p:B2Vec2 = B2Math.mulX(xf, m_p, true);
		var l:Float = -(B2Math.dot(normal, p) - offset);
		
		if (l < -m_radius + B2Math.MIN_VALUE)
		{
			//Completely dry
			return 0;
		}
		if (l > m_radius)
		{
			//Completely wet
			c.setV(p);
			return Math.PI * m_radius * m_radius;
		}
		
		//Magic
		var r2:Float = m_radius * m_radius;
		var l2:Float = l * l;
		var area:Float = r2 *( Math.asin(l / m_radius) + Math.PI / 2) + l * Math.sqrt( r2 - l2 );
		var com:Float = -2 / 3 * Math.pow(r2 - l2, 1.5) / area;
		
		c.x = p.x + normal.x * com;
		c.y = p.y + normal.y * com;
		
		return area;
	}

	/**
	 * Get the local position of this circle in its parent body.
	 */
	public function getLocalPosition() : B2Vec2{
		return m_p;
	}
	
	/**
	 * Set the local position of this circle in its parent body.
	 */
	public function setLocalPosition(position:B2Vec2):Void {
		m_p.setV(position);
	}
	
	/**
	 * Get the radius of the circle
	 */
	public function getRadius():Float
	{
		return m_radius;
	}
	
	/**
	 * Set the radius of the circle
	 */
	public function setRadius(radius:Float):Void
	{
		m_radius = radius;
	}

	public function new (radius:Float = 0){
		super();
		m_p = new B2Vec2();
		m_type = B2Shape.e_circleShape;
		m_radius = radius;
	}

	// Local position in parent body
	public var m_p:B2Vec2;
	
}