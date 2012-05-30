/**
 * ...
 * @author original author: waneck - modifications by: fermmmm
 */

package com.stencyl.utils;
import haxe.Serializer;
import haxe.Unserializer;

#if flash9
typedef HashMap<Key, Val> = flash.utils.TypedDictionary<Key, Val>;
#else

class HashMap<Key, Val> 
{
	private static inline var SAFE_NUM = #if neko 1073741823 #else 2147483647 #end;
	private static var clsId:Int = 0;

	#if !php
	private var ival:IntHash<Array<Dynamic>>;
	#else
	private var ival:Hash<Array<Dynamic>>;
	#end
	
	public var length(default, null):Int;
	
	public function new() 
	{
		#if !php
		ival = new IntHash();
		#else
		ival = new Hash();
		#end
		
		length = 0;
	}
	
	public function set(k:Key, v:Val)
	{
		var oid = getObjectId(k);
		
		var g = ival.get(oid);
		if (g == null)
		{
			g = [];
			ival.set(oid, g);
		}
		
		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				g[i + 1] = v;
				return;
			}
			
			i += 2;
		}
		
		g.push(k);
		g.push(v);
		
		length++;
	}
	
	private #if (cpp || php || java || cs) inline #end function getObjectId(obj:Dynamic):#if !php Int #else String #end untyped
	{
#if cpp
		return __global__.__hxcpp_obj_id(obj);
#elseif (neko || js || flash)
		if (Std.is(obj, Class))
		{
			if (obj.__cls_id__ == null)
				obj.__cls_id__ = clsId++;
			return obj.__cls_id__;
		} else {
#if neko
			if (__dollar__typeof(obj) == __dollar__tfunction)
				return 0;
#end
			if (obj.__get_id__ == null)
			{
				var cls:Dynamic = Type.getClass(obj);
				if (cls == null)
				{
					var id = Std.random(SAFE_NUM);
					obj.__get_id__ = function() return id;
					return id;
				}
				
				var fstid = Std.random(SAFE_NUM);
				var _this = this;
				cls.prototype.__get_id__ = function()
				{
					if (_this.___id___ == null)
					{
						return _this.___id___ = Std.random(SAFE_NUM);
					}
					return _this.___id___;
					
				}
			}
			return obj.__get_id__();
		}

	
#elseif php
		if (Reflect.isFunction(obj))
			return "fun";
		else
			return __call__('spl_object_hash', obj);
#elseif java
		return obj.hashCode();
#elseif cs
		return obj.GetHashCode();
#else
		UnsupportedPlatform
#end
	}
	
	public function get(k:Key):Null<Val>
	{
		if (k == null)
			return null;
		var oid = getObjectId(k);
		
		var g = ival.get(oid);
		if (g == null)
		{
			return null;
		}
		
		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				return g[i + 1];
			}
			
			i += 2;
		}
		
		return null;
	}
	
	public function exists(k:Key):Bool
	{
		var oid = getObjectId(k);
		var removed = false;
		
		var g = ival.get(oid);
		if (g == null)
		{
			return false;
		}
		
		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				return true;
			}
			i += 2;
		}
		
		return false;
	}
	
	public function delete(k:Key):Bool
	{
		var oid = getObjectId(k);
		
		var removed = false;
		
		var g = ival.get(oid);
		if (g == null)
		{
			return false;
		}
		
		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				g.splice(i, 2);
				removed = true;
				length--;
				break;
			}
			i += 2;
		}
		
		if (g.length == 0)
			ival.remove(oid);
		
		return removed;
	}
	
	public function keys():Iterator<Key>
	{
		var valit = ival.iterator();
		var curr = null;
		var currIndex = 0;
		return {
			hasNext: function() return (curr != null || valit.hasNext()),
			next: function()
			{
				if (curr == null)
					curr = valit.next();
				
				var ret = curr[currIndex];
				currIndex += 2;
				
				if (currIndex >= curr.length)
				{
					currIndex = 0;
					curr = null;
				}
				
				return ret;
			}
		};
	}
	
	public function values():Iterator<Val>
	{
		var valit = ival.iterator();
		var curr = null;
		var currIndex = 1;
		return {
			hasNext: function() return (curr != null || valit.hasNext()),
			next: function()
			{
				if (curr == null)
					curr = valit.next();
				
				var ret = curr[currIndex];
				currIndex += 2;
				
				if (currIndex >= curr.length)
				{
					currIndex = 1;
					curr = null;
				}
				
				return ret;
			}
		};
	}
	
	public function iterator():Iterator<Key>
	{
		return keys();
	}
	
	public function toString()
	{
		var ret = new StringBuf();
		ret.add("{ ");
		var first = true;
		
		for (k in keys())
		{
			if (first)
			{
				ret.add("\"");
				first = false;
			} else {
				ret.add(", \"");
			}
			
			ret.add(k);
			ret.add("\" => \"");
			ret.add(get(k));
			ret.add("\"");
		}
		
		ret.add(" }");
		return ret.toString();
	}
	
	public function hxSerialize(s:Serializer)
	{
		s.serialize(length);
		
		var valit = ival.iterator();
		var curr = null;
		var currIndex = 0;
		while (curr != null || valit.hasNext())
		{
			if (curr == null)
				curr = valit.next();
			
			var ret = curr[currIndex];
			s.serialize(curr[currIndex]);
			s.serialize(curr[currIndex + 1]);
			
			currIndex += 2;
			if (currIndex >= curr.length)
			{
				currIndex = 0;
				curr = null;
			}
			
		}
	}
	
	public function hxUnserialize(s:Unserializer)
	{
		var len:Int = s.unserialize();
		for (i in 0...len)
		{
			var k = s.unserialize();
			var v = s.unserialize();
			set(k, v);
		}
	}
}
#end