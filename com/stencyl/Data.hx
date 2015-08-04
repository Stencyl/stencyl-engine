package com.stencyl;

import com.stencyl.io.AbstractReader;
import com.stencyl.io.ActorTypeReader;
import com.stencyl.io.BackgroundReader;
import com.stencyl.io.BehaviorReader;
import com.stencyl.io.FontReader;
import com.stencyl.io.SoundReader;
import com.stencyl.io.SpriteReader;
import com.stencyl.io.TilesetReader;

import openfl.Assets;
import openfl.Lib;
import haxe.xml.Fast;

import com.stencyl.behavior.Behavior;
import com.stencyl.models.Scene;
import com.stencyl.models.Resource;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.GameModel;
import com.stencyl.models.Atlas;
import com.stencyl.models.Sound;
import openfl.display.Sprite;

class Data
{
	//*-----------------------------------------------
	//* Singleton
	//*-----------------------------------------------
	
	public static var instance:Data;
	private var loader:AssetLoader;
	public static var theLoader:AssetLoader;
	private var preloader:Sprite;

	public static function get():Data
	{
		if(instance == null)
		{
			#if scriptable

			Type.createInstance(Type.resolveClass("scripts.CppiaAssets"), []);
			
			#else
			
			instance = new Data();
			instance.loader = theLoader = Type.createInstance(Type.resolveClass("scripts.MyAssets"), []);
			
			#end

			#if(mobile && !air)
			
			instance.preloader = Type.createInstance(Type.resolveClass("scripts.StencylPreloader"), []);
			
			#end
			
			instance.loadAll();
		}
		
		return instance;
	}
	
	
	//*-----------------------------------------------
	//* Pluggable Reader Map
	//*-----------------------------------------------
	
	private var readers:Array<AbstractReader>;
	
	
	//*-----------------------------------------------
	//* Master XML Files
	//*-----------------------------------------------
	
	public var gameXML:Fast;
	public var resourceListXML:Fast;
	public var sceneListXML:Fast;
	public var behaviorListXML:Fast;
			
	
	//*-----------------------------------------------
	//* Data
	//*-----------------------------------------------
	
	//Map of each [sceneID].xml by ID
	public var scenesXML:Map<Int,String>;
	
	//Map of each [sceneID].scn by ID
	//public var scenesTerrain:Map<Int,Dynamic>;

	//Map of each resource in memory by ID
	public var resources:Map<Int,Resource>;

	//Map of each resource in memory by name
	public var resourceMap:Map<String,Resource>;

	//Map of each static asset by filename
	public var resourceAssets:Map<String,Dynamic>;
	
	//Map of each behavior by ID
	public var behaviors:Map<Int,Behavior>;
	

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
	
	public function updatePreloader(pct:Int)
	{
		//trace(pct);
		
		#if(mobile && !air)
		if(preloader != null)
		{
			Reflect.callMethod(preloader, Reflect.field(preloader, "onUpdate"), [pct, 100]);
		}
		#end
	}
	
	public function loadAll()
	{
		#if(mobile && !air)
		if(preloader != null)
		{
			Lib.current.addChild(preloader);
		}
		updatePreloader(0);
		#end
		
		gameXML = new Fast(Xml.parse(Assets.getText("assets/data/game.xml")).firstElement());
		resourceListXML = new Fast(Xml.parse(Assets.getText("assets/data/resources.xml")).firstElement());
		sceneListXML = new Fast(Xml.parse(Assets.getText("assets/data/scenes.xml")).firstElement());
		behaviorListXML = new Fast(Xml.parse(Assets.getText("assets/data/behaviors.xml")).firstElement());

		updatePreloader(5);

		loadReaders();
		loadBehaviors();
		
		updatePreloader(15);
		
		loadResources();
		
		updatePreloader(90);
		
		scenesXML = new Map<Int,String>();
		
		loader.loadScenes(scenesXML);
		
		updatePreloader(100);
		
		#if(mobile && !air)
		Lib.current.removeChild(instance.preloader);
		#end
		
		resourceListXML = null;
		behaviorListXML = null;		
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
	
	private function loadBehaviors()
	{
		behaviors = new Map<Int,Behavior>();
		
		#if(mobile && !air)
		var numParts = 0;
		
		for(e in behaviorListXML.elements)
		{
			numParts++;
		}
		
		var i = 0;
		var increment = 10.0 / numParts;
		#end
		
		for(e in behaviorListXML.elements)
		{
			//trace("Reading Behavior: " + e.att.name);
			
			#if(mobile && !air)
			updatePreloader(5 + Std.int(increment * i));
			#end
			
			behaviors.set(Std.parseInt(e.att.id), BehaviorReader.readBehavior(e));
			
			#if(mobile && !air)
			i++;
			#end
		}
	}
	
	private function loadResources()
	{
		resourceAssets = new Map<String,Dynamic>();	
		loader.loadResources(resourceAssets);
		updatePreloader(65);	
		readResourceXML(resourceListXML);

		resourceMap = new Map<String,Resource>();
		for(r in resources)
		{
			if(r == null)
				continue;
			if(Std.is(r, com.stencyl.models.actor.Sprite))
				resourceMap.set("Sprite_" + r.name, r);
			else
				resourceMap.set(r.name, r);
		}
	}
	
	private function readResourceXML(list:Fast)
	{
		resources = new Map<Int,Resource>();
		
		#if(mobile && !air)
		var numParts = 0;
		
		for(e in list.elements)
		{
			numParts++;
		}
		
		var i = 0;
		var increment = 10.0 / numParts;
		#end
		
		for(e in list.elements)
		{
			//trace("Reading: " + e.att.name);
			
			#if(mobile && !air)
			updatePreloader(65 + Std.int(increment * i));
			#end
			
			var atlasID = 0;
			
			if(e.has.atlasID)
			{
				atlasID = Std.parseInt(e.att.atlasID);
			}
			
			resources.set(Std.parseInt(e.att.id), readResource(Std.parseInt(e.att.id), atlasID, e.name, e.att.name, e));
			
			#if(mobile && !air)
			i++;
			#end
		}
	}
	
	private function readResource(ID:Int, atlasID:Int, type:String, name:String, xml:Fast):Resource
	{
		for(reader in readers)
		{
			if(reader.accepts(type))
			{
				return reader.read(ID, atlasID, type, name, xml);
			}
		}
		
		return null;
	}
	
	public function getResourcesOfType(type:Dynamic):Array<Dynamic>
	{
		var a:Array<Dynamic> = new Array<Dynamic>();
		
		for(r in resources)
		{
			if(Std.is(r, type))
			{
				a.push(r);
			}
		}
		
		return a;
	}
	
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
}
