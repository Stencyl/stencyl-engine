package com.stencyl.models;

import polygonal.ds.IntHashTable;
import polygonal.ds.HashTable;

import com.stencyl.behavior.BehaviorInstance;
import com.stencyl.graphics.BlendModes;

import com.stencyl.io.mbs.scene.layers.*;
import com.stencyl.io.mbs.scene.physics.*;
import com.stencyl.io.mbs.scene.*;
import com.stencyl.io.mbs.scene.MbsScene.*;
import com.stencyl.io.mbs.shape.*;
import com.stencyl.io.mbs.Typedefs;
import com.stencyl.io.AttributeValues;
import com.stencyl.io.BackgroundReader;
import com.stencyl.io.ActorTypeReader;
import com.stencyl.io.ShapeReader;

import com.stencyl.models.background.ColorBackground;
import com.stencyl.models.background.GradientBackground;
import com.stencyl.models.collision.Mask;
import com.stencyl.models.scene.layers.BackgroundLayer;
import com.stencyl.models.scene.layers.RegularLayer;
import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.Tileset;
import com.stencyl.models.scene.TileLayer;
import com.stencyl.models.scene.Layer;
import com.stencyl.models.scene.ActorInstance;
import com.stencyl.models.scene.RegionDef;
import com.stencyl.models.scene.TerrainDef;
import com.stencyl.models.scene.Wireframe;

import com.stencyl.utils.Assets;
import com.stencyl.utils.PolyDecompBayazit;
import com.stencyl.utils.Utils;
import com.stencyl.Engine;

import openfl.display.BlendMode;
import openfl.geom.Point;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.joints.B2Joint;
import box2D.dynamics.joints.B2JointDef;
import box2D.dynamics.joints.B2DistanceJointDef;
import box2D.dynamics.joints.B2RevoluteJointDef;
import box2D.dynamics.joints.B2LineJointDef;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Math;

import haxe.ds.Vector;
import haxe.xml.Fast;

import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.*;
import mbs.io.MbsListBase.MbsDynamicList;
import mbs.io.MbsListBase.MbsIntList;

class Scene
{
	public var ID:Int;
	public var name:String;
	
	public var sceneWidth:Int;
	public var sceneHeight:Int;
	
	public var tileWidth:Int;
	public var tileHeight:Int;
	
	public var gravityX:Float;
	public var gravityY:Float;
	
	public var eventID:Int;
	
	public var colorBackground:Background;
	public var layers:IntHashTable<RegularLayer>;
	
	public var actors:Map<Int,ActorInstance>;
	public var behaviorValues:Map<String,BehaviorInstance>;
	public var atlases:Array<Int>;

	public var retainsAtlases:Bool;

	//Box2D
	public var wireframes:Array<Wireframe>;
	public var joints:Map<Int,B2JointDef>;
	public var regions:Map<Int,RegionDef>;
	public var terrainRegions:Map<Int,TerrainDef>;
	
	public var animatedTiles:Array<Tile>;
	
	public function new(ID:Int, name:String)
	{
		this.ID = ID;
		this.name = name;
	}
	
	public function load()
	{
		var r = new MbsReader(Typedefs.get(), false, true);
		r.readData(Assets.getBytes("assets/data/scene-" + ID + ".mbs"));
		
		var scene:MbsScene = cast r.getRoot();

		var numTileLayers = scene.getDepth();
		
		sceneWidth = scene.getWidth();
		sceneHeight = scene.getHeight();
		
		tileWidth = scene.getTileWidth();
		tileHeight = scene.getTileHeight();
		
		gravityX = scene.getGravityX();
		gravityY = scene.getGravityY();
		
		animatedTiles = new Array<Tile>();
		
		actors = readActors(scene.getActorInstances());
		behaviorValues = AttributeValues.readBehaviors(scene.getSnippets());
		
		var eventSnippetID = scene.getEventSnippetID();
		
		if(eventSnippetID > -1)
		{
			behaviorValues.set(""+eventSnippetID, new BehaviorInstance(eventSnippetID, new Map<String,Dynamic>()));
		}
		
		joints = readJoints(scene.getJoints());
		regions = readRegions(scene.getRegions());
		terrainRegions = readTerrainRegions(scene.getTerrainRegions());
		
		wireframes = readWireframes(scene.getTerrain());
		
		var bytes = Assets.getBytes("assets/data/scene-" + ID + ".scn");
		bytes.endian = openfl.utils.Endian.BIG_ENDIAN;
		var rawLayers = readRawLayers(bytes, numTileLayers);
		
		layers = readAllLayers(scene.getLayers(), rawLayers);

		retainsAtlases = scene.getRetainAtlases();
		
		if(!retainsAtlases)
			atlases = readAtlases(scene.getAtlasMembers());
		else
			atlases = new Array<Int>();
	}
	
