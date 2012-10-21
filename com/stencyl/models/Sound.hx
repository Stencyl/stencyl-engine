package com.stencyl.models;

import nme.media.SoundChannel;
import nme.Assets;

class Sound extends Resource
{	
	public var streaming:Bool;
	public var looping:Bool;
	
	public var panning:Float;
	public var volume:Float;
	
	public var ext:String;
	
	public var src:nme.media.Sound;

	public function new(ID:Int, name:String, streaming:Bool, looping:Bool, panning:Float, volume:Float, ext:String) 
	{
		super(ID, name, -1);
		
		this.streaming = streaming;
		this.looping = looping;
		this.panning = panning;
		this.volume = volume;
		this.ext = ext;
		
		#if(cpp && desktop)
		this.ext = "ogg";
		#else
		this.ext = "mp3";
		#end
		
		if(!streaming)
		{
			src = Assets.getSound("assets/sfx/sound-" + ID + "." + this.ext);
		}
	}		
	
	public function play(channelNum:Int = 1, position:Float = 0):SoundChannel
	{
		if(streaming)
		{
			src = Assets.getSound("assets/music/sound-" + ID + "." + ext);
		}
		
		return src.play(position);	
	}
	
	public function loop(channelNum:Int = 1, position:Float = 0):SoundChannel
	{
		if(streaming)
		{
			src = Assets.getSound("assets/music/sound-" + ID + "." + ext);
		}
		
		return src.play(position, com.stencyl.utils.Utils.INT_MAX);
	}
}
