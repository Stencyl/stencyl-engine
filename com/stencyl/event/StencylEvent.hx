package com.stencyl.event;

class StencylEvent 
{
	public var type:Int;
	public var data1:String;
	
	//Ads
	public static var AD_USER_OPEN:Int = 100;
	public static var AD_USER_CLOSE:Int = 101;
	public static var AD_LOADED:Int = 102;
	public static var AD_FAILED:Int = 103;
	
	//Purchases
	public static var PURCHASE_READY:Int = 200;
	public static var PURCHASE_SUCCESS:Int = 201;
	public static var PURCHASE_FAIL:Int = 202;
	public static var PURCHASE_RESTORE:Int = 203;
	public static var PURCHASE_CANCEL:Int = 204;
	
	//Game Center
	public static var GAME_CENTER_READY:Int = 300;
	public static var GAME_CENTER_SCORE:Int = 301;
	public static var GAME_CENTER_ACHIEVEMENT:Int = 302;
	public static var GAME_CENTER_ACHIEVEMENT_RESET:Int = 303;
	
	public static var GAME_CENTER_READY_FAIL:Int = 304;
	public static var GAME_CENTER_SCORE_FAIL:Int = 305;
	public static var GAME_CENTER_ACHIEVEMENT_FAIL:Int = 306;
	public static var GAME_CENTER_ACHIEVEMENT_RESET_FAIL:Int = 307;
	
	//Open Feint
	
	public function new(type:Int, data1:String = "") 
	{		
		this.type = type;
		this.data1 = data1;
	}		
}
