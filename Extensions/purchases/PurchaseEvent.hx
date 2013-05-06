package;

import nme.events.Event;

class PurchaseEvent extends Event
{	
	public inline static var UNKNOWN:String = "unknownEvent"; //0 
	public inline static var IN_APP_PURCHASE_SUCCESS:String = "inAppPurchaseSuccess"; //1
	public inline static var IN_APP_PURCHASE_FAIL:String = "inAppPurchaseFail"; //2
	public inline static var IN_APP_PURCHASE_CANCEL:String = "inAppPurchaseCancel"; //3
	
	public var eventID:Int;
	public var code:Int;
	public var value:Int;
	public var data:String;
	
	public function new(type:String, code:Int, value:Int, data:String)
	{
		super(type);
	}
}