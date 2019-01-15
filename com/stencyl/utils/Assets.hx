package com.stencyl.utils;

#if !stencyltools

typedef Assets = openfl.utils.Assets;

#else

import lime.media.AudioBuffer;
import lime.utils.Assets as LimeAssets;
import lime.utils.Bytes;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.ByteArray;

class Assets
{
	public static var modifiedAssetCache:Map<String,Dynamic> = new Map<String,Dynamic>();

	public static function getBitmapData(id:String, useCache:Bool = true):BitmapData
	{
		if(modifiedAssetCache.exists(id))
		{
			return cast modifiedAssetCache.get(id);
		}
		return OpenFLAssets.getBitmapData(id, useCache);
	}

	public static function getBytes(id:String):ByteArray
	{
		if(modifiedAssetCache.exists(id))
		{
			var ba:ByteArray = cast modifiedAssetCache.get(id);
			ba.position = 0;
			return ba;
		}
		return OpenFLAssets.getBytes(id);
	}
	
	public static function getPath(id:String):String
	{
		return OpenFLAssets.getPath(id);
	}

	public static function getSound(id:String, useCache:Bool = true):Sound
	{
		if(modifiedAssetCache.exists(id))
		{
			return cast modifiedAssetCache.get(id);
		}
		return OpenFLAssets.getSound(id, useCache);
	}

	public static function getText(id:String):String
	{
		if(modifiedAssetCache.exists(id))
		{
			return cast modifiedAssetCache.get(id);
		}
		return OpenFLAssets.getText(id);
	}

	public static function updateAsset(id:String, type:String, content:ByteArray, callback:Void->Void):Void
	{
		var decoded:Dynamic = null;

		switch(type)
		{
			case "IMAGE":
				BitmapData.loadFromBytes(content, null).onComplete(function(img) {
					modifiedAssetCache.set(id, img);
					callback();
				});

			case "BINARY":
				modifiedAssetCache.set(id, content);
				callback();

			case "SOUND":
				modifiedAssetCache.set(id, Sound.fromAudioBuffer(AudioBuffer.fromBytes(content)));
				callback();

			case "TEXT":
				modifiedAssetCache.set(id, content.readUTFBytes(content.length));
				callback();
		}
	}
}

#end