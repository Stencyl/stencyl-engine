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


import box2D.collision.B2Manifold;
import box2D.common.B2Settings;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;


class B2PositionSolverManifold
{
	public function new ()
	{
		m_normal = new B2Vec2();
		m_separations = new Array <Float> ();
		m_points = new Array <B2Vec2> ();
		for (i in 0...B2Settings.b2_maxManifoldPoints)
		{
			m_points[i] = new B2Vec2();
		}
	}
	
	private static var circlePointA:B2Vec2 = new B2Vec2();
	private static var circlePointB:B2Vec2 = new B2Vec2();
	public function initialize(cc:B2ContactConstraint):Void
	{
		B2Settings.b2Assert(cc.pointCount > 0);
		
		var i:Int;
		var clipPointX:Float;
		var clipPointY:Float;
		var tMat:B2Mat22;
		var tVec:B2Vec2;
		var planePointX:Float;
		var planePointY:Float;
		
		switch(cc.type)
		{
			case B2Manifold.e_circles:
			{
				//var pointA:B2Vec2 = cc.bodyA.GetWorldPoint(cc.localPoint);
				tMat = cc.bodyA.m_xf.R;
				tVec = cc.localPoint;
				var pointAX:Float = cc.bodyA.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
				var pointAY:Float = cc.bodyA.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
				//var pointB:B2Vec2 = cc.bodyB.GetWorldPoint(cc.points[0].localPoint);
				tMat = cc.bodyB.m_xf.R;
				tVec = cc.points[0].localPoint;
				var pointBX:Float = cc.bodyB.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
				var pointBY:Float = cc.bodyB.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
				var dX:Float = pointBX - pointAX;
				var dY:Float = pointBY - pointAY;
				var d2:Float = dX * dX + dY * dY;
				if (d2 > B2Math.MIN_VALUE*B2Math.MIN_VALUE)
				{
					var d:Float = Math.sqrt(d2);
					m_normal.x = dX/d;
					m_normal.y = dY/d;
				}
				else
				{
					m_normal.x = 1.0;
					m_normal.y = 0.0;
				}
				m_points[0].x = 0.5 * (pointAX + pointBX);
				m_points[0].y = 0.5 * (pointAY + pointBY);
				m_separations[0] = dX * m_normal.x + dY * m_normal.y - cc.radius;
			}
			
			case B2Manifold.e_faceA:
			{
				//m_normal = cc.bodyA.GetWorldVector(cc.localPlaneNormal);
				tMat = cc.bodyA.m_xf.R;
				tVec = cc.localPlaneNormal;
				m_normal.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				m_normal.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				//planePoint = cc.bodyA.GetWorldPoint(cc.localPoint);
				tMat = cc.bodyA.m_xf.R;
				tVec = cc.localPoint;
				planePointX = cc.bodyA.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
				planePointY = cc.bodyA.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
				
				tMat = cc.bodyB.m_xf.R;
				for (i in 0...cc.pointCount)
				{
					//clipPoint = cc.bodyB.GetWorldPoint(cc.points[i].localPoint);
					tVec = cc.points[i].localPoint;
					clipPointX = cc.bodyB.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
					clipPointY = cc.bodyB.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
					m_separations[i] = (clipPointX - planePointX) * m_normal.x + (clipPointY - planePointY) * m_normal.y - cc.radius;
					m_points[i].x = clipPointX;
					m_points[i].y = clipPointY;
				}
			}
			
			case B2Manifold.e_faceB:
			{
				//m_normal = cc.bodyB.GetWorldVector(cc.localPlaneNormal);
				tMat = cc.bodyB.m_xf.R;
				tVec = cc.localPlaneNormal;
				m_normal.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				m_normal.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				//planePoint = cc.bodyB.GetWorldPoint(cc.localPoint);
				tMat = cc.bodyB.m_xf.R;
				tVec = cc.localPoint;
				planePointX = cc.bodyB.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
				planePointY = cc.bodyB.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
				
				tMat = cc.bodyA.m_xf.R;
				for (i in 0...cc.pointCount)
				{
					//clipPoint = cc.bodyA.GetWorldPoint(cc.points[i].localPoint);
					tVec = cc.points[i].localPoint;
					clipPointX = cc.bodyA.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
					clipPointY = cc.bodyA.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
					m_separations[i] = (clipPointX - planePointX) * m_normal.x + (clipPointY - planePointY) * m_normal.y - cc.radius;
					m_points[i].set(clipPointX, clipPointY);
				}
				
				// Ensure normal points from A to B
				m_normal.x *= -1;
				m_normal.y *= -1;
			}
			
		}
	}
	
	public var m_normal:B2Vec2;
	public var m_points:Array <B2Vec2>;
	public var m_separations:Array <Float>;
}