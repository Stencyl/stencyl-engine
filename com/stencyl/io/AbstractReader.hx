package com.stencyl.io;

import com.stencyl.models.Resource;

interface AbstractReader 
{
	function accepts(type:String):Bool;
	function read(object:Dynamic):Resource;
}
