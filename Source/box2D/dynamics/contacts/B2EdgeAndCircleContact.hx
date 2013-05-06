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

import box2D.collision.B2ContactID;
import box2D.collision.B2Manifold;
import box2D.collision.B2ManifoldPoint;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.contacts.B2Contact;

class B2EdgeAndCircleContact extends B2Contact
{
	static var m_xf:B2Transform = new B2Transform();
	static var q:B2Vec2 = new B2Vec2();
	static var p:B2Vec2 = new B2Vec2();
	static var e:B2Vec2 = new B2Vec2();
	static var temp1:B2Vec2 = new B2Vec2();
	static var temp2:B2Vec2 = new B2Vec2();
	static var m_centroidB:B2Vec2 = new B2Vec2();
	
	static var mat:B2Mat22 = new B2Mat22();
	
	var m_v0:B2Vec2;
    var m_v1:B2Vec2;
	var m_v2:B2Vec2;
    var m_v3:B2Vec2;
	
	static public function create(allocator:Dynamic):B2Contact
	{
		return new B2EdgeAndCircleContact();
	}

	static public function destroy(contact:B2Contact, allocator:Dynamic):Void
	{
	}

	public override function reset(fixtureA:B2Fixture = null, fixtureB:B2Fixture = null):Void
	{
		super.reset(fixtureA, fixtureB);
		//b2Settings.b2Assert(m_shape1.m_type == b2Shape.e_circleShape);
		//b2Settings.b2Assert(m_shape2.m_type == b2Shape.e_circleShape);
	}

	//~b2EdgeAndCircleContact() {}

	public override function evaluate():Void
	{
		var bA:B2Body = m_fixtureA.getBody();
		var bB:B2Body = m_fixtureB.getBody();

		b2CollideEdgeAndCircle
		(
			m_manifold,
			cast(m_fixtureA.getShape(), B2EdgeShape), bA.m_xf,
			cast(m_fixtureB.getShape(), B2CircleShape), bB.m_xf
		);
	}

