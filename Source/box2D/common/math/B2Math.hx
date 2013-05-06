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

package box2D.common.math;

import box2D.common.B2Settings;
import box2D.collision.B2AABB;

/**
* @private
*/
class B2Math {
	
	
	/**
	* This function is used to ensure that a floating point number is
	* not a NaN or infinity.
	*/
	static public function isValid(x:Float) : Bool
	{
		if (Math.isNaN (x) || x == Math.NEGATIVE_INFINITY || x == Math.POSITIVE_INFINITY) {
			
			return false;
			
		}
		
		return true;
		//return isFinite(x);
	}
	
	/*static public function b2InvSqrt(x:Float):Float{
		union
		{
			float32 x;
			int32 i;
		} convert;
		
		convert.x = x;
		float32 xhalf = 0.5f * x;
		convert.i = 0x5f3759df - (convert.i >> 1);
		x = convert.x;
		x = x * (1.5f - xhalf * x * x);
		return x;
	}*/

	static public function dot(a:B2Vec2, b:B2Vec2):Float
	{
		return a.x * b.x + a.y * b.y;
	}

	static public function crossVV(a:B2Vec2, b:B2Vec2):Float
	{
		return a.x * b.y - a.y * b.x;
	}

	static public function crossVF(a:B2Vec2, s:Float, fromPool:Bool = false):B2Vec2
	{
		var v:B2Vec2;
		
		if(fromPool) 
		{
			v = B2Vec2.getFromPool();
			v.set(s * a.y, -s * a.x);	
		} 
		
		else 
		{	
			v = new B2Vec2(s * a.y, -s * a.x);
		}
		
		return v;
	}

	static public function crossFV(s:Float, a:B2Vec2, fromPool:Bool = false):B2Vec2
	{
		var v:B2Vec2;
		
		if(fromPool) 
		{
			v = B2Vec2.getFromPool();
			v.set(-s * a.y, s * a.x);	
		} 
		
		else 
		{	
			v = new B2Vec2(-s * a.y, s * a.x);
		}
		
		return v;
	}

	static public function mulMV(A:B2Mat22, v:B2Vec2, fromPool:Bool = false):B2Vec2
	{
		var vec:B2Vec2;
		
		if(fromPool) 
		{
			vec = B2Vec2.getFromPool();
			vec.set(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y);
		} 
		
		else 
		{
			vec = new B2Vec2(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y);
		}

		return vec;
	}

	static public function mulTMV(A:B2Mat22, v:B2Vec2, fromPool:Bool = false):B2Vec2
	{
		var vec:B2Vec2;
		
		if(fromPool) 
		{
			vec = B2Vec2.getFromPool();
			vec.set(dot(v, A.col1), dot(v, A.col2));
		} 
		
		else 
		{	
			vec = new B2Vec2(dot(v, A.col1), dot(v, A.col2));
		}

		return vec;
	}
	
	static public function mulX(T:B2Transform, v:B2Vec2, fromPool:Bool = false):B2Vec2
	{
		var a:B2Vec2 = mulMV(T.R, v, fromPool);
		a.x += T.position.x;
		a.y += T.position.y;
		return a;
	}

	static public function mulXT(T:B2Transform, v:B2Vec2, fromPool:Bool = false):B2Vec2
	{
		var a:B2Vec2 = subtractVVPooled(v, T.position);
		var tX:Float = (a.x * T.R.col1.x + a.y * T.R.col1.y);
		a.y = (a.x * T.R.col2.x + a.y * T.R.col2.y);
		a.x = tX;
		return a;
	}

	static public function addVV(a:B2Vec2, b:B2Vec2):B2Vec2
	{
		var v:B2Vec2 = new B2Vec2(a.x + b.x, a.y + b.y);
		return v;
	}

	static public function subtractVV(a:B2Vec2, b:B2Vec2):B2Vec2
	{
		return new B2Vec2(a.x - b.x, a.y - b.y);
	}
	
	static public function subtractVVPooled(a:B2Vec2, b:B2Vec2):B2Vec2
	{
		var v:B2Vec2 = B2Vec2.getFromPool();
		v.set(a.x - b.x, a.y - b.y);
		return v;
	}
	
	static public function distance(a:B2Vec2, b:B2Vec2) : Float{
		var cX:Float = a.x-b.x;
		var cY:Float = a.y-b.y;
		return Math.sqrt(cX*cX + cY*cY);
	}
	
	static public function distanceSquared(a:B2Vec2, b:B2Vec2) : Float{
		var cX:Float = a.x-b.x;
		var cY:Float = a.y-b.y;
		return (cX*cX + cY*cY);
	}

	static public function mulFV(s:Float, a:B2Vec2):B2Vec2
	{
		var v:B2Vec2 = new B2Vec2(s * a.x, s * a.y);
		return v;
	}

	static public function addMM(A:B2Mat22, B:B2Mat22):B2Mat22
	{
		var C:B2Mat22 = B2Mat22.fromVV(addVV(A.col1, B.col1), addVV(A.col2, B.col2));
		return C;
	}

