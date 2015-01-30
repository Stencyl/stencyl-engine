package com.stencyl.utils;

class FastIntHash<T> extends IntHash<T>
{	
	public var obj:Dynamic;
	
	public function new() { super(); obj = h; }
	
	override public function iterator():Iterator<T> 
	{
		#if (cpp)
		untyped return __global__.__int_hash_fast_values(h);
		#else
		return super.iterator();
		#end
		
	}	
	
	override public function keys():Iterator<Int> 
	{
		#if (cpp)
		untyped return __global__.__int_hash_fast_keys(h);
		#else
		return super.keys();
		#end
		
	}
}