package com.stencyl.utils;

#if !stencyltools

typedef Assets = openfl.utils.Assets;

#else

import haxe.io.Bytes;

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
				#if flash
				modifiedAssetCache.set(id, loadBitmapDataFromBytes(content));
				callback();
				#else
				BitmapData.loadFromBytes(content, null).onComplete(function(img) {
					modifiedAssetCache.set(id, img);
					callback();
				});
				#end

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

	#if flash
	@:access(lime.graphics.Image)
	@:access(lime.graphics.ImageBuffer)
	public static function loadBitmapDataFromBytes(bytes:Bytes):BitmapData
	{
		var bytesInput = new haxe.io.BytesInput(bytes);
		var pngReader = new format.png.Reader(bytesInput);
		var data = pngReader.read();
		var header = format.png.Tools.getHeader(data);
		var argb = (format.png.Tools.extract32(data):ByteArray);
		argb.position = 0;

		var bd:BitmapData = new BitmapData(header.width, header.height);
		bd.setPixels(new openfl.geom.Rectangle(0, 0, header.width, header.height), argb);

		if (bd == null) return null;
		
		var buffer = new lime.graphics.ImageBuffer(null, bd.width, bd.height);
		buffer.__srcBitmapData = bd;
		buffer.transparent = bd.transparent;
		var img = new lime.graphics.Image(buffer);

		var bdToReturn = BitmapData.fromImage(img);
		return bdToReturn;
	}
	#end
}

#end