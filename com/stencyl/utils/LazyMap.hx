package com.stencyl.utils;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.TypeTools;
#end

class LazyMap<K,V>
{
	macro public static function fromFunction<K,V>(e:Expr)
	{
		var type = Context.typeof(e);
		var keyType:Type = null;
		var valueType:Type = null;
		
		switch(type)
		{
			case TFun(args, ret):
				if(args.length == 1)
				{
					keyType = args[0].t;
					valueType = ret;
				}
			case(_):
		}
		
		var key = keyType.toComplexType();
		var value = valueType.toComplexType();
		
		return macro new LazyMap<$key,$value>(new Map<$key,$value>(), $e);
	}

	private var map:Map<K,V>;
	private var initializer:K->V;

	public function new(map:Map<K,V>, initializer:K->V)
	{
		this.map = map;
		this.initializer = initializer;
	}

	public function get(key:K):V
	{
		var obj:V = map.get(key);
		
		if(obj == null)
		{
			obj = initializer(key);
			map.set(key, obj);
		}

		return obj;
	}

	public inline function set(key:K, value:V) map.set(key, value);
	public inline function exists(key:K) return map.exists(key);
	public inline function remove(key:K) return map.remove(key);
	public inline function keys():Iterator<K> return map.keys();
	public inline function iterator():Iterator<V> return map.iterator();
}