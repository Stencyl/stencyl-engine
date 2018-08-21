package com.stencyl.models;

import lime.media.AudioBuffer;
import lime.media.vorbis.VorbisFile;
import openfl.media.SoundChannel;
import openfl.media.Sound in OpenFLSound;
import com.stencyl.behavior.Script;
import com.stencyl.utils.Assets;

//TODO: don't load a sound upfront - tie to atlas (remove loading from init)
//Provide load/unload functions (need to hack into NME to unload a sound forcefully?)
//Make sure load/unload get calleed alongside rest of atlas stuff.
//For streaming sounds, the atlas flag is ignored (?).

//Corner case - if sound is looping/playing and you unload...? (we "try" to immediately stop playback and then unload - but how do you know it's playing in the first place?)
//Corner case - if the sound isn't loaded in, it's a no-op. It does not attempt to load it in.

class Sound extends Resource
{	
	public var streaming:Bool;
	public var looping:Bool;
	
	public var panning:Float;
	public var volume:Float;
	
	public var ext:String;
	
	public var src:openfl.media.Sound;

	public function new(ID:Int, name:String, streaming:Bool, looping:Bool, panning:Float, volume:Float, ext:String, atlasID:Int)
	{
		super(ID, name, -1);
		
		this.streaming = streaming;
		this.looping = looping;
		this.panning = panning;
		this.volume = volume;
		this.ext = ext;
		this.atlasID = atlasID;

		#if(mobile || desktop || js)
		this.ext = "ogg";
		#else
		this.ext = "mp3";
		#end
		
		var atlas = GameModel.get().atlases.get(atlasID);

		if(atlas != null && atlas.active)
		{
			loadGraphics();
		}
	}
	
	override public function loadGraphics()
	{
		if(!streaming)
		{
			//trace("Loading sound: " + ID);
			src = Assets.getSound("assets/sfx/sound-" + ID + "." + this.ext, false);
		}
	}
	
	override public function unloadGraphics()
	{
		if(!streaming)
		{
			if(src != null)
			{
				stopInstances();
				src.close();
			}
			
			src = null;
		}
	}

	public function play(channelNum:Int = 1, position:Float = 0):SoundChannel
	{
		if(streaming)
		{
			#if(mobile || desktop || js)
			
			var vorbisFile = VorbisFile.fromFile(Assets.getPath("assets/music/sound-" + ID + "." + ext));
			var audioBuffer = AudioBuffer.fromVorbisFile(vorbisFile);
			src = OpenFLSound.fromAudioBuffer(audioBuffer);
			
			#else
			
			src = Assets.getSound("assets/music/sound-" + ID + "." + ext, false);
			
			#end
		}
		
		if(src == null)
		{
			trace("Trying to play uninitialized sound: " + name + " - " + ID);
			return null;
		}
		
		return src.play(position);	
	}
	
	public function loop(channelNum:Int = 1, position:Float = 0):SoundChannel
	{
		if(streaming)
		{
			#if(mobile || desktop || js)
			
			var vorbisFile = VorbisFile.fromFile(Assets.getPath("assets/music/sound-" + ID + "." + ext));
			var audioBuffer = AudioBuffer.fromVorbisFile(vorbisFile);
			src = OpenFLSound.fromAudioBuffer(audioBuffer);
			
			#else
			
			src = Assets.getSound("assets/music/sound-" + ID + "." + ext, false);
			
			#end
		}
		
		if(src == null)
		{
			trace("Trying to play uninitialized sound: " + name + " - " + ID);
			return null;
		}
		
		return src.play(position, com.stencyl.utils.Utils.INTEGER_MAX);
	}
	
	public function stopInstances()
	{
		for(i in 0...Script.CHANNELS)
		{
			var sc:com.stencyl.models.SoundChannel = com.stencyl.Engine.engine.channels[i];	
			
			if(sc.currentSource == src)
			{
				sc.stopSound();
			}
		}
	}
}
