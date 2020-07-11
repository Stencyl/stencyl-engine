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

#if stencyltools
typedef CallTemplate =
{
	code:String,
	className:String,
	methodName:String,
	lineNumber:Int,
	expr:Expr
}
#end

@:access(com.stencyl.behavior.Script)

class Callable<T>
{
	#if stencyltools
	public static var callTemplates:Map<Int, CallTemplate> = new Map<Int, CallTemplate>();
	public static var callTable:Map<Int, Array<Callable<Dynamic>>> = new Map<Int, Array<Callable<Dynamic>>>();
	
	//className -> functionName
	public static var namedFunctionTemplates:Map<String, Map<String, CallTemplate>> = new Map<String, Map<String, CallTemplate>>();
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
			
			if(callTemplates.exists(id))
			{
				var ct = callTemplates.get(id);
				if(parent.interp == null) parent.initHscript();
				this.f = parent.interp.asFunction(ct.expr);
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
	
	public static function parseCallable(ct:CallTemplate):Expr
	{
		var parser = new hscript.Parser();
		parser.allowTypes = true;
		
		for(name in ReflectionHelper.getStaticFieldMap("com.stencyl.behavior.Script").keys())
		{
			parser.knownFields.set(name, "Script");
		}
		for(name in ReflectionHelper.getFieldMap(ct.className).keys())
		{
			parser.knownFields.set(name, "this");
		}
		
		return parser.parseString(ct.code, {
			className : ct.className,
			methodName : ct.methodName,
			firstLine : ct.lineNumber
		});
	}
	
	public static function reloadCallable(id:Int, className:String, methodName:String, lineNumber:Int, script:String)
	{
		var ct = {code: script, className: className, methodName: methodName, lineNumber: lineNumber, expr: null};
		ct.expr = parseCallable(ct);
		callTemplates.set(id, ct);
		
		for(c in callTable.get(id))
		{
			if(c.parent.interp == null) c.parent.initHscript();
			c.f = c.parent.interp.asFunction(ct.expr);
		}
	}
	
	public static function reloadNamedFunction(className:String, methodName:String, lineNumber:Int, script:String)
	{
		var ct = {code: script, className: className, methodName: methodName, lineNumber: lineNumber, expr: null};
		ct.expr = parseCallable(ct);
		if(!namedFunctionTemplates.exists(className)) namedFunctionTemplates.set(className, []);
		namedFunctionTemplates.get(className).set(methodName, ct);
		
		if(BehaviorManager.liveScripts.exists(className))
		{
			for(script in BehaviorManager.liveScripts.get(className))
			{
				if(script.interp == null) script.initHscript();
				Reflect.setField(script, methodName, script.interp.asFunction(ct.expr));
			}
		}
	}
	
	#end
}