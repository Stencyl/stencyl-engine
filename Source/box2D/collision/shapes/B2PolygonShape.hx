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
import box2D.collision.B2OBB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.B2Settings;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;


/**
* Convex polygon. The vertices must be in CCW order for a right-handed
* coordinate system with the z-axis coming out of the screen.
* @see b2PolygonDef
*/

class B2PolygonShape extends B2Shape
{
	public override function copy():B2Shape 
	{
		var s:B2PolygonShape = new B2PolygonShape();
		s.set(this);
		return s;
	}
	
	public override function set(other:B2Shape):Void 
	{
		super.set(other);
		if (Std.is (other, B2PolygonShape))
		{
			var other2:B2PolygonShape = cast (other, B2PolygonShape);
			m_centroid.setV(other2.m_centroid);
			m_vertexCount = other2.m_vertexCount;
			reserve(m_vertexCount);
			for (i in 0...m_vertexCount)
			{
				m_vertices[i].setV(other2.m_vertices[i]);
				m_normals[i].setV(other2.m_normals[i]);
			}
		}
	}
	
	/**
	 * Copy vertices. This assumes the vertices define a convex polygon.
	 * It is assumed that the exterior is the the right of each edge.
	 */
	public function setAsArray(vertices:Array <Dynamic>, vertexCount:Float = 0):Void
	{
		var v:Array <B2Vec2> = new Array <B2Vec2>();
		for (tVec in vertices)
		{
			v.push(tVec);
		}
		setAsVector(v, vertexCount);
	}
	
	public static function asArray(vertices:Array <Dynamic>, vertexCount:Float):B2PolygonShape
	{
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsArray(vertices, vertexCount);
		return polygonShape;
	}
	
	/**
	 * Copy vertices. This assumes the vertices define a convex polygon.
	 * It is assumed that the exterior is the the right of each edge.
	 */
	public function setAsVector(vertices:Array <B2Vec2>, vertexCount:Float = 0):Void
	{
		if (vertexCount == 0)
			vertexCount = vertices.length;
			
		B2Settings.b2Assert(2 <= vertexCount);
		m_vertexCount = Std.int (vertexCount);
		
		reserve(Std.int (vertexCount));
		
		var i:Int;
		
		// Copy vertices
		for (i in 0...m_vertexCount)
		{
			m_vertices[i].setV(vertices[i]);
		}
		
		// Compute normals. Ensure the edges have non-zero length.
		for (i in 0...m_vertexCount)
		{
			var i1:Int = i;
			var i2:Int = i + 1 < m_vertexCount ? i + 1 : 0;
			var edge:B2Vec2 = B2Math.subtractVVPooled(m_vertices[i2], m_vertices[i1]);
			B2Settings.b2Assert(edge.lengthSquared() > B2Math.MIN_VALUE /* * Number.MIN_VALUE*/);
			m_normals[i].setV(B2Math.crossVF(edge, 1.0));
			m_normals[i].normalize();
		}

		// Compute the polygon centroid
		m_centroid = computeCentroid(m_vertices, m_vertexCount);
	}
	
	public static function asVector(vertices:Array <B2Vec2>, vertexCount:Float):B2PolygonShape
	{
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsVector(vertices, vertexCount);
		return polygonShape;
	}
	
	/**
	* Build vertices to represent an axis-aligned box.
	* @param hx the half-width.
	* @param hy the half-height.
	*/
	public function setAsBox(hx:Float, hy:Float) : Void 
	{
		m_vertexCount = 4;
		reserve(4);
		m_vertices[0].set(-hx, -hy);
		m_vertices[1].set( hx, -hy);
		m_vertices[2].set( hx,  hy);
		m_vertices[3].set(-hx,  hy);
		m_normals[0].set(0.0, -1.0);
		m_normals[1].set(1.0, 0.0);
		m_normals[2].set(0.0, 1.0);
		m_normals[3].set(-1.0, 0.0);
		m_centroid.setZero();
	}
	
	public static function asBox(hx:Float, hy:Float):B2PolygonShape
	{
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsBox(hx, hy);
		return polygonShape;
	}
	
