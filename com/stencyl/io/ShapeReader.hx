package com.stencyl.io;

import com.stencyl.models.collision.Hitbox;
import com.stencyl.utils.Utils;

import com.stencyl.io.mbs.shape.*;
import com.stencyl.models.Resource;
import com.stencyl.models.actor.Sprite;
import com.stencyl.models.actor.Animation;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.B2AABB;
import box2D.common.math.B2Transform;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;

import haxe.ds.Vector;

import mbs.io.MbsList;

import openfl.geom.Point;

class ShapeReader
{
	public static inline function readPoint(r:MbsPoint):Point
	{
		return new Point(r.getX(), r.getY());
	}

	public static function readPoints(list:MbsList<MbsPoint>):Vector<Point>
	{
		var points = new Vector<Point>(list.length());
		for(i in 0...list.length())
		{
			points[i] = readPoint(list.getNextObject());
		}
		return points;
	}

	public static function createCircle(radius:Float, x:Float, y:Float, imgWidth:Float=-1, imgHeight:Float=-1):B2CircleShape
	{
		var diameter = radius * 2;
		
		var c = new B2CircleShape();
		c.m_radius = Engine.toPhysicalUnits(radius);
		c.m_p.x = Engine.toPhysicalUnits(x - (imgWidth - diameter)/2);
		c.m_p.y = Engine.toPhysicalUnits(y - (imgHeight - diameter)/2);
		
		return c;
	}

	public static function createPolygon(type:String, points:Array<Point>, imgWidth:Int=0, imgHeight:Int=0):Dynamic
	{
		var x:Float = 0;
		var y:Float = 0;
		var w:Float = 0;
		var h:Float = 0;
		
		var vertices = new Array<B2Vec2>();
		
		var numVertices = points.length;
		var vIndex = 0;
		var i = 1;

		var offsetX = Std.int(-imgWidth / 2);
		var offsetY = Std.int(-imgHeight / 2);
		
		if(type == "MbsPolygon" || type == "MbsPolyRegion")
		{
			//Construct a polygon that's axis-oriented.
			vIndex = 0;
			
			while(vIndex < numVertices)
			{
				var point = points[vIndex];

				var vX:Float = Engine.toPhysicalUnits(point.x + offsetX);
				var vY:Float = Engine.toPhysicalUnits(point.y + offsetY);
				vertices[vIndex] = new B2Vec2(vX, vY);
				
				vIndex++;
			}

			EnsureCorrectVertexDirection(vertices);			

			return B2PolygonShape.asArray(vertices, vertices.length);
		}
		
		else if(type == "MbsWireframe")
		{
			while(vIndex < numVertices)
			{
				var point = points[vIndex];
				vertices.push(new B2Vec2(Engine.toPhysicalUnits(point.x), Engine.toPhysicalUnits(point.y)));
				vIndex++;
			}
			
			w = getWidth(vertices);
			h = getHeight(vertices);
			
			var arr = new Array<Dynamic>();
			
			for(i in 0...vertices.length + 1)
			{
				var edge:B2EdgeShape = new B2EdgeShape(vertices[i%vertices.length], vertices[(i+1)%vertices.length]);
				arr.push(edge);
				
				edge.m_hasVertex0 = true;
				edge.m_hasVertex3 = true;
				
				var v0 = vertices[(i-1)%vertices.length];
				var v3 = vertices[(i+2)%vertices.length];
				
				if(v0 == null)
				{
					v0 = vertices[vertices.length - 1];
				}
				
				if(v3 == null)
				{
					v3 = vertices[0];
				}
				
				edge.m_v0 = v0;
				edge.m_v3 = v3;
			}

			/*for(i in 0...vertices.length + 1)
			{
				//Uncomment this to enable edge shapes
				var edge:B2EdgeShape = new B2EdgeShape(vertices[i%vertices.length], vertices[(i+1)%vertices.length]);
				arr.push(edge);
				
				//Comment this out when enabling edge shapes
				//var poly = B2PolygonShape.asEdge(vertices[i%vertices.length], vertices[(i+1)%vertices.length]);
				//arr.push(poly);
			}*/
			
			var toReturn = new Map<Int,Dynamic>();
			toReturn.set(0, arr);
			toReturn.set(1, w);
			toReturn.set(2, h);

			return toReturn;				
		}
		
		return null;
	}

	/*public static function decomposeShape(params:Array<String>):Array<B2PolygonShape>
	{
		var vlist = new Array<Float>();
		var numVertices = Std.parseFloat(params[0]);
		var vIndex:Int = 0;
		var i:Int = 0;
			
		while(vIndex < numVertices)
		{			
			vlist[i] = Std.parseFloat(params[i+1]);
		    vlist[i + 1] = Std.parseFloat(params[i + 2]);
			vIndex++;
			i += 2;
		}

		return B2PolygonShape.decompose(vlist);
	}*/

	/// Check the orientation of vertices. If they are in the wrong direction, flip them. Returns true if the vertecies need to be flipped.
	public static function CheckVertexDirection(v:Array<B2Vec2>):Bool 
	{
		if(v.length > 2) 
		{
			var wind:Float = 0;
			var i:Int = 0;
			
			while(wind == 0 && i < (v.length - 2)) 
			{
				wind = v[i].winding(v[i + 1], v[i + 2]);
				++i;
			}
			
			if(wind < 0) 
			{
				return false;
			}
		}
		
		return true;
	}

	/// If the vertices are in the wrong direction, flips them. Returns true if they were ok to start with, false if they were flipped.
	public static function EnsureCorrectVertexDirection(v:Array<B2Vec2>):Bool 
	{
		if(!CheckVertexDirection(v))
		{
			ReverseVertices(v);
			return false;
		}
		
		return true;
	}

	/// Reverses the direction of a V2 vector.
	public static function ReverseVertices(v:Array<B2Vec2>) 
	{
		var low:Int = 0;
		var high:Int = v.length - 1;
		var tmp:Float;
		
		while(high > low) 
		{
			tmp = v[low].x;
			v[low].x = v[high].x;
			v[high].x = tmp;
			tmp = v[low].y;
			v[low].y = v[high].y;
			v[high].y = tmp;
			++low;
			--high;
		}			
	}
		
	public static function getWidth(vertices:Array<B2Vec2>):Float
	{
		var minX:Float = 10000000;
		var maxX:Float = 0;
		
		for(v in vertices)
		{
			minX = Math.min(minX, v.x);
			maxX = Math.max(maxX, v.x);
		}
		
		return maxX - minX;
	}

	public static function getHeight(vertices:Array<B2Vec2>):Float
	{
		var minY:Float = 10000000;
		var maxY:Float = 0;
		
		for(v in vertices)
		{
			minY = Math.min(minY, v.y);
			maxY = Math.max(maxY, v.y);
		}
		
		return maxY - minY;
	}
}