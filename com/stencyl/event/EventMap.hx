package com.stencyl.event;

@:generic @:remove
class EventMap<K,T>
{
	public var keys:Array<K>;
	public var map:Map<K,T>;

	public function new()
	{
		keys = [];
		map = new Map<K, T>();
	}

	public inline function hasEvents():Bool
	{
		return keys.length > 0;
	}

	public function getOrCreateEvent(key:K):T
	{
		var event = map.get(key);

		if(event == null)
		{
			event = cast new Event();
			map.set(key, event);
			keys.push(key);
		}

		return event;
	}

	public inline function getEvent(key:K):T
	{
		return map.get(key);
	}
}