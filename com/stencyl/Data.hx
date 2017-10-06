package com.stencyl;

import com.stencyl.io.mbs.actortype.*;
import com.stencyl.io.mbs.snippet.*;
import com.stencyl.io.mbs.*;
import com.stencyl.io.mbs.Typedefs;
import com.stencyl.io.AbstractReader;
import com.stencyl.io.ActorTypeReader;
import com.stencyl.io.BackgroundReader;
import com.stencyl.io.BehaviorReader;
import com.stencyl.io.FontReader;
import com.stencyl.io.SoundReader;
import com.stencyl.io.SpriteReader;
import com.stencyl.io.TilesetReader;

import com.stencyl.behavior.Behavior;
import com.stencyl.models.Scene;
import com.stencyl.models.Resource;
import com.stencyl.models.GameModel;
import com.stencyl.models.Atlas;
import com.stencyl.models.Sound;
import com.stencyl.models.Font;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Sprite;
import com.stencyl.utils.Assets;
import com.stencyl.utils.LazyMap;

import haxe.xml.Fast;

import mbs.core.MbsObject;
import mbs.core.MbsTypes;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsReader;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsDynamicList;

class Data
{
	//*-----------------------------------------------
	//* Singleton
	//*-----------------------------------------------
	
	public static var instance:Data;

	public static function get():Data
	{
		if(instance == null)
		{
			instance = new Data();
			instance.loadAll();
		}
		
		return instance;
	}

	public static function resetStatics():Void
	{
		instance = null;
	}
	
	
	//*-----------------------------------------------
	//* Pluggable Reader Map
	//*-----------------------------------------------
	
	private var readers:Array<AbstractReader>;
	
	
	//*-----------------------------------------------
	//* Master XML/MBS Files
	//*-----------------------------------------------
	
	public var gameXML:Fast;
	public var resourceListMbs:MbsReader;
	public var sceneListXML:Fast;
	public var behaviorListMbs:MbsReader;
			
	
	//*-----------------------------------------------
	//* Data
	//*-----------------------------------------------
	
	//Map of each [sceneID].scn by ID
	//public var scenesTerrain:Map<Int,Dynamic>;

	//Map of each resource in memory by ID
	public var resources:LazyMap<Int,Resource>;

	//Map of each resource in memory by name
	public var resourceMap:LazyMap<String,Resource>;

	//Map of each static asset by filename
	public var resourceAssets:Map<String,Dynamic>;
	
	//Map of each behavior by ID
	public var behaviors:LazyMap<Int,Behavior>;
	

	private var resourceLookup:Map<Int,Int> = null; //id -> address
	private var resourceNameLookup:Map<String,Int> = null; //name -> id
	private var behaviorLookup:Map<Int,Int> = null; //id -> address
	private var behaviorReader:MbsSnippetDef = null;
	private var resourceReader:MbsResource = null;

	//*-----------------------------------------------
	//* Loading
	//*-----------------------------------------------
	
	public function new()
	{
		if(Assets.getText("assets/data/game.xml") == "")
		{
			throw "Data.hx - Could not load game. Check your logs for a possible cause (likely a bad MP3 file).";
		}
	}
	
	public function loadAll()
	{
		gameXML = new Fast(Xml.parse(Assets.getText("assets/data/game.xml")).firstElement());
		sceneListXML = new Fast(Xml.parse(Assets.getText("assets/data/scenes.xml")).firstElement());
		resourceListMbs = new MbsReader(Assets.getBytes("assets/data/resources.mbs"), Typedefs.instance, false);
		behaviorListMbs = new MbsReader(Assets.getBytes("assets/data/behaviors.mbs"), Typedefs.instance, false);

		resourceAssets = new Map<String,Dynamic>();
		behaviors = LazyMap.fromFunction(loadBehaviorFromMbs);
		resources = LazyMap.fromFunction(loadResourceFromMbs);
		resourceMap = LazyMap.fromFunction(loadResourceFromMbsByName);

		loadReaders();

		scanBehaviorMbs();
		scanResourceMbs();
	}
	
	private function loadReaders()
	{
		readers = new Array<AbstractReader>();
		readers.push(new BackgroundReader());
		readers.push(new SoundReader());
		readers.push(new TilesetReader());
		readers.push(new ActorTypeReader());
		readers.push(new SpriteReader());
		readers.push(new FontReader());
	}
	
