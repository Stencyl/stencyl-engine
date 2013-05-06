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
 * An edge shape.
 * @private
 * @see b2EdgeChainDef
 */
class B2EdgeShape extends B2Shape
{
	/**
	* Returns false. Edges cannot contain points. 
	*/
	public override function testPoint(transform:B2Transform, p:B2Vec2) : Bool{
		return false;
	}

	/**
	* @inheritDoc
	*/
	public override function rayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool
	{
		var tMat:B2Mat22;
		var rX: Float = input.p2.x - input.p1.x;
		var rY: Float = input.p2.y - input.p1.y;
		
		//b2Vec2 v1 = b2Mul(transform, m_v1);
		tMat = transform.R;
		var v1X: Float = transform.position.x + (tMat.col1.x * m_v1.x + tMat.col2.x * m_v1.y);
		var v1Y: Float = transform.position.y + (tMat.col1.y * m_v1.x + tMat.col2.y * m_v1.y);
		
		//b2Vec2 n = b2Cross(d, 1.0);
		var nX: Float = transform.position.y + (tMat.col1.y * m_v2.x + tMat.col2.y * m_v2.y) - v1Y;
		var nY: Float = -(transform.position.x + (tMat.col1.x * m_v2.x + tMat.col2.x * m_v2.y) - v1X);
		
		var k_slop: Float = 100.0 * B2Math.MIN_VALUE;
		var denom: Float = -(rX * nX + rY * nY);
	
		// Cull back facing collision and ignore parallel segments.
		if (denom > k_slop)
		{
			// Does the segment intersect the infinite line associated with this segment?
			var bX: Float = input.p1.x - v1X;
			var bY: Float = input.p1.y - v1Y;
			var a: Float = (bX * nX + bY * nY);
	
			if (0.0 <= a && a <= input.maxFraction * denom)
			{
				var mu2: Float = -rX * bY + rY * bX;
	
				// Does the segment intersect this segment?
				if (-k_slop * denom <= mu2 && mu2 <= denom * (1.0 + k_slop))
				{
					a /= denom;
					output.fraction = a;
					var nLen: Float = Math.sqrt(nX * nX + nY * nY);
					output.normal.x = nX / nLen;
					output.normal.y = nY / nLen;
					return true;
				}
			}
		}
		
		return false;
	}

	/**
	* @inheritDoc
	*/
	public override function computeAABB(aabb:B2AABB, transform:B2Transform) : Void{
		var tMat:B2Mat22 = transform.R;
		//b2Vec2 v1 = b2Mul(transform, m_v1);
		var v1X:Float = transform.position.x + (tMat.col1.x * m_v1.x + tMat.col2.x * m_v1.y);
		var v1Y:Float = transform.position.y + (tMat.col1.y * m_v1.x + tMat.col2.y * m_v1.y);
		//b2Vec2 v2 = b2Mul(transform, m_v2);
		var v2X:Float = transform.position.x + (tMat.col1.x * m_v2.x + tMat.col2.x * m_v2.y);
		var v2Y:Float = transform.position.y + (tMat.col1.y * m_v2.x + tMat.col2.y * m_v2.y);
		if (v1X < v2X) {
			aabb.lowerBound.x = v1X;
			aabb.upperBound.x = v2X;
		} else {
			aabb.lowerBound.x = v2X;
			aabb.upperBound.x = v1X;
		}
		if (v1Y < v2Y) {
			aabb.lowerBound.y = v1Y;
			aabb.upperBound.y = v2Y;
		} else {
			aabb.lowerBound.y = v2Y;
			aabb.upperBound.y = v1Y;
		}
	}

