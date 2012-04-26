package ;

public class Data
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
			
			var cls:Class = getDefinitionByName("scripts.MyAssets") as Class;
			instance.loader = new cls(remote);
			theLoader = instance.loader;
			instance.loader.init(instance, numLeft, state);
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
	
	public function Data()
	{
		loadReaders();
	}
	
	public function loadAll():void
	{
		loadBehaviors();
		loadResources();
		loader.loadScenes();
	}
	
	private function loadReaders():void
	{
		readers = new Array<AbstractReader>();
		readers.push(new BackgroundReader());
		readers.push(new SoundReader());
		readers.push(new TilesetReader());
		readers.push(new ActorTypeReader());
		readers.push(new SpriteReader());
		readers.push(new FontReader());
	}
	
	private function loadBehaviors():void
	{
		behaviors = new Hash<Behavior>();
		
		for(e in behaviorListXML.nodes)
		{
			trace("Reading Behavior: " + e.att.name);
			behaviors.set(e.att.id, BehaviorReader.readBehavior(e));
		}
	}
	
	private function loadResources():void
	{
		resourceAssets = new Hash<Dynamic>();	
		loader.loadResources();		
		readResourceXML(resourceListXML);
	}
	
	private function readResourceXML(list:Fast):void
	{
		resources = new Array();
		
		for(e in list.nodes)
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
	
	public function getResourcesOfType(type:Class<Dynamic>):Array
	{
		var a:Array<Class<Dynamic>> = new Array<Class<Dynamic>>();
		
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
