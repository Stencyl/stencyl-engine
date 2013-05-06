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
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;


class B2Simplex
{
	
public function new ()
{
	m_v1 = new B2SimplexVertex();
	m_v2 = new B2SimplexVertex();
	m_v3 = new B2SimplexVertex();
	m_vertices = new Array <B2SimplexVertex> ();
	
	m_vertices[0] = m_v1;
	m_vertices[1] = m_v2;
	m_vertices[2] = m_v3;
}

public function readCache(cache:B2SimplexCache, 
			proxyA:B2DistanceProxy, transformA:B2Transform,
			proxyB:B2DistanceProxy, transformB:B2Transform):Void
{
	B2Settings.b2Assert(0 <= cache.count && cache.count <= 3);
	
	var wALocal:B2Vec2;
	var wBLocal:B2Vec2;
	
	// Copy data from cache.
	m_count = cache.count;
	var vertices:Array <B2SimplexVertex> = m_vertices;
	var v:B2SimplexVertex;
	for (i in 0...m_count)
	{
		v = vertices[i];
		v.indexA = cache.indexA[i];
		v.indexB = cache.indexB[i];
		wALocal = proxyA.getVertex(v.indexA);
		wBLocal = proxyB.getVertex(v.indexB);
		v.wA = B2Math.mulX(transformA, wALocal, true);
		v.wB = B2Math.mulX(transformB, wBLocal, true);
		v.w = B2Math.subtractVVPooled(v.wB, v.wA);
		v.a = 0;
	}
	
	// Compute the new simplex metric, if it substantially different than
	// old metric then flush the simplex
	if (m_count > 1)
	{
		var metric1:Float = cache.metric;
		var metric2:Float = getMetric();
		if (metric2 < .5 * metric1 || 2.0 * metric1 < metric2 || metric2 < B2Math.MIN_VALUE)
		{
			// Reset the simplex
			m_count = 0;
		}
	}
	
	// If the cache is empty or invalid
	if (m_count == 0)
	{
		v = vertices[0];
		v.indexA = 0;
		v.indexB = 0;
		wALocal = proxyA.getVertex(0);
		wBLocal = proxyB.getVertex(0);
		v.wA = B2Math.mulX(transformA, wALocal, true);
		v.wB = B2Math.mulX(transformB, wBLocal, true);
		v.w = B2Math.subtractVVPooled(v.wB, v.wA);
		m_count = 1;
	}
}

public function writeCache(cache:B2SimplexCache):Void
{
	cache.metric = getMetric();
	cache.count = Std.int (m_count);
	var vertices:Array <B2SimplexVertex> = m_vertices;
	for (i in 0...m_count)
	{
		cache.indexA[i] = Std.int(vertices[i].indexA);
		cache.indexB[i] = Std.int(vertices[i].indexB);
	}
}

public function getSearchDirection():B2Vec2
{
	switch(m_count)
	{
		case 1:
			return m_v1.w.getNegativePooled();
			
		case 2:
		{
			var e12:B2Vec2 = B2Math.subtractVVPooled(m_v2.w, m_v1.w);
			var sgn:Float = B2Math.crossVV(e12, m_v1.w.getNegative());
			if (sgn > 0.0)
			{
				// Origin is left of e12.
				return B2Math.crossFV(1.0, e12, true);
			}else {
				// Origin is right of e12.
				return B2Math.crossVF(e12, 1.0, true);
			}
		}
		default:
		B2Settings.b2Assert(false);
		return B2Vec2.getFromPool();
	}
}

public function getClosestPoint():B2Vec2
{
	switch(m_count)
	{
		case 0:
			B2Settings.b2Assert(false);
			return B2Vec2.getFromPool();
		case 1:
			return m_v1.w;
		case 2:
			var toReturn = B2Vec2.getFromPool();
			toReturn.x = m_v1.a * m_v1.w.x + m_v2.a * m_v2.w.x;
			toReturn.y = m_v1.a * m_v1.w.y + m_v2.a * m_v2.w.y;
			return toReturn;
		default:
			B2Settings.b2Assert(false);
			return B2Vec2.getFromPool();
	}
}

public function getWitnessPoints(pA:B2Vec2, pB:B2Vec2):Void
{
	switch(m_count)
	{
		case 0:
			B2Settings.b2Assert(false);
			
		case 1:
			pA.setV(m_v1.wA);
			pB.setV(m_v1.wB);
			
		case 2:
			pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x;
			pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y;
			pB.x = m_v1.a * m_v1.wB.x + m_v2.a * m_v2.wB.x;
			pB.y = m_v1.a * m_v1.wB.y + m_v2.a * m_v2.wB.y;
			
		case 3:
			pB.x = pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x + m_v3.a * m_v3.wA.x;
			pB.y = pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y + m_v3.a * m_v3.wA.y;
			
		default:
			B2Settings.b2Assert(false);
			
	}
}

public function getMetric():Float
{
	switch (m_count)
	{
	case 0:
		B2Settings.b2Assert(false);
		return 0.0;

	case 1:
		return 0.0;

	case 2:
		return B2Math.subtractVVPooled(m_v1.w, m_v2.w).length();

	case 3:
		return B2Math.crossVV(B2Math.subtractVVPooled(m_v2.w, m_v1.w),B2Math.subtractVVPooled(m_v3.w, m_v1.w));

	default:
		B2Settings.b2Assert(false);
		return 0.0;
	}
}

// Solve a line segment using barycentric coordinates.
//
// p = a1 * w1 + a2 * w2
// a1 + a2 = 1
//
// The vector from the origin to the closest point on the line is
// perpendicular to the line.
// e12 = w2 - w1
// dot(p, e) = 0
// a1 * dot(w1, e) + a2 * dot(w2, e) = 0
//
// 2-by-2 linear system
// [1      1     ][a1] = [1]
// [w1.e12 w2.e12][a2] = [0]
//
// Define
// d12_1 =  dot(w2, e12)
// d12_2 = -dot(w1, e12)
// d12 = d12_1 + d12_2
//
// Solution
// a1 = d12_1 / d12
// a2 = d12_2 / d12
public function solve2():Void
{
	var w1:B2Vec2 = m_v1.w;
	var w2:B2Vec2 = m_v2.w;
	var e12:B2Vec2 = B2Math.subtractVVPooled(w2, w1);
	
	// w1 region
	var d12_2:Float = -(w1.x * e12.x + w1.y * e12.y);
	if (d12_2 <= 0.0)
	{
		// a2 <= 0, so we clamp it to 0
		m_v1.a = 1.0;
		m_count = 1;
		return;
	}
	
	// w2 region
	var d12_1:Float = (w2.x * e12.x + w2.y * e12.y);
	if (d12_1 <= 0.0)
	{
		// a1 <= 0, so we clamp it to 0
		m_v2.a = 1.0;
		m_count = 1;
		m_v1.set(m_v2);
		return;
	}
	
	// Must be in e12 region.
	var inv_d12:Float = 1.0 / (d12_1 + d12_2);
	m_v1.a = d12_1 * inv_d12;
	m_v2.a = d12_2 * inv_d12;
	m_count = 2;
}

public function solve3():Void
{
	var w1:B2Vec2 = m_v1.w;
	var w2:B2Vec2 = m_v2.w;
	var w3:B2Vec2 = m_v3.w;
	
	// Edge12
	// [1      1     ][a1] = [1]
	// [w1.e12 w2.e12][a2] = [0]
	// a3 = 0
	var e12:B2Vec2 = B2Math.subtractVVPooled(w2, w1);
	var w1e12:Float = B2Math.dot(w1, e12);
	var w2e12:Float = B2Math.dot(w2, e12);
	var d12_1:Float = w2e12;
	var d12_2:Float = -w1e12;

	// Edge13
	// [1      1     ][a1] = [1]
	// [w1.e13 w3.e13][a3] = [0]
	// a2 = 0
	var e13:B2Vec2 = B2Math.subtractVVPooled(w3, w1);
	var w1e13:Float = B2Math.dot(w1, e13);
	var w3e13:Float = B2Math.dot(w3, e13);
	var d13_1:Float = w3e13;
	var d13_2:Float = -w1e13;

	// Edge23
	// [1      1     ][a2] = [1]
	// [w2.e23 w3.e23][a3] = [0]
	// a1 = 0
	var e23:B2Vec2 = B2Math.subtractVVPooled(w3, w2);
	var w2e23:Float = B2Math.dot(w2, e23);
	var w3e23:Float = B2Math.dot(w3, e23);
	var d23_1:Float = w3e23;
	var d23_2:Float = -w2e23;
	
	// Triangle123
	var n123:Float = B2Math.crossVV(e12, e13);

	var d123_1:Float = n123 * B2Math.crossVV(w2, w3);
	var d123_2:Float = n123 * B2Math.crossVV(w3, w1);
	var d123_3:Float = n123 * B2Math.crossVV(w1, w2);

	// w1 region
	if (d12_2 <= 0.0 && d13_2 <= 0.0)
	{
		m_v1.a = 1.0;
		m_count = 1;
		return;
	}

	// e12
	if (d12_1 > 0.0 && d12_2 > 0.0 && d123_3 <= 0.0)
	{
		var inv_d12:Float = 1.0 / (d12_1 + d12_2);
		m_v1.a = d12_1 * inv_d12;
		m_v2.a = d12_2 * inv_d12;
		m_count = 2;
		return;
	}

	// e13
	if (d13_1 > 0.0 && d13_2 > 0.0 && d123_2 <= 0.0)
	{
		var inv_d13:Float = 1.0 / (d13_1 + d13_2);
		m_v1.a = d13_1 * inv_d13;
		m_v3.a = d13_2 * inv_d13;
		m_count = 2;
		m_v2.set(m_v3);
		return;
	}

	// w2 region
	if (d12_1 <= 0.0 && d23_2 <= 0.0)
	{
		m_v2.a = 1.0;
		m_count = 1;
		m_v1.set(m_v2);
		return;
	}

	// w3 region
	if (d13_1 <= 0.0 && d23_1 <= 0.0)
	{
		m_v3.a = 1.0;
		m_count = 1;
		m_v1.set(m_v3);
		return;
	}

	// e23
	if (d23_1 > 0.0 && d23_2 > 0.0 && d123_1 <= 0.0)
	{
		var inv_d23:Float = 1.0 / (d23_1 + d23_2);
		m_v2.a = d23_1 * inv_d23;
		m_v3.a = d23_2 * inv_d23;
		m_count = 2;
		m_v1.set(m_v3);
		return;
	}

	// Must be in triangle123
	var inv_d123:Float = 1.0 / (d123_1 + d123_2 + d123_3);
	m_v1.a = d123_1 * inv_d123;
	m_v2.a = d123_2 * inv_d123;
	m_v3.a = d123_3 * inv_d123;
	m_count = 3;
}

public var m_v1:B2SimplexVertex;
public var m_v2:B2SimplexVertex;
public var m_v3:B2SimplexVertex;
public var m_vertices:Array <B2SimplexVertex>;
public var m_count:Int;
}