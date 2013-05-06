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

import box2D.collision.B2ContactID;
import box2D.collision.B2Manifold;
import box2D.collision.B2ManifoldPoint;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Math;
import box2D.common.math.B2Mat22;
import box2D.common.B2Settings;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;

class B2PolyAndEdgeContact extends B2Contact
{
	static var m_xf:B2Transform = new B2Transform();
	static var temp:B2Vec2 = new B2Vec2();
	static var m_centroidB:B2Vec2 = new B2Vec2();
	static var m_lowerLimit:B2Vec2 = new B2Vec2();
	static var m_upperLimit:B2Vec2 = new B2Vec2();
	static var m_polygonB:TempPolygon = new TempPolygon();
	static var edgeAxis:EPAxis = new EPAxis();
	static var polygonAxis:EPAxis = new EPAxis();
	static var perp:B2Vec2 = new B2Vec2();
	static var n:B2Vec2 = new B2Vec2();
	static var rf:ReferenceFace = new ReferenceFace();
	
	static var mat:B2Mat22 = new B2Mat22();
	static var temp1:B2Vec2 = new B2Vec2();
	static var temp2:B2Vec2 = new B2Vec2();
	
	static var ie:Array<ClipVertex> = [new ClipVertex(), new ClipVertex()];
	static var clipPoints1:Array<ClipVertex> = [new ClipVertex(), new ClipVertex()];
	static var clipPoints2:Array<ClipVertex> = [new ClipVertex(), new ClipVertex()];

	var m_v0:B2Vec2;
    var m_v1:B2Vec2;
    var m_v2:B2Vec2;
    var m_v3:B2Vec2;
    
    static var edge0:B2Vec2 = new B2Vec2();
    static var edge1:B2Vec2 = new B2Vec2();
    static var edge2:B2Vec2 = new B2Vec2();
    
    static var m_normal:B2Vec2 = new B2Vec2();
    static var m_normal0:B2Vec2 = new B2Vec2();
    static var m_normal1:B2Vec2 = new B2Vec2();
    static var m_normal2:B2Vec2 = new B2Vec2();   
    
    var m_front:Bool;
    var m_radius:Float;
    
	static public function create(allocator:Dynamic):B2Contact
	{
		return new B2PolyAndEdgeContact();
	}
	
	static public function destroy(contact:B2Contact, allocator:Dynamic):Void
	{
	}

	public override function reset(fixtureA:B2Fixture = null, fixtureB:B2Fixture = null):Void
	{
		//Has to be in reverse
		if (Std.is(fixtureA.getShape(), B2PolygonShape))
		{
			super.reset(fixtureB, fixtureA);
			
			B2Settings.b2Assert(fixtureA.getType() == B2Shape.e_polygonShape);
			B2Settings.b2Assert(fixtureB.getType() == B2Shape.e_edgeShape);	
		}
		
		else
		{
			super.reset(fixtureA, fixtureB);
			
			B2Settings.b2Assert(fixtureA.getType() == B2Shape.e_edgeShape);
			B2Settings.b2Assert(fixtureB.getType() == B2Shape.e_polygonShape);			
		}			
	}

	public override function evaluate():Void
	{
		var bA:B2Body = m_fixtureA.getBody();
		var bB:B2Body = m_fixtureB.getBody();
		
		b2CollidePolyAndEdge(m_manifold,
					cast(m_fixtureA.getShape(), B2EdgeShape), bA.m_xf,
					cast(m_fixtureB.getShape(), B2PolygonShape), bB.m_xf);
	}
	
