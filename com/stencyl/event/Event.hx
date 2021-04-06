package com.stencyl.event;

class Event<T>
{
	public var listeners:Array<T>;
	public var length:Int;
	
	/**
		Creates a new Event instance
	**/
	public function new()
	{
		listeners = new Array();
		length = 0;
	}

	/**
		Adds a new event listener
		@param	listener	A callback that matches the signature of the event
	**/
	public function add(listener:T):Void
	{
		listeners.push(listener);
		++length;
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
	}
}