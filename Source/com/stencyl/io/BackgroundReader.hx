package com.stencyl.io;

import haxe.xml.Fast;
import com.stencyl.utils.Utils;

import com.stencyl.models.Resource;
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
		return type == "background";
	}
	
	public function read(ID:Int, atlasID:Int, type:String, name:String, xml:Fast):Resource
	{
		//trace("Reading Background (" + ID + ") - " + name);

		var red:Int;
		var green:Int;
		var blue:Int;
		var alpha:Int;
		
		if(type == "color-bg")
		{
			red = Std.parseInt(xml.att.red);
			green = Std.parseInt(xml.att.green);
			blue = Std.parseInt(xml.att.blue);
			alpha = 255;
			
			if(red == -1 || green == -1 || blue == -1)
			{
				return new ColorBackground(ColorBackground.TRANSPARENT);
			}
			
			else
			{
				var color:Int = (alpha << 24) | (red << 16) | (green << 8) | blue;
				return new ColorBackground(color);
			}	
		}
		
		else if(type == "grad-bg")
		{
			red = Std.parseInt(xml.att.r1);
			green = Std.parseInt(xml.att.g1);
			blue = Std.parseInt(xml.att.b1);
			alpha = 255;
			
			var color1:Int = (alpha << 24) | (red << 16) | (green << 8) | blue;
			
			red = Std.parseInt(xml.att.r2);
			green = Std.parseInt(xml.att.g2);
			blue = Std.parseInt(xml.att.b2);
			
			var color2:Int = (alpha << 24) | (red << 16) | (green << 8) | blue;
			
			return new GradientBackground(color1, color2);
		}
		
		var scrollX:Float = Std.parseFloat(xml.att.dx);
		var scrollY:Float = Std.parseFloat(xml.att.dy);
		var parallaxX:Float = Std.parseFloat(xml.att.xpf);
		var parallaxY:Float = Std.parseFloat(xml.att.ypf);
		var numFrames:Int = Std.parseInt(xml.att.numframes);
		var durations:Array<Int> = new Array<Int>();
		var frameData:Array<Dynamic> = new Array<Dynamic>();
		var counter:Int = 0;
		
		if(numFrames > 0)
		{
			var s:String = xml.att.durations;
			var frames:Array<String> = s.split(",");
			
			for(f in frames)
			{
				durations[counter] = Std.parseInt(f);
				counter++;
			}
		}

		var repeats:Bool = Utils.toBoolean(xml.att.repeats);						
		
		if(scrollX != 0 || scrollY != 0)
		{
			return new ScrollingBackground(ID, atlasID, name, durations, parallaxX, parallaxY, repeats, scrollX, scrollY);
		}
		
		else
		{
			return new ImageBackground(ID, atlasID, name, durations, parallaxX, parallaxY, repeats);
		}
	}
}
