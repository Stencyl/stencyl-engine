package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#else
import nme.Lib;
#end

#if !js
import nme.net.SharedObject;
import nme.net.SharedObjectFlushStatus;
#end

import com.stencyl.Engine;
import com.stencyl.event.EventMaster;
import com.stencyl.event.StencylEvent;

import nme.events.EventDispatcher;
import nme.events.Event;

class Purchases
{	
	//Used for Android callbacks from Java
	public function new()
	{
	}
	
	public function onStarted()
	{
		trace("Purchases: Started");
		Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_READY, ""));
	}
	
	public function onPurchase(productID:String)
	{
		trace("Purchases: Successful Purchase");
		Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_SUCCESS, productID));
		
		if(hasBought(productID))
		{
			items.set(productID, Purchases.items.get(productID) + 1);
		}
			
		else
		{
			items.set(productID, 1);
		}
		
		save();
	}
	
	public function onFailedPurchase(productID:String)
	{
		trace("Purchases: Failed Purchase");
		Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_FAIL, productID));
	}
	
	public function onCanceledPurchase(productID:String)
	{
		trace("Purchases: Canceled Purchase");
		Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_CANCEL, productID));
	}
	
	public function onRestorePurchases()
	{
		trace("Purchases: Restored Purchase");
		Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_RESTORE, ""));
	}

	public function onProductsVerified()
	{
		trace("Purchases: Products Verified");
		Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_PRODUCTS_VERIFIED, ""));
	}
		
	//---------------------------------------------

	private static var initialized:Bool = false;
	private static var items:Hash<Int> = new Hash<Int>();

	private static function registerHandle()
	{
		#if(cpp && mobile && !android)
		set_event_handle(notifyListeners);
		#end
	}
	
	private static function notifyListeners(inEvent:Dynamic)
	{
		#if(cpp && mobile && !android)
		var type:String = Std.string(Reflect.field(inEvent, "type"));
		var data:String = Std.string(Reflect.field(inEvent, "data"));
		
		if(type == "started")
		{
			trace("Purchases: Started");
			Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_READY, data));
		}
		
		else if(type == "success")
		{
			trace("Purchases: Successful Purchase");
			Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_SUCCESS, data));
		}
		
		else if(type == "failed")
		{
			trace("Purchases: Failed Purchase");
			Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_FAIL, data));
		}
		
		else if(type == "cancel")
		{
			trace("Purchases: Canceled Purchase");
			Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_CANCEL, data));
		}
		
		else if(type == "restore")
		{
			trace("Purchases: Restored Purchase");
			Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_RESTORE, data));
		}

		else if(type == "productsVerified")
		{
			trace("Purchases: Products Verified");
			Engine.events.addPurchaseEvent(new StencylEvent(StencylEvent.PURCHASE_PRODUCTS_VERIFIED, data));
		}

		//Consumable
		if(type == "success")
		{
			var productID = data;
			
			if(hasBought(productID))
			{
				items.set(productID, Purchases.items.get(productID) + 1);
			}
			
			else
			{
				items.set(productID, 1);
			}
		
			save();
		}
		#end
	}
	
	public static function initialize(publicKey:String = ""):Void 
	{
		#if(cpp && mobile && !android)
		if(!initialized)
		{
			set_event_handle(notifyListeners);
			load();
			
			initialized = true;
		}
		
		purchases_initialize();
		#end	
		
		#if android
		if(funcInit == null)
		{
			funcInit = nme.JNI.createStaticMethod("AndroidBilling", "initialize", "(Ljava/lang/String;Lorg/haxe/nme/HaxeObject;)V", true);
			load();
		}
		
		funcInit([publicKey, new Purchases()]);
		#end
	}
	
	public static function restorePurchases():Void
	{
		#if(cpp && mobile && !android)
		purchases_restore();
		#end
		
		#if(android)
		if(funcRestore == null)
		{
			funcRestore = nme.JNI.createStaticMethod("AndroidBilling", "restore", "()V", true);
		}
		
		funcRestore([]);
		#end
	}
	
	private static function load()
	{
		#if cpp
		try 
		{
			var data = SharedObject.getLocal("in-app-purchases");
			var saveData = Reflect.field(data.data, "data");
			
			if(saveData != null)
			{
				items = saveData;
				trace(items);
			}
		}
		
		catch(e:Dynamic) 
		{
			trace("Error! Failed to load purchases: " + e);
		}
		#end
	}
	
	private static function save()
	{
		#if cpp
		var so = SharedObject.getLocal("in-app-purchases");
		Reflect.setField(so.data, "data", items);
		#end
		
		#if (cpp || neko)
		var flushStatus:SharedObjectFlushStatus = null;
		#else
		var flushStatus:String = null;
		#end
		
		#if(!js && !air)
		try 
		{
		    flushStatus = so.flush();
		} 
		
		catch(e:Dynamic) 
		{
			trace("Error! Failed to save purchases: " + e);
		}
		
		if(flushStatus != null) 
		{
		    switch(flushStatus) 
		    {
		        case SharedObjectFlushStatus.PENDING:
		            trace("Requesting Permission to Save Purchases");
		            
		        case SharedObjectFlushStatus.FLUSHED:
		            trace("Saved Purchases");
		    }
		}
		#end	
	}
	
	//True if they've bought this before. If consumable, if they have 1 or more of it.
	public static function hasBought(productID:String)
	{
		#if(cpp && mobile)
		if(items == null)
		{
			return false;
		}
		
		return items.exists(productID) && items.get(productID) > 0;
		#else
		return false;
		#end
	}
	
	//Uses up a "consumable" (decrements its count by 1).
	public static function use(productID:String)
	{
		#if(cpp && mobile)
		if(hasBought(productID))
		{
			items.set(productID, items.get(productID) - 1);
			save();
		}
		#end
	}
	
	public static function getQuantity(productID:String):Int
	{
		#if(cpp && mobile)
		if(hasBought(productID))
		{
			return items.get(productID);
		}
		#end
		
		return 0;
	}

	public static function buy(productID:String):Void 
	{
		#if(cpp && mobile && !android)
		purchases_buy(productID);
		#end	
		
		#if(android)
		if(funcBuy == null)
		{
			funcBuy = nme.JNI.createStaticMethod("AndroidBilling", "buy", "(Ljava/lang/String;)V", true);
		}
		
		funcBuy([productID]);
		#end	
	}

	public static function requestProductInfo(productIDlist:Array<Dynamic>):Void 
	{
		#if(cpp && mobile && !android)
		var productIDcommalist:String = productIDlist.join(",");
		purchases_requestProductInfo(productIDcommalist);
		#else
		// TODO?
		#end
	}

	public static function getTitle(productID:String):String 
	{
		#if(cpp && mobile && !android)
		return purchases_title(productID);
		#else
		return "None";
		#end
	}
	
	public static function getDescription(productID:String):String 
	{
		#if(cpp && mobile && !android)
		return purchases_desc(productID);
		#else
		return "None";
		#end
	}
	
	public static function getPrice(productID:String):String 
	{
		#if(cpp && mobile && !android)
		return purchases_price(productID);
		#else
		return "None";
		#end
	}
	
	public static function canBuy():Bool 
	{
		#if(cpp && mobile && !android)
		return purchases_canbuy();
		#else
		return false;
		#end
	}
	
	public static function release():Void 
	{
		#if(cpp && mobile && !android)
		purchases_release();
		#end
	}
	
	#if android
	private static var funcInit:Dynamic;
	private static var funcBuy:Dynamic;
	private static var funcRestore:Dynamic;
	private static var funcTest:Dynamic;
	#end

	#if(cpp && mobile && !android)
	private static var purchases_initialize = Lib.load("purchases", "purchases_initialize", 0);
	private static var purchases_restore = Lib.load("purchases", "purchases_restore", 0);
	private static var purchases_buy = Lib.load("purchases", "purchases_buy", 1);
	private static var purchases_canbuy = Lib.load("purchases", "purchases_canbuy", 0);
	private static var purchases_release = Lib.load("purchases", "purchases_release", 0);
	private static var purchases_requestProductInfo = Lib.load("purchases", "purchases_requestProductInfo", 1);
	private static var purchases_title = Lib.load("purchases", "purchases_title", 1);
	private static var purchases_desc = Lib.load("purchases", "purchases_desc", 1);
	private static var purchases_price = Lib.load("purchases", "purchases_price", 1);
	private static var set_event_handle = Lib.load("purchases", "purchases_set_event_handle", 1);
	#end
}