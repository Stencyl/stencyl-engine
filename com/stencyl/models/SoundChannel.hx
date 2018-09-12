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
	
	public static function resetStatics():Void
	{
		muted = false;
		masterVolume = 1;
	}

	public var currentSource:openfl.media.Sound;
	public var currentSound:openfl.media.SoundChannel;
	public var currentClip:com.stencyl.models.Sound;
	public var volume:Float;
	public var channelNum:Int;
	public var looping:Bool;
	public var paused:Bool = false;
	
	public var position:Float;
	
	public var engine:Engine;
	public var transform:SoundTransform;
	
	public function new(engine:Engine, channelNum:Int) 
	{
		trace("com.stencyl.models.SoundChannel.new");
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
		trace("com.stencyl.models.SoundChannel.playSound");
		if(currentSound != null)
		{
			currentSound.stop();
			paused = false;
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
		trace("com.stencyl.models.SoundChannel.loopSound");
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
		trace("com.stencyl.models.SoundChannel.setPause");
		if(currentSound != null)
		{
			if(pause)
			{
				currentSound.removeEventListener(Event.SOUND_COMPLETE, looped);
			
				position = currentSound.position;
				currentSound.stop();
				paused = true;
			}
			
			else
			{
				if(currentSource != null && paused)
				{
					currentSound = currentClip.play(channelNum, position);
					currentSound.soundTransform = transform;
				
					if(looping)
					{
						currentSound.addEventListener(Event.SOUND_COMPLETE, looped);
					}
					
					paused = false;
				}
			}
		}
	}
	
	private function looped(event:Event = null)
	{
		trace("com.stencyl.models.SoundChannel.looped");
		if(currentSound != null)
		{
        	currentSound.removeEventListener(Event.SOUND_COMPLETE, looped);
        }
        
		loopSound(currentClip);
	}
	
	private function stopped(event:Event = null)
	{
		trace("com.stencyl.models.SoundChannel.stopped");
		//trace("Sound stopped: " + channelNum);
	
		if(currentSound != null)
		{
        	currentSound.removeEventListener(Event.SOUND_COMPLETE, stopped);
        }
        
		Engine.engine.soundFinished(channelNum);
	}
	
	public function stopSound()
	{
		trace("com.stencyl.models.SoundChannel.stopSound");
		//trace("STOP SOUND: " + currentSound +  " - " + channelNum);
	
		if(currentSound != null)
		{
			currentSound.stop();
			
			//keep on stopping it till it's stopped?
			
			position = 0;
			currentSource = null;
			currentSound = null;
			paused = false;
		}			
	}	
	
	public function fadeInSound(time:Float)
	{
		trace("com.stencyl.models.SoundChannel.fadeInSound");
		if(currentSound != null)
		{
			Actuate.tween(transform, time, {volume:1}).onUpdate(onUpdate);
		}
	}
	
	public function fadeOutSound(time:Float)
	{
		trace("com.stencyl.models.SoundChannel.fadeOutSound");
		if(currentSound != null)
		{
			Actuate.tween(transform, time, {volume:0}).onUpdate(onUpdate);
		}
	}
	
	public function fadeSound(time:Float, amount:Float)
	{
		trace("com.stencyl.models.SoundChannel.fadeSound");
		if(currentSound != null)
		{
			Actuate.tween(transform, time, {volume:amount}).onUpdate(onUpdate);
		}
	}
	
	public function onUpdate()
	{
		trace("com.stencyl.models.SoundChannel.onUpdate");
		if(currentSound != null)
		{
			currentSound.soundTransform = transform;
		}
	}
	
	public function setVolume(volume:Float)
	{
		trace("com.stencyl.models.SoundChannel.setVolume");
		this.volume = volume;
		
		if(currentSound != null)
		{
			transform.volume = volume * masterVolume;
			currentSound.soundTransform = transform;
		}
	}
}
