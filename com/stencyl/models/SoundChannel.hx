package com.stencyl.models;

import com.stencyl.Engine;
import com.stencyl.models.Sound;
import com.eclecticdesignstudio.motion.Actuate;

class SoundChannel 
{	
	public static var muted:Bool = false;
	public static var masterVolume:Float = 1;
	
	public var currentSource:nme.media.Sound;
	public var currentSound:nme.media.SoundChannel;
	public var currentClip:com.stencyl.models.Sound;
	public var volume:Float;
	public var channelNum:Int;
	public var looping:Bool;
	
	public var position:Float;
	
	public var engine:Engine;
	
	public function new(engine:Engine, channelNum:Int) 
	{
		currentSound = null;
		currentClip = null;
		
		looping = false;
		volume = 1;
		position = 0;
		
		this.channelNum = channelNum;
		this.engine = engine;
	}
	
	public function playSound(clip:Sound):nme.media.SoundChannel
	{			
		if(currentSound != null)
		{
			currentSound.stop();
		}
		
		if(clip != null)
		{
			clip.volume = volume * masterVolume;
			currentClip = clip;
			currentSound = clip.play(channelNum);	
			
			//currentSound.setScene(engine);
		}
		
		position = 0;
		currentSource = clip.src;
		looping = false;
		
		return currentSound;
	}
	
	public function loopSound(clip:Sound):nme.media.SoundChannel
	{
		if(currentSound != null)
		{
			currentSound.stop();
		}
		
		if(clip != null)
		{
			clip.volume = volume * masterVolume;
			currentClip = clip;
			currentSound = clip.loop(channelNum);
			
			//currentSound.setScene(engine);
		}
		
		position = 0;
		currentSource = clip.src;
		looping = true;
		
		return currentSound;
	}
	
	public function setPause(pause:Bool)
	{
		if(currentSound != null)
		{
			if(pause)
			{
				position = currentSound.position;
				currentSound.stop();	
			}
			
			else
			{
				if(currentSource != null)
				{
					currentSource.play(position);
				}
			}
		}
	}
	
	public function stopSound()
	{
		if(currentSound != null)
		{
			currentSound.stop();
			position = 0;
			currentSource = null;
		}			
	}	
	
	public function fadeInSound(time:Float)
	{
		if(currentSound != null)
		{
			Actuate.tween(currentSound.soundTransform, time, {volume:1});
		}
	}
	
	public function fadeOutSound(time:Float)
	{
		if(currentSound != null)
		{
			Actuate.tween(currentSound.soundTransform, time, {volume:0});
		}
	}
	
	public function setVolume(volume:Float)
	{
		this.volume = volume;
		
		if(currentSound != null)
		{
			currentSound.soundTransform.volume = volume;
		}
	}
}