	private function b2CollidePolyAndEdge(manifold:B2Manifold,
										  edgeA:B2EdgeShape, 
	                                      xfA:B2Transform,
	                                      polygonB:B2PolygonShape, 
	                                      xfB:B2Transform
	                                      ):Void
	{
		//m_xf = b2MulT(xfA, xfB);
        //m_centroidB = b2Mul(m_xf, polygonB->m_centroid);
        
		multiplyTransformsInverse(xfA, xfB, m_xf);
        multiplyTransformVector(m_xf, polygonB.m_centroid, temp);
		m_centroidB.setV(temp);
	
		m_v0 = edgeA.m_v0;
		m_v1 = edgeA.m_v1;
		m_v2 = edgeA.m_v2;
		m_v3 = edgeA.m_v3;
		
		//boolean hasVertex0 = edgeA.m_hasVertex0;
        //boolean hasVertex3 = edgeA.m_hasVertex3;
        
        var hasVertex0 = edgeA.m_hasVertex0;
        var hasVertex3 = edgeA.m_hasVertex3;
        
        //edge1.set(m_v2).subLocal(m_v1);
        //edge1.normalize();
        //m_normal1.set(edge1.y, -edge1.x);
        
        edge1.setV(m_v2);
        edge1.subtract(m_v1);
        edge1.normalize();
        m_normal1.set(edge1.y, -edge1.x);
        
        //float offset1 = Vec2.dot(m_normal1, temp.set(m_centroidB).subLocal(m_v1));
        //float offset0 = 0.0f, offset2 = 0.0f;
        //boolean convex1 = false, convex2 = false;
        
        temp.setV(m_centroidB);
        temp.subtract(m_v1);
        
        var offset1 = B2Math.dot(m_normal1, temp);
        var offset0:Float = 0.0;
        var offset2:Float = 0.0;
        var convex1 = false;
        var convex2 = false;
        
        //-----------------------------
        
        /*
          //Is there a preceding edge?
		  if(hasVertex0) 
		  {
			edge0.set(m_v1).subLocal(m_v0);
			edge0.normalize();
			m_normal0.set(edge0.y, -edge0.x);
			convex1 = Vec2.cross(edge0, edge1) >= 0.0f;
			offset0 = Vec2.dot(m_normal0, temp.set(m_centroidB).subLocal(m_v0));
		  }
        */
        
        //Is there a preceding edge?
		if(hasVertex0) 
		{
			edge0.setV(m_v1);
			edge0.subtract(m_v0);
			edge0.normalize();
			
			m_normal0.set(edge0.y, -edge0.x);
			convex1 = B2Math.crossVV(edge0, edge1) >= 0.0;
			
			temp.setV(m_centroidB);
			temp.subtract(m_v0);
			offset0 = B2Math.dot(m_normal0, temp);
		}
		
		/*
		//Is there a following edge?
      	if(hasVertex3) 
      	{
        	edge2.set(m_v3).subLocal(m_v2);
        	edge2.normalize();
        	m_normal2.set(edge2.y, -edge2.x);
        	convex2 = Vec2.cross(edge1, edge2) > 0.0f;
        	offset2 = Vec2.dot(m_normal2, temp.set(m_centroidB).subLocal(m_v2));
      	}
		*/
		
		//Is there a following edge?
      	if(hasVertex3) 
      	{
        	edge2.setV(m_v3);
        	edge2.subtract(m_v2);
        	edge2.normalize();
        	
        	m_normal2.set(edge2.y, -edge2.x);
        	convex2 = B2Math.crossVV(edge1, edge2) > 0.0;
        	
        	temp.setV(m_centroidB);
        	temp.subtract(m_v2);
        	offset2 = B2Math.dot(m_normal2, temp);
      	}
      	
      	//-----------------------------
      	
      	//Determine front or back collision. Determine collision normal limits.
      	if(hasVertex0 && hasVertex3) 
      	{
        	if(convex1 && convex2) 
        	{
          		m_front = offset0 >= 0.0 || offset1 >= 0.0 || offset2 >= 0.0;
          		
          		if(m_front) 
          		{
            		m_normal.setV(m_normal1);
            		m_lowerLimit.setV(m_normal0);
            		m_upperLimit.setV(m_normal2);
          		} 
          		
          		else 
          		{
            		m_normal.setV(m_normal1);
            		m_normal.negativeSelf();
            		m_lowerLimit.setV(m_normal1);
            		m_lowerLimit.negativeSelf();
            		m_upperLimit.setV(m_normal1);
            		m_upperLimit.negativeSelf();
          		}
        	} 
        	
        	else if(convex1) 
        	{
          		m_front = offset0 >= 0.0 || (offset1 >= 0.0 && offset2 >= 0.0);
          		
          		if(m_front) 
          		{
            		m_normal.setV(m_normal1);
            		m_lowerLimit.setV(m_normal0);
            		m_upperLimit.setV(m_normal1);
          		} 
          		
          		else 
          		{
            		m_normal.setV(m_normal1);
            		m_normal.negativeSelf();
            		m_lowerLimit.setV(m_normal2);
            		m_lowerLimit.negativeSelf();
            		m_upperLimit.setV(m_normal1);
            		m_upperLimit.negativeSelf();
          		}
        	} 
        	
        	else if(convex2) 
        	{
         	 	m_front = offset2 >= 0.0 || (offset0 >= 0.0 && offset1 >= 0.0);
         
         		if(m_front) 
         		{
            		m_normal.setV(m_normal1);
            		m_lowerLimit.setV(m_normal1);
            		m_upperLimit.setV(m_normal2);
          		} 
          		
          		else 
          		{
            		m_normal.setV(m_normal1);
            		m_normal.negativeSelf();
            		m_lowerLimit.setV(m_normal1);
            		m_lowerLimit.negativeSelf();
            		m_upperLimit.setV(m_normal0);
            		m_upperLimit.negativeSelf();
          		}
        	}
        	
        	else 
        	{
          		m_front = offset0 >= 0.0 && offset1 >= 0.0 && offset2 >= 0.0;
          		
          		if(m_front) 
          		{
            		m_normal.setV(m_normal1);
            		m_lowerLimit.setV(m_normal1);
            		m_upperLimit.setV(m_normal1);
          		} 
          		
          		else 
          		{
            		m_normal.setV(m_normal1);
            		m_normal.negativeSelf();
            		m_lowerLimit.setV(m_normal2);
            		m_lowerLimit.negativeSelf();
            		m_upperLimit.setV(m_normal0);
            		m_upperLimit.negativeSelf();
          		}
        	}
      	} 
      
      	else if(hasVertex0) 
      	{
     		if(convex1) 
        	{
        		m_front = offset0 >= 0.0 || offset1 >= 0.0;
          
          		if(m_front) 
          		{
            		m_normal.setV(m_normal1);
           			m_lowerLimit.setV(m_normal0);
            		m_upperLimit.setV(m_normal1);
            		m_upperLimit.negativeSelf();
          		} 
          
          		else
          		{
            		m_normal.setV(m_normal1);
            		m_normal.negativeSelf();
            		m_lowerLimit.setV(m_normal1);
            		m_upperLimit.setV(m_normal1);
            		m_upperLimit.negativeSelf();
          		}
        	} 
        	
        	else 
        	{
          		m_front = offset0 >= 0.0 && offset1 >= 0.0;
          		
				if(m_front) 
				{
					m_normal.setV(m_normal1);
					m_lowerLimit.setV(m_normal1);
					m_upperLimit.setV(m_normal1);
					m_upperLimit.negativeSelf();
				} 
				
				else 
				{
					m_normal.setV(m_normal1);
					m_normal.negativeSelf();
					m_lowerLimit.setV(m_normal1);
					m_upperLimit.setV(m_normal0);
					m_upperLimit.negativeSelf();
				}
        	}
     	} 
     	
     	else if(hasVertex3) 
     	{
        	if(convex2) 
        	{
        		m_front = offset1 >= 0.0 || offset2 >= 0.0;
        		
				if(m_front) 
				{
					m_normal.setV(m_normal1);
					m_lowerLimit.setV(m_normal1);
					m_lowerLimit.negativeSelf();
					m_upperLimit.setV(m_normal2);
			 	 } 
			  
			  	else 
			  	{
					m_normal.setV(m_normal1);
					m_normal.negativeSelf();
					m_lowerLimit.setV(m_normal1);
					m_lowerLimit.negativeSelf();
					m_upperLimit.setV(m_normal1);
			  	}
        	}
        	
        	else 
        	{
          		m_front = offset1 >= 0.0 && offset2 >= 0.0;
          		
          		if(m_front) 
          		{
            		m_normal.setV(m_normal1);
            		m_lowerLimit.setV(m_normal1);
            		m_lowerLimit.negativeSelf();
            		m_upperLimit.setV(m_normal1);
          		} 
          		
          		else 
          		{
            		m_normal.setV(m_normal1);
            		m_normal.negativeSelf();
            		m_lowerLimit.setV(m_normal2);
            		m_lowerLimit.negativeSelf();
            		m_upperLimit.setV(m_normal1);
          		}
        	}
      	} 
      
      	else 
      	{
        	m_front = offset1 >= 0.0;
        	
        	if(m_front) 
        	{
          		m_normal.setV(m_normal1);
          		m_lowerLimit.setV(m_normal1);
          		m_lowerLimit.negativeSelf();
          		m_upperLimit.setV(m_normal1);
          		m_upperLimit.negativeSelf();
        	} 
        	
        	else 
        	{
          		m_normal.setV(m_normal1);
          		m_normal.negativeSelf();
          		m_lowerLimit.setV(m_normal1);
         		m_upperLimit.setV(m_normal1);
        	}
      	}
      	
      	//-----------------------------
      	
      	//Get polygonB in frameA
      	m_polygonB.count = polygonB.m_vertexCount;
      	
      	for(i in 0...polygonB.m_vertexCount)
      	{
       		multiplyTransformVector(m_xf, polygonB.m_vertices[i], temp);
       		m_polygonB.vertices[i].setV(temp);
   
       		multiplyRotationVector(m_xf.R, polygonB.m_normals[i], temp);
       		m_polygonB.normals[i].setV(temp);
    	}

    	//-----------------------------
    	
    	m_radius = 2.0 * B2Settings.b2_polygonRadius;

      	manifold.m_pointCount = 0;

		computeEdgeSeparation(edgeAxis);

      	//If no valid normal can be found than this edge should not collide.
      	if(edgeAxis.type == Type.UNKNOWN) 
      	{
        	return;
      	}

      	if(edgeAxis.separation > m_radius) 
      	{
        	return;
      	}

		computePolygonSeparation(polygonAxis);
      	
      	if(polygonAxis.type != Type.UNKNOWN && polygonAxis.separation > m_radius) 
      	{
      		//trace("polysep: " + polygonAxis.separation + " is > " + m_radius);
        	return;
     	}
    	
    	//-----------------------------
    	
    	//Use hysteresis for jitter reduction.
      	var k_relativeTol = 0.98;
      	var k_absoluteTol = 0.001;

      	var primaryAxis:EPAxis;
      	
      	if(polygonAxis.type == Type.UNKNOWN) 
      	{
        	primaryAxis = edgeAxis;
      	}
      	
      	else if(polygonAxis.separation > k_relativeTol * edgeAxis.separation + k_absoluteTol) 
      	{
        	primaryAxis = polygonAxis;
      	}
      	
      	else 
      	{
        	primaryAxis = edgeAxis;
      	}
    	
    	//-----------------------------
    	
    	//ClipVertex[] ie = new ClipVertex[2];
    	
      	if(primaryAxis.type == Type.EDGE_A) 
      	{
			manifold.m_type = B2Manifold.e_faceA;
	
			//Search for the polygon normal that is most anti-parallel to the edge normal.
			var bestIndex:Int = 0;
			var bestValue:Float = B2Math.dot(m_normal, m_polygonB.normals[0]);
			
			for(i in 1...m_polygonB.count) 
			{
				var value:Float = B2Math.dot(m_normal, m_polygonB.normals[i]);
			  	
			  	if(value < bestValue) 
			  	{
					bestValue = value;
					bestIndex = i;
			  	}
			}
	
			var i1:Int = bestIndex;
			var i2:Int = i1 + 1 < m_polygonB.count ? i1 + 1 : 0;
	
			ie[0].v.setV(m_polygonB.vertices[i1]);
			ie[0].id.indexA = 0;
			ie[0].id.indexB = i1;
			ie[0].id.typeA = B2ContactID.FACE;
			ie[0].id.typeB = B2ContactID.VERTEX;
	
			ie[1].v.setV(m_polygonB.vertices[i2]);
			ie[1].id.indexA = 0;
			ie[1].id.indexB = i2;
			ie[1].id.typeA = B2ContactID.FACE;
			ie[1].id.typeB = B2ContactID.VERTEX;
	
			if(m_front) 
			{
			  	rf.i1 = 0;
			  	rf.i2 = 1;
			  	rf.v1.setV(m_v1);
			  	rf.v2.setV(m_v2);
			  	rf.normal.setV(m_normal1);
			} 
			
			else 
			{
			  	rf.i1 = 1;
			  	rf.i2 = 0;
			  	rf.v1.setV(m_v2);
			  	rf.v2.setV(m_v1);
			  	rf.normal.setV(m_normal1);
			  	rf.normal.negativeSelf();
			}
      	} 
      	
      	else 
      	{
			manifold.m_type = B2Manifold.e_faceB;
	
			ie[0].v.setV(m_v1);
			ie[0].id.indexA = 0;
			ie[0].id.indexB = primaryAxis.index;
			ie[0].id.typeA = B2ContactID.VERTEX;
			ie[0].id.typeB = B2ContactID.FACE;
	
			ie[1].v.setV(m_v2);
			ie[1].id.indexA = 0;
			ie[1].id.indexB = primaryAxis.index;
			ie[1].id.typeA = B2ContactID.VERTEX;
			ie[1].id.typeB = B2ContactID.FACE;
	
			rf.i1 = primaryAxis.index;
			rf.i2 = rf.i1 + 1 < m_polygonB.count ? rf.i1 + 1 : 0;
			rf.v1.setV(m_polygonB.vertices[rf.i1]);
			rf.v2.setV(m_polygonB.vertices[rf.i2]);
			rf.normal.setV(m_polygonB.normals[rf.i1]);
      	}
    	
    	//-----------------------------
    	
    	rf.sideNormal1.set(rf.normal.y, -rf.normal.x);
      	rf.sideNormal2.setV(rf.sideNormal1);
      	rf.sideNormal2.negativeSelf();
      	rf.sideOffset1 = B2Math.dot(rf.sideNormal1, rf.v1);
      	rf.sideOffset2 = B2Math.dot(rf.sideNormal2, rf.v2);

      	//Clip incident edge against extruded edge1 side edges.
      	var np:Int;

      	//Clip to box side 1
      	np = clipSegmentToLine(clipPoints1, ie, rf.sideNormal1, rf.sideOffset1, rf.i1);

      	if(np < B2Settings.b2_maxManifoldPoints) 
      	{
        	return;
      	}

      	//Clip to negative box side 1
      	np = clipSegmentToLine(clipPoints2, clipPoints1, rf.sideNormal2, rf.sideOffset2, rf.i2);

      	if(np < B2Settings.b2_maxManifoldPoints) 
      	{
        	return;
      	}

      	//Now clipPoints2 contains the clipped points.
      	if(primaryAxis.type == Type.EDGE_A) 
      	{
        	manifold.m_localPlaneNormal.setV(rf.normal);
        	manifold.m_localPoint.setV(rf.v1);
      	} 
      	
      	else 
      	{
        	manifold.m_localPlaneNormal.setV(polygonB.m_normals[rf.i1]);
        	manifold.m_localPoint.setV(polygonB.m_vertices[rf.i1]);
      	}
    	
    	//-----------------------------
    	
    	var pointCount:Int = 0;
    	
      	for(i in 0...B2Settings.b2_maxManifoldPoints)
      	{
      		temp.setV(clipPoints2[i].v);
      		temp.subtract(rf.v1);
      		
        	var separation:Float = B2Math.dot(rf.normal, temp);

        	if(separation <= m_radius)
        	{
          		var cp:B2ManifoldPoint = manifold.m_points[pointCount];

          		if(primaryAxis.type == Type.EDGE_A) 
          		{
            		cp.m_localPoint.setV(B2Math.mulXT(m_xf, clipPoints2[i].v));
            		cp.m_id.set(clipPoints2[i].id);
          		} 
          	
          		else 
          		{
            		cp.m_localPoint.setV(clipPoints2[i].v);
            		cp.m_id.typeA = clipPoints2[i].id.typeB;
            		cp.m_id.typeB = clipPoints2[i].id.typeA;
            		cp.m_id.indexA = clipPoints2[i].id.indexB;
            		cp.m_id.indexB = clipPoints2[i].id.indexA;
          		}

          		pointCount++;
        	}
      	}

    	manifold.m_pointCount = pointCount;
	}
	
