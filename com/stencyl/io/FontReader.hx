package com.stencyl.io;

import com.stencyl.io.mbs.MbsFont;
import com.stencyl.io.mbs.MbsFont.*;
import com.stencyl.models.Font;
import com.stencyl.models.Resource;

class FontReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == MBS_FONT.getName();
	}
	
	public function read(obj:Dynamic):Resource
	{
		//Log.verbose("Reading Font (" + ID + ") - " + name);
		
		var r:MbsFont = cast obj;

		return new Font(r.getId(), r.getAtlasID(), r.getName(), false);
	}
}
