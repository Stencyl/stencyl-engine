package models;

import nme.media.SoundChannel;
import nme.Assets;

class Sound extends Resource
{	
	public var streaming:Bool;
	public var looping:Bool;
	
	public var panning:Float;
	public var volume:Float;
	
	public var ext:String;
	
	public var lastInstance:SoundChannel;
		
	public function new(ID:Int, name:String, streaming:Bool, looping:Bool, panning:Float, volume:Float, ext:String) 
	{
		super(ID, name);
		
		this.streaming = streaming;
		this.looping = looping;
		this.panning = panning;
		this.volume = volume;
		this.ext = ext;
	}		
	
	public function play(channelNum:Int = 1):SoundChannel
	{
		if(streaming)
		{
			var sound = Assets.getSound("assets/music/" + ID + "." + ext);
			return sound.play();
		}
		
		else
		{
			var sound = Assets.getSound("assets/sound/" + ID + "." + ext);
			return sound.play();
		}	
	}
	
	public function loop(channelNum:Int = 1):SoundChannel
	{
		if(streaming)
		{
			var sound = Assets.getSound("assets/music/" + ID + "." + ext);
			return sound.play(0, -1);
		}
		
		else
		{
			var sound = Assets.getSound("assets/sound/" + ID + "." + ext);
			return sound.play(0, -1);
		}
	}
}