	public function computeEdgeSeparation(axis:EPAxis):Void
	{
		axis.type = Type.EDGE_A;
		axis.index = m_front ? 0 : 1;
		axis.separation = B2Math.MAX_VALUE;
	
		for(i in 0...m_polygonB.count) 
		{
			temp.setV(m_polygonB.vertices[i]);
			temp.subtract(m_v1);
		
			var s:Float = B2Math.dot(m_normal, temp);
			
			if(s < axis.separation) 
			{
				axis.separation = s;
			}
		}
	}
	
	public function computePolygonSeparation(axis:EPAxis):Void
	{
    	axis.type = Type.UNKNOWN;
      	axis.index = -1;
      	axis.separation = -B2Math.MAX_VALUE;

      	perp.set(-m_normal.y, m_normal.x);

      	for(i in 0...m_polygonB.count) 
      	{
        	n.setV(m_polygonB.normals[i]);
        	n.negativeSelf();

			temp.setV(m_polygonB.vertices[i]);
			temp.subtract(m_v1);
        	var s1:Float = B2Math.dot(n, temp);
        	
        	temp.setV(m_polygonB.vertices[i]);
        	temp.subtract(m_v2);
        	var s2:Float = B2Math.dot(n, temp);
        	
        	var s:Float = Math.min(s1, s2);

        	if(s > m_radius) 
        	{
          		//No collision
          		axis.type = Type.EDGE_B;
          		axis.index = i;
          		axis.separation = s;
          		
          		//TODO: Print out values of vertices / normals to make sure they're sane.
          		//trace("#" + i);
          		//trace("No collision: " + s + " > " + m_radius);
          		//trace("pt: " + m_polygonB.vertices[i].x + " , " + m_polygonB.vertices[i].y);
          		//trace("sep: " + s1 + " , " + s2);
          		
          		return;
        	}

        	//Adjacency
        	if(B2Math.dot(n, perp) >= 0.0) 
        	{
        		temp.setV(n);
        		temp.subtract(m_upperLimit);
        	
          		if(B2Math.dot(temp, m_normal) < -B2Settings.b2_angularSlop) 
          		{
            		continue;
          		}
        	} 
        	
        	else 
        	{
        		temp.setV(n);
        		temp.subtract(m_lowerLimit);
        	
          		if(B2Math.dot(temp, m_normal) < -B2Settings.b2_angularSlop)
          		{
            		continue;
          		}
        	}

        	if(s > axis.separation) 
        	{
          		axis.type = Type.EDGE_B;
          		axis.index = i;
          		axis.separation = s;
        	}
      	}
    }
    