	public function unload()
	{
		colorBackground = null;
	
		actors = null;
		behaviorValues = null;
		layers = null;
		
		//Box2D
		wireframes = null;
		joints = null;
		regions = null;
		terrainRegions = null;
	
		animatedTiles = null;
	}
	
	public function readRegions(list:MbsList<MbsRegion>):Map<Int,RegionDef>
	{
		var map = new Map<Int,RegionDef>();
		
		for(i in 0...list.length())
		{
			var r:RegionDef = readRegion(list.getNextObject());
			map.set(r.ID, r);
		}
		
		return map;
	}
	
	public function readRegion(r:MbsRegion):RegionDef
	{
		var elementID = r.getId();
		var name = r.getName();
		var region:RegionDef;
		
		var x:Float = r.getX();
		var y:Float = r.getY();
		
		var shape:B2Shape = null;
		var ps = new Array<B2PolygonShape>();
		shapeList = new Array<B2Shape>();
		var decompParams:Array<String>;

		var shapeData = r.getShape();
		
		if(Std.is(shapeData, MbsPolyRegion))
		{
			var polygon:MbsPolyRegion = cast shapeData;
			var w = currW = polygon.getWidth();
			var h = currH = polygon.getHeight();

			var ptList = polygon.getPoints();
			
			if(Engine.NO_PHYSICS)
			{
				region = new RegionDef(shapeList, elementID, name, x, y, 0, new Rectangle(0, 0, w, h));
			}
			
			else
			{
				var points = ShapeReader.readPoints(ptList).toArray();
				var decomp = new PolyDecompBayazit(points);
				decomp.decompose(addPolygonRegion);
				region = new RegionDef(shapeList, elementID, name, x, y);
			}
		}
			
		else
		{
			var circle:MbsCircle = cast shapeData;
			var radius = circle.getRadius();
			
			if(Engine.NO_PHYSICS)
			{
				region = new RegionDef(shapeList, elementID, name, x, y, 0, new Rectangle(0, 0, radius*2, radius*2));
			}
			
			else
			{
				shape = new B2CircleShape();
				shape.m_radius = Engine.toPhysicalUnits(radius);
				shapeList[0] = shape;
				region = new RegionDef(shapeList, elementID, name, x, y);
			}
		}
		
		return region;
	}
	
	var shapeList:Array<B2Shape>;
	var currW:Int = 0;
	var currH:Int = 0;
	
	function addPolygonRegion(p:PolyDecompBayazit)
	{
   		trace("THE POLY: " + p.points);
   		trace(currW + ", " + currH);

   		var polyShape = cast(ShapeReader.createPolygon("MbsPolyRegion", p.points, currW, currH), B2PolygonShape);
		shapeList.push(polyShape);
	}
	
	function addPolygonTerrain(p:PolyDecompBayazit)
	{
		trace("THE POLY: " + p.points);
		trace(currW + ", " + currH);
		
		var polyShape = cast(ShapeReader.createPolygon("MbsPolyRegion", p.points, currW, currH), B2PolygonShape);
		shapeList.push(polyShape);
	}
	
	public function readTerrainRegions(list:MbsList<MbsTerrainRegion>):Map<Int,TerrainDef>
	{
		var map = new Map<Int,TerrainDef>();
		
		for(i in 0...list.length())
		{
			var r:TerrainDef = readTerrainRegion(list.getNextObject());
			map.set(r.ID, r);
		}
		
		return map;
	}
	
