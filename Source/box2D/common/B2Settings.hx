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

package box2D.common;
	
	
/**
* This class controls Box2D global settings
*/
class B2Settings{
    
    /**
    * The current version of Box2D
    */
    static public var VERSION:String = "2.1alpha";
	
	#if !cpp
	static public var USHRT_MAX:Int = 0x0000ffff;
	#end

	static public var b2_pi:Float = Math.PI;



	// Collision
    /**
     *   Number of manifold points in a b2Manifold. This should NEVER change.
     */
	static public var b2_maxManifoldPoints:Int = 2;

    /*
     * The growable broadphase doesn't have upper limits,
	 * so there is no b2_maxProxies or b2_maxPairs settings.
     */
	//static public const b2_maxProxies:Int = 0;
	//static public const b2_maxPairs:Int = 8 * b2_maxProxies;
	
	/**
	 * This is used to fatten AABBs in the dynamic tree. This allows proxies
	 * to move by a small amount without triggering a tree adjustment.
	 * This is in meters.
	 */
	static public var b2_aabbExtension:Float = 0.1;
	
 	/**
 	 * This is used to fatten AABBs in the dynamic tree. This is used to predict
 	 * the future position based on the current displacement.
	 * This is a dimensionless multiplier.
	 */
	static public var b2_aabbMultiplier:Float = 2.0;

	// Dynamics
	
	/**
	* A small length used as a collision and constraint tolerance. Usually it is
	* chosen to be numerically significant, but visually insignificant.
	*/
	static public var b2_linearSlop:Float = 0.005;	// 0.5 cm

	/**
	 * The radius of the polygon/edge shape skin. This should not be modified. Making
	 * this smaller means polygons will have and insufficient for continuous collision.
	 * Making it larger may create artifacts for vertex collision.
	 */
	static public var b2_polygonRadius:Float = 2.0 * b2_linearSlop;
	
	/**
	* A small angle used as a collision and constraint tolerance. Usually it is
	* chosen to be numerically significant, but visually insignificant.
	*/
	static public var b2_angularSlop:Float = 2.0 / 180.0 * b2_pi;			// 2 degrees
	
	/**
	* Continuous collision detection (CCD) works with core, shrunken shapes. This is the
	* amount by which shapes are automatically shrunk to work with CCD. This must be
	* larger than b2_linearSlop.
    * @see b2_linearSlop
	*/
	static public var b2_toiSlop:Float = 8.0 * b2_linearSlop;
	
	/**
	* Maximum number of contacts to be handled to solve a TOI island.
	*/
	static public var b2_maxTOIContactsPerIsland:Int = 32;
	
	/**
	* Maximum number of joints to be handled to solve a TOI island.
	*/
	static public var b2_maxTOIJointsPerIsland:Int = 32;
	
	/**
	* A velocity threshold for elastic collisions. Any collision with a relative linear
	* velocity below this threshold will be treated as inelastic.
	*/
	static public var b2_velocityThreshold:Float = 1.0;		// 1 m/s
	
	/**
	* The maximum linear position correction used when solving constraints. This helps to
	* prevent overshoot.
	*/
	static public var b2_maxLinearCorrection:Float = 0.2;	// 20 cm
	
	/**
	* The maximum angular position correction used when solving constraints. This helps to
	* prevent overshoot.
	*/
	static public var b2_maxAngularCorrection:Float = 8.0 / 180.0 * b2_pi;			// 8 degrees
	
	/**
	* The maximum linear velocity of a body. This limit is very large and is used
	* to prevent numerical problems. You shouldn't need to adjust this.
	*/
	static public var b2_maxTranslation:Float = 2.0;
	static public var b2_maxTranslationSquared:Float = b2_maxTranslation * b2_maxTranslation;
	
	/**
	* The maximum angular velocity of a body. This limit is very large and is used
	* to prevent numerical problems. You shouldn't need to adjust this.
	*/
	static public var b2_maxRotation:Float = 0.5 * b2_pi;
	static public var b2_maxRotationSquared:Float = b2_maxRotation * b2_maxRotation;
	
	/**
	* This scale factor controls how fast overlap is resolved. Ideally this would be 1 so
	* that overlap is removed in one time step. However using values close to 1 often lead
	* to overshoot.
	*/
	static public var b2_contactBaumgarte:Float = 0.2;
	
	/**
	 * Friction mixing law. Feel free to customize this.
	 */
	public static function b2MixFriction(friction1:Float, friction2:Float):Float
	{
		return Math.sqrt(friction1 * friction2);
	}

	/** 
	 * Restitution mixing law. Feel free to customize this.
	 */
	public static function b2MixRestitution(restitution1:Float, restitution2:Float):Float
	{
		return restitution1 > restitution2 ? restitution1 : restitution2;
	}



	// Sleep
	
	/**
	* The time that a body must be still before it will go to sleep.
	*/
	static public var b2_timeToSleep:Float = 0.5;					// half a second
	/**
	* A body cannot sleep if its linear velocity is above this tolerance.
	*/
	static public var b2_linearSleepTolerance:Float = 0.01;			// 1 cm/s
	/**
	* A body cannot sleep if its angular velocity is above this tolerance.
	*/
	static public var b2_angularSleepTolerance:Float = 2.0 / 180.0 * B2Settings.b2_pi;	// 2 degrees/s
	
	// assert
    /**
    * b2Assert is used internally to handle assertions. By default, calls are commented out to save performance,
    * so they serve more as documentation than anything else.
    */
	static public function b2Assert(a:Bool) : Void
	{
		if (!a){
			//var nullVec:B2Vec2;
			//nullVec.x++;
			throw "Assertion Failed";
		}
	}
}