    public static function clipSegmentToLine
    (
    	vOut:Array<ClipVertex>, 
    	vIn:Array<ClipVertex>,
    	normal:B2Vec2, 
    	offset:Float, 
    	vertexIndexA:Int
    ):Int
    {
    	//Start with no output points
   		var numOut:Int = 0;

    	//Calculate the distance of end points to the line
    	var distance0:Float = B2Math.dot(normal, vIn[0].v) - offset;
    	var distance1:Float = B2Math.dot(normal, vIn[1].v) - offset;

    	//If the points are behind the plane
    	if(distance0 <= 0.0) 
    	{
     		vOut[numOut++].set(vIn[0]);
    	}
    	
    	if(distance1 <= 0.0) 
    	{
      		vOut[numOut++].set(vIn[1]);
    	}

    	//If the points are on different sides of the plane
    	if(distance0 * distance1 < 0.0) 
    	{
      		//Find intersection point of edge and plane
      		var interp:Float = distance0 / (distance0 - distance1);
      		
      		//vOut[numOut].v = vIn[0].v + interp * (vIn[1].v - vIn[0].v);
      		vOut[numOut].v.setV(vIn[1].v);
      		vOut[numOut].v.subtract(vIn[0].v);
      		vOut[numOut].v.multiply(interp);
			vOut[numOut].v.add(vIn[0].v);

      		//VertexA is hitting edgeB.
      		vOut[numOut].id.indexA = vertexIndexA;
      		vOut[numOut].id.indexB = vIn[0].id.indexB;
      		vOut[numOut].id.typeA = B2ContactID.VERTEX;
      		vOut[numOut].id.typeB = B2ContactID.FACE;
      		
      		numOut++;
    	}

    	return numOut;
  	}
  	
