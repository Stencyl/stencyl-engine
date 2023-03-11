package com.stencyl.event;

class StencylEvent 
{
	public var type:Int;
	public var data1:String;
	
	public function new(type:Int, data1:String = "") 
	{		
		this.type = type;
		this.data1 = data1;
	}		
}
