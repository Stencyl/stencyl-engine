package box2D.dynamics.controllers;

import box2D.dynamics.B2Body;

class B2ControllerEdge 
{
	public function new () {}
	/** provides quick access to other end of this edge */
	public var controller:B2Controller;
	/** the body */
	public var body:B2Body;
	/** the previous controller edge in the controllers's body list */
	public var prevBody:B2ControllerEdge;
	/** the next controller edge in the controllers's body list */
	public var nextBody:B2ControllerEdge;
	/** the previous controller edge in the body's controller list */
	public var prevController:B2ControllerEdge;
	/** the next controller edge in the body's controller list */
	public var nextController:B2ControllerEdge;
}