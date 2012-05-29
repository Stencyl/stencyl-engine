package com.stencyl.models.scene;

import box2D.collision.shapes.B2Shape;
import com.stencyl.utils.Utils;

class TerrainDef
{
	public var x:Float;
	public var y:Float;
	public var shape:B2Shape;
	public var shapes:Array<B2Shape>;
	
	public var ID:Int;
	public var name:String;
	public var groupID:Int;
	public var fillColor:Int;
	
	public function new(shapes:Array<B2Shape>, ID:Int, name:String, x:Float, y:Float, groupID:Int=0, fillColor:Int=0)
	{
		this.x = x;
		this.y = y;
		
		this.shapes = shapes;
		this.shape = this.shapes[0];
		this.ID = ID;
		this.name = name;
		this.groupID = groupID;
		
		if(this.fillColor == 0) 
		{
			this.fillColor = Utils.getColorRGB(0, 0, 0);
		}
		
		this.fillColor = fillColor;
	}
}