	@:access(mbs.io.MbsListBase.elementAddress)
	private function scanBehaviorMbs()
	{
		behaviorLookup = new Map<Int,Int>();
		
		var reader = behaviorListMbs;
		var listReader:MbsList<MbsSnippetDef> = cast reader.getRoot();
		
		for(i in 0...listReader.length())
		{
			var address = listReader.elementAddress;
			behaviorReader = listReader.getNextObject();

			behaviorLookup.set(behaviorReader.getId(), address);
		}
	}

	@:access(mbs.io.MbsListBase.elementAddress)
	private function scanResourceMbs()
	{
		resourceLookup = new Map<Int,Int>();
		resourceNameLookup = new Map<String,Int>();

		var listReader:MbsDynamicList = cast resourceListMbs.getRoot();
		
		for(i in 0...listReader.length())
		{
			var address = listReader.elementAddress;
			var obj:MbsResource = cast listReader.readObject();

			resourceLookup.set(obj.getId(), address);
			if(Std.is(obj, MbsSprite))
				resourceNameLookup.set("Sprite_" + obj.getName(), obj.getId());
			else
				resourceNameLookup.set(obj.getName(), obj.getId());
		}
	}

	private function loadResourceFromMbsByName(name:String):Resource
	{
		return loadResourceFromMbs(resourceNameLookup.get(name));
	}

	private function loadResourceFromMbs(id:Int):Resource
	{
		var address = resourceLookup.get(id);
		var obj:MbsObject = cast MbsDynamicHelper.readDynamic(resourceListMbs, address);

		var newResource = readResource(obj.getMbsType().getName(), obj);

		if(newResource != null)
		{
			resources.set(newResource.ID, newResource);

			if(Std.is(newResource, Sprite))
				resourceMap.set("Sprite_" + newResource.name, newResource);
			else
				resourceMap.set(newResource.name, newResource);
		}

		return newResource;
	}

	private function loadBehaviorFromMbs(id:Int):Behavior
	{
		behaviorReader.setAddress(behaviorLookup.get(id));
		return BehaviorReader.readBehavior(behaviorReader);
	}
	
	private function readResource(type:String, object:Dynamic):Resource
	{
		for(reader in readers)
		{
			if(reader.accepts(type))
			{
				return reader.read(object);
			}
		}
		
		return null;
	}

	//At the moment, this will be broken in most cases.
	public function getAllActorTypes():Array<ActorType>
	{
		var a = new Array<ActorType>();
		
		for(r in resources)
		{
			if(Std.is(r, ActorType))
			{
				a.push(cast(r, ActorType));
			}
		}
		
		return a;
	}
	
	public function getGraphicAsset(url:String, diskURL:String):Dynamic
	{
		if(resourceAssets.get(url) == null)
		{
			resourceAssets.set(url, Assets.getBitmapData(diskURL, false));
		}
		
		return resourceAssets.get(url);
	}
	
	public function loadAtlas(atlasID:Int)
	{
		trace("Load Atlas: " + atlasID);
	
		var atlas = GameModel.get().atlases.get(atlasID);
		
		if(atlas != null && !atlas.active)
		{
			atlas.active = true;
			
			for(resourceID in atlas.members)
			{
				var resource = resources.get(resourceID);
				
				if(resource != null)
				{
					resource.loadGraphics();
				}
			}
		}
	}
	
	public function unloadAtlas(atlasID:Int)
	{
		#if(cpp || neko)
		trace("Unload Atlas: " + atlasID);
		
		var atlas = GameModel.get().atlases.get(atlasID);
		
		if(atlas != null && atlas.active)
		{
			atlas.active = false;
		
			for(resourceID in atlas.members)
			{
				var resource = resources.get(resourceID);
				
				if(resource != null)
				{
					resource.unloadGraphics();
				}
			}
		}
		#end
	}

	public function reloadScaledResources():Void
	{
		for(r in resources)
		{
			if(r == null)
				continue;
			if(Std.is(r, Sound) || Std.is(r, ActorType))
				continue;
			if(!r.isAtlasActive())
				continue;
			r.reloadGraphics(-1);
		}
	}
}