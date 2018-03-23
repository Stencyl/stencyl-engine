package com.stencyl.utils;

#if stencyltools

import hscript.*;

class HscriptRunner
{
	var parser:Parser;
	var interp:Interp;
	
	public function new()
	{
		parser = new Parser();
		interp = new Interp();
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