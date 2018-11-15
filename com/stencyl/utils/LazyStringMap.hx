package com.stencyl.utils;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.TypeTools;
#end

class LazyStringMap<V>
{
	macro public static function fromFunction<V>(e:Expr)
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
		
		return macro new LazyStringMap<$value>(new Map<String,$value>(), $e);
	}

	private var map:Map<String,V>;
	private var initializer:String->V;

	public function new(map:Map<String,V>, initializer:String->V)
	{
		this.map = map;
		this.initializer = initializer;
	}

	public function get(key:String):V
	{
		var obj:V = map.get(key);
		
		if(obj == null)
		{
			obj = initializer(key);
			map.set(key, obj);
		}

		return obj;
	}

	public inline function set(key:String, value:V) map.set(key, value);
	public inline function exists(key:String) return map.exists(key);
	public inline function remove(key:String) return map.remove(key);
	public inline function keys():Iterator<String> return map.keys();
	public inline function iterator():Iterator<V> return map.iterator();
}