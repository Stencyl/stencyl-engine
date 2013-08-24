package com.stencyl.models.collision;

class CollisionInfo 
{ 
	private static var infoArray:Array<CollisionInfo> = new Array<CollisionInfo>();
	public var max:Float;
	public var min:Float;
	
	public var maskA:Mask;
	public var maskB:Mask;
	
	public var solidCollision:Bool;
	
	public function new():Void 
	{
		reset();
	}
	
	public function reset():Void 
	{
		max = min = 0;
		maskA = maskB = null;
		solidCollision = true;
	}	
	
	public static function getCollisionInfo():CollisionInfo
	{
		if (infoArray.length > 0)
		{
			return infoArray.pop();
		}
		
		return new CollisionInfo();
	}
	
	public static function recycle(info:CollisionInfo):Void 
	{
		infoArray.push(info);
	}
}