  	public function multiplyTransformsInverse(A:B2Transform, B:B2Transform, out:B2Transform):Void
	{
        //b2MulT(A.q, B.q); Rotation * Rotation
        multiplyRotationsInverse(A.R, B.R, mat);
        
        //b2MulT(A.q, B.p - A.p); Rotation * Vector        
        temp2.setV(B.position);
        temp2.subtract(A.position);
        multiplyRotationVectorInverse(A.R, temp2, out.position);
		
        out.R.col1.setV(mat.col1);
		out.R.col2.setV(mat.col2);
	}
	
	public function multiplyRotationsInverse(q:B2Mat22, r:B2Mat22, out:B2Mat22)
	{		
		out.col1.x = q.col1.x * r.col1.x + q.col1.y * r.col1.y;
		out.col1.y = q.col2.x * r.col1.x + q.col2.y * r.col1.y;
		out.col2.x = q.col1.x * r.col2.x + q.col1.y * r.col2.y;
		out.col2.y = q.col2.x * r.col2.x + q.col2.y * r.col2.y;
	}
	
	private function multiplyRotationVector(q:B2Mat22, v:B2Vec2, out:B2Vec2):Void
	{
		out.x = q.col1.x * v.x + q.col2.x * v.y;
		out.y = q.col1.y * v.x + q.col2.y * v.y;
	}
	
