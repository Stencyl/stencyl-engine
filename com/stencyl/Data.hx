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
import com.stencyl.utils.LazyIntMap;
import com.stencyl.utils.LazyStringMap;
import com.stencyl.utils.Utils;

import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsDynamicHelper.DynamicPool;
import mbs.io.MbsReader;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsDynamicList;

import haxe.CallStack;

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
	//* Master MBS Files
	//*-----------------------------------------------
	
	public var gameMbs:MbsReader;
	public var resourceListMbs:MbsReader;
	public var sceneListMbs:MbsReader;
	public var behaviorListMbs:MbsReader;
			
	
	//*-----------------------------------------------
	//* Data
	//*-----------------------------------------------
	
	//Map of each resource in memory by ID
	public var resources:LazyIntMap<Resource>;

	//Map of each resource in memory by name
	public var resourceMap:LazyStringMap<Resource>;

	//Map of each behavior by ID
	public var behaviors:LazyIntMap<Behavior>;
	

	private var resourceLookup:Map<Int,Int> = null; //id -> address
	private var resourceNameLookup:Map<String,Int> = null; //name -> id
	private var behaviorLookup:Map<Int,Int> = null; //id -> address

	private var behaviorReader:MbsSnippetDef = null;
	private var resourceReaderPool:DynamicPool = null;

	//*-----------------------------------------------
	//* Loading
	//*-----------------------------------------------
	
	public function new()
	{
		if(Assets.getBytes("assets/data/game.mbs") == null)
		{
			throw "Data.hx - Could not load game. Check your logs for a possible cause.";
		}
	}
	
	public function loadAll()
	{
		gameMbs = new MbsReader(Typedefs.get(), false, true);
		gameMbs.readData(Assets.getBytes("assets/data/game.mbs"));

		sceneListMbs = new MbsReader(Typedefs.get(), false, true);
		sceneListMbs.readData(Assets.getBytes("assets/data/scenes.mbs"));

		resourceListMbs = new MbsReader(Typedefs.get(), false, false);
		resourceListMbs.readData(Assets.getBytes("assets/data/resources.mbs"));

		behaviorListMbs = new MbsReader(Typedefs.get(), false, false);
		behaviorListMbs.readData(Assets.getBytes("assets/data/behaviors.mbs"));

		behaviors = LazyIntMap.fromFunction(loadBehaviorFromMbs);
		resources = LazyIntMap.fromFunction(loadResourceFromMbs);
		resourceMap = LazyStringMap.fromFunction(loadResourceFromMbsByName);

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

	@:access(mbs.io.MbsListBase)
	private function scanResourceMbs()
	{
		resourceLookup = new Map<Int,Int>();
		resourceNameLookup = new Map<String,Int>();

		var listReader:MbsDynamicList = cast resourceListMbs.getRoot();
		resourceReaderPool = MbsDynamicHelper.createObjectPool(resourceListMbs);
		
		var obj:MbsResource = new MbsResource(resourceListMbs);
		var intSize = mbs.core.MbsTypes.INTEGER.getSize();

		for(i in 0...listReader.length())
		{
			var dynAddress = listReader.elementAddress;
			var objAddress = resourceListMbs.readInt(dynAddress + intSize);
			listReader.elementAddress += listReader.elementSize;

			obj.setAddress(objAddress);
			resourceLookup.set(obj.getId(), dynAddress);
			
			var type = resourceListMbs.readTypecode(dynAddress);
			if(type == MbsSprite.MBS_SPRITE)
				resourceNameLookup.set("Sprite_" + obj.getName(), obj.getId());
			else
				resourceNameLookup.set(obj.getName(), obj.getId());
		}
	}

	private function loadResourceFromMbsByName(name:String):Resource
	{
		var id:Null<Int> = resourceNameLookup.get(name);
		if(id == null)
		{
			trace("Error: Resource with name " + name + " doesn't exist." + Utils.printCallstackIfAvailable());
			return null;
		}
		
		return loadResourceFromMbs(id);
	}

	private function loadResourceFromMbs(id:Int):Resource
	{
		var address:Null<Int> = resourceLookup.get(id);
		if(address == null)
		{
			trace("Error: resource with id " + id + " doesn't exist." + Utils.printCallstackIfAvailable());
			return null;
		}
		var obj:MbsObject = cast MbsDynamicHelper.readDynamicUsingPool(resourceListMbs, address, resourceReaderPool);

		var newResource = readResource(obj.getMbsType().getName(), obj);

		if(newResource != null)
		{
			resources.set(newResource.ID, newResource);

			if(Std.isOfType(newResource, Sprite))
				resourceMap.set("Sprite_" + newResource.name, newResource);
			else
				resourceMap.set(newResource.name, newResource);
		}

		return newResource;
	}

	@:access(mbs.io.MbsListBase)
	private function loadAllResourcesOfType(type:MbsType):Void
	{
		var listReader:MbsDynamicList = cast resourceListMbs.getRoot();
		
		var obj:MbsResource = new MbsResource(resourceListMbs);
		var intSize = mbs.core.MbsTypes.INTEGER.getSize();

		listReader.elementAddress = listReader.getAddress() + intSize * 2;
		for(i in 0...listReader.length())
		{
			var dynAddress = listReader.elementAddress;
			var objType = resourceListMbs.readTypecode(dynAddress);

			if(objType == type)
			{
				var objAddress = resourceListMbs.readInt(dynAddress + intSize);
				obj.setAddress(objAddress);
				loadResourceFromMbs(obj.getId());
			}
			
			listReader.elementAddress += listReader.elementSize;
		}
	}

	private function loadBehaviorFromMbs(id:Int):Behavior
	{
		var address = behaviorLookup.get(id);
		if(address == null)
			return null;
		
		behaviorReader.setAddress(address);
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

	private var actorTypesLoaded = false;
	
	public function getAllActorTypes():Array<ActorType>
	{
		if(!actorTypesLoaded)
		{
			loadAllResourcesOfType(MbsActorType.MBS_ACTOR_TYPE);
			actorTypesLoaded = true;
		}

		var a = new Array<ActorType>();
		
		for(r in resources)
		{
			if(Std.isOfType(r, ActorType))
			{
				a.push(cast(r, ActorType));
			}
		}
		
		return a;
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
		#if (cpp || hl)
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
			if(Std.isOfType(r, Sound) || Std.isOfType(r, ActorType))
				continue;
			if(!r.isAtlasActive())
				continue;
			r.reloadGraphics(-1);
		}
	}
}