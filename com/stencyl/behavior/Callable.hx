package com.stencyl.behavior;

import haxe.ds.Either;

#if stencyltools
import hscript.*;
#end

abstract CFunction<A>(Either<Callable<A>, A>) from Either<Callable<A>, A> to Either<Callable<A>, A> {
  @:from inline static function fromCallable<A>(a:Callable<A>) : CFunction<A> return Left(a);
  @:from inline static function fromFunction<A>(a:A) : CFunction<A> return Right(a);
    
  @:to inline function toCallable():Null<Callable<A>> return switch(this) {case Left(a): a; default: null;}
  @:to inline function toFunction():Null<A> return switch(this) {case Right(a): a; default: null;}
}

@:access(com.stencyl.behavior.Script)

class Callable<T>
{
	#if stencyltools
	public static var callTemplatesRaw:Map<Int, String> = new Map<Int, String>();
	public static var callTemplates:Map<Int, Expr> = new Map<Int, Expr>();
	public static var callTable:Map<Int, Array<Callable<Dynamic>>> = new Map<Int, Array<Callable<Dynamic>>>();
	#end

	public var id:Int;
	public var parent:Script;
	public var f:T;
	public var finished:Bool;
	
	public function new(id:Int, parent:Script, f:T)
	{
		this.id = id;
		this.parent = parent;
		
		#if stencyltools
		
		if(id != -1 && parent != null)
		{
			if(!callTable.exists(id))
				callTable.set(id, []);
			callTable.get(id).push(this);
			
			if(!callTemplates.exists(id) && callTemplatesRaw.exists(id))
			{
				parseCallable(id);
			}
			
			if(callTemplates.exists(id))
			{
				var expr = callTemplates.get(id);
				this.f = parent.interp.expr(expr);
			}
			else
			{
				this.f = f;
			}
		}
		else
		{
			this.f = f;
		}
		
		#else
		
		this.f = f;
		
		#end
	}
	
	#if stencyltools
	
	public static function parseCallable(id:Int)
	{
		if(callTable.get(id).length > 0)
		{
			var c = callTable.get(id)[0];
			
			var parser = new hscript.Parser();
			parser.allowTypes = true;
			
			for(name in ReflectionHelper.getStaticFieldMap("com.stencyl.behavior.Script").keys())
			{
				parser.knownFields.set(name, "Script");
			}
			for(name in ReflectionHelper.getFieldMap(c.parent.wrapper.classname).keys())
			{
				parser.knownFields.set(name, "this");
			}
			
			callTemplates.set(id, parser.parseString(callTemplatesRaw.get(id)));
		}
	}
	
	public static function reloadCallable(id:Int, methodName:String, lineNumber:Int, script:String)
	{
		callTemplatesRaw.set(id, script);
		parseCallable(id);
		
		var expr = callTemplates.get(id);

		for(c in callTable.get(id))
		{
			if(c.parent.interp == null)
				c.parent.initHscript();
			
			c.parent.interp.variables.set("trace", Reflect.makeVarArgs(function(el) {
				var inf = c.parent.interp.posInfos();
				inf.className = c.parent.wrapper.classname;
				inf.methodName = methodName;
				inf.lineNumber += lineNumber - 1;
				var v = el.shift();
				if( el.length > 0 ) inf.customParams = el;
				haxe.Log.trace(v, inf);
			}));
			
			c.f = c.parent.interp.expr(expr);
		}
	}
	
	#end
}