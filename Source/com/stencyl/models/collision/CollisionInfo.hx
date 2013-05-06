package com.stencyl.models.collision;

class CollisionInfo 
{ 
	public var max:Float;
	public var min:Float;
	
	public var maskA:Mask;
	public var maskB:Mask;
	
	public var solidCollision:Bool;
	
	public function new():Void 
	{
		max = min = 0;
		maskA = maskB = null;
		solidCollision = true;
	}
}