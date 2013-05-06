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

package box2D.dynamics;





/**
* This holds contact filtering data.
*/
class B2FilterData
{
	
	public function new () {
		
		categoryBits = 0x0001;
		maskBits = 0xFFFF;
		groupIndex = 0;
		
	}
	
	public function copy() : B2FilterData {
		var copy: B2FilterData = new B2FilterData();
		copy.categoryBits = categoryBits;
		copy.maskBits = maskBits;
		copy.groupIndex = groupIndex;
		return copy;
	}
	
	/**
	* The collision category bits. Normally you would just set one bit.
	*/
	public var categoryBits: Int;

	/**
	* The collision mask bits. This states the categories that this
	* shape would accept for collision.
	*/
	public var maskBits: Int;

	/**
	* Collision groups allow a certain group of objects to never collide (negative)
	* or always collide (positive). Zero means no collision group. Non-zero group
	* filtering always wins against the mask bits.
	*/
	public var groupIndex: Int;
}