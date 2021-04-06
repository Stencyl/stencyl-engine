package com.stencyl.event;

@:generic @:remove
class EventMap<K,T>
{
	public var keys:Array<K>;
	public var map:Map<K,Event<T>>;

	public function new()
	{
		keys = [];
		map = [];
	}

	public inline function hasEvents():Bool
	{
		return keys.length > 0;
	}

	public function getOrCreateEvent(key:K):Event<T>
	{
		var event = map.get(key);

		if(event == null)
		{
			event = new Event<T>();
			map.set(key, event);
			keys.push(key);
		}

		return event;
	}

	public inline function getEvent(key:K):Event<T>
	{
		return map.get(key);
	}
}