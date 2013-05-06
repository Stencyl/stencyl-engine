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

package box2D.collision;
	

import box2D.common.B2Settings;
import box2D.common.math.B2Math;
import box2D.common.math.B2Sweep;
import box2D.common.math.B2Transform;


/**
* @private
*/
class B2TimeOfImpact
{
	
	private static var b2_toiCalls:Int = 0;
	private static var b2_toiIters:Int = 0;
	private static var b2_toiMaxIters:Int = 0;
	private static var b2_toiRootIters:Int = 0;
	private static var b2_toiMaxRootIters:Int = 0;

	private static var s_cache:B2SimplexCache = new B2SimplexCache();
	private static var s_distanceInput:B2DistanceInput = new B2DistanceInput();
	private static var s_xfA:B2Transform = new B2Transform();
	private static var s_xfB:B2Transform = new B2Transform();
	private static var s_fcn:B2SeparationFunction = new B2SeparationFunction();
	private static var s_distanceOutput:B2DistanceOutput = new B2DistanceOutput();
	public static function timeOfImpact(input:B2TOIInput):Float
	{
		++b2_toiCalls;
		
		var proxyA:B2DistanceProxy = input.proxyA;
		var proxyB:B2DistanceProxy = input.proxyB;
		
		var sweepA:B2Sweep = input.sweepA;
		var sweepB:B2Sweep = input.sweepB;
		
		B2Settings.b2Assert(sweepA.t0 == sweepB.t0);
		B2Settings.b2Assert(1.0 - sweepA.t0 > B2Math.MIN_VALUE);
		
		var radius:Float = proxyA.m_radius + proxyB.m_radius;
		var tolerance:Float = input.tolerance;
		
		var alpha:Float = 0.0;
		
		var k_maxIterations:Int = 1000; //TODO_ERIN b2Settings
		var iter:Int = 0;
		var target:Float = 0.0;
		
		// Prepare input for distance query.
		s_cache.count = 0;
		s_distanceInput.useRadii = false;
		
		while (true)
		{
			sweepA.getTransform(s_xfA, alpha);
			sweepB.getTransform(s_xfB, alpha);
			
			// Get the distance between shapes
			s_distanceInput.proxyA = proxyA;
			s_distanceInput.proxyB = proxyB;
			s_distanceInput.transformA = s_xfA;
			s_distanceInput.transformB = s_xfB;
			
			B2Distance.distance(s_distanceOutput, s_cache, s_distanceInput);
			
			if (s_distanceOutput.distance <= 0.0)
			{
				alpha = 1.0;
				break;
			}
			
			s_fcn.initialize(s_cache, proxyA, s_xfA, proxyB, s_xfB);
			
			var separation:Float = s_fcn.evaluate(s_xfA, s_xfB);
			if (separation <= 0.0)
			{
				alpha = 1.0;
				break;
			}
			
			if (iter == 0)
			{
				// Compute a reasonable target distance to give some breathing room
				// for conservative advancement. We take advantage of the shape radii
				// to create additional clearance
				if (separation > radius)
				{
					target = B2Math.max(radius - tolerance, 0.75 * radius);
				}
				else
				{
					target = B2Math.max(separation - tolerance, 0.02 * radius);
				}
			}
			
			if (separation - target < 0.5 * tolerance)
			{
				if (iter == 0)
				{
					alpha = 1.0;
					break;
				}
				break;
			}
			
//#if 0
			// Dump the curve seen by the root finder
			//{
				//const N:Int = 100;
				//var dx:Float = 1.0 / N;
				//var xs:Vector.<Number> = new Array(N + 1);
				//var fs:Vector.<Number> = new Array(N + 1);
				//
				//var x:Float = 0.0;
				//for (var i:Int = 0; i <= N; i++)
				//{
					//sweepA.GetTransform(xfA, x);
					//sweepB.GetTransform(xfB, x);
					//var f:Float = fcn.Evaluate(xfA, xfB) - target;
					//
					//trace(x, f);
					//xs[i] = x;
					//fx[i] = f'
					//
					//x += dx;
				//}
			//}
//#endif
			// Compute 1D root of f(x) - target = 0
			var newAlpha:Float = alpha;
			{
				var x1:Float = alpha;
				var x2:Float = 1.0;
				
				var f1:Float = separation;
				
				sweepA.getTransform(s_xfA, x2);
				sweepB.getTransform(s_xfB, x2);
				
				var f2:Float = s_fcn.evaluate(s_xfA, s_xfB);
				
				// If intervals don't overlap at t2, then we are done
				if (f2 >= target)
				{
					alpha = 1.0;
					break;
				}
				
				// Determine when intervals intersect
				var rootIterCount:Int = 0;
				while (true)
				{
					// Use a mis of the secand rule and bisection
					var x:Float;
					if ((rootIterCount & 1) != 0)
					{
						// Secant rule to improve convergence
						x = x1 + (target - f1) * (x2 - x1) / (f2 - f1);
					}
					else
					{
						// Bisection to guarantee progress
						x = 0.5 * (x1 + x2);
					}
					
					sweepA.getTransform(s_xfA, x);
					sweepB.getTransform(s_xfB, x);
					
					var f:Float = s_fcn.evaluate(s_xfA, s_xfB);
					
					if (B2Math.abs(f - target) < 0.025 * tolerance)
					{
						newAlpha = x;
						break;
					}
					
					// Ensure we continue to bracket the root
					if (f > target)
					{
						x1 = x;
						f1 = f;
					}
					else
					{
						x2 = x;
						f2 = f;
					}
					
					++rootIterCount;
					++b2_toiRootIters;
					if (rootIterCount == 50)
					{
						break;
					}
				}
				
				b2_toiMaxRootIters = Std.int (B2Math.max(b2_toiMaxRootIters, rootIterCount));
			}
			
			// Ensure significant advancement
			if (newAlpha < (1.0 + 100.0 * B2Math.MIN_VALUE) * alpha)
			{
				break;
			}
			
			alpha = newAlpha;
			
			iter++;
			++b2_toiIters;
			
			if (iter == k_maxIterations)
			{
				break;
			}
		}
		
		b2_toiMaxIters = Std.int (B2Math.max(b2_toiMaxIters, iter));

		return alpha;
	}

}