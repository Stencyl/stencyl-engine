package com.stencyl.event;

class StencylEvent 
{
	public var type:Int;
	public var data1:String;
	
	//Purchases
	public static var PURCHASE_READY:Int = 200;
	public static var PURCHASE_SUCCESS:Int = 201;
	public static var PURCHASE_FAIL:Int = 202;
	public static var PURCHASE_RESTORE:Int = 203;
	public static var PURCHASE_CANCEL:Int = 204;
	public static var PURCHASE_PRODUCTS_VERIFIED:Int = 205;
	public static var PURCHASE_PRODUCT_VALIDATED:Int = 206;
	
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
