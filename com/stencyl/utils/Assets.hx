package com.stencyl.utils;

#if use_tilemap
import com.stencyl.graphics.TextureAtlas;
#end

import haxe.io.Bytes;
import haxe.Json;

import lime.media.AudioBuffer;
import lime.utils.Assets as LimeAssets;
import lime.utils.Bytes;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.ByteArray;

class Assets
{
	#if stencyltools
	public static var modifiedAssetCache:Map<String,Dynamic> = new Map<String,Dynamic>();
	#end
	
	#if use_tilemap
	
	//img base -> atlas id -> atlas
	public static var atlases = new Map<String,Map<String,TextureAtlas>>();
	
	//asset path -> atlas
	public static var imageAtlasMap = new Map<String,TextureAtlas>();
	
	//asset path -> image
	public static var imageAtlasCache = new Map<String,BitmapData>();
	
	//img base -> atlas group id -> atlases
	public static var atlasGroups = new Map<String,Map<String,Array<TextureAtlas>>>();
	
	public static function loadAtlases()
	{
		var atlasConfig = Utils.getConfigText("atlases/list.json");
		if(atlasConfig == null || atlasConfig == "")
			return;
		var atlasLists = Json.parse(atlasConfig);

		for(imgBase in Reflect.fields(atlasLists))
		{
			var atlasesForThisImgBase = new Map<String, TextureAtlas>();
			var atlasGroupsForThisImgBase = new Map<String, Array<TextureAtlas>>();

			var dataForScale:Dynamic = Reflect.field(atlasLists, imgBase);
			for(atlasGroupId in Reflect.fields(dataForScale))
			{
				var atlasesForThisGroup = new Array<TextureAtlas>();
				var atlasIdList:Array<String> = Reflect.field(dataForScale, atlasGroupId);
				for(atlasId in atlasIdList)
				{
					var atlas = new TextureAtlas(imgBase, atlasId);
					atlas.loadData();
					for(filename in atlas.listFiles())
					{
						imageAtlasMap.set(filename, atlas);
					}
					atlasesForThisImgBase.set(atlasId, atlas);
					atlasesForThisGroup.push(atlas);
				}
				atlasGroupsForThisImgBase.set(atlasGroupId, atlasesForThisGroup);
			}
			
			atlases.set(imgBase, atlasesForThisImgBase);
			atlasGroups.set(imgBase, atlasGroupsForThisImgBase);
		}
	}
	
	public static function hasAtlasForImage(imageName:String):Bool
	{
		return imageAtlasMap.exists(imageName);
	}

	public static function getAtlasForImage(imageName:String):TextureAtlas
	{
		return imageAtlasMap.get(imageName);
	}
	#end

	public static function getBitmapData(id:String, useCache:Bool = true):BitmapData
	{
		#if stencyltools
		if(modifiedAssetCache.exists(id))
		{
			return cast modifiedAssetCache.get(id);
		}
		#end
		#if use_tilemap
		var atlas = imageAtlasMap.get(id);
		if(atlas != null)
		{
			if(atlas.tileset == null)
			{
				atlas.loadImage();
			}
			return atlas.getTile(id, useCache);
		}
		#end
		return OpenFLAssets.getBitmapData(id, useCache);
	}

	public static function getBytes(id:String):ByteArray
	{
		#if stencyltools
		if(modifiedAssetCache.exists(id))
		{
			var ba:ByteArray = cast modifiedAssetCache.get(id);
			ba.position = 0;
			return ba;
		}
		#end
		return OpenFLAssets.getBytes(id);
	}
	
	public static function getPath(id:String):String
	{
		return OpenFLAssets.getPath(id);
	}

	public static function getSound(id:String, useCache:Bool = true):Sound
	{
		#if stencyltools
		if(modifiedAssetCache.exists(id))
		{
			return cast modifiedAssetCache.get(id);
		}
		#end
		return OpenFLAssets.getSound(id, useCache);
	}

	public static function getText(id:String):String
	{
		#if stencyltools
		if(modifiedAssetCache.exists(id))
		{
			return cast modifiedAssetCache.get(id);
		}
		#end
		return OpenFLAssets.getText(id);
	}

	#if stencyltools
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
	#end
}