	public function readTerrainRegion(r:MbsTerrainRegion):TerrainDef
	{
		var elementID = r.getId();
		var name = r.getName();
		var group = r.getGroupID();
		var terrainRegion:TerrainDef;
		
		var x:Float = Engine.toPhysicalUnits(r.getX());
		var y:Float = Engine.toPhysicalUnits(r.getY());
		var fillColor = r.getColor();
		
		var shape:B2Shape = null;
		var ps = new Array<B2PolygonShape>();
		shapeList = new Array<B2Shape>();
		var decompParams:Array<String>;

		var shapeData = r.getShape();
		
		if(Std.is(shapeData, MbsPolyRegion))
		{
			var polygon:MbsPolyRegion = cast shapeData;
			currW = polygon.getWidth();
			currH = polygon.getHeight();

			var points = ShapeReader.readPoints(polygon.getPoints()).toArray();
			var decomp = new PolyDecompBayazit(points);
			decomp.decompose(addPolygonTerrain);
			terrainRegion = new TerrainDef(shapeList, elementID, name, x, y, group, fillColor);
		}
		
		else
		{
			var circle:MbsCircle = cast shapeData;
			var radius:Float = circle.getRadius();
			shape = new B2CircleShape();
			shape.m_radius = Engine.toPhysicalUnits(radius);
			shapeList[0] = shape;
			terrainRegion = new TerrainDef(shapeList, elementID, name, x, y, group, fillColor);
		}
		
		return terrainRegion;
	}
	
	public function readJoints(list:MbsDynamicList):Map<Int,B2JointDef>
	{
		var map = new Map<Int,B2JointDef>();
		
		for(i in 0...list.length())
		{
			var j = readJoint(cast list.readObject());
			map.set(j.ID, j);
		}
		
		return map;
	}
	
	public function readJoint(r:MbsJoint):B2JointDef
	{
		var elementID = r.getId();
		
		var a1 = r.getActor1();
		var a2 = r.getActor2();
		var collide = r.getCollide();
		
		if(Std.is(r, MbsStickJoint))
		{
			var j = new B2DistanceJointDef();
			var r2:MbsStickJoint = cast r;

			j.ID = elementID;
			j.actor1 = a1;
			j.actor2 = a2;
			j.localAnchorA = null;
			j.localAnchorB = null;
			j.collideConnected = collide;
			
			//---
			
			j.dampingRatio = r2.getDamping();
			j.frequencyHz = r2.getFrequency();
			
			return j;
		}
		
		else if(Std.is(r, MbsHingeJoint))
		{
			var j2 = new B2RevoluteJointDef();
			var r2:MbsHingeJoint = cast r;

			j2.ID = elementID;
			j2.actor1 = a1;
			j2.actor2 = a2;
			j2.localAnchorA = null;
			j2.localAnchorB = null;
			j2.collideConnected = collide;
			
			//---
			
			j2.enableLimit = r2.getLimit();
			j2.enableMotor = r2.getMotor();
			j2.lowerAngle = r2.getLower();
			j2.upperAngle = r2.getUpper();
			j2.maxMotorTorque = r2.getTorque();
			j2.motorSpeed = r2.getSpeed();
			
			return j2;
		}
		
		else if(Std.is(r, MbsSlidingJoint))
		{
			var j3 = new B2LineJointDef();
			var r2:MbsSlidingJoint = cast r;
			
			j3.ID = elementID;
			j3.actor1 = a1;
			j3.actor2 = a2;
			j3.localAnchorA = null;
			j3.localAnchorB = null;
			j3.collideConnected = collide;
			
			//---
			
			j3.enableLimit = r2.getLimit();
			j3.enableMotor = r2.getMotor();
			j3.lowerTranslation = r2.getLower();
			j3.upperTranslation = r2.getUpper();
			j3.maxMotorForce = r2.getForce();
			j3.motorSpeed = r2.getSpeed();
			j3.localAxisA.x = r2.getX();
			j3.localAxisA.y = r2.getY();
			
			return j3;
		}
		
		trace("Error: unsuppported joint type: " + type);
		
		return null;
	}

