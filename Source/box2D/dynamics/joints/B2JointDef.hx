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

package box2D.dynamics.joints;


import box2D.dynamics.B2Body;


/**
* Joint definitions are used to construct joints.
* @see b2Joint
*/
class B2JointDef
{
	
	public function new ()
	{
		type = B2Joint.e_unknownJoint;
		userData = null;
		bodyA = null;
		bodyB = null;
		collideConnected = false;
	}

	/**
	* The joint type is set automatically for concrete joint types.
	*/
	public var type:Int;
	/**
	* Use this to attach application specific data to your joints.
	*/
	public var userData:Dynamic;
	/**
	* The first attached body.
	*/
	public var bodyA:B2Body;
	/**
	* The second attached body.
	*/
	public var bodyB:B2Body;
	/**
	* Set this flag to true if the attached bodies should collide.
	*/
	public var collideConnected:Bool;
	
	
	//Stencyl
	public static var CENTER:String = "center";
	
	public var ID:Int;
	public var actor1:Int;
	public var actor2:Int;
	
}