	// A * B
	static public function mulMM(A:B2Mat22, B:B2Mat22):B2Mat22
	{
		var C:B2Mat22 = B2Mat22.fromVV(mulMV(A, B.col1), mulMV(A, B.col2));
		return C;
	}

	// A^T * B
	static public function mulTMM(A:B2Mat22, B:B2Mat22):B2Mat22
	{
		var c1:B2Vec2 = new B2Vec2(dot(A.col1, B.col1), dot(A.col2, B.col1));
		var c2:B2Vec2 = new B2Vec2(dot(A.col1, B.col2), dot(A.col2, B.col2));
		var C:B2Mat22 = B2Mat22.fromVV(c1, c2);
		return C;
	}

	static public function abs(a:Float):Float
	{
		return a > 0.0 ? a : -a;
	}

	static public function absV(a:B2Vec2):B2Vec2
	{
		var b:B2Vec2 = new B2Vec2(abs(a.x), abs(a.y));
		return b;
	}

	static public function absM(A:B2Mat22):B2Mat22
	{
		var B:B2Mat22 = B2Mat22.fromVV(absV(A.col1), absV(A.col2));
		return B;
	}

	static public function min(a:Float, b:Float):Float
	{
		return a < b ? a : b;
	}

	static public function minV(a:B2Vec2, b:B2Vec2):B2Vec2
	{
		var c:B2Vec2 = new B2Vec2(min(a.x, b.x), min(a.y, b.y));
		return c;
	}

	static public function max(a:Float, b:Float):Float
	{
		return a > b ? a : b;
	}

	static public function maxV(a:B2Vec2, b:B2Vec2):B2Vec2
	{
		var c:B2Vec2 = new B2Vec2(max(a.x, b.x), max(a.y, b.y));
		return c;
	}

	static public function clamp(a:Float, low:Float, high:Float):Float
	{
		return a < low ? low : a > high ? high : a;
	}

	static public function clampV(a:B2Vec2, low:B2Vec2, high:B2Vec2):B2Vec2
	{
		return maxV(low, minV(a, high));
	}

	static public function swap(a:Array <Dynamic>, b:Array <Dynamic>) : Void
	{
		var tmp:Dynamic = a[0];
		a[0] = b[0];
		b[0] = tmp;
	}

	// b2Random number in range [-1,1]
	static public function random():Float
	{
		return Math.random() * 2 - 1;
	}

	static public function randomRange(lo:Float, hi:Float) : Float
	{
		var r:Float = Math.random();
		r = (hi - lo) * r + lo;
		return r;
	}

	// "Next Largest Power of 2
	// Given a binary integer value x, the next largest power of 2 can be computed by a SWAR algorithm
	// that recursively "folds" the upper bits into the lower bits. This process yields a bit vector with
	// the same most significant 1 as x, but all 1's below it. Adding 1 to that value yields the next
	// largest power of 2. For a 32-bit value:"
	static public function nextPowerOfTwo(x:Int):Int
	{
		x |= (x >> 1) & 0x7FFFFFFF;
		x |= (x >> 2) & 0x3FFFFFFF;
		x |= (x >> 4) & 0x0FFFFFFF;
		x |= (x >> 8) & 0x00FFFFFF;
		x |= (x >> 16)& 0x0000FFFF;
		return x + 1;
	}

	static public function isPowerOfTwo(x:Int):Bool
	{
		var result:Bool = x > 0 && (x & (x - 1)) == 0;
		return result;
	}
	
	
	// Temp vector functions to reduce calls to 'new'
	/*static public var tempVec:B2Vec2 = new B2Vec2();
	static public var tempVec2:B2Vec2 = new B2Vec2();
	static public var tempVec3:B2Vec2 = new B2Vec2();
	static public var tempVec4:B2Vec2 = new B2Vec2();
	static public var tempVec5:B2Vec2 = new B2Vec2();
	
	static public var tempMat:B2Mat22 = new B2Mat22();	
	
	static public var tempAABB:B2AABB = new B2AABB();	*/
	
	static public var b2Vec2_zero:B2Vec2 = new B2Vec2(0.0, 0.0);
	static public var b2Mat22_identity:B2Mat22 = B2Mat22.fromVV(new B2Vec2(1.0, 0.0), new B2Vec2(0.0, 1.0));
	static public var b2Transform_identity:B2Transform = new B2Transform(b2Vec2_zero, b2Mat22_identity);
	
	
	#if flash
	
	public static inline var MIN_VALUE:Float = untyped __global__ ["Number"].MIN_VALUE;
	public static inline var MAX_VALUE:Float = untyped __global__ ["Number"].MAX_VALUE;
	
	#elseif js
	
	public static inline var MIN_VALUE:Float = untyped __js__ ("Number.MIN_VALUE");
	public static inline var MAX_VALUE:Float = untyped __js__ ("Number.MAX_VALUE");
	
	#else
	
    public static inline var MIN_VALUE:Float = 2.2250738585072014e-308;
    public static inline var MAX_VALUE:Float = 1.7976931348623158e+308;
	
	#end
	

}