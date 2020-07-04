package com.stencyl.behavior;

#if stencyltools
import hscript.*;
#end

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
			for(name in c.parent.nameMap)
			{
				parser.classFields.set(name, name);
			}
			
			callTemplates.set(id, parser.parseString(callTemplatesRaw.get(id)));
		}
	}
	
	public static function reloadCallable(id:Int, script:String)
	{
		callTemplatesRaw.set(id, script);
		parseCallable(id);
		
		var expr = callTemplates.get(id);

		for(c in callTable.get(id))
		{
			if(c.parent.interp == null)
				c.parent.initHscript();
			
			c.f = c.parent.interp.expr(expr);
		}
	}
	
	#end
}