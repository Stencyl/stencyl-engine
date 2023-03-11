package com.stencyl.event;

import com.stencyl.utils.Utils;

//Native Events get queued up here for processing. Cleared once per step.
class EventMaster 
{	
	//HashTable of Lists of Events. Key = EventType
	public var eventTable:Map<Int,Array<StencylEvent>>;
	
	public function new() 
	{	
		eventTable = new Map<Int,Array<StencylEvent>>();
	}	
	
	public function clear()
	{
	}
}
