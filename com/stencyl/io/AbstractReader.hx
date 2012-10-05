package com.stencyl.io;

import com.stencyl.models.Resource;
import haxe.xml.Fast;

interface AbstractReader 
{
	function accepts(type:String):Bool;
	function read(ID:Int, atlasID:Int, type:String, name:String, xml:Fast):Resource;
}
