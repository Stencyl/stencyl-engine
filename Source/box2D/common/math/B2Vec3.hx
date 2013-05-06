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


/**
* A 2D column vector with 3 elements.
*/

class B2Vec3
{
	/**
	 * Construct using co-ordinates
	 */
	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	/**
	 * Sets this vector to all zeros
	 */
	public function setZero():Void
	{
		x = y = z = 0.0;
	}
	
	/**
	 * Set this vector to some specified coordinates.
	 */
	public function set(x:Float, y:Float, z:Float):Void
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public function setV(v:B2Vec3):Void
	{
		x = v.x;
		y = v.y;
		z = v.z;
	}
	
	/**
	 * Negate this vector
	 */
	public function getNegative():B2Vec3 { return new B2Vec3( -x, -y, -z); }
	
	public function negativeSelf():Void { x = -x; y = -y; z = -z; }
	
	public function copy():B2Vec3{
		return new B2Vec3(x,y,z);
	}
	
	public function add(v:B2Vec3) : Void
	{
		x += v.x; y += v.y; z += v.z;
	}
	
	public function subtract(v:B2Vec3) : Void
	{
		x -= v.x; y -= v.y; z -= v.z;
	}

	public function multiply(a:Float) : Void
	{
		x *= a; y *= a; z *= a;
	}
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
}