	private function multiplyRotationVectorInverse(q:B2Mat22, v:B2Vec2, out:B2Vec2):Void
	{		
		out.x = q.col1.x * v.x + q.col1.y * v.y;
		out.y = q.col2.x * v.x + q.col2.y * v.y;
	}
	
	private function multiplyTransformVector(T:B2Transform, v:B2Vec2, out:B2Vec2):Void
	{
		out.x = (T.R.col1.x * v.x + T.R.col2.x * v.y) + T.position.x;
		out.y = (T.R.col1.y * v.x + T.R.col2.y * v.y) + T.position.y;
	}
}

class TempPolygon 
{
	public var vertices:Array<B2Vec2>;
	public var normals:Array<B2Vec2>;
	public var count:Int;

	public function new() 
	{
		vertices = new Array<B2Vec2>();
		normals = new Array<B2Vec2>();
	
		for(i in 0...32)
		{
			vertices.push(new B2Vec2());
			normals.push(new B2Vec2());
		}
	}
}

enum Type 
{
    UNKNOWN;
    EDGE_A;
    EDGE_B;
}

class EPAxis
{
    public var type:Type;
    public var index:Int;
    public var separation:Float;
    
    public function new()
    {
    }
}

class ClipVertex
{
	public var v:B2Vec2;
	public var id:B2ContactID;
	
	public function new()
	{
		v = new B2Vec2();
		id = new B2ContactID();
	}
	
	public function set(cv:ClipVertex)
	{
		v.setV(cv.v);
		id.set(cv.id);
	}
}

class ReferenceFace
{
	public var i1:Int;
	public var i2:Int;
	
	public var v1:B2Vec2;
	public var v2:B2Vec2;
	public var normal:B2Vec2;
	public var sideNormal1:B2Vec2;
	public var sideNormal2:B2Vec2;
	
	public var sideOffset1:Float;
	public var sideOffset2:Float;
	
	public function new()
	{
		v1 = new B2Vec2();
		v2 = new B2Vec2();
		normal = new B2Vec2();
		sideNormal1 = new B2Vec2();
		sideNormal2 = new B2Vec2();
	}
}