package com.stencyl.models.scene;

import box2D.collision.shapes.B2Shape;
import openfl.geom.Rectangle;

class RegionDef
{
	public var x:Float;
	public var y:Float;
	public var shape:B2Shape;
	public var shapes:Array<B2Shape>;
	
	public var ID:Int;
	public var name:String;
	public var shapeID:Int;
	public var simpleBounds:Rectangle;
	
	public function new(shapes:Array<B2Shape>, ID:Int, name:String, x:Float, y:Float, shapeID:Int=0, simpleBounds:Rectangle = null)
	{
		this.x = x;
		this.y = y;
		
		this.shapes = shapes;
		this.shape = this.shapes[0];
		this.ID = ID;
		this.name = name;
		this.shapeID = shapeID;
		this.simpleBounds = simpleBounds;
	}
}