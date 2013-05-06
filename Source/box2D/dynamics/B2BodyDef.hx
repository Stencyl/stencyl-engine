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


import box2D.common.math.B2Vec2;


/**
* A body definition holds all the data needed to construct a rigid body.
* You can safely re-use body definitions.
*/
class B2BodyDef
{
	/**
	* This constructor sets the body definition default values.
	*/
	public function new ()
	{
		position = new B2Vec2();
		linearVelocity = new B2Vec2 ();
		
		userData = null;
		//position.set(0.0, 0.0);
		angle = 0.0;
		//linearVelocity.set(0, 0);
		angularVelocity = 0.0;
		linearDamping = 0.0;
		angularDamping = 0.0;
		allowSleep = true;
		awake = true;
		fixedRotation = false;
		bullet = false;
		type = B2Body.b2_staticBody;
		active = true;
		inertiaScale = 1.0;
		
		//STENCYL
		groupID = 3;
	}

	/** The body type: static, kinematic, or dynamic. A member of the b2BodyType class
	 * Note: if a dynamic body would have zero mass, the mass is set to one.
	 * @see b2Body#b2_staticBody
	 * @see b2Body#b2_dynamicBody
	 * @see b2Body#b2_kinematicBody
	 */
	public var type:Int;

	/**
	 * The world position of the body. Avoid creating bodies at the origin
	 * since this can lead to many overlapping shapes.
	 */
	public var position:B2Vec2;

	/**
	 * The world angle of the body in radians.
	 */
	public var angle:Float;
	
	/**
	 * The linear velocity of the body's origin in world co-ordinates.
	 */
	public var linearVelocity:B2Vec2;
	
	/**
	 * The angular velocity of the body.
	 */
	public var angularVelocity:Float;

	/**
	 * Linear damping is use to reduce the linear velocity. The damping parameter
	 * can be larger than 1.0f but the damping effect becomes sensitive to the
	 * time step when the damping parameter is large.
	 */
	public var linearDamping:Float;

	/**
	 * Angular damping is use to reduce the angular velocity. The damping parameter
	 * can be larger than 1.0f but the damping effect becomes sensitive to the
	 * time step when the damping parameter is large.
	 */
	public var angularDamping:Float;

	/**
	 * Set this flag to false if this body should never fall asleep. Note that
	 * this increases CPU usage.
	 */
	public var allowSleep:Bool;

	/**
	 * Is this body initially awake or sleeping?
	 */
	public var awake:Bool;

	/**
	 * Should this body be prevented from rotating? Useful for characters.
	 */
	public var fixedRotation:Bool;

	/**
	 * Is this a fast moving body that should be prevented from tunneling through
	 * other moving bodies? Note that all bodies are prevented from tunneling through
	 * static bodies.
	 * @warning You should use this flag sparingly since it increases processing time.
	 */
	public var bullet:Bool;
	
	/**
	 * Does this body start out active?
	 */ 
	public var active:Bool;
	
	/**
	 * Use this to store application specific body data.
	 */
	public var userData:Dynamic;
	
	/**
	 * Scales the inertia tensor.
	 * @warning Experimental
	 */
	public var inertiaScale:Float;
	
	
	//STENCYL: We store these globally
	public var groupID:Int;
	public var ignoreGravity:Bool;
	public var friction:Float;
	public var bounciness:Float;
	public var mass:Float;
	public var aMass:Float;
}