package com.stencyl.models;

import haxe.xml.Fast;

import com.stencyl.io.SpriteReader;
import com.stencyl.utils.Utils;
import com.stencyl.models.scene.Autotile;
import com.stencyl.models.scene.AutotileFormat;

import box2D.common.math.B2Vec2;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;

import openfl.geom.Point;

class GameModel
{
	public static var instance:GameModel;
	
	public var name:String;

	public var width:Int;
	public var height:Int;
	public var actualWidth:Int;
	public var actualHeight:Int;
	public var scale:Int;
	
	public var defaultSceneID:Int;
	
	public var groups:Array<GroupDef>;
	public var groupsCollidesWith:Map<Int,Array<Int>>;
	public static var collisionMap:Array<Array<Bool>>;
	
	public var collisionGroups:Array<CollisionGroupDef>;
	public var gameAttributes:Map<String,Dynamic>;
	public var shapes:Map<Int,B2PolygonShape>;
	public var atlases:Map<Int,Atlas>;
	public var scenes:Map<Int,Scene>;
	public var autotileFormats:Map<Int, AutotileFormat>;
	
	public static var INHERIT_ID:Int = -1000;
	public static var REGION_ID:Int = -2;
	public static var PLAYER_ID:Int = 0;
	public static var TERRAIN_ID:Int = 1;
	public static var DOODAD_ID:Int = 2;
	public static var ACTOR_ID:Int = 3;
	
	public static function get():GameModel
	{
		if(instance == null)
		{
			instance = new GameModel(Data.get().gameXML);
		}
		
		return instance;
	}
	
	public function new(xml:Fast)
	{
		name = xml.att.name;

		width = Std.parseInt(xml.att.width);
		height = Std.parseInt(xml.att.height);
		actualWidth = Std.parseInt(xml.att.awidth);
		actualHeight = Std.parseInt(xml.att.aheight);
		scale = Std.parseInt(xml.att.scale);
		defaultSceneID = 0;
		
		try
		{
			defaultSceneID = Std.parseInt(xml.att.defaultSceneID);
		}
		
		catch(e:String)
		{
		}
		
		//---
		
		shapes = readShapes(xml.node.collisions.elements);
		atlases = readAtlases(xml.node.atlases.elements);
		autotileFormats = readAutotileFormats(xml.node.autotileFormats.elements);

		groups = readGroups(xml.node.groups.elements);
		groups.push(new GroupDef(REGION_ID, "Regions"));
		groups.push(new GroupDef(PLAYER_ID, "Players"));
		groups.push(new GroupDef(TERRAIN_ID, "Terrain"));
		groups.push(new GroupDef(DOODAD_ID, "Doodads"));
		groups.push(new GroupDef(ACTOR_ID, "Actors"));
		
		//---
		
		groupsCollidesWith = new Map<Int,Array<Int>>();
		
		collisionGroups = readCollisionGroups(xml.node.cgroups.elements);
		collisionGroups.push(new CollisionGroupDef(PLAYER_ID, TERRAIN_ID));
		collisionGroups.push(new CollisionGroupDef(ACTOR_ID, TERRAIN_ID));
		
		collisionMap = new Array<Array<Bool>>();
		
		var groupCount = 0;
			
		for(g in groups)
		{
			groupCount = Std.int(Math.max(Std.int(g.ID), groupCount));
		}
		
		groupCount++;
		
		for(i in 0...groupCount)
		{
			collisionMap.push(new Array<Bool>());
		
			for(j in 0...groupCount)
			{
				collisionMap[i].push(false);
			}
		}
		
		if(Engine.NO_PHYSICS)
		{
			for(g in groups)
			{
				collisionGroups.push(new CollisionGroupDef(g.ID, REGION_ID));
			}
		}
		
		for(cg in collisionGroups)
		{
			var g1 = cg.group1;
			var g2 = cg.group2;
			
			if(!groupsCollidesWith.exists(g1))
			{
				groupsCollidesWith.set(g1, new Array<Int>());
			}
			
			if(!groupsCollidesWith.exists(g2))
			{
				groupsCollidesWith.set(g2, new Array<Int>());
			}
			
			if(!Engine.NO_PHYSICS || (g1 >= 0 && g2 >= 0))
			{
				collisionMap[g1][g2] = true;
				collisionMap[g2][g1] = true;
			}
			
			groupsCollidesWith.get(g1).push(g2);
			groupsCollidesWith.get(g2).push(g1);
		}
		
		//---
		
		//Defined in MyScripts
		//readInput(xml.node.input.elements);
		
		gameAttributes = readGameAttributes(xml.node.attributes.elements);
				
		Data.get().gameXML = null;
	}
	
