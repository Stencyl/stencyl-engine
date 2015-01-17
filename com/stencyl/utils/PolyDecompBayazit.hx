package com.stencyl.utils;

import openfl.geom.Point;
import box2D.common.math.B2Math;

/*
* Copyright (c) 2006-2007 Tim Kerchmar http://ptymn.blogspot.com/
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

class PolyDecompBayazit 
{	
	public static function area(a:Point, b:Point, c:Point):Float {
		return (((b.x - a.x)*(c.y - a.y))-((c.x - a.x)*(b.y - a.y)));
	}
	
	public static function right(a:Point, b:Point, c:Point):Bool {
		return area(a, b, c) < 0;
	}

	public static function rightOn(a:Point, b:Point, c:Point):Bool {
		return area(a, b, c) <= 0;
	}
	
	public static function left(a:Point, b:Point, c:Point):Bool {
	    return area(a, b, c) > 0;
	}
	
	public static function leftOn(a:Point, b:Point, c:Point):Bool {
	    return area(a, b, c) >= 0;
	}
	
	public static function sqdist(a:Point, b:Point):Float {
		var dx:Float = b.x - a.x;
		var dy:Float = b.y - a.y;
		return dx * dx + dy * dy;
	}
	
	public static function getIntersection(start1:Point, end1:Point, start2:Point, end2:Point):Point {
		var a1:Float = end1.y - start1.y;
		var b1:Float = start1.x - end1.x;
		var c1:Float = a1 * start1.x + b1 * start1.y;
		var a2:Float = end2.y - start2.y;
		var b2:Float = start2.x - end2.x;
		var c2:Float = a2 * start2.x + b2 * start2.y;
		var det:Float = a1 * b2 - a2*b1;
		
		if (Math.abs(det) > B2Math.MIN_VALUE) { // lines are not parallel
			return new Point((b2 * c1 - b1 * c2) / det,  (a1 * c2 - a2 * c1) / det);
		}
		return null;
	}
	
	public function combineColinearPoints():Void {
		// combine similar points
		var combinedPoints:Array<Point> = [];
		
		for(i in 0...points.length) {
			var a:Point = at(i - 1), b:Point = at(i), c:Point = at(i + 1);
			
			if(getIntersection(a, b, b, c) != null)
				combinedPoints.push(b);
		}
		
		points = combinedPoints;
	}

	public var points:Array<Point>;
	
	public function new(points:Array<Point>) 
	{
		this.points = points;
		
		combineClosePoints();
		combineColinearPoints();
		makeCCW();
	}
	
	public function combineClosePoints():Void {
		var combinedPoints:Array<Point> = [];
		
		for(i in 0...points.length) {
			var a:Point = at(i);
			var b:Point = at(i + 1);

			if(sqdist(a, b) > B2Math.MIN_VALUE)
				combinedPoints.push(a);
		}
		
		points = combinedPoints;
	}
	
	public function at(i:Int):Point {
		var s:Int = points.length;
		return points[(i + s) % s];
	}

	public function isReflex(i:Int):Bool {
	    return right(at(i - 1), at(i), at(i + 1));
	}
	
	public function polyFromRange(lower:Int, upper:Int):PolyDecompBayazit {
		if(lower < upper)
			return new PolyDecompBayazit(points.slice(lower, upper + 1));
		else
			return new PolyDecompBayazit(points.slice(lower).concat(points.slice(0, upper + 1)));
	}
	
	public function decompose(cb:PolyDecompBayazit->Void):Void {
		if(points.length < 3) return;
		
		for(i in 0...points.length) {
			if (isReflex(i)) {
				// Find closest two vertices in range from a reflex point (two the vertices are by going CW and CCW around polygon)
				// See first diagram on this page: http://mnbayazit.com/406/bayazit
				var upperDist:Float = B2Math.MAX_VALUE;
				var upperIntersection:Point = null;
				var upperIndex:Int = 0;
				var lowerDist:Float = B2Math.MAX_VALUE;
				var lowerIntersection:Point = null;
				var lowerIndex:Int = 0;
				
				for(j in 0...points.length) {
					if (left(at(i - 1), at(i), at(j)) && rightOn(at(i - 1), at(i), at(j - 1))) { // if line intersects with an edge
						var intersectionPoint:Point = getIntersection(at(i - 1), at(i), at(j), at(j - 1)); // find the point of intersection
						if (right(at(i + 1), at(i), intersectionPoint)) { // make sure it's inside the poly
							var distance:Float = sqdist(at(i), intersectionPoint);
							if (distance < lowerDist) { // keep only the closest intersection
								lowerDist = distance;
								lowerIntersection = intersectionPoint;
								lowerIndex = j;
							}
						}
					}
					if (left(at(i + 1), at(i), at(j + 1)) && rightOn(at(i + 1), at(i), at(j))) {
						var intersectionPoint = getIntersection(at(i + 1), at(i), at(j), at(j + 1));
						if (left(at(i - 1), at(i), intersectionPoint)) {
							var distance = sqdist(at(i), intersectionPoint);
							if (distance < upperDist) {
								upperDist = distance;
								upperIntersection = intersectionPoint;
								upperIndex = j;
							}
						}
					}
				}
				
				var lowerPoly:PolyDecompBayazit;
				var upperPoly:PolyDecompBayazit;
	
				// if there are no vertices to connect to, choose a point in the middle
				if (lowerIndex == (upperIndex + 1) % points.length) {
					var steinerPoint:Point = new Point(
						(lowerIntersection.x + upperIntersection.x) * 0.5,
						(lowerIntersection.y + upperIntersection.y) * 0.5);
	
					lowerPoly = polyFromRange(i, upperIndex);
					lowerPoly.points.push(steinerPoint);
	
					if (i < upperIndex)
						upperPoly = polyFromRange(lowerIndex, i);
					else
						upperPoly = polyFromRange(0, i);
					upperPoly.points.push(steinerPoint);
				} else {
					// connect to the closest point within the triangle
	
					// at(n) handles mod points.length, so increase upperIndex to make for loop easy
					if (lowerIndex > upperIndex) upperIndex += points.length;
					
					// Find closest point in range
					var closestIndex:Int = 0;
					var closestDist:Float = B2Math.MAX_VALUE;
					var closestVert:Point = null;
					
					var j = lowerIndex;
					
					while (j <= upperIndex) {
						if (leftOn(at(i - 1), at(i), at(j)) && rightOn(at(i + 1), at(i), at(j))) {
							var distance = sqdist(at(i), at(j));
							if (distance < closestDist) {
								closestDist = distance;
								closestVert = at(j);
								closestIndex = j % points.length;
							}
						}
						
						++j;
					}
	
					lowerPoly = polyFromRange(i, closestIndex);
					upperPoly = polyFromRange(closestIndex, i);
				}
	
				// solve smallest poly first
				if (lowerPoly.points.length < upperPoly.points.length) {
					lowerPoly.decompose(cb);
					upperPoly.decompose(cb);
				} else {
					upperPoly.decompose(cb);
					lowerPoly.decompose(cb);
				}
				return;
			}
		}
		
		if(points.length >= 3) cb(this);
	}
	
	public function makeCCW():Void {
		var br:Int = 0;
	
		// find bottom right point
		for(i in 1...points.length) {
			if (at(i).y < at(br).y || (at(i).y == at(br).y && at(i).x > at(br).x)) {
				br = i;
			}
		}
	
		// reverse poly if clockwise
		if (!left(at(br - 1), at(br), at(br + 1))) {
			points.reverse();
		}
	}
}
