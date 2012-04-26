package models;

import haxe.xml.Fast;

class GameModel
{
	public static var instance:GameModel;
	
	public var width:Int;
	public var height:Int;
	public var actualWidth:Int;
	public var actualHeight:Int;
	public var scale:Int;
	
	public var defaultSceneID:Int;
	
	public var groups:Array<GroupDef>;
	public var collisionGroups:Array<CollisionGroupDef>;
	public var gameAttributes:Hash<Dynamic>;
	public var scenes:Array<Scene>;
	
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
		defaultSceneID = Std.parseInt(xml.att.defaultSceneID);
		
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
		
		readInput(xml.node.input.elements);
		gameAttributes = readGameAttributes(xml.node.attributes.elements);
		//TODO: scenes = readScenes(Assets.get().sceneListXML);	
	}
	
	public function readScenes(list:Fast):Array<Scene>
	{
		var map:Array<Scene> = new Array<Scene>();
		
		for(e in list.elements)
		{
			var sceneID = Std.parseInt(e.att.id);
		
			trace("Loading Scene " + sceneID);
			//TODO: map[sceneID] = new Scene(sceneID, e.att.name, Assets.get().scenesXML[sceneID]);
		}
		
		return map;
	}
	
	public function readGroups(list:Iterator<Fast>):Array<GroupDef>
	{
		var map:Array<GroupDef> = new Array<GroupDef>();
		
		for(e in list)
		{
			map[Std.parseInt(e.att.id)] = new GroupDef(Std.parseInt(e.att.id), e.att.name);
		}
		
		return map;
	}
	
	public function readCollisionGroups(list:Iterator<Fast>):Array<CollisionGroupDef>
	{
		var map:Array<CollisionGroupDef> = new Array();
		
		for(e in list)
		{
			map.push(new CollisionGroupDef(Std.parseInt(e.att.g1), Std.parseInt(e.att.g2)));
		}
		
		return map;
	}
	
	public function readInput(list:Iterator<Fast>):Void
	{
		for(e in list)
		{
			//map["_" + e.att.name] = e.att.keyname; 
			
			//TODO:
			//Input.define("left", [Key.A, Key.LEFT]);
		}
	}
	
	public static function readGameAttributes(list:Iterator<Fast>):Hash<Dynamic>
	{
		var map:Hash<Dynamic> = new Hash<Dynamic>();
		
		for(e in list)
		{
			var type:String = e.name;
			
			if(type == "number")
			{
				var num:Float = Std.parseFloat(e.att.value);
				map.set(e.att.name, num);
			}
			
			else if(type == "text")
			{
				var str:String = e.att.value;
				map.set(e.att.name, str);
			}
			
			else if(type == "bool")
			{
				var bool:Bool = Utils.toBoolean(e.att.value);
				map.set(e.att.name, bool);
			}
			
			else if(type == "list")
			{
				var value:Array<Dynamic> = new Array<Dynamic>();
				
				for(item in e.elements)
				{
					var order:Int = Std.parseInt(item.att.order);
					value[order] = item.att.value;
				}
				
				map.set(e.att.name, value);
			}
		}
		
		return map;
	}
}
