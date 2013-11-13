package com.stencyl.event;

import com.stencyl.utils.Utils;

//Native Events get queued up here for processing. Cleared once per step.
class EventMaster 
{	
	//HashTable of Lists of Events. Key = EventType
	public var eventTable:Map<Int,Array<StencylEvent>>;
	
	public static var TYPE_ADS:Int = 1;
	public static var TYPE_PURCHASES:Int = 2;
	public static var TYPE_GAMECENTER:Int = 3;
	public static var TYPE_KEYBOARD:Int = 4;

	public function new() 
	{	
		eventTable = new Map<Int,Array<StencylEvent>>();
		
		eventTable.set(TYPE_ADS, new Array<StencylEvent>());
		eventTable.set(TYPE_PURCHASES, new Array<StencylEvent>());
		eventTable.set(TYPE_GAMECENTER, new Array<StencylEvent>());
		eventTable.set(TYPE_KEYBOARD, new Array<StencylEvent>());
	}	
	
	public function addAdEvent(e:StencylEvent)
	{
		eventTable.get(TYPE_ADS).push(e);
	}	
	
	public function addPurchaseEvent(e:StencylEvent)
	{
		eventTable.get(TYPE_PURCHASES).push(e);
	}	
	
	public function addGameCenterEvent(e:StencylEvent)
	{
		eventTable.get(TYPE_GAMECENTER).push(e);
	}	
	
	public function addKeyboardEvent(e:StencylEvent)
	{
		eventTable.get(TYPE_KEYBOARD).push(e);
	}	
	
	public function clear()
	{
		Utils.clear(eventTable.get(TYPE_ADS));
		Utils.clear(eventTable.get(TYPE_PURCHASES));
		Utils.clear(eventTable.get(TYPE_GAMECENTER));
		Utils.clear(eventTable.get(TYPE_KEYBOARD));
	}
}