	public function readAllLayers(list:MbsDynamicList, rawLayers:IntHashTable<TileLayer>):IntHashTable<RegularLayer>
	{
		var map:IntHashTable<RegularLayer> = new IntHashTable<RegularLayer>(16);
		map.reuseIterator = true;

		for(i in 0...list.length())
		{
			var dyn = list.readObject();
			
			if(Std.is(dyn, MbsColorBackground) || Std.is(dyn, MbsGradientBackground))
				colorBackground = readColorBackground(dyn);
			else
			{
				var r:MbsLayer = cast dyn;

				var ID:Int = r.getId();
				var name:String = r.getName();
				var order:Int = r.getOrder();
				var scrollFactorX:Float = r.getScrollFactorX();
				var scrollFactorY:Float = r.getScrollFactorY();
				var opacity:Float = r.getOpacity() / 100;
				var blendMode:BlendMode = BlendModes.get(r.getBlendmode());

				if(Std.is(dyn, MbsInteractiveLayer))
				{
					var tileLayer:TileLayer = rawLayers.get(ID);
					if(tileLayer == null)
						tileLayer = new TileLayer(ID, this, Std.int(Math.floor(sceneWidth / tileWidth)), Std.int(Math.floor(sceneHeight / tileHeight)));
					tileLayer.name = name;

					var layer:Layer = new Layer(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode, tileLayer);

					map.set(layer.ID, layer);
				}
				else if(Std.is(dyn, MbsImageBackground))
				{
					//Need to change order, atlases aren't loaded yet
					var bgR:MbsImageBackground = cast dyn;
					var bgID = bgR.getResourceID();
					var customScroll = bgR.getCustomScroll();

					var layer:BackgroundLayer = new BackgroundLayer(ID, name, order, scrollFactorX, scrollFactorY, opacity, blendMode, bgID, customScroll);

					map.set(layer.ID, layer);
				}
			}
		}
		
		return map;
	}

	public function readColorBackground(r:MbsObject):Background
	{
		if(Std.is(r, MbsColorBackground))
		{
			var r2:MbsColorBackground = cast r;
			var color = r2.getColor();
			return new ColorBackground(color);
		}
		
		else if(Std.is(r, MbsGradientBackground))
		{
			var r2:MbsGradientBackground = cast r;
			var color1 = r2.getColor1();
			var color2 = r2.getColor2();
			
			return new GradientBackground(color1, color2);
		}

		else
		{
			return null;
		}
	}
	
	public function readRawLayers(bytes:ByteArray, numTileLayers:Int):IntHashTable<TileLayer>
	{
		var map = new IntHashTable<TileLayer>(16);
		map.reuseIterator = true;
		
		var layerHeaders = new Array<Int>();
		
		if(bytes != null)
		{
			for(i in 0...numTileLayers)
			{
				layerHeaders[i] = bytes.readInt();
			}
			
			for(i in 0...numTileLayers)
			{
				var newLayer = readRawLayer(bytes, layerHeaders[i]);
				map.set(newLayer.layerID, newLayer);
			}
		}
				
		return map;
	}
	
	public function readRawLayer(bytes:ByteArray, length:Int):TileLayer
	{	
		var width = Std.int(Math.floor(sceneWidth / tileWidth));
		var height = Std.int(Math.floor(sceneHeight / tileHeight));
		
		var layerID = bytes.readInt();
		length -= 4;
		
		var zOrder = bytes.readInt();
		length -= 4;
		
		var layer = new TileLayer(layerID, this, width, height);
		
		var noTiles = true;
		var row = 0;
		var col = 0;
		
		var RLETILE_BYTE_COUNT = 8;
		var numChunks:Int = Std.int(length / RLETILE_BYTE_COUNT);
		
		//Grid for non-Box2D games - TODO: Don't make this for Box2D games?
		var grid = new com.stencyl.models.collision.Grid(sceneWidth, sceneHeight, tileWidth, tileHeight);
		layer.grid = grid;
		
		for(i in 0...numChunks)
		{
			var autotileFlag:Int = bytes.readShort();
			var tilesetID:Int = bytes.readShort();
			var tileID:Int = bytes.readShort();
			var runLength:Int = bytes.readShort();
			
			var tset:Tileset = null;
			
			if(tilesetID != -1)
			{
				tset = cast Data.get().resources.get(tilesetID);
			}
			
			if(autotileFlag < 0)
				autotileFlag = Std.int(Math.abs(autotileFlag + 1));

			for(runIndex in 0...runLength)
			{
				if(tset == null || tileID < 0)
				{
					layer.setTileAt(row, col, null, false);
				}
				
				else
				{
					var tile = tset.tiles[tileID];
					
					if(tile == null)
					{
						layer.setTileAt(row, col, null, false);
					}
					
					else
					{
						layer.setTileAt(row, col, tile, false);
						layer.autotileData[row][col] = autotileFlag;
						
						if(tile.collisionID >= 0)
						{
							grid.setTile(col, row, true);
						}
						
						if(tile.durations.length > 1)
						{
							var inList:Bool = false;
							
							for(checkTile in animatedTiles)
							{
								if(inList = (checkTile == tile)) 
									break;
							}
							
							if(!inList)
							{
								animatedTiles.push(tile);
							}
						}
					}	
				}
				
				col++;
				
				if(col >= width)
				{
					col = 0;
					row++;
				}
			}
		}

		return layer;
	}

