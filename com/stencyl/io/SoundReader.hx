package com.stencyl.io;

import com.stencyl.utils.Utils;

import com.stencyl.io.mbs.MbsMusic;
import com.stencyl.io.mbs.MbsMusic.*;
import com.stencyl.models.Resource;
import com.stencyl.models.Sound;

class SoundReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == MBS_MUSIC.getName();
	}
	
	public function read(obj:Dynamic):Resource
	{
		//Log.verbose("Reading Sound (" + ID + ") - " + name);

		var r:MbsMusic = cast obj;

		var streaming = r.getStream();
		var looping = r.getLoop();
		var panning:Float = r.getPan();
		var volume:Float = r.getVolume();
		var ext = r.getType();
		var s = new Sound(r.getId(), r.getName(), streaming, looping, panning, volume, ext, r.getAtlasID());
		
		return s;
	}
}
