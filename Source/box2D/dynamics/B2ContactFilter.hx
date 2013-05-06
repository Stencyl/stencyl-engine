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
* Implement this class to provide collision filtering. In other words, you can implement
* this class if you want finer control over contact creation.
*/
class B2ContactFilter
{
	public function new () {
		
	}

	/**
	* Return true if contact calculations should be performed between these two fixtures.
	* @warning for performance reasons this is only called when the AABBs begin to overlap.
	*/
	public function shouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture) : Bool {
		var g1 = fixtureA.m_body.groupID;
		var g2 = fixtureB.m_body.groupID;
		
		var gf1 = fixtureA.groupID;
		var gf2 = fixtureB.groupID;
		
		if(gf1 != -1000)
		{
			g1 = gf1;
		}
		
		if(gf2 != -1000)
		{
			g2 = gf2;
		}
		
		if(g1 == -1 || g2 == -1)
		{
			return false;
		}
		
		//REGION ID
		if(g1 == -2 || g2 == -2)
		{
			return true;
		}
		
		return com.stencyl.models.GameModel.collisionMap[g1][g2];
	}
	
	/**
	* Return true if the given fixture should be considered for ray intersection.
	* By default, userData is cast as a b2Fixture and collision is resolved according to ShouldCollide
	* @see ShouldCollide()
	* @see b2World#Raycast
	* @param userData	arbitrary data passed from Raycast or RaycastOne
	* @param fixture		the fixture that we are testing for filtering
	* @return a Boolean, with a value of false indicating that this fixture should be ignored.
	*/
	public function rayCollide(userData:Dynamic, fixture:B2Fixture) : Bool {
		if(userData == null)
			return true;
		return shouldCollide(cast (userData, B2Fixture),fixture);
	}
	
	static public var b2_defaultFilter:B2ContactFilter = new B2ContactFilter();
	
}