	private function b2CollideEdgeAndCircle(manifold:B2Manifold,
			edge:B2EdgeShape, 
			xf1:B2Transform,
			circle:B2CircleShape, 
			xf2:B2Transform):Void
	{
		manifold.m_pointCount = 0;

		// Compute circle in frame of edge
		//b2Vec2 Q = b2MulT(xfA, b2Mul(xfB, circleB->m_p));	
		multiplyTransformVector(xf2, circle.m_p, temp1);
		q.setV(B2Math.mulXT(xf1, temp1));
		
		//b2Vec2 A = edgeA->m_vertex1, B = edgeA->m_vertex2;
		//b2Vec2 e = B - A;
		m_v0 = edge.m_v0;
		m_v1 = edge.m_v1;
		m_v2 = edge.m_v2;
		m_v3 = edge.m_v3;
		
		e.set(m_v2.x - m_v1.x, m_v2.y - m_v1.y);
		
		//float32 u = b2Dot(e, B - Q);
		//float32 v = b2Dot(e, Q - A);
		temp1.set(m_v2.x - q.x, m_v2.y - q.y);
		var u:Float = B2Math.dot(e, temp1);
		
		temp1.set(q.x - m_v1.x, q.y - m_v1.y);
		var v:Float = B2Math.dot(e, temp1);
		
		//float32 radius = edgeA->m_radius + circleB->m_radius;
		var radius = edge.m_radius + circle.m_radius;
				
		// Region A
		if (v <= 0.0)
		{
			//b2Vec2 P = A;
			//b2Vec2 d = Q - P;
			//float32 dd = b2Dot(d, d);
			p.setV(m_v1);
			temp1.set(q.x - p.x, q.y - p.y);
			var dd:Float = B2Math.dot(temp1, temp1);		
			
			if (dd > radius * radius)
			{
				return;
			}
		
			// Is there an edge connected to A?
			if (edge.m_hasVertex0)
			{
				//b2Vec2 A1 = edgeA->m_vertex0;
				//b2Vec2 B1 = A;
				//b2Vec2 e1 = B1 - A1;
				//float32 u1 = b2Dot(e1, B1 - Q);
				temp1.set(m_v1.x - m_v0.x, m_v1.y - m_v0.y);
				temp2.set(m_v1.x - q.x, m_v1.y - q.y);
				var u1:Float = B2Math.dot(temp1, temp2);				
			
				// Is the circle in Region AB of the previous edge?
				if (u1 > 0.0)
				{
					return;
				}
			}
		
			//cf.indexA = 0;
			//cf.typeA = b2ContactFeature::e_vertex;
			//manifold->pointCount = 1;
			//manifold->type = b2Manifold::e_circles;
			//manifold->localNormal.SetZero();
			//manifold->localPoint = P;
			//manifold->points[0].id.key = 0;
			//manifold->points[0].id.cf = cf;
			//manifold->points[0].localPoint = circleB->m_p;
		
			manifold.m_pointCount = 1;
			manifold.m_type = B2Manifold.e_circles;
			manifold.m_localPlaneNormal.setZero();
			manifold.m_localPoint.setV(p);
			
			manifold.m_points[0].m_id.key = 0;
			manifold.m_points[0].m_id.indexA = 0;
			manifold.m_points[0].m_id.indexB = 0;
			manifold.m_points[0].m_id.typeA = B2ContactID.VERTEX; 
			manifold.m_points[0].m_id.typeB = B2ContactID.VERTEX; 
			manifold.m_points[0].m_localPoint.setV(circle.m_p);
		
			return;
		}
	
		// Region B
		if (u <= 0.0)
		{
			//b2Vec2 P = B;
			//b2Vec2 d = Q - P;
			//float32 dd = b2Dot(d, d);
			p.setV(m_v2);
			temp1.set(q.x - p.x, q.y - p.y);
			var dd:Float = B2Math.dot(temp1, temp1);
			
			if (dd > radius * radius)
			{
				return;
			}
		
			//Is there an edge connected to B?
			if (edge.m_hasVertex3)
			{
				//b2Vec2 B2 = edgeA->m_vertex3;
				//b2Vec2 A2 = B;
				//b2Vec2 e2 = B2 - A2;
				//float32 v2 = b2Dot(e2, Q - A2);
			
				temp1.set(m_v3.x - m_v2.x, m_v3.y - m_v2.y);
				temp2.set(q.x - m_v2.x, q.y - m_v2.y);
				var v2:Float = B2Math.dot(temp1, temp2);
								
				// Is the circle in Region AB of the next edge?
				if (v2 > 0.0)
				{
					return;
				}
			}
			
			//cf.indexA = 1;
			//cf.typeA = b2ContactFeature::e_vertex;
			//manifold->pointCount = 1;
			//manifold->type = b2Manifold::e_circles;
			//manifold->localNormal.SetZero();
			//manifold->localPoint = P;
			//manifold->points[0].id.key = 0;
			//manifold->points[0].id.cf = cf;
			//manifold->points[0].localPoint = circleB->m_p;
			//return;
		
			manifold.m_pointCount = 1;
			manifold.m_type = B2Manifold.e_circles;
			manifold.m_localPlaneNormal.setZero();
			manifold.m_localPoint.setV(p);
			
			manifold.m_points[0].m_id.key = 0;
			manifold.m_points[0].m_id.indexA = 1;
			manifold.m_points[0].m_id.indexB = 0;
			manifold.m_points[0].m_id.typeA = B2ContactID.VERTEX; 
			manifold.m_points[0].m_id.typeB = B2ContactID.VERTEX; 
			manifold.m_points[0].m_localPoint.setV(circle.m_p);

			return;
		}
		
		// Region AB
		//float32 den = b2Dot(e, e);
		//b2Assert(den > 0.0f);
		var den:Float = B2Math.dot(e, e);
		B2Settings.b2Assert(den > 0.0);
	
		//b2Vec2 P = (1.0f / den) * (u * A + v * B);
		//b2Vec2 d = Q - P;
		//float32 dd = b2Dot(d, d);
		p.x = (m_v1.x * u + m_v2.x * v) * (1.0 / den);
		p.y = (m_v1.y * u + m_v2.y * v) * (1.0 / den);
		temp1.x = q.x - p.x;
		temp1.y = q.y - p.y;
		var dd:Float = B2Math.dot(temp1, temp1);
		
		if (dd > radius * radius)
		{
			return;
		}
		
		//b2Vec2 n(-e.y, e.x);
		temp1.set( -e.y, e.x);
		temp2.set(q.x - m_v1.x, q.y - m_v1.y);
		
		if (B2Math.dot(temp1,temp2) < 0.0)
		{
			temp1.negativeSelf();
		}
		
		temp1.normalize();
	
		//cf.indexA = 0;
		//cf.typeA = b2ContactFeature::e_face;
		//manifold->pointCount = 1;
		//manifold->type = b2Manifold::e_faceA;
		//manifold->localNormal = n;
		//manifold->localPoint = A;
		//manifold->points[0].id.key = 0;
		//manifold->points[0].id.cf = cf;
		//manifold->points[0].localPoint = circleB->m_p;
	
		manifold.m_pointCount = 1;
		manifold.m_type = B2Manifold.e_faceA;
		manifold.m_localPlaneNormal.setV(temp1);
		manifold.m_localPoint.setV(m_v1);
			
		manifold.m_points[0].m_id.key = 0;
		manifold.m_points[0].m_id.indexA = 0;
		manifold.m_points[0].m_id.indexB = 0;
		manifold.m_points[0].m_id.typeA = B2ContactID.FACE; 
		manifold.m_points[0].m_id.typeB = B2ContactID.VERTEX; 
		manifold.m_points[0].m_localPoint.setV(circle.m_p);				
	}
	
