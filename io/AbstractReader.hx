package io;

import models.Resource;
import haxe.xml.Fast;

interface AbstractReader 
{
	function accepts(type:String):Bool;
	function read(ID:Int, type:String, name:String, xml:Fast):Resource;
}