	/**
	* Build vertices to represent an oriented box.
	* @param hx the half-width.
	* @param hy the half-height.
	* @param center the center of the box in local coordinates.
	* @param angle the rotation of the box in local coordinates.
	*/
	static private var s_mat:B2Mat22 = new B2Mat22();
	public function setAsOrientedBox(hx:Float, hy:Float, center:B2Vec2 = null, angle:Float = 0.0) : Void
	{
		m_vertexCount = 4;
		reserve(4);
		m_vertices[0].set(-hx, -hy);
		m_vertices[1].set( hx, -hy);
		m_vertices[2].set( hx,  hy);
		m_vertices[3].set(-hx,  hy);
		m_normals[0].set(0.0, -1.0);
		m_normals[1].set(1.0, 0.0);
		m_normals[2].set(0.0, 1.0);
		m_normals[3].set(-1.0, 0.0);
		m_centroid = center;

		var xf:B2Transform = new B2Transform();
		xf.position = center;
		xf.R.set(angle);

		// Transform vertices and normals.
		for (i in 0...m_vertexCount)
		{
			m_vertices[i] = B2Math.mulX(xf, m_vertices[i]);
			m_normals[i] = B2Math.mulMV(xf.R, m_normals[i]);
		}
	}
	
	public static function asOrientedBox(hx:Float, hy:Float, center:B2Vec2 = null, angle:Float = 0.0):B2PolygonShape
	{
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsOrientedBox(hx, hy, center, angle);
		return polygonShape;
	}
	
	/**
	 * Set this as a single edge.
	 */
	public function setAsEdge(v1:B2Vec2, v2:B2Vec2):Void
	{
		m_vertexCount = 2;
		reserve(2);
		m_vertices[0].setV(v1);
		m_vertices[1].setV(v2);
		m_centroid.x = 0.5 * (v1.x + v2.x);
		m_centroid.y = 0.5 * (v1.y + v2.y);
		m_normals[0] = B2Math.crossVF(B2Math.subtractVV(v2, v1), 1.0);
		m_normals[0].normalize();
		m_normals[1].x = -m_normals[0].x;
		m_normals[1].y = -m_normals[0].y;
	}
	
	/**
	 * Set this as a single edge.
	 */
	static public function asEdge(v1:B2Vec2, v2:B2Vec2):B2PolygonShape
	{
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsEdge(v1, v2);
		return polygonShape;
	}
	
	
	/**
	* @inheritDoc
	*/
	public override function testPoint(xf:B2Transform, p:B2Vec2) : Bool{
		var tVec:B2Vec2;
		
		//b2Vec2 pLocal = b2MulT(xf.R, p - xf.position);
		var tMat:B2Mat22 = xf.R;
		var tX:Float = p.x - xf.position.x;
		var tY:Float = p.y - xf.position.y;
		var pLocalX:Float = (tX*tMat.col1.x + tY*tMat.col1.y);
		var pLocalY:Float = (tX*tMat.col2.x + tY*tMat.col2.y);
		
		for (i in 0...m_vertexCount)
		{
			//float32 dot = b2Dot(m_normals[i], pLocal - m_vertices[i]);
			tVec = m_vertices[i];
			tX = pLocalX - tVec.x;
			tY = pLocalY - tVec.y;
			tVec = m_normals[i];
			var dot:Float = (tVec.x * tX + tVec.y * tY);
			if (dot > 0.0)
			{
				return false;
			}
		}
		
		return true;
	}