	/**
	* @inheritDoc
	*/
	public override function computeMass(massData:B2MassData, density:Float) : Void{
		massData.mass = 0;
		massData.center.setV(m_v1);
		massData.I = 0;
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
		// Note that v0 is independant of any details of the specific edge
		// We are relying on v0 being consistent between multiple edges of the same body
		//b2Vec2 v0 = offset * normal;
		var v0:B2Vec2 = new B2Vec2(normal.x * offset, normal.y * offset);
		
		var v1:B2Vec2 = B2Math.mulX(xf, m_v1, true);
		var v2:B2Vec2 = B2Math.mulX(xf, m_v2, true);
		
		var d1:Float = B2Math.dot(normal, v1) - offset;
		var d2:Float = B2Math.dot(normal, v2) - offset;
		if (d1 > 0)
		{
			if (d2 > 0)
			{
				return 0;
			}
			else
			{
				//v1 = -d2 / (d1 - d2) * v1 + d1 / (d1 - d2) * v2;
				v1.x = -d2 / (d1 - d2) * v1.x + d1 / (d1 - d2) * v2.x;
				v1.y = -d2 / (d1 - d2) * v1.y + d1 / (d1 - d2) * v2.y;
			}
		}
		else
		{
			if (d2 > 0)
			{
				//v2 = -d2 / (d1 - d2) * v1 + d1 / (d1 - d2) * v2;
				v2.x = -d2 / (d1 - d2) * v1.x + d1 / (d1 - d2) * v2.x;
				v2.y = -d2 / (d1 - d2) * v1.y + d1 / (d1 - d2) * v2.y;
			}
			else
			{
				// Nothing
			}
		}
		// v0,v1,v2 represents a fully submerged triangle
		// Area weighted centroid
		c.x = (v0.x + v1.x + v2.x) / 3;
		c.y = (v0.y + v1.y + v2.y) / 3;
		
		//b2Vec2 e1 = v1 - v0;
		//b2Vec2 e2 = v2 - v0;
		//return 0.5f * b2Cross(e1, e2);
		return 0.5 * ( (v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x) );
	}

	/**
	* Get the distance from vertex1 to vertex2.
	*/
	public function getLength(): Float
	{
		return m_length;
	}

	/**
	* Get the local position of vertex1 in parent body.
	*/
	public function getVertex1(): B2Vec2
	{
		return m_v1;
	}

	/**
	* Get the local position of vertex2 in parent body.
	*/
	public function getVertex2(): B2Vec2
	{
		return m_v2;
	}

	/**
	* Get a core vertex in local coordinates. These vertices
	* represent a smaller edge that is used for time of impact
	* computations.
	*/
	public function getCoreVertex1(): B2Vec2
	{
		return m_coreV1;
	}

	/**
	* Get a core vertex in local coordinates. These vertices
	* represent a smaller edge that is used for time of impact
	* computations.
	*/
	public function getCoreVertex2(): B2Vec2
	{
		return m_coreV2;
	}
	
	/**
	* Get a perpendicular unit vector, pointing
	* from the solid side to the empty side.
	*/
	public function getNormalVector(): B2Vec2
	{
		return m_normal;
	}
	
	
	/**
	* Get a parallel unit vector, pointing
	* from vertex1 to vertex2.
	*/
	public function getDirectionVector(): B2Vec2
	{
		return m_direction;
	}
	
	/**
	* Returns a unit vector halfway between 
	* m_direction and m_prevEdge.m_direction.
	*/
	public function getCorner1Vector(): B2Vec2
	{
		return m_cornerDir1;
	}
	
	/**
	* Returns a unit vector halfway between 
	* m_direction and m_nextEdge.m_direction.
	*/
	public function getCorner2Vector(): B2Vec2
	{
		return m_cornerDir2;
	}
	
	/**
	* Returns true if the first corner of this edge
	* bends towards the solid side.
	*/
	public function corner1IsConvex(): Bool
	{
		return m_cornerConvex1;
	}
	
	/**
	* Returns true if the second corner of this edge
	* bends towards the solid side. 
	*/
	public function corner2IsConvex(): Bool
	{
		return m_cornerConvex2;
	}

	/**
	* Get the first vertex and apply the supplied transform.
	*/
	public function getFirstVertex(xf: B2Transform): B2Vec2
	{
		//return b2Mul(xf, m_coreV1);
		var tMat:B2Mat22 = xf.R;
		return new B2Vec2(xf.position.x + (tMat.col1.x * m_coreV1.x + tMat.col2.x * m_coreV1.y),
		                  xf.position.y + (tMat.col1.y * m_coreV1.x + tMat.col2.y * m_coreV1.y));
	}
	
	/**
	* Get the next edge in the chain.
	*/
	public function getNextEdge(): B2EdgeShape
	{
		return m_nextEdge;
	}
	
	/**
	* Get the previous edge in the chain.
	*/
	public function getPrevEdge(): B2EdgeShape
	{
		return m_prevEdge;
	}

