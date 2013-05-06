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


import box2D.collision.B2Manifold;
import box2D.dynamics.contacts.B2Contact;

import com.stencyl.models.Actor;
import com.stencyl.models.Region;
import com.stencyl.models.Terrain;


/**
 * Implement this class to get contact information. You can use these results for
 * things like sounds and game logic. You can also get contact results by
 * traversing the contact lists after the time step. However, you might miss
 * some contacts because continuous physics leads to sub-stepping.
 * Additionally you may receive multiple callbacks for the same contact in a
 * single time step.
 * You should strive to make your callbacks efficient because there may be
 * many callbacks per time step.
 * @warning You cannot create/destroy Box2D entities inside these callbacks.
 */
class B2ContactListener
{
	private static var KEY_LOCK:Int = 0;
	public function new () {
		
		
	}
	
	
	/**
	 * Called when two fixtures begin to touch.
	 */
	public function beginContact(contact:B2Contact):Void 
	{
		//5000 seems reasonable time to reset
		if (KEY_LOCK > 5000)
		{
			KEY_LOCK = 0;
		}
		
		contact.key = KEY_LOCK++;

		var a1 = cast(contact.getFixtureA().getUserData(), Actor);
		var a2 = cast(contact.getFixtureB().getUserData(), Actor);
		
		var r1 = Std.is(a1, Region);
		var r2 = Std.is(a2, Region);
		
		if(r1 && !(r2 || Std.is(a2, Terrain)))
		{
			cast(a1, Region).addActor(a2);
			a2.addRegionContact(contact);
			return;
		}
		
		if(r2 && !(r1 || Std.is(a1, Terrain)))
		{
			cast(a2, Region).addActor(a1);
			a1.addRegionContact(contact);
			return;
		}

		a1.addContact(contact);
		a2.addContact(contact);
	}

	/**
	 * Called when two fixtures cease to touch.
	 */
	public function endContact(contact:B2Contact):Void 
	{ 
		var a1 = cast(contact.getFixtureA().getUserData(), Actor);
		var a2 = cast(contact.getFixtureB().getUserData(), Actor);
			
		var r1 = Std.is(a1, Region);
		var r2 = Std.is(a2, Region);
			
		if(r1 && !r2)
		{
			var inRegion = false;
			
			a2.removeRegionContact(contact);
			
			for(p in a2.regionContacts)
			{
				if(Std.is(p.getFixtureA().getUserData(), Region) && p.getFixtureA().getUserData() == a1)
				{
					inRegion = true;
					break;
				}
				
				if(Std.is(p.getFixtureB().getUserData(), Region) && p.getFixtureB().getUserData() == a1)
				{
					inRegion = true;
					break;
				}
			}
			
			if(!inRegion || a2.recycled) cast(a1, Region).removeActor(a2);

			return;
		}
		
		if(r2 && !r1)
		{
			var inRegion = false;
			
			a1.removeRegionContact(contact);
			
			for(p in a1.regionContacts)
			{
				if(Std.is(p.getFixtureA().getUserData(), Region) && p.getFixtureA().getUserData() == a2)
				{
					inRegion = true;
					break;
				}
				
				if(Std.is(p.getFixtureB().getUserData(), Region) && p.getFixtureB().getUserData() == a2)
				{
					inRegion = true;
					break;
				}
			}
			
			if(!inRegion || a1.recycled) cast(a2, Region).removeActor(a1);

			return;
		}
		
		a1.removeContact(contact);
		a2.removeContact(contact);
	}
		

	/**
	 * This is called after a contact is updated. This allows you to inspect a
	 * contact before it goes to the solver. If you are careful, you can modify the
	 * contact manifold (e.g. disable contact).
	 * A copy of the old manifold is provided so that you can detect changes.
	 * Note: this is called only for awake bodies.
	 * Note: this is called even when the number of contact points is zero.
	 * Note: this is not called for sensors.
	 * Note: if you set the number of contact points to zero, you will not
	 * get an EndContact callback. However, you may get a BeginContact callback
	 * the next step.
	 */
	public function preSolve(contact:B2Contact, oldManifold:B2Manifold):Void {}

	/**
	 * This lets you inspect a contact after the solver is finished. This is useful
	 * for inspecting impulses.
	 * Note: the contact manifold does not include time of impact impulses, which can be
	 * arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
	 * in a separate data structure.
	 * Note: this is only called for contacts that are touching, solid, and awake.
	 */
	public function postSolve(contact:B2Contact, impulse:B2ContactImpulse):Void { }
	
	public static var b2_defaultListener:B2ContactListener = new B2ContactListener();
}