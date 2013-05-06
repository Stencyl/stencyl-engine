/*
* Copyright (c) 2006-2007 Adam Newgas
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


import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;


/**
 * Applies simplified gravity between every pair of bodies 
 */
class B2GravityController extends B2Controller
{	
	/**
	 * Specifies the strength of the gravitiation force
	 */
	public var G:Float;
	/**
	 * If true, gravity is proportional to r^-2, otherwise r^-1
	 */
	public var invSqr:Bool;
	
	public function new () {
		
		G = 1;
		invSqr = true;
		
	}
	
	public override function step(step:B2TimeStep):Void{
		//Inlined
		var i:B2ControllerEdge = null;
		var body1:B2Body = null;
		var p1:B2Vec2 = null;
		var mass1:Float = 0;
		var j:B2ControllerEdge = null;
		var body2:B2Body = null;
		var p2:B2Vec2 = null;
		var dx:Float = 0;
		var dy:Float = 0;
		var r2:Float = 0;
		var f:B2Vec2 = null;
		if (invSqr) {
			i=m_bodyList;
			while (i != null){
				body1 = i.body;
				p1 = body1.getWorldCenter();
				mass1 = body1.getMass();
				j=m_bodyList;
				while (j!=i) {
					body2 = j.body;
					p2 = body2.getWorldCenter()
					dx = p2.x - p1.x;
					dy = p2.y - p1.y;
					r2 = dx*dx+dy*dy;
					if (r2 < B2Math.MIN_VALUE) {
						j = j.nextBody;
						continue;
					}
					f = new B2Vec2(dx,dy);
					f.multiply(G / r2 / Math.sqrt(r2) * mass1* body2.getMass());
					if(body1.isAwake())
						body1.applyForce(f,p1);
					f.multiply(-1);
					if(body2.isAwake())
						body2.applyForce(f, p2);
					j = j.nextBody;
				}
				i = i.nextBody;
			}
		}else {
			i=m_bodyList;
			while (i != null){
				body1 = i.body;
				p1 = body1.getWorldCenter();
				mass1 = body1.getMass();
				for(j=m_bodyList;j!=i;j=j.nextBody){
					body2 = j.body;
					p2 = body2.getWorldCenter()
					dx = p2.x - p1.x;
					dy = p2.y - p1.y;
					r2 = dx*dx+dy*dy;
					if(r2<B2Math.MIN_VALUE) {
						i = i.nextBody;
						continue;
					}
					f = new B2Vec2(dx,dy);
					f.multiply(G / r2 * mass1 * body2.getMass());
					if(body1.isAwake())
						body1.applyForce(f,p1);
					f.multiply(-1);
					if(body2.isAwake())
						body2.applyForce(f,p2);
				}
				i = i.nextBody;
			}
		}
	}
}