	private var s_supportVec:B2Vec2;
	/**
	* Get the support point in the given world direction.
	* Use the supplied transform.
	*/
	public function support(xf:B2Transform, dX:Float, dY:Float) : B2Vec2{
		var tMat:B2Mat22 = xf.R;
		//b2Vec2 v1 = b2Mul(xf, m_coreV1);
		var v1X:Float = xf.position.x + (tMat.col1.x * m_coreV1.x + tMat.col2.x * m_coreV1.y);
		var v1Y:Float = xf.position.y + (tMat.col1.y * m_coreV1.x + tMat.col2.y * m_coreV1.y);
		
		//b2Vec2 v2 = b2Mul(xf, m_coreV2);
		var v2X:Float = xf.position.x + (tMat.col1.x * m_coreV2.x + tMat.col2.x * m_coreV2.y);
		var v2Y:Float = xf.position.y + (tMat.col1.y * m_coreV2.x + tMat.col2.y * m_coreV2.y);
		
		if ((v1X * dX + v1Y * dY) > (v2X * dX + v2Y * dY)) {
			s_supportVec.x = v1X;
			s_supportVec.y = v1Y;
		} else {
			s_supportVec.x = v2X;
			s_supportVec.y = v2Y;
		}
		return s_supportVec;
	}
	
	//--------------- Internals Below -------------------

	override public function copy():B2Shape 
	{
		var s:B2Shape = new B2EdgeShape(m_v1, m_v2);
		s.set(this);
		
		var edge = cast(s, B2EdgeShape);
		edge.m_v0.setV(m_v0);
		edge.m_v3.setV(m_v3);
		edge.m_hasVertex0 = m_hasVertex0;
		edge.m_hasVertex3 = m_hasVertex3;
		return s;
	}

	/**
	* @private
	*/
	public function new (v1: B2Vec2, v2: B2Vec2){
		super();
		
		s_supportVec = new B2Vec2();
		m_v1 = new B2Vec2();
		m_v2 = new B2Vec2();
		
		m_v0 = new B2Vec2();
		m_v3 = new B2Vec2();
		m_hasVertex0 = false;
		m_hasVertex3 = false;
		
		m_coreV1 = new B2Vec2();
		m_coreV2 = new B2Vec2();
		
		m_normal = new B2Vec2();
		
		m_direction = new B2Vec2();
		
		m_cornerDir1 = new B2Vec2();
		
		m_cornerDir2 = new B2Vec2();
		
		m_type = B2Shape.e_edgeShape;
		
		m_prevEdge = null;
		m_nextEdge = null;
		
		m_v1 = v1;
		m_v2 = v2;
		
		m_direction.set(m_v2.x - m_v1.x, m_v2.y - m_v1.y);
		m_length = m_direction.normalize();
		m_normal.set(m_direction.y, -m_direction.x);
		
		m_coreV1.set(-B2Settings.b2_toiSlop * (m_normal.x - m_direction.x) + m_v1.x,
		             -B2Settings.b2_toiSlop * (m_normal.y - m_direction.y) + m_v1.y);
		m_coreV2.set(-B2Settings.b2_toiSlop * (m_normal.x + m_direction.x) + m_v2.x,
		             -B2Settings.b2_toiSlop * (m_normal.y + m_direction.y) + m_v2.y);
		
		m_cornerDir1 = m_normal;
		m_cornerDir2.set(-m_normal.x, -m_normal.y);
	}

	/**
	* @private
	*/
	public function setPrevEdge(edge: B2EdgeShape, core: B2Vec2, cornerDir: B2Vec2, convex: Bool): Void
	{
		m_prevEdge = edge;
		m_coreV1 = core;
		m_cornerDir1 = cornerDir;
		m_cornerConvex1 = convex;
	}
	
	/**
	* @private
	*/
	public function setNextEdge(edge: B2EdgeShape, core: B2Vec2, cornerDir: B2Vec2, convex: Bool): Void
	{
		m_nextEdge = edge;
		m_coreV2 = core;
		m_cornerDir2 = cornerDir;
		m_cornerConvex2 = convex;
	}

	public var m_v1:B2Vec2;
	public var m_v2:B2Vec2;
	
	//SMOOTH COLLISION
	public var m_v0:B2Vec2;
	public var m_v3:B2Vec2;
	public var m_hasVertex0:Bool;
	public var m_hasVertex3:Bool;
	//END SMOOTH COLLISION
	
	public var m_coreV1:B2Vec2;
	public var m_coreV2:B2Vec2;
	
	public var m_length:Float;
	
	public var m_normal:B2Vec2;
	
	public var m_direction:B2Vec2;
	
	public var m_cornerDir1:B2Vec2;
	
	public var m_cornerDir2:B2Vec2;
	
	public var m_cornerConvex1:Bool;
	public var m_cornerConvex2:Bool;
	
	public var m_nextEdge:B2EdgeShape;
	public var m_prevEdge:B2EdgeShape;
	
}