	/**
	 * @inheritDoc
	 */
	public override function rayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool
	{
		var lower:Float = 0.0;
		var upper:Float = input.maxFraction;
		
		var tX:Float;
		var tY:Float;
		var tMat:B2Mat22;
		var tVec:B2Vec2;
		
		// Put the ray into the polygon's frame of reference. (AS3 Port Manual inlining follows)
		//b2Vec2 p1 = b2MulT(transform.R, segment.p1 - transform.position);
		tX = input.p1.x - transform.position.x;
		tY = input.p1.y - transform.position.y;
		tMat = transform.R;
		var p1X:Float = (tX * tMat.col1.x + tY * tMat.col1.y);
		var p1Y:Float = (tX * tMat.col2.x + tY * tMat.col2.y);
		//b2Vec2 p2 = b2MulT(transform.R, segment.p2 - transform.position);
		tX = input.p2.x - transform.position.x;
		tY = input.p2.y - transform.position.y;
		tMat = transform.R;
		var p2X:Float = (tX * tMat.col1.x + tY * tMat.col1.y);
		var p2Y:Float = (tX * tMat.col2.x + tY * tMat.col2.y);
		//b2Vec2 d = p2 - p1;
		var dX:Float = p2X - p1X;
		var dY:Float = p2Y - p1Y;
		var index:Int = -1;
		
		for (i in 0...m_vertexCount)
		{
			// p = p1 + a * d
			// dot(normal, p - v) = 0
			// dot(normal, p1 - v) + a * dot(normal, d) = 0
			
			//float32 numerator = b2Dot(m_normals[i], m_vertices[i] - p1);
			tVec = m_vertices[i];
			tX = tVec.x - p1X;
			tY = tVec.y - p1Y;
			tVec = m_normals[i];
			var numerator:Float = (tVec.x*tX + tVec.y*tY);
			//float32 denominator = b2Dot(m_normals[i], d);
			var denominator:Float = (tVec.x * dX + tVec.y * dY);
			
			if (denominator == 0.0)
			{
				if (numerator < 0.0)
				{
					return false;
				}
			}
			else
			{
				// Note: we want this predicate without division:
				// lower < numerator / denominator, where denominator < 0
				// Since denominator < 0, we have to flip the inequality:
				// lower < numerator / denominator <==> denominator * lower > numerator.
				if (denominator < 0.0 && numerator < lower * denominator)
				{
					// Increase lower.
					// The segment enters this half-space.
					lower = numerator / denominator;
					index = i;
				}
				else if (denominator > 0.0 && numerator < upper * denominator)
				{
					// Decrease upper.
					// The segment exits this half-space.
					upper = numerator / denominator;
				}
			}
			
			if (upper < lower - B2Math.MIN_VALUE)
			{
				return false;
			}
		}
		
		//b2Settings.b2Assert(0.0 <= lower && lower <= input.maxLambda);
		
		if (index >= 0)
		{
			output.fraction = lower;
			//output.normal = b2Mul(transform.R, m_normals[index]);
			tMat = transform.R;
			tVec = m_normals[index];
			output.normal.x = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			output.normal.y = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			return true;
		}
		
		return false;
	}


	/**
	 * @inheritDoc
	 */
	public override function computeAABB(aabb:B2AABB, xf:B2Transform) : Void
	{
		//var lower:B2Vec2 = b2Math.MulX(xf, m_vertices[0]);
		var tMat:B2Mat22 = xf.R;
		var tVec:B2Vec2 = m_vertices[0];
		var lowerX:Float = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var lowerY:Float = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		var upperX:Float = lowerX;
		var upperY:Float = lowerY;
		
		for (i in 1...m_vertexCount)
		{
			tVec = m_vertices[i];
			var vX:Float = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			var vY:Float = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			lowerX = lowerX < vX ? lowerX : vX;
			lowerY = lowerY < vY ? lowerY : vY;
			upperX = upperX > vX ? upperX : vX;
			upperY = upperY > vY ? upperY : vY;
		}

		aabb.lowerBound.x = lowerX - m_radius;
		aabb.lowerBound.y = lowerY - m_radius;
		aabb.upperBound.x = upperX + m_radius;
		aabb.upperBound.y = upperY + m_radius;
	}


