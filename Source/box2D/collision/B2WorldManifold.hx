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


import box2D.common.B2Settings;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;


/**
 * This is used to compute the current state of a contact manifold.
 */
class B2WorldManifold 
{
	public function new ()
	{
		m_normal = new B2Vec2();	
		
		m_points = new Array <B2Vec2> ();
		for (i in 0...B2Settings.b2_maxManifoldPoints)
		{
			m_points[i] = new B2Vec2();
		}
	}
	
	inline public function reset()
	{
		m_normal = new B2Vec2();	
		
		m_points = new Array <B2Vec2> ();
		for (i in 0...B2Settings.b2_maxManifoldPoints)
		{
			m_points[i] = new B2Vec2();
		}
	}
	
	/**
	 * Evaluate the manifold with supplied transforms. This assumes
	 * modest motion from the original state. This does not change the
	 * point count, impulses, etc. The radii must come from the shapes
	 * that generated the manifold.
	 */
	public function initialize(manifold:B2Manifold,
					xfA:B2Transform, radiusA:Float,
					xfB:B2Transform, radiusB:Float):Void
	{
		if (manifold.m_pointCount == 0)
		{
			return;
		}
		
		reset();
		
		var i:Int;
		var tVec:B2Vec2;
		var tMat:B2Mat22;
		var normalX:Float;
		var normalY:Float;
		var planePointX:Float;
		var planePointY:Float;
		var clipPointX:Float;
		var clipPointY:Float;
		
		switch(manifold.m_type)
		{
			case B2Manifold.e_circles:
			{
				//var pointA:B2Vec2 = b2Math.b2MulX(xfA, manifold.m_localPoint);
				tMat = xfA.R;
				tVec = manifold.m_localPoint;
				var pointAX:Float = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				var pointAY:Float = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				//var pointB:B2Vec2 = b2Math.b2MulX(xfB, manifold.m_points[0].m_localPoint);
				tMat = xfB.R;
				tVec = manifold.m_points[0].m_localPoint;
				var pointBX:Float = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				var pointBY:Float = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				var dX:Float = pointBX - pointAX;
				var dY:Float = pointBY - pointAY;
				var d2:Float = dX * dX + dY * dY;
				if (d2 > B2Math.MIN_VALUE * B2Math.MIN_VALUE)
				{
					var d:Float = Math.sqrt(d2);
					m_normal.x = dX/d;
					m_normal.y = dY/d;
				}else {
					m_normal.x = 1;
					m_normal.y = 0;
				}
				
				//b2Vec2 cA = pointA + radiusA * m_normal;
				var cAX:Float = pointAX + radiusA * m_normal.x;
				var cAY:Float = pointAY + radiusA * m_normal.y;
				//b2Vec2 cB = pointB - radiusB * m_normal;
				var cBX:Float = pointBX - radiusB * m_normal.x;
				var cBY:Float = pointBY - radiusB * m_normal.y;
				m_points[0].x = 0.5 * (cAX + cBX);
				m_points[0].y = 0.5 * (cAY + cBY);
				
				//XXX: Workaround for - http://community.stencyl.com/index.php/topic,14925.0.html
				//m_points[0].x *= 2;
				//m_points[0].y *= 2;
			}
			
			case B2Manifold.e_faceA:
			{
				//normal = b2Math.b2MulMV(xfA.R, manifold.m_localPlaneNormal);
				tMat = xfA.R;
				tVec = manifold.m_localPlaneNormal;
				normalX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				normalY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				//planePoint = b2Math.b2MulX(xfA, manifold.m_localPoint);
				tMat = xfA.R;
				tVec = manifold.m_localPoint;
				planePointX = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				planePointY = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				// Ensure normal points from A to B
				m_normal.x = normalX;
				m_normal.y = normalY;
				for (i in 0...manifold.m_pointCount)
				{
					//clipPoint = b2Math.b2MulX(xfB, manifold.m_points[i].m_localPoint);
					tMat = xfB.R;
					tVec = manifold.m_points[i].m_localPoint;
					clipPointX = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
					clipPointY = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
					
					//b2Vec2 cA = clipPoint + (radiusA - b2Dot(clipPoint - planePoint, normal)) * normal;
					//b2Vec2 cB = clipPoint - radiusB * normal;
					//m_points[i] = 0.5f * (cA + cB);
					m_points[i].x = clipPointX + 0.5 * (radiusA - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusB ) * normalX;
					m_points[i].y = clipPointY + 0.5 * (radiusA - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusB ) * normalY;
					
				}
			}
			
			case B2Manifold.e_faceB:
			{
				//normal = b2Math.b2MulMV(xfB.R, manifold.m_localPlaneNormal);
				tMat = xfB.R;
				tVec = manifold.m_localPlaneNormal;
				normalX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				normalY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				//planePoint = b2Math.b2MulX(xfB, manifold.m_localPoint);
				tMat = xfB.R;
				tVec = manifold.m_localPoint;
				planePointX = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				planePointY = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				// Ensure normal points from A to B
				m_normal.x = -normalX;
				m_normal.y = -normalY;
				for (i in 0...manifold.m_pointCount)
				{
					//clipPoint = b2Math.b2MulX(xfA, manifold.m_points[i].m_localPoint);
					tMat = xfA.R;
					tVec = manifold.m_points[i].m_localPoint;
					clipPointX = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
					clipPointY = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
					
					//b2Vec2 cA = clipPoint - radiusA * normal;
					//b2Vec2 cB = clipPoint + (radiusB - b2Dot(clipPoint - planePoint, normal)) * normal;
					//m_points[i] = 0.5f * (cA + cB);
					m_points[i].x = clipPointX + 0.5 * (radiusB - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusA ) * normalX;
					m_points[i].y = clipPointY + 0.5 * (radiusB - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusA ) * normalY;
					
				}
			}
			
		}
	}
	
	/**
		 * If there are more than one contact points, this getter will return the average.
		 */
		public function getPoint():B2Vec2 {
			if(m_points.length == 0) {
				return null;
			}
			if(m_points.length == 1) {
				return m_points[0];
			}
			return new B2Vec2((m_points[0].x + m_points[1].x) / 2, (m_points[0].y + m_points[1].y) / 2);
		}	

	/**
	 * world vector pointing from A to B
	 */
	public var m_normal:B2Vec2;						
	/**
	 * world contact point (point of intersection)
	 */
	public var m_points:Array <B2Vec2>;
	
}