package models;

class GameModel
{
	public static var instance:GameModel;
	
	public var width:Number;
	public var height:Number;
	public var actualWidth:Number;
	public var actualHeight:Number;
	public var scale:Number;
	
	public var defaultSceneID:Number;
	
	public var groups:Array;
	public var collisionGroups:Array;
	public var controller:Array;
	public var gameAttributes:Hash<Dynamic>;
	
	public var scenes:Array
	
	public static var REGION_ID:Int = -2;
	public static var PLAYER_ID:Int = 0;
	public static var TERRAIN_ID:Int = 1;
	public static var DOODAD_ID:Int = 2;
	public static var ACTOR_ID:Int = 3;
	
	public static function get():GameModel
	{
		if(instance == null)
		{
			//TODO
			//instance = new GameModel(Assets.get().gameXML);
		}
		
		return instance;
	}
	
	public function new(xml:Fast)
	{
		width = Std.parseInt(xml.att.width);
		height = Std.parseInt(xml.att.height);
		actualWidth = Std.parseInt(xml.att.awidth);
		actualHeight = Std.parseInt(xml.att.aheight);
		scale = Std.parseInt(xml.att.scale);
		defaultSceneID = Std.parseInt(xml.att.default);
		
		//---
		
		groups = readGroups(xml.node.groups.elements);
		groups[REGION_ID] = new GroupDef(REGION_ID, "Regions");
		groups[PLAYER_ID] = new GroupDef(PLAYER_ID, "Players");
		groups[TERRAIN_ID] = new GroupDef(TERRAIN_ID, "Terrain");
		groups[DOODAD_ID] = new GroupDef(DOODAD_ID, "Doodads");
		groups[ACTOR_ID] = new GroupDef(ACTOR_ID, "Actors");
		
		//---
		
		collisionGroups = readCollisionGroups(xml.node.cgroups.elements);
		collisionGroups.push(new CollisionGroupDef(PLAYER_ID, TERRAIN_ID));
		collisionGroups.push(new CollisionGroupDef(ACTOR_ID, TERRAIN_ID));
		
		//---
		
		controller = readInput(xml.node.input.elements);
		gameAttributes = readGameAttributes(xml.node.attributes.elements);
		//TODO: scenes = readScenes(Assets.get().sceneListXML);	
	}
	
	public function readScenes(list:Fast):Array<Scene>
	{
		var map:Array<Scene> = new Array<Scene>();
		
		for(e in list)
		{
			trace("Loading Scene " + e.att.id);
			map[e.att.id] = new Scene(e.att.id, e.att.name, Assets.get().scenesXML[e.att.id]);
		}
		
		return map;
	}
	
	public function readGroups(list:Array<Fast>):Array<GroupDef>
	{
		var map:Array<GroupDef> = new Array<GroupDef>();
		
		for(e in list)
		{
			map[e.att.id] = new GroupDef(e.att.id, e.att.name);
		}
		
		return map;
	}
	
	public function readCollisionGroups(list:Array<Fast>):Array<CollisionGroupDef>
	{
		var map:Array<CollisionGroupDef> = new Array();
		
		for(e in list)
		{
			map.push(new CollisionGroupDef(e.att.g1, e.att.g2));
		}
		
		return map;
	}
	
	public function readInput(list:Array<Fast>):Array
	{
		var map:Array<String> = new Array<String>();
		
		for(e in list)
		{
			map["_" + e.att.name] = e.att.keyname; 
		}
		
		return map;
	}
	
	public static function readGameAttributes(list:Array<Fast>):Hash
	{
		var map:Hash<Dynamic> = new Hash<Dynamic>();
		
		for(e in list)
		{
			var type:String = e.name;
			
			if(type == "number")
			{
				var num:Number = e.att.value;
				map[e.att.name] = num;
			}
			
			else if(type == "text")
			{
				var str:String = e.att.value;
				map[e.att.name] = str;
			}
			
			else if(type == "bool")
			{
				var bool:Boolean = Utils.toBoolean(e.att.value);
				map[e.att.name] = bool;
			}
			
			else if(type == "list")
			{
				var value:Array = new Array();
				
				for(item in e.nodes)
				{
					var order:Int = Std.parseInt(item.att.order);
					value[order] = item.att.value;
				}
				
				map[e.att.name] = value;
			}
		}
		
		return map;
	}
}