	public function multiplyTransformsInverse(A:B2Transform, B:B2Transform, out:B2Transform):Void
	{
        //b2MulT(A.q, B.q); Rotation * Rotation
        multiplyRotationsInverse(A.R, B.R, mat);
        
        //b2MulT(A.q, B.p - A.p); Rotation * Vector        
        temp2.setV(B.position);
        temp2.subtract(A.position);
        multiplyRotationVectorInverse(A.R, temp2, out.position);
		
        out.R.col1.setV(mat.col1);
		out.R.col2.setV(mat.col2);
	}
	
	//TODO: Combine/Transfer to B2Math
	public function multiplyRotationsInverse(q:B2Mat22, r:B2Mat22, out:B2Mat22)
	{		
		out.col1.x = q.col1.x * r.col1.x + q.col1.y * r.col1.y;
		out.col1.y = q.col2.x * r.col1.x + q.col2.y * r.col1.y;
		out.col2.x = q.col1.x * r.col2.x + q.col1.y * r.col2.y;
		out.col2.y = q.col2.x * r.col2.x + q.col2.y * r.col2.y;
	}
	
	private function multiplyRotationVector(q:B2Mat22, v:B2Vec2, out:B2Vec2):Void
	{
		out.x = q.col1.x * v.x + q.col2.x * v.y;
		out.y = q.col1.y * v.x + q.col2.y * v.y;
	}
	
	private function multiplyRotationVectorInverse(q:B2Mat22, v:B2Vec2, out:B2Vec2):Void
	{		
		out.x = q.col1.x * v.x + q.col1.y * v.y;
		out.y = q.col2.x * v.x + q.col2.y * v.y;
	}
	
	private function multiplyTransformVector(T:B2Transform, v:B2Vec2, out:B2Vec2):Void
	{
		out.x = (T.R.col1.x * v.x + T.R.col2.x * v.y) + T.position.x;
		out.y = (T.R.col1.y * v.x + T.R.col2.y * v.y) + T.position.y;
	}
}
