package com.stencyl.models;

import openfl.events.Event;
import com.stencyl.Engine;
import com.stencyl.models.Sound;
import motion.Actuate;

import openfl.media.SoundTransform;

class SoundChannel 
{	
	public static var muted:Bool = false;
	public static var masterVolume:Float = 1;
	
	public var currentSource:openfl.media.Sound;
	public var currentSound:openfl.media.SoundChannel;
	public var currentClip:com.stencyl.models.Sound;
	public var volume:Float;
	public var channelNum:Int;
	public var looping:Bool;
	
	public var position:Float;
	
	public var engine:Engine;
	public var transform:SoundTransform;
	
	public function new(engine:Engine, channelNum:Int) 
	{
		currentSound = null;
		currentClip = null;
		
		looping = false;
		volume = 1;
		position = 0;
		
		this.channelNum = channelNum;
		this.engine = engine;
		
		transform = new SoundTransform();
	}
	
	public function playSound(clip:Sound):openfl.media.SoundChannel
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
			
			if(currentSound == null)
			{
				currentClip = null;
				return null;
			}
			
			setVolume(volume);
			
			currentSound.addEventListener(Event.SOUND_COMPLETE, stopped);
		}
		
		position = 0;
		
		if(clip != null)
		{
			currentSource = clip.src;
		}
		
		looping = false;
		
		return currentSound;
	}
	
	public function loopSound(clip:Sound):openfl.media.SoundChannel
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
			
			if(currentSound == null)
			{
				currentClip = null;
				return null;
			}
			
			setVolume(volume);
			
			currentSound.addEventListener(Event.SOUND_COMPLETE, stopped);
		}

		position = 0;
		
		if(clip != null)
		{
			currentSource = clip.src;
		}
		
		looping = true;
		
		return currentSound;
	}
	
	public function setPause(pause:Bool)
	{
		if(currentSound != null)
		{
			if(pause)
			{
				currentSound.removeEventListener(Event.SOUND_COMPLETE, looped);
			
				position = currentSound.position;
				currentSound.stop();	
			}
			
			else
			{
				if(currentSource != null)
				{
					currentSound = currentClip.play(channelNum, position);
					currentSound.soundTransform = transform;
				
					if(looping)
					{
						currentSound.addEventListener(Event.SOUND_COMPLETE, looped);
					}
				}
			}
		}
	}
	
	private function looped(event:Event = null)
	{
		if(currentSound != null)
		{
        	currentSound.removeEventListener(Event.SOUND_COMPLETE, looped);
        }
        
		loopSound(currentClip);
	}
	
	private function stopped(event:Event = null)
	{
		//trace("Sound stopped: " + channelNum);
	
		if(currentSound != null)
		{
        	currentSound.removeEventListener(Event.SOUND_COMPLETE, stopped);
        }
        
		Engine.engine.soundFinished(channelNum);
	}
	
	public function stopSound()
	{
		//trace("STOP SOUND: " + currentSound +  " - " + channelNum);
	
		if(currentSound != null)
		{
			currentSound.stop();
			
			//keep on stopping it till it's stopped?
			
			position = 0;
			currentSource = null;
			currentSound = null;
		}			
	}	
	
	public function fadeInSound(time:Float)
	{
		if(currentSound != null)
		{
			Actuate.tween(transform, time, {volume:1}).onUpdate(onUpdate);
		}
	}
	
	public function fadeOutSound(time:Float)
	{
		if(currentSound != null)
		{
			Actuate.tween(transform, time, {volume:0}).onUpdate(onUpdate);
		}
	}
	
	public function onUpdate()
	{	
		if(currentSound != null)
		{
			currentSound.soundTransform = transform;
		}
	}
	
	public function setVolume(volume:Float)
	{
		this.volume = volume;
		
		if(currentSound != null)
		{
			transform.volume = volume * masterVolume;
			currentSound.soundTransform = transform;
		}
	}
}