	public function loadScenes()
	{
		scenes = readScenes(Data.get().sceneListXML);
	}
	
	public function readScenes(list:Fast):Map<Int,Scene>
	{
		var map:Map<Int,Scene> = new Map<Int,Scene>();
		
		for(e in list.elements)
		{
			var sceneID = Std.parseInt(e.att.id);
			
			map.set(Std.parseInt(e.att.id), new Scene(sceneID, e.att.name));
		}
		
		Data.get().scenesXML = null;
		Data.get().sceneListXML = null;
		
		return map;
	}
	
	public function readShapes(list:Iterator<Fast>):Map<Int,B2PolygonShape>
	{
		var map:Map<Int,B2PolygonShape> = new Map<Int,B2PolygonShape>();
		
		for(e in list)
		{
			var s:String = e.att.pts;
			var pts = s.split("#");
			var vertices = new Array<B2Vec2>();
			
			for(pt in pts)
			{
				var ptArray = pt.split(",");
				var px = Std.parseFloat(ptArray[0]);
				var py = Std.parseFloat(ptArray[1]);
				vertices.push(new B2Vec2(px * 3.1, py * 3.1));
			}
			
			SpriteReader.EnsureCorrectVertexDirection(vertices);
			
			var p = new B2PolygonShape();
			p.setAsArray(vertices, vertices.length);
			map.set(Std.parseInt(e.att.id), p);
		}
		
		return map;
	}
	
	public function readAtlases(list:Iterator<Fast>):Map<Int,Atlas>
	{
		var map:Map<Int,Atlas> = new Map<Int,Atlas>();
		
		for(e in list)
		{
			var ID = Std.parseInt(e.att.id);
			var name = e.att.name;
			var mems = e.att.members.split(",");
			var allScenes = e.has.allScenes ?
				e.att.allScenes == "true" :
				e.att.start == "true";
			var members = new Array<Int>();
			
			if(e.att.members != "")
			{
				for(n in mems)
				{
					members.push(Std.parseInt(n));
				}
				
				members.pop();
			}
			
			map.set(ID, new Atlas(ID, name, allScenes, members)); 
		}
		
		return map;
	}

	public function readAutotileFormats(list:Iterator<Fast>):Map<Int, AutotileFormat>
	{
		var map = new Map<Int, AutotileFormat>();

		for(e in list)
		{
			var name = e.att.name;
			var id = Std.parseInt(e.att.id);
			var across = Std.parseInt(e.att.across);
			var down = Std.parseInt(e.att.down);

			var allCorners = new Array<Corners>();
			
			for(autotile in e.elements)
			{
				var cornerStrings = autotile.att.corners.split(" ");
				var corners = new Corners
				(
					readPoint(cornerStrings[0]),
					readPoint(cornerStrings[1]),
					readPoint(cornerStrings[2]),
					readPoint(cornerStrings[3])
				);
				
				for(range in autotile.att.flag.split(","))
				{
					if(range.indexOf("-") != -1)
					{
						var low = Std.parseInt(range.split("-")[0]);
						var high = Std.parseInt(range.split("-")[1]);
						
						for(k in low...high + 1)
						{
							allCorners[k] = corners;
						}
						
						continue;
					}
					
					allCorners[Std.parseInt(range)] = corners;
				}
			}
			
			map.set(id, new AutotileFormat(name, id, across, down, allCorners));
		}

		return map;
	}

	private function readPoint(s:String):Point
	{
		var coords = s.split(",");
		return new Point(Std.parseInt(coords[0]), Std.parseInt(coords[1]));
	}
	
	public function readGroups(list:Iterator<Fast>):Array<GroupDef>
	{
		var map:Array<GroupDef> = new Array<GroupDef>();
		
		for(e in list)
		{
			map.push(new GroupDef(Std.parseInt(e.att.id), e.att.name));
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
	
	public static function readGameAttributes(list:Iterator<Fast>):Map<String,Dynamic>
	{
		var map:Map<String,Dynamic> = new Map<String,Dynamic>();
		
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
			
			else if(type == "bool" || type == "boolean")
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
			
			else if(type == "map")
			{
				var value:Map<String,Dynamic> = new Map<String,Dynamic>();
				
				for(item in e.elements)
				{
					//TODO MIKE: Support references
					value.set(item.att.key, item.att.value);
				}
				
				map.set(e.att.name, value);
			}
		}
		
		return map;
	}
}