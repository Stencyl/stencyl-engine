package com.stencyl.io;

import com.stencyl.utils.Utils;

import com.stencyl.models.Resource;
import com.stencyl.io.mbs.MbsBackground;
import com.stencyl.io.mbs.MbsBackground.*;
import com.stencyl.models.background.ColorBackground;
import com.stencyl.models.background.GradientBackground;
import com.stencyl.models.background.ImageBackground;
import com.stencyl.models.background.ScrollingBackground;

class BackgroundReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == MBS_BACKGROUND.getName();
	}
	
	public function read(obj:Dynamic):Resource
	{
		//trace("Reading Background (" + ID + ") - " + name);
		
		var r:MbsBackground = cast obj;

		var id = r.getId();
		var atlasID = r.getAtlasID();
		var name = r.getName();
		
		var scrollX = r.getXVelocity();
		var scrollY = r.getYVelocity();
		var parallaxX = r.getXParallaxFactor();
		var parallaxY = r.getYParallaxFactor();
		var numFrames = r.getNumFrames();
		var durations = new Array<Int>();
		var frameData = new Array<Dynamic>();
		
		if(numFrames > 0)
		{
			var intList = r.getDurations();
			for(i in 0...intList.length())
				durations.push(intList.readInt());
		}

		var repeats = r.getRepeats();
		
		if(scrollX != 0 || scrollY != 0)
		{
			return new ScrollingBackground(id, atlasID, name, durations, parallaxX, parallaxY, repeats, scrollX, scrollY);
		}
		
		else
		{
			return new ImageBackground(id, atlasID, name, durations, parallaxX, parallaxY, repeats);
		}
	}
}
