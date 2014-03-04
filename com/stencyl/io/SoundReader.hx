package com.stencyl.io;

import haxe.xml.Fast;
import com.stencyl.utils.Utils;

import com.stencyl.models.Resource;
import com.stencyl.models.Sound;

class SoundReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == "sound" || type == "music";
	}
	
	public function read(ID:Int, atlasID:Int, type:String, name:String, xml:Fast):Resource
	{
		//trace("Reading Sound (" + ID + ") - " + name);

		var streaming:Bool = Utils.toBoolean(xml.att.stream);
		var looping:Bool = Utils.toBoolean(xml.att.loop);
		var panning:Float = Std.parseFloat(xml.att.pan);
		var volume:Float = Std.parseFloat(xml.att.volume);	
		var ext:String = xml.att.type;
		var s = new Sound(ID, name, streaming, looping, panning, volume, ext);
		s.atlasID = atlasID;
		
		return s;
	}
}
