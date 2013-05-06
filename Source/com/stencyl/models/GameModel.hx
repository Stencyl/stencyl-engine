package com.stencyl.models;

import haxe.xml.Fast;

import com.stencyl.io.SpriteReader;
import com.stencyl.utils.Utils;

import box2D.common.math.B2Vec2;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;

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
	public var groupsCollidesWith:IntHash<Array<Int>>;
	public static var collisionMap:Array<Array<Bool>>;
	
	public var collisionGroups:Array<CollisionGroupDef>;
	public var gameAttributes:Hash<Dynamic>;
	public var shapes:IntHash<B2PolygonShape>;
	public var atlases:IntHash<Atlas>;
	public var scenes:IntHash<Scene>;
	
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
		
		groups = readGroups(xml.node.groups.elements);
		groups.push(new GroupDef(REGION_ID, "Regions"));
		groups.push(new GroupDef(PLAYER_ID, "Players"));
		groups.push(new GroupDef(TERRAIN_ID, "Terrain"));
		groups.push(new GroupDef(DOODAD_ID, "Doodads"));
		groups.push(new GroupDef(ACTOR_ID, "Actors"));
		
		//---
		
		groupsCollidesWith = new IntHash<Array<Int>>();
		
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
			
			if(!Engine.NO_PHYSICS)
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
	}
	
	public function loadScenes()
	{
		scenes = readScenes(Data.get().sceneListXML);
	}
	
	public function readScenes(list:Fast):IntHash<Scene>
	{
		var map:IntHash<Scene> = new IntHash<Scene>();
		
		for(e in list.elements)
		{
			var sceneID = Std.parseInt(e.att.id);
			var data = Data.get().scenesXML.get(Std.parseInt(e.att.id));
			
			map.set(Std.parseInt(e.att.id), new Scene(sceneID, e.att.name, data));
		}
		
		return map;
	}
	
	public function readShapes(list:Iterator<Fast>):IntHash<B2PolygonShape>
	{
		var map:IntHash<B2PolygonShape> = new IntHash<B2PolygonShape>();
		
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
	
	public function readAtlases(list:Iterator<Fast>):IntHash<Atlas>
	{
		var map:IntHash<Atlas> = new IntHash<Atlas>();
		
		for(e in list)
		{
			var ID = Std.parseInt(e.att.id);
			var name = e.att.name;
			var mems = e.att.members.split(",");
			var active = e.att.start == "true";
			var members = new Array<Int>();
			
			for(n in mems)
			{
				members.push(Std.parseInt(n));
			}

			map.set(ID, new Atlas(ID, name, members, active));
		}
		
		return map;
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