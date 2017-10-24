package com.stencyl.models;

import com.stencyl.io.mbs.game.autotile.*;
import com.stencyl.io.mbs.game.*;
import com.stencyl.io.mbs.scene.MbsSceneHeader;
import com.stencyl.io.AttributeValues;
import com.stencyl.io.ShapeReader;
import com.stencyl.utils.Utils;
import com.stencyl.models.scene.Autotile;
import com.stencyl.models.scene.AutotileFormat;

import box2D.common.math.B2Vec2;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;

import openfl.geom.Point;

import mbs.io.*;
import mbs.io.MbsListBase.*;

class GameModel
{
	public static var instance:GameModel;
	
	public static function resetStatics():Void
	{
		instance = null;
		collisionMap = null;
	}

	public var groups:Array<GroupDef>;
	public var groupsCollidesWith:Map<Int,Array<Int>>;
	public static var collisionMap:Array<Array<Bool>>;
	
	public var collisionGroups:Array<CollisionGroupDef>;
	public var gameAttributes:Map<String,Dynamic>;
	public var shapes:Map<Int,B2PolygonShape>;
	public var atlases:Map<Int,Atlas>;
	public var scenes:Map<Int,Scene>;
	public var autotileFormats:Map<Int, AutotileFormat>;
	
	public static inline var INHERIT_ID:Int = -1000;
	public static inline var REGION_ID:Int = -2;
	public static inline var PLAYER_ID:Int = 0;
	public static inline var TERRAIN_ID:Int = 1;
	public static inline var DOODAD_ID:Int = 2;
	public static inline var ACTOR_ID:Int = 3;
	
	public static function get():GameModel
	{
		if(instance == null)
		{
			instance = new GameModel();
		}
		
		return instance;
	}
	
	public function new()
	{
		var mg:MbsGame = cast Data.get().gameMbs.getRoot();
		
		shapes = readShapes(mg);
		atlases = readAtlases(mg);
		autotileFormats = readAutotileFormats(mg);

		groups = readGroups(mg);
		groups.push(new GroupDef(REGION_ID, "Regions"));
		groups.push(new GroupDef(PLAYER_ID, "Players"));
		groups.push(new GroupDef(TERRAIN_ID, "Terrain"));
		groups.push(new GroupDef(DOODAD_ID, "Doodads"));
		groups.push(new GroupDef(ACTOR_ID, "Actors"));
		
		//---
		
		groupsCollidesWith = new Map<Int,Array<Int>>();
		
		collisionGroups = readCollisionGroups(mg);

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
		
		gameAttributes = readGameAttributes(mg);
				
		Data.get().gameMbs = null;
	}
	
	public function loadScenes()
	{
		scenes = new Map<Int,Scene>();
		
		var list:MbsList<MbsSceneHeader> = cast Data.get().sceneListMbs.getRoot();
		for(i in 0...list.length())
		{
			var header = list.getNextObject();
			var sceneID = header.getId();
			
			scenes.set(sceneID, new Scene(sceneID, header.getName()));
		}
		
		Data.get().sceneListMbs = null;
	}
	
	public function readShapes(mg:MbsGame):Map<Int,B2PolygonShape>
	{
		var map:Map<Int,B2PolygonShape> = new Map<Int,B2PolygonShape>();
		
		var list = mg.getShapes();

		for(i in 0...list.length())
		{
			var colShape = list.getNextObject();
			var ptList = colShape.getPoints();

			var vertices = new Array<B2Vec2>();
			
			for(pt in ShapeReader.readPoints(ptList))
			{
				vertices.push(new B2Vec2(pt.x * 3.1, pt.y * 3.1));
			}
			
			ShapeReader.EnsureCorrectVertexDirection(vertices);
			
			var p = new B2PolygonShape();
			p.setAsArray(vertices, vertices.length);
			map.set(colShape.getId(), p);
		}
		
		return map;
	}
	
	public function readAtlases(mg:MbsGame):Map<Int,Atlas>
	{
		var map:Map<Int,Atlas> = new Map<Int,Atlas>();
		
		var list = mg.getAtlases();

		for(i in 0...list.length())
		{
			var atlas = list.getNextObject();
			var ID = atlas.getId();
			var name = atlas.getName();
			var allScenes = atlas.getAllScenes();
			
			var memList = atlas.getMembers();
			var members = [for(j in 0...memList.length()) memList.readInt()];
			
			map.set(ID, new Atlas(ID, name, allScenes, members));
		}
		
		return map;
	}

	public function readAutotileFormats(mg:MbsGame):Map<Int, AutotileFormat>
	{
		var map = new Map<Int, AutotileFormat>();

		var list = mg.getAutotileFormats();

		for(i in 0...list.length())
		{
			var atf = list.getNextObject();
			var name = atf.getName();
			var id = atf.getId();
			var across = atf.getAcross();
			var down = atf.getDown();

			var allCorners = new Array<Corners>();
			var cornersMap = new Array<Corners>();
			
			var cornersList = atf.getCorners();

			for(cornersIndex in 0...cornersList.length())
			{
				var mbsCorners = cornersList.getNextObject();

				cornersMap.push(new Corners
				(
					ShapeReader.readPoint(mbsCorners.getTopLeft()),
					ShapeReader.readPoint(mbsCorners.getTopRight()),
					ShapeReader.readPoint(mbsCorners.getBottomLeft()),
					ShapeReader.readPoint(mbsCorners.getBottomRight())
				));
			}

			var mbsFlags = atf.getFlags();

			for(fi in 0...mbsFlags.length())
			{
				allCorners[fi] = cornersMap[mbsFlags.readInt()];
			}
			
			map.set(id, new AutotileFormat(name, id, across, down, allCorners));
		}

		return map;
	}
	
	public function readGroups(mg:MbsGame):Array<GroupDef>
	{
		var map:Array<GroupDef> = new Array<GroupDef>();
		
		var list = mg.getGroups();
		
		for(i in 0...list.length())
		{
			var group = list.getNextObject();
			map.push(new GroupDef(group.getId(), group.getName()));
		}
		
		return map;
	}
	
	public function readCollisionGroups(mg:MbsGame):Array<CollisionGroupDef>
	{
		var map:Array<CollisionGroupDef> = new Array();
		
		var list = mg.getCgroups();

		for(i in 0...list.length())
		{
			var cpair = list.getNextObject();
			map.push(new CollisionGroupDef(cpair.getGroup1(), cpair.getGroup2()));
		}
		
		return map;
	}
	
	public static function readGameAttributes(mg:MbsGame):Map<String,Dynamic>
	{
		return AttributeValues.readMap(mg.getGameAttributes());
	}
}