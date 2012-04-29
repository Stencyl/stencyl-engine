package models.actor;

import models.Resource;

class Sprite extends Resource
{
	public var width:Int;
	public var height:Int;
	public var defaultAnimation:Int;
	public var animations:Array<Animation>;
	
	public function new(ID:Int, name:String, width:Int, height:Int, defaultAnimation:Int)
	{
		super(ID, name);
		
		this.width = width;
		this.height = height;
		this.defaultAnimation = defaultAnimation;
		
		animations = new Array<Animation>();
	}
}