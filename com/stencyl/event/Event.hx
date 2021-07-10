package com.stencyl.event;

class Event<T>
{
	public var listeners:Array<T>;
	public var length:Int;
	private var _dispatchIndex:Int = -1;
	#if debug_event_dispatch
	public var posInfos:Array<haxe.PosInfos>;
	#end
	
	/**
		Creates a new Event instance
	**/
	public function new()
	{
		listeners = new Array();
		length = 0;

		#if debug_event_dispatch
		posInfos = new Array();
		#end
	}

	/**
		Adds a new event listener
		@param	listener	A callback that matches the signature of the event
	**/
	public function add(listener:T #if debug_event_dispatch , posInfo:haxe.PosInfos #end):Void
	{
		listeners.push(listener);
		++length;

		#if debug_event_dispatch
		posInfos.push(posInfo);
		#end
	}

	/**
		Checks whether a callback is a listener to this event
		@param	listener	A callback that matches the signature of the event
		@return	Whether the callback is a listener
	**/
	public function has(listener:T):Bool
	{
		for (l in listeners)
		{
			if (Reflect.compareMethods(l, listener)) return true;
		}

		return false;
	}

	/**
		Removes an event listener
		@param	listener	A callback that matches the signature of the event
	**/
	public function remove(listener:T):Void
	{
		var i = listeners.length;

		while (--i >= 0)
		{
			if (Reflect.compareMethods(listeners[i], listener))
			{
				listeners.splice(i, 1);
				--length;
				if(_dispatchIndex >= i)
					--_dispatchIndex;

				#if debug_event_dispatch
				posInfos.splice(i, 1);
				#end
			}
		}
	}

	/**
		Removes all event listeners
	**/
	public function removeAll():Void
	{
		listeners.splice(0, length);
		length = 0;
		_dispatchIndex = 0;

		#if debug_event_dispatch
		posInfos.splice(0, posInfos.length);
		#end
	}
}