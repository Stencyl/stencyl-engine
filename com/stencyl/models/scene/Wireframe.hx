package com.stencyl.models.scene;

import box2D.collision.shapes.B2Shape;
import com.stencyl.models.collision.Mask;

class Wireframe
{
	public var x:Float;
	public var y:Float;
	
	public var shape:B2Shape;
	public var shape2:Mask;
	
	public var width:Float;
	public var height:Float;
	
	public function new(x:Float, y:Float, width:Float, height:Float, shape:B2Shape, shape2:Mask)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.shape = shape;
		this.shape2 = shape2;
	}
}
