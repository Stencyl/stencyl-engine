package io;

import haxe.xml.Fast;
import models.Resource;

class FontReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == "font";
	}
	
	public function read(ID:Int, type:String, name:String, xml:Fast):Resource
	{
		//trace("Reading Font (" + ID + ") - " + name);
		
		var height:Int = Std.parseInt(xml.att.height);
		var rowHeight:Int = Std.parseInt(xml.att.rowHeight);
		var alphabet:String = xml.att.alphabet;
		var xs:String = xml.att.offsets;
		var xOffsets:Array<String> = xs.split(",");
		
		return null;
		//return new Font(ID, name, alphabet, xOffsets, height, rowHeight, Assets.get().resourceAssets[ID + ".png"]);
	}
}
