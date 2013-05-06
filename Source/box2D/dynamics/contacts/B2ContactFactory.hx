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


import box2D.collision.shapes.B2Shape;
import box2D.dynamics.B2Fixture;


//typedef b2Contact* b2ContactCreateFcn(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator);
//typedef void b2ContactDestroyFcn(b2Contact* contact, b2BlockAllocator* allocator);



/**
 * This class manages creation and destruction of b2Contact objects.
 * @private
 */
class B2ContactFactory
{
	public function new (allocator:Dynamic)
	{
		m_allocator = allocator;
		initializeRegisters();
	}
	
	public function addType(createFcn:Dynamic, destroyFcn:Dynamic, type1:Int, type2:Int) : Void
	{
		//b2Settings.b2Assert(b2Shape.e_unknownShape < type1 && type1 < b2Shape.e_shapeTypeCount);
		//b2Settings.b2Assert(b2Shape.e_unknownShape < type2 && type2 < b2Shape.e_shapeTypeCount);
		
		m_registers[type1][type2].createFcn = createFcn;
		m_registers[type1][type2].destroyFcn = destroyFcn;
		m_registers[type1][type2].primary = true;
		
		if (type1 != type2)
		{
			m_registers[type2][type1].createFcn = createFcn;
			m_registers[type2][type1].destroyFcn = destroyFcn;
			m_registers[type2][type1].primary = false;
		}
	}
	public function initializeRegisters() : Void{
		m_registers = new Array <Array <B2ContactRegister> > ();
		for (i in 0...B2Shape.e_shapeTypeCount){
			m_registers[i] = new Array <B2ContactRegister> ();
			for (j in 0...B2Shape.e_shapeTypeCount){
				m_registers[i][j] = new B2ContactRegister();
			}
		}
		
		addType(B2CircleContact.create, B2CircleContact.destroy, B2Shape.e_circleShape, B2Shape.e_circleShape);
		addType(B2PolyAndCircleContact.create, B2PolyAndCircleContact.destroy, B2Shape.e_polygonShape, B2Shape.e_circleShape);
		addType(B2PolygonContact.create, B2PolygonContact.destroy, B2Shape.e_polygonShape, B2Shape.e_polygonShape);
		
		addType(B2EdgeAndCircleContact.create, B2EdgeAndCircleContact.destroy, B2Shape.e_edgeShape, B2Shape.e_circleShape);
		addType(B2PolyAndEdgeContact.create, B2PolyAndEdgeContact.destroy, B2Shape.e_polygonShape, B2Shape.e_edgeShape);
	}
	public function create(fixtureA:B2Fixture, fixtureB:B2Fixture):B2Contact{
		var type1:Int = fixtureA.getType();
		var type2:Int = fixtureB.getType();
		
		//b2Settings.b2Assert(b2Shape.e_unknownShape < type1 && type1 < b2Shape.e_shapeTypeCount);
		//b2Settings.b2Assert(b2Shape.e_unknownShape < type2 && type2 < b2Shape.e_shapeTypeCount);
		
		var reg:B2ContactRegister = m_registers[type1][type2];
		
		var c:B2Contact;
		
		if (reg.pool != null)
		{
			// Pop a contact off the pool
			c = reg.pool;
			reg.pool = c.m_next;
			reg.poolCount--;
			c.reset(fixtureA, fixtureB);
			return c;
		}
		
		var createFcn:Dynamic = reg.createFcn;
		if (createFcn != null)
		{
			if (reg.primary)
			{
				c = createFcn(m_allocator);
				c.reset(fixtureA, fixtureB);
				return c;
			}
			else
			{
				c = createFcn(m_allocator);
				c.reset(fixtureB, fixtureA);
				return c;
			}
		}
		else
		{
			return null;
		}
	}
	public function destroy(contact:B2Contact) : Void{
		if (contact.m_manifold.m_pointCount > 0)
		{
			contact.m_fixtureA.m_body.setAwake(true);
			contact.m_fixtureB.m_body.setAwake(true);
		}
		
		var type1:Int = contact.m_fixtureA.getType();
		var type2:Int = contact.m_fixtureB.getType();
		
		//b2Settings.b2Assert(b2Shape.e_unknownShape < type1 && type1 < b2Shape.e_shapeTypeCount);
		//b2Settings.b2Assert(b2Shape.e_unknownShape < type2 && type2 < b2Shape.e_shapeTypeCount);
		
		var reg:B2ContactRegister = m_registers[type1][type2];
		
		if (true)
		{
			reg.poolCount++;
			contact.m_next = reg.pool;
			reg.pool = contact;
		}
		
		var destroyFcn:Dynamic = reg.destroyFcn;
		destroyFcn(contact, m_allocator);
	}

	
	private var m_registers:Array <Array <B2ContactRegister> >;
	private var m_allocator:Dynamic;
}