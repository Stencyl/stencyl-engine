package com.stencyl;

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
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.GameModel;
import com.stencyl.models.Atlas;
import com.stencyl.models.Sound;
import com.stencyl.models.Font;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.ProgressEvent;
import haxe.xml.Fast;

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
		if(Assets.getText("stencyl:assets/data/game.xml") == "")
		{
			throw "Data.hx - Could not load game. Check your logs for a possible cause (likely a bad MP3 file).";
		}
	}
	
	public function loadAll()
	{
		gameXML = new Fast(Xml.parse(Assets.getText("stencyl:assets/data/game.xml")).firstElement());
		resourceListXML = new Fast(Xml.parse(Assets.getText("stencyl:assets/data/resources.xml")).firstElement());
		sceneListXML = new Fast(Xml.parse(Assets.getText("stencyl:assets/data/scenes.xml")).firstElement());
		behaviorListXML = new Fast(Xml.parse(Assets.getText("stencyl:assets/data/behaviors.xml")).firstElement());

		loadReaders();
		loadBehaviors();
		
		loadResources();
		
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
		
		for(e in behaviorListXML.elements)
		{
			//trace("Reading Behavior: " + e.att.name);
			
			behaviors.set(Std.parseInt(e.att.id), BehaviorReader.readBehavior(e));
		}
	}
	
	private function loadResources()
	{
		resourceAssets = new Map<String,Dynamic>();	
		
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
		
		for(e in list.elements)
		{
			//trace("Reading: " + e.att.name);
			
			var atlasID = 0;
			
			if(e.has.atlasID)
			{
				atlasID = Std.parseInt(e.att.atlasID);
			}
			
			resources.set(Std.parseInt(e.att.id), readResource(Std.parseInt(e.att.id), atlasID, e.name, e.att.name, e));
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
			resourceAssets.set(url, Assets.getBitmapData('stencyl:$diskURL', false));
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
