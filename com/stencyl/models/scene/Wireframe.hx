package com.stencyl.models.scene;

import box2D.collision.shapes.B2Shape;
import com.stencyl.models.collision.Mask;

class Wireframe
{
	public var x:Float;
	public var y:Float;
	
	public var shape:Dynamic; //Usually an array of B2PolygonShapes
	public var shape2:Mask;
	
	public var width:Float;
	public var height:Float;
	
	public function new(x:Float, y:Float, width:Float, height:Float, shape:Dynamic, shape2:Mask)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.shape = shape;
		this.shape2 = shape2;
	}
}
