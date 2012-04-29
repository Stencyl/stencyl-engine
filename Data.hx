package ;

import io.AbstractReader;
import io.ActorTypeReader;
import io.BackgroundReader;
import io.BehaviorReader;
import io.FontReader;
import io.SoundReader;
import io.SpriteReader;
import io.TilesetReader;
import haxe.xml.Fast;

import behavior.Behavior;
import models.Scene;
import models.Resource;

class Data
{
	//*-----------------------------------------------
	//* Singleton
	//*-----------------------------------------------
	
	public static var instance:Data;
	private var loader:AssetLoader;
	public static var theLoader:AssetLoader;
	
	public static function get(remote:Bool = false, numLeft:Int = 0, state:Engine=null):Data
	{
		if(instance == null)
		{
			instance = new Data();
			
			var loader = Type.createInstance(Type.resolveClass("scripts.MyAssets"), [remote]);
			loader.init(instance, numLeft, state);
			
			/*var cls:Class = getDefinitionByName("scripts.MyAssets") as Class;
			instance.loader = new cls(remote);
			theLoader = instance.loader;
			instance.loader.init(instance, numLeft, state);*/
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
	public var scenesXML:Hash<Fast>;
	
	//Map of each [sceneID].scn by ID
	public var scenesTerrain:Hash<Scene>;

	//Map of each resource in memory by ID
	public var resources:Hash<Resource>;
	
	//Map of each static asset by filename
	public var resourceAssets:Hash<Dynamic>;
	
	//Map of each behavior by ID
	public var behaviors:Hash<Behavior>;
	

	//*-----------------------------------------------
	//* Loading
	//*-----------------------------------------------
	
	public function new()
	{
		loadReaders();
	}
	
	public function loadAll()
	{
		loadBehaviors();
		loadResources();
		loader.loadScenes();
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
		behaviors = new Hash<Behavior>();
		
		for(e in behaviorListXML.elements)
		{
			trace("Reading Behavior: " + e.att.name);
			behaviors.set(e.att.id, BehaviorReader.readBehavior(e));
		}
	}
	
	private function loadResources()
	{
		resourceAssets = new Hash<Dynamic>();	
		loader.loadResources();		
		readResourceXML(resourceListXML);
	}
	
	private function readResourceXML(list:Fast)
	{
		resources = new Hash<Resource>();
		
		for(e in list.elements)
		{
			trace("Reading: " + e.att.name);
			resources.set(e.att.id, readResource(Std.parseInt(e.att.id), e.name, e.att.name, e));
		}
	}
	
	private function readResource(ID:Int, type:String, name:String, xml:Fast):Resource
	{
		for(reader in readers)
		{
			if(reader.accepts(type))
			{
				return reader.read(ID, type, name, xml);
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
}
