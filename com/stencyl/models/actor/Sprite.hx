package com.stencyl.models.actor;

import com.stencyl.models.Resource;
import com.stencyl.utils.SizedIntHash;

class Sprite extends Resource
{
	public var width:Int;
	public var height:Int;
	public var defaultAnimation:Int;
	public var animations:SizedIntHash<Animation>;
	
	public function new(ID:Int, name:String, width:Int, height:Int, defaultAnimation:Int)
	{
		super(ID, name);
		
		this.width = width;
		this.height = height;
		this.defaultAnimation = defaultAnimation;
		
		animations = new SizedIntHash<Animation>();
	}
}