	/**
	* @inheritDoc
	*/
	public override function computeMass(massData:B2MassData, density:Float) : Void{
		// Polygon mass, centroid, and inertia.
		// Let rho be the polygon density in mass per unit area.
		// Then:
		// mass = rho * int(dA)
		// centroid.x = (1/mass) * rho * int(x * dA)
		// centroid.y = (1/mass) * rho * int(y * dA)
		// I = rho * int((x*x + y*y) * dA)
		//
		// We can compute these integrals by summing all the integrals
		// for each triangle of the polygon. To evaluate the integral
		// for a single triangle, we make a change of variables to
		// the (u,v) coordinates of the triangle:
		// x = x0 + e1x * u + e2x * v
		// y = y0 + e1y * u + e2y * v
		// where 0 <= u && 0 <= v && u + v <= 1.
		//
		// We integrate u from [0,1-v] and then v from [0,1].
		// We also need to use the Jacobian of the transformation:
		// D = cross(e1, e2)
		//
		// Simplification: triangle centroid = (1/3) * (p1 + p2 + p3)
		//
		// The rest of the derivation is handled by computer algebra.
		
		//b2Settings.b2Assert(m_vertexCount >= 2);
		
		// A line segment has zero mass.
		if (m_vertexCount == 2)
		{
			massData.center.x = 0.5 * (m_vertices[0].x + m_vertices[1].x);
			massData.center.y = 0.5 * (m_vertices[0].y + m_vertices[1].y);
			massData.mass = 0.0;
			massData.I = 0.0;
			return;
		}
		
		//b2Vec2 center; center.Set(0.0f, 0.0f);
		var centerX:Float = 0.0;
		var centerY:Float = 0.0;
		var area:Float = 0.0;
		var I:Float = 0.0;
		
		// pRef is the reference point for forming triangles.
		// It's location doesn't change the result (except for rounding error).
		//b2Vec2 pRef(0.0f, 0.0f);
		var p1X:Float = 0.0;
		var p1Y:Float = 0.0;
		/*#if 0
		// This code would put the reference point inside the polygon.
		for (int32 i = 0; i < m_vertexCount; ++i)
		{
			pRef += m_vertices[i];
		}
		pRef *= 1.0f / count;
		#endif*/
		
		var k_inv3:Float = 1.0 / 3.0;
		
		for (i in 0...m_vertexCount)
		{
			// Triangle vertices.
			//b2Vec2 p1 = pRef;
			//
			//b2Vec2 p2 = m_vertices[i];
			var p2:B2Vec2 = m_vertices[i];
			//b2Vec2 p3 = i + 1 < m_vertexCount ? m_vertices[i+1] : m_vertices[0];
			var p3:B2Vec2 = i + 1 < m_vertexCount ? m_vertices[Std.int(i+1)] : m_vertices[0];
			
			//b2Vec2 e1 = p2 - p1;
			var e1X:Float = p2.x - p1X;
			var e1Y:Float = p2.y - p1Y;
			//b2Vec2 e2 = p3 - p1;
			var e2X:Float = p3.x - p1X;
			var e2Y:Float = p3.y - p1Y;
			
			//float32 D = b2Cross(e1, e2);
			var D:Float = e1X * e2Y - e1Y * e2X;
			
			//float32 triangleArea = 0.5f * D;
			var triangleArea:Float = 0.5 * D;
			area += triangleArea;
			
			// Area weighted centroid
			//center += triangleArea * k_inv3 * (p1 + p2 + p3);
			centerX += triangleArea * k_inv3 * (p1X + p2.x + p3.x);
			centerY += triangleArea * k_inv3 * (p1Y + p2.y + p3.y);
			
			//float32 px = p1.x, py = p1.y;
			var px:Float = p1X;
			var py:Float = p1Y;
			//float32 ex1 = e1.x, ey1 = e1.y;
			var ex1:Float = e1X;
			var ey1:Float = e1Y;
			//float32 ex2 = e2.x, ey2 = e2.y;
			var ex2:Float = e2X;
			var ey2:Float = e2Y;
			
			//float32 intx2 = k_inv3 * (0.25f * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5f*px*px;
			var intx2:Float = k_inv3 * (0.25 * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5*px*px;
			//float32 inty2 = k_inv3 * (0.25f * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5f*py*py;
			var inty2:Float = k_inv3 * (0.25 * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5*py*py;
			
			I += D * (intx2 + inty2);
		}
		
		// Total mass
		massData.mass = density * area;
		
		// Center of mass
		//b2Settings.b2Assert(area > Number.MIN_VALUE);
		//center *= 1.0f / area;
		centerX *= 1.0 / area;
		centerY *= 1.0 / area;
		//massData->center = center;
		massData.center.set(centerX, centerY);
		
		// Inertia tensor relative to the local origin.
		massData.I = density * I;
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
		// Transform plane into shape co-ordinates
		var normalL:B2Vec2 = B2Math.mulTMV(xf.R, normal, true);
		var offsetL:Float = offset - B2Math.dot(normal, xf.position);
		
		var depths:Array <Float> = new Array <Float>();
		var diveCount:Int = 0;
		var intoIndex:Int = -1;
		var outoIndex:Int = -1;
		
		var lastSubmerged:Bool = false;
		var i:Int;
		for (i in 0...m_vertexCount)
		{
			depths[i] = B2Math.dot(normalL, m_vertices[i]) - offsetL;
			var isSubmerged:Bool = depths[i] < -B2Math.MIN_VALUE;
			if (i > 0)
			{
				if (isSubmerged)
				{
					if (!lastSubmerged)
					{
						intoIndex = i - 1;
						diveCount++;
					}
				}
				else
				{
					if (lastSubmerged)
					{
						outoIndex = i - 1;
						diveCount++;
					}
				}
			}
			lastSubmerged = isSubmerged;
		}
		switch(diveCount)
		{
			case 0:
			if (lastSubmerged )
			{
				// Completely submerged
				var md:B2MassData = new B2MassData();
				computeMass(md, 1);
				c.setV(B2Math.mulX(xf, md.center));
				return md.mass;
			}
			else
			{
				//Completely dry
				return 0;
			}
			
			case 1:
			if (intoIndex == -1)
			{
				intoIndex = m_vertexCount - 1;
			}
			else
			{
				outoIndex = m_vertexCount - 1;
			}
			
		}
		var intoIndex2:Int = (intoIndex + 1) % m_vertexCount;
		var outoIndex2:Int = (outoIndex + 1) % m_vertexCount;
		var intoLamdda:Float = (0 - depths[intoIndex]) / (depths[intoIndex2] - depths[intoIndex]);
		var outoLamdda:Float = (0 - depths[outoIndex]) / (depths[outoIndex2] - depths[outoIndex]);
		
		var intoVec:B2Vec2 = new B2Vec2(m_vertices[intoIndex].x * (1 - intoLamdda) + m_vertices[intoIndex2].x * intoLamdda,
										m_vertices[intoIndex].y * (1 - intoLamdda) + m_vertices[intoIndex2].y * intoLamdda);
		var outoVec:B2Vec2 = new B2Vec2(m_vertices[outoIndex].x * (1 - outoLamdda) + m_vertices[outoIndex2].x * outoLamdda,
										m_vertices[outoIndex].y * (1 - outoLamdda) + m_vertices[outoIndex2].y * outoLamdda);
										
		// Initialize accumulator
		var area:Float = 0;
		var center:B2Vec2 = new B2Vec2();
		var p2:B2Vec2 = m_vertices[intoIndex2];
		var p3:B2Vec2;
		
		// An awkward loop from intoIndex2+1 to outIndex2
		i = intoIndex2;
		while (i != outoIndex2)
		{
			i = (i + 1) % m_vertexCount;
			if(i == outoIndex2)
				p3 = outoVec
			else
				p3 = m_vertices[i];
			
			var triangleArea:Float = 0.5 * ( (p2.x - intoVec.x) * (p3.y - intoVec.y) - (p2.y - intoVec.y) * (p3.x - intoVec.x) );
			area += triangleArea;
			// Area weighted centroid
			center.x += triangleArea * (intoVec.x + p2.x + p3.x) / 3;
			center.y += triangleArea * (intoVec.y + p2.y + p3.y) / 3;
			
			p2 = p3;
		}
		
		//Normalize and transform centroid
		center.multiply(1 / area);
		c.setV(B2Math.mulX(xf, center));
		
		return area;
	}
	
	/**
	* Get the vertex count.
	*/
	public function getVertexCount() : Int{
		return m_vertexCount;
	}

	/**
	* Get the vertices in local coordinates.
	*/
	public function getVertices() : Array <B2Vec2>{
		return m_vertices;
	}
	
	/**
	* Get the edge normal vectors. There is one for each vertex.
	*/
	public function getNormals() : Array <B2Vec2>
	{
		return m_normals;
	}
	
	/**
	 * Get the supporting vertex index in the given direction.
	 */
	public function getSupport(d:B2Vec2):Int
	{
		var bestIndex:Int = 0;
		var bestValue:Float = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
		for (i in 1...m_vertexCount)
		{
			var value:Float = m_vertices[i].x * d.x + m_vertices[i].y * d.y;
			if (value > bestValue)
			{
				bestIndex = i;
				bestValue = value;
			}
		}
		return bestIndex;
	}
	
	public function getSupportVertex(d:B2Vec2):B2Vec2
	{
		var bestIndex:Int = 0;
		var bestValue:Float = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
		for (i in 1...m_vertexCount)
		{
			var value:Float = m_vertices[i].x * d.x + m_vertices[i].y * d.y;
			if (value > bestValue)
			{
				bestIndex = i;
				bestValue = value;
			}
		}
		return m_vertices[bestIndex];
	}

	// TODO: Expose this
	private function validate():Bool
	{
		/*
		// Ensure the polygon is convex.
		for (int32 i = 0; i < m_vertexCount; ++i)
		{
			for (int32 j = 0; j < m_vertexCount; ++j)
			{
				// Don't check vertices on the current edge.
				if (j == i || j == (i + 1) % m_vertexCount)
				{
					continue;
				}
				
				// Your polygon is non-convex (it has an indentation).
				// Or your polygon is too skinny.
				float32 s = b2Dot(m_normals[i], m_vertices[j] - m_vertices[i]);
				b2Assert(s < -b2_linearSlop);
			}
		}
		
		// Ensure the polygon is counter-clockwise.
		for (i = 1; i < m_vertexCount; ++i)
		{
			var cross:Float = b2Math.b2CrossVV(m_normals[int(i-1)], m_normals[i]);
			
			// Keep asinf happy.
			cross = b2Math.b2Clamp(cross, -1.0, 1.0);
			
			// You have consecutive edges that are almost parallel on your polygon.
			var angle:Float = Math.asin(cross);
			//b2Assert(angle > b2_angularSlop);
			trace(angle > b2Settings.b2_angularSlop);
		}
		*/
		return false;
	}
	//--------------- Internals Below -------------------
	
	/**
	 * @private
	 */
	public function new (){
		
		super ();
		
		//b2Settings.b2Assert(def.type == e_polygonShape);
		m_type = B2Shape.e_polygonShape;
		
		m_centroid = new B2Vec2();
		m_vertices = new Array <B2Vec2>();
		m_normals = new Array <B2Vec2>();
	}
	
	private function reserve(count:Int):Void
	{
		for (i in m_vertices.length...count)
		{
			m_vertices[i] = new B2Vec2();
			m_normals[i] = new B2Vec2();
		}
	}

	// Local position of the polygon centroid.
	public var m_centroid:B2Vec2;

	public var m_vertices:Array <B2Vec2>;
	public var m_normals:Array <B2Vec2>;
	
	public var m_vertexCount:Int;
	
	
	
	/**
	 * Computes the centroid of the given polygon
	 * @param	vs		vector of b2Vec specifying a polygon
	 * @param	count	length of vs
	 * @return the polygon centroid
	 */
	static public function computeCentroid(vs:Array <B2Vec2>, count:Int) : B2Vec2
	{
		//b2Settings.b2Assert(count >= 3);
		
		//b2Vec2 c; c.Set(0.0f, 0.0f);
		var c:B2Vec2 = new B2Vec2();
		var area:Float = 0.0;
		
		// pRef is the reference point for forming triangles.
		// It's location doesn't change the result (except for rounding error).
		//b2Vec2 pRef(0.0f, 0.0f);
		var p1X:Float = 0.0;
		var p1Y:Float = 0.0;
		
		var inv3:Float = 1.0 / 3.0;
		
		for (i in 0...count)
		{
			// Triangle vertices.
			//b2Vec2 p1 = pRef;
				// 0.0, 0.0
			//b2Vec2 p2 = vs[i];
			var p2:B2Vec2 = vs[i];
			//b2Vec2 p3 = i + 1 < count ? vs[i+1] : vs[0];
			var p3:B2Vec2 = i + 1 < count ? vs[Std.int(i+1)] : vs[0];
			
			//b2Vec2 e1 = p2 - p1;
			var e1X:Float = p2.x - p1X;
			var e1Y:Float = p2.y - p1Y;
			//b2Vec2 e2 = p3 - p1;
			var e2X:Float = p3.x - p1X;
			var e2Y:Float = p3.y - p1Y;
			
			//float32 D = b2Cross(e1, e2);
			var D:Float = (e1X * e2Y - e1Y * e2X);
			
			//float32 triangleArea = 0.5f * D;
			var triangleArea:Float = 0.5 * D;
			area += triangleArea;
			
			// Area weighted centroid
			//c += triangleArea * inv3 * (p1 + p2 + p3);
			c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
			c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
		}
		
		// Centroid
		//beSettings.b2Assert(area > Number.MIN_VALUE);
		//c *= 1.0 / area;
		c.x *= 1.0 / area;
		c.y *= 1.0 / area;
		return c;
	}

	/**
	 * Computes a polygon's OBB
	 * @see http://www.geometrictools.com/Documentation/MinimumAreaRectangle.pdf
	 */
	static public function computeOBB(obb:B2OBB, vs:Array <B2Vec2>, count:Int) : Void
	{
		var i:Int;
		var p:Array <B2Vec2> = new Array <B2Vec2> ();
		for (i in 0...count)
		{
			p[i] = vs[i];
		}
		p[count] = p[0];
		
		var minArea:Float = B2Math.MAX_VALUE;
		
		for (i in 1...(count + 1))
		{
			var root:B2Vec2 = p[Std.int(i-1)];
			//b2Vec2 ux = p[i] - root;
			var uxX:Float = p[i].x - root.x;
			var uxY:Float = p[i].y - root.y;
			//var length:Float = ux.Normalize();
			var length:Float = Math.sqrt(uxX*uxX + uxY*uxY);
			uxX /= length;
			uxY /= length;
			//b2Settings.b2Assert(length > Number.MIN_VALUE);
			//b2Vec2 uy(-ux.y, ux.x);
			var uyX:Float = -uxY;
			var uyY:Float = uxX;
			//b2Vec2 lower(FLT_MAX, FLT_MAX);
			var lowerX:Float = B2Math.MAX_VALUE;
			var lowerY:Float = B2Math.MAX_VALUE;
			//b2Vec2 upper(-FLT_MAX, -FLT_MAX);
			var upperX:Float = -B2Math.MAX_VALUE;
			var upperY:Float = -B2Math.MAX_VALUE;
			
			for (j in 0...count)
			{
				//b2Vec2 d = p[j] - root;
				var dX:Float = p[j].x - root.x;
				var dY:Float = p[j].y - root.y;
				//b2Vec2 r;
				//var rX:Float = b2Dot(ux, d);
				var rX:Float = (uxX*dX + uxY*dY);
				//var rY:Float = b2Dot(uy, d);
				var rY:Float = (uyX*dX + uyY*dY);
				//lower = b2Min(lower, r);
				if (rX < lowerX) lowerX = rX;
				if (rY < lowerY) lowerY = rY;
				//upper = b2Max(upper, r);
				if (rX > upperX) upperX = rX;
				if (rY > upperY) upperY = rY;
			}
			
			var area:Float = (upperX - lowerX) * (upperY - lowerY);
			if (area < 0.95 * minArea)
			{
				minArea = area;
				//obb->R.col1 = ux;
				obb.R.col1.x = uxX;
				obb.R.col1.y = uxY;
				//obb->R.col2 = uy;
				obb.R.col2.x = uyX;
				obb.R.col2.y = uyY;
				//b2Vec2 center = 0.5f * (lower + upper);
				var centerX:Float = 0.5 * (lowerX + upperX);
				var centerY:Float = 0.5 * (lowerY + upperY);
				//obb->center = root + b2Mul(obb->R, center);
				var tMat:B2Mat22 = obb.R;
				obb.center.x = root.x + (tMat.col1.x * centerX + tMat.col2.x * centerY);
				obb.center.y = root.y + (tMat.col1.y * centerX + tMat.col2.y * centerY);
				//obb->extents = 0.5f * (upper - lower);
				obb.extents.x = 0.5 * (upperX - lowerX);
				obb.extents.y = 0.5 * (upperY - lowerY);
			}
		}
		
		//b2Settings.b2Assert(minArea < Number.MAX_VALUE);
	}
	
	
}