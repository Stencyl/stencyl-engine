package com.stencyl.event;

class StencylEvent 
{
	public var type:Int;
	public var data1:String;
	
	//Other
	public static var KEYBOARD_EVENT = 400;
	public static var KEYBOARD_DONE = 401;
	public static var KEYBOARD_SHOW = 402;
	public static var KEYBOARD_HIDE = 403;
	
	public function new(type:Int, data1:String = "") 
	{		
		this.type = type;
		this.data1 = data1;
	}		
}
