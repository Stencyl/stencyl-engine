package com.stencyl.utils;

#if (stencyltools && !(scriptable || cppia))

import hscript.*;

class HscriptRunner
{
	var parser:Parser;
	var interp:Interp;
	
	public function new()
	{
		parser = new Parser();
		interp = new Interp();
		
		interp.variables.set("trace", Reflect.makeVarArgs(function(el) {
			var inf = interp.posInfos();
			inf.className = "Script";
			inf.methodName = "run";
			var v = el.shift();
			if( el.length > 0 ) inf.customParams = el;
			haxe.Log.trace(v, inf);
		}));
	}
	
	public function registerVar(name:String, obj:Dynamic):Void
	{
		interp.variables.set(name, obj);
	}
	
	public function execute(script:String)
	{
		var program = parser.parseString(script);
		interp.execute(program);
	}
}

#end