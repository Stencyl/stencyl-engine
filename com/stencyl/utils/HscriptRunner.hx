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
		
		interp.variables.set("imageTrace", Reflect.makeVarArgs(function(el) {
			var inf = interp.posInfos();
			var v = el.shift();
			if( el.length > 0 ) inf.customParams = el;
			ToolsetInterface.imageTrace(cast v, inf);
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