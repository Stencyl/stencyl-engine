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

package box2D.dynamics.controllers;


import box2D.dynamics.B2Body;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2TimeStep;
import box2D.dynamics.B2World;

	
/**
 * Base class for controllers. Controllers are a convience for encapsulating common
 * per-step functionality.
 */
class B2Controller 
{
	public function step(step:B2TimeStep):Void {}
		
	public function draw(debugDraw:B2DebugDraw):Void { }
	
	public function addBody(body:B2Body) : Void 
	{
		var edge:B2ControllerEdge = new B2ControllerEdge();
		edge.controller = this;
		edge.body = body;
		//
		edge.nextBody = m_bodyList;
		edge.prevBody = null;
		m_bodyList = edge;
		if (edge.nextBody != null)
			edge.nextBody.prevBody = edge;
		m_bodyCount++;
		//
		edge.nextController = body.m_controllerList;
		edge.prevController = null;
		body.m_controllerList = edge;
		if (edge.nextController != null)
			edge.nextController.prevController = edge;
		body.m_controllerCount++;
	}
	
	public function removeBody(body:B2Body) : Void
	{
		var edge:B2ControllerEdge = body.m_controllerList;
		while (edge != null && edge.controller != this)
			edge = edge.nextController;
			
		//Attempted to remove a body that was not attached?
		//b2Settings.b2Assert(bEdge != null);
		
		if (edge.prevBody != null)
			edge.prevBody.nextBody = edge.nextBody;
		if (edge.nextBody != null)
			edge.nextBody.prevBody = edge.prevBody;
		if (edge.nextController != null)
			edge.nextController.prevController = edge.prevController;
		if (edge.prevController != null)
			edge.prevController.nextController = edge.nextController;
		if (m_bodyList == edge)
			m_bodyList = edge.nextBody;
		if (body.m_controllerList == edge)
			body.m_controllerList = edge.nextController;
		body.m_controllerCount--;
		m_bodyCount--;
		//b2Settings.b2Assert(body.m_controllerCount >= 0);
		//b2Settings.b2Assert(m_bodyCount >= 0);
	}
	
	public function clear():Void
	{
		while (m_bodyList != null)
			removeBody(m_bodyList.body);
	}
	
	public function getNext():B2Controller{return m_next;}
	public function getWorld():B2World { return m_world; }
	
	public function getBodyList() : B2ControllerEdge
	{
		return m_bodyList;
	}
	
	public var m_next:B2Controller;
	public var m_prev:B2Controller;
	
	public var m_bodyList:B2ControllerEdge;
	public var m_bodyCount:Int;
	
	public var m_world:B2World;
}