	public function readAtlases(r:MbsIntList):Array<Int>
	{
		var members = new Array<Int>();
		
		for(i in 0...r.length())
		{
			var atlasID = r.readInt();
			
			if(GameModel.get().atlases.get(atlasID).allScenes)
				continue;

			members.push(atlasID);
		}

		return members;
	}
	
	private static var MAX_VERTICES:Int = 200;
	
	public function readWireframes(list:MbsList<MbsWireframe>):Array<Wireframe>
	{
		if(Engine.NO_PHYSICS)
		{
			return new Array<Wireframe>();
		}

		var map = new Array<Wireframe>();

		for(i in 0...list.length())
		{
			var poly = list.getNextObject();
			
			var position = ShapeReader.readPoint(poly.getPosition());
			var points = ShapeReader.readPoints(poly.getPoints()).toArray();
			var shapeData:Map<Int,Dynamic> = ShapeReader.createPolygon("MbsWireframe", points);
			
			map.push
			(
				new Wireframe
				(
					position.x,
					position.y,
					shapeData.get(1),
					shapeData.get(2),
					shapeData.get(0),
					null
				)
			);
		}
		
		return map;
	}
	
	public function readActors(list:MbsList<MbsActorInstance>):Map<Int,ActorInstance>
	{
		var map:Map<Int,ActorInstance> = new Map<Int,ActorInstance>();
		
		for(i in 0...list.length())
		{
			var ai:ActorInstance = readActorInstance(list.getNextObject());
			
			if(ai != null)
			{
				map.set(ai.elementID, ai);
			}
		}
		
		return map;
	}
	
	public function readActorInstance(r:MbsActorInstance):ActorInstance
	{
		var elementID = r.getAid();
		var x = r.getX();
		var y = r.getY();
		
		var scaleX = r.getScaleX();
		var scaleY = r.getScaleY();
		
		var layerID = r.getZ();
		var orderInLayer = r.getOrderInLayer();
		var angle = Std.int(r.getAngle());
		var groupID = r.getGroupID();
		var actorID = r.getId();
		var isCustomized = r.getCustomized();
		
		var behaviors:Map<String,BehaviorInstance> = null;
		
		if(isCustomized)
		{
			behaviors = AttributeValues.readBehaviors(r.getSnippets());
		}
		
		if (scaleX == 0 || scaleY == 0)
		{
			scaleX = 1;
			scaleY = 1;
		}
		
		if(!isCustomized)
		{
			behaviors = null;
		}
		
		if(Data.get().resources.get(actorID) == null)
		{
			return null;
		}
		
		var ai:ActorInstance = new ActorInstance
		(
			elementID,
			x,
			y,
			scaleX,
			scaleY,
			layerID,
			orderInLayer,
			angle,
			groupID,
			actorID,
			behaviors,
			isCustomized
		);
		
		if(ai.actorType != null)
		{
			ai.groupID = ai.actorType.groupID;
		}
		
		return ai;
	}
	
	public function getID():Int
	{
		return ID;
	}
}
