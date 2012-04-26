package models;

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
	
	public var bgs:Array;
	public var fgs:Array;
	
	public var terrain:Array;
	public var actors:Array;
	public var behaviorValues:Array;
	
	//Box2D
	//public var wireframes:Array;
	//public var joints:Array;
	//public var regions:Array;
	//public var terrainRegions:Array;
	
	public var animatedTiles:Array;
	
	public function new(ID:Int, name:String, xml:Fast)
	{
		this.ID = ID;
		this.name = name;
		
		var numLayers:Int = Std.parseInt(xml.att.depth);
		
		sceneWidth = Std.parseInt(xml.att.width);
		sceneHeight = Std.parseInt(xml.att.height);
		
		tileWidth = Std.parseInt(xml.att.tilew);
		tileHeight = Std.parseInt(xml.att.tileh);
		
		gravityX = Std.parseFloat(xml.att.gravx);
		gravityY = Std.parseFloat(xml.att.gravy);
								
		animatedTiles = new Array();
		
		bgs = readBackgrounds(xml.backgrounds);
		fgs = readBackgrounds(xml.foregrounds);
					
		colorBackground = new ColorBackground(0xFFFFFFFF);
		
		for(e in xml.elements)
		{
			if(e.name() == "color-bg" || e.name() == "grad-bg")
			{
				colorBackground = new BackgroundReader().read(0, e.name(), "", e) as Background;
				break;
			}
		}
		
		actors = readActors(xml.actors);
		behaviorValues = ActorTypeReader.readBehaviors(xml.snippets);
		
		if (xml.att.eventsnippetid.length() > 0)
		{
			eventID = Std.parseInt(xml.att.eventsnippetid);
			
			if(eventID > -1)
			{
				behaviorValues[eventID] = new BehaviorInstance(eventID, new Array());
			}
		}
		
		//joints = readJoints(xml.joints);
		//regions = readRegions(xml.regions);
		//terrainRegions = readTerrainRegions(xml.terrainRegions);
		
		//wireframes = readWireframes(xml.terrain);
		
		var rawLayers:Array = readRawLayers(Assets.get().scenesTerrain[ID], numLayers);
		terrain = readLayers(xml.layers, rawLayers);
	}
	
	/*public function readRegions(list:Iterator<Fast>):Array
	{
		var map:Array = new Array();
		
		for(e in list)
		{
			var r:RegionDef = readRegion(e);
			
			map[r.ID] = r;
		}
		
		return map;
	}
	
	public function readRegion(e:XML):RegionDef
	{
		var type:String = e.att.type;
		var elementID:Number = e.@id;
		var name:String = e.@name;
		var pts:String = e.@pts;
		var region:RegionDef;
		
		var x:Number = GameState.toPhysicalUnits(e.@x);
		var y:Number = GameState.toPhysicalUnits(e.@y);
		
		var shape:b2Shape = null;
		var ps:Vector.<b2PolygonShape> = new Vector.<b2PolygonShape>();
		var shapeList:Array = new Array();
		var decompParams:Array;
		
		if(type == "box")
		{
			var w:Number = GameState.toPhysicalUnits(e.@w); 
			var h:Number = GameState.toPhysicalUnits(e.@h); 
			var box:b2PolygonShape = new b2PolygonShape();
			box.SetAsBox(w / 2, h / 2);
			shape = box;
			shapeList[0] = shape;
			region= new RegionDef(shapeList, elementID, name, x, y);
		}
		else if (type == "poly")
		{
			var w:Number = e.@w;
			var h:Number = e.@h;
			
			var shapeType:String = "polyregion";
			
			//backwards compatibility for box regions
			if (pts == null)
			{
				var box:b2PolygonShape = new b2PolygonShape();
				box.SetAsBox(w / 2, h / 2);
				shape = box;
				shapeList[0] = shape;
				region = new RegionDef(shapeList, elementID, name, x, y);
				return region;
			}
			
			var shapeParams:Array = pts.split(",");

			ps = SpriteReader.decomposeShape(shapeParams);
			
			for (var i:int = 0; i < ps.length; i++)
			{
				var loX:Number = int.MAX_VALUE;
				var loY:Number = int.MAX_VALUE;
				var hiX:Number = 0;
				var hiY:Number = 0;
				var j:Number = 0;
				
				decompParams = new Array();
				decompParams[0] = ps[i].GetVertexCount();

				for (j= 0; j < ps[i].m_vertices.length; j++)
				{
					loX = Math.min(loX, ps[i].m_vertices[j].x);
					loY = Math.min(loY, ps[i].m_vertices[j].y);
					hiX = Math.min(hiX, ps[i].m_vertices[j].x);
					hiY = Math.min(hiY, ps[i].m_vertices[j].y);
					decompParams.push(ps[i].m_vertices[j].x);
					decompParams.push(ps[i].m_vertices[j].y);
				}
				
				var localWidth:Number;
				var localHeight:Number;
				
				localWidth = hiX - loX;
				localHeight = hiY - loY;
				loX = GameState.toPhysicalUnits(loX);
				loY = GameState.toPhysicalUnits(loY);
				
				var polyShape:b2PolygonShape = SpriteReader.createShape(shapeType, decompParams, x, y, w, h) as b2PolygonShape;
				shapeList[i] = polyShape;
			}
			
			region = new RegionDef(shapeList, elementID, name, x, y);
		}	
		else
		{
			var radius:Number = GameState.toPhysicalUnits(e.@rad);
			shape = new b2CircleShape();
			shape.m_radius = radius;
			shapeList[0] = shape;
			region= new RegionDef(shapeList, elementID, name, x, y);
		}
		
		return region;
	}*/
	
	/*public function readTerrainRegions(list:XMLList):Array
	{
		var map:Array = new Array();
		
		for each(var e:XML in list.children())
		{
			var t:TerrainRegionDef = readTerrainRegion(e);
			map[t.ID] = t;
		}
		
		return map;
	}
	
	public function readTerrainRegion(e:XML):TerrainRegionDef
	{
		var type:String = e.@type;
		var elementID:Number = e.@id;
		var name:String = e.@name;
		var group:int = e.@group;
		var terrainRegion:TerrainRegionDef;
		
		var x:Number = GameState.toPhysicalUnits(e.@x);
		var y:Number = GameState.toPhysicalUnits(e.@y);
		var r:Number = e.@r;
		var g:Number = e.@g;
		var b:Number = e.@b;
		var fillColor:uint = Util.RGBToHex(r, g, b);
		
		var shape:b2Shape = null;
		var ps:Vector.<b2PolygonShape> = new Vector.<b2PolygonShape>();
		var tr:Array = new Array();
		var shapeList:Array = new Array();
		var decompParams:Array;
		
		if(type == "box")
		{
			var w:Number = GameState.toPhysicalUnits(e.@w); 
			var h:Number = GameState.toPhysicalUnits(e.@h); 
			var box:b2PolygonShape = new b2PolygonShape();
			box.SetAsBox(w / 2, h / 2);
			shape = box;
			shapeList[0] = shape;
			terrainRegion= new TerrainRegionDef(shapeList, elementID, name, x, y, group, fillColor);
		}
		else if(type == "poly")
		{
			var w:Number = e.@w;
			var h:Number = e.@h;
			
			var shapeType:String = "polyregion";
			var shapeParams:Array = e.@pts.split(",");

			ps = SpriteReader.decomposeShape(shapeParams);
			
			for (var i:int = 0; i < ps.length; i++)
			{
				var loX:Number = int.MAX_VALUE;
				var loY:Number = int.MAX_VALUE;
				var hiX:Number = 0;
				var hiY:Number = 0;
				var j:Number = 0;
				decompParams = new Array();
				decompParams[0] = ps[i].GetVertexCount();

				for (j= 0; j < ps[i].m_vertices.length; j++)
				{
					loX = Math.min(loX, ps[i].m_vertices[j].x);
					loY = Math.min(loY, ps[i].m_vertices[j].y);
					hiX = Math.min(hiX, ps[i].m_vertices[j].x);
					hiY = Math.min(hiY, ps[i].m_vertices[j].y);
					decompParams.push(ps[i].m_vertices[j].x);
					decompParams.push(ps[i].m_vertices[j].y);
				}
				
				var localWidth:Number;
				var localHeight:Number;
				
				localWidth = hiX - loX;
				localHeight = hiY - loY;
				loX = GameState.toPhysicalUnits(loX);
				loY = GameState.toPhysicalUnits(loY);
				
				var polyShape:b2PolygonShape = SpriteReader.createShape(shapeType, decompParams, x, y, w, h) as b2PolygonShape;
				shapeList[i] = polyShape;
			}
			
			terrainRegion = new TerrainRegionDef(shapeList, elementID, name, x, y, group, fillColor);
		}
		
		else
		{
			var radius:Number = GameState.toPhysicalUnits(e.@rad);
			shape = new b2CircleShape();
			shape.m_radius = radius;
			shapeList[0] = shape;
			terrainRegion = new TerrainRegionDef(shapeList, elementID, name, x, y, group, fillColor);
		}
		
		return terrainRegion;
	}
	
	public function readJoints(list:XMLList):Array
	{
		var map:Array = new Array();
		
		for each(var e:XML in list.children())
		{
			var j:b2JointDef = readJoint(e);
			
			map[j.ID] = j;
		}
		
		return map;
	}
	
	public function readJoint(e:XML):b2JointDef
	{
		var type:String = e.name();
		
		var elementID:Number = e.@id;
		
		var a1:Number = e.@a1;
		var a2:Number = e.@a2;
		var collide:Boolean = Util.toBoolean(e.@collide);
		
		if(type == "STICK_JOINT")
		{
			var j:b2DistanceJointDef = new b2DistanceJointDef();
			
			j.ID = elementID;
			j.actor1 = a1;
			j.actor2 = a2;
			j.localAnchorA = null;
			j.localAnchorB = null;
			j.collideConnected = collide;
			
			//---
			
			j.dampingRatio = e.@damping;
			j.frequencyHz = e.@freq;
			
			return j;
		}
		
		else if(type == "HINGE_JOINT")
		{
			var j2:b2RevoluteJointDef = new b2RevoluteJointDef();
			
			j2.ID = elementID;
			j2.actor1 = a1;
			j2.actor2 = a2;
			j2.localAnchorA = null;
			j2.localAnchorB = null;
			j2.collideConnected = collide;
			
			//---
			
			j2.enableLimit = Util.toBoolean(e.@limit);
			j2.enableMotor = Util.toBoolean(e.@motor);
			j2.lowerAngle = e.@lower;
			j2.upperAngle = e.@upper;
			j2.maxMotorTorque = e.@torque;
			j2.motorSpeed = e.@speed;
			
			return j2;
		}
		
		else if(type == "SLIDING_JOINT")
		{
			var j3:b2LineJointDef = new b2LineJointDef();
			
			j3.ID = elementID;
			j3.actor1 = a1;
			j3.actor2 = a2;
			j3.localAnchorA = null;
			j3.localAnchorB = null;
			j3.collideConnected = collide;
			
			//---
			
			j3.enableLimit = Util.toBoolean(e.@limit);
			j3.enableMotor = Util.toBoolean(e.@motor);
			j3.lowerTranslation = e.@lower;
			j3.upperTranslation = e.@upper;
			j3.maxMotorForce = e.@force;
			j3.motorSpeed = e.@speed;
			j3.localAxisA.x = e.@x;
			j3.localAxisA.y = e.@y;
			
			return j3;
		}
		
		trace("Error: unsuppported joint type: " + type);
		
		return null;
	}*/

	public function readLayers(list:XMLList, rawLayers:Array):Array
	{
		var map:Array = new Array();
		
		for each(var e:XML in list.children())
		{
			map[e.@id] = rawLayers[e.@id];
			
			var layer:TileLayer = map[e.@id];
			layer.name = e.@name;
			layer.zOrder = e.@order;
		}
		
		return map;
	}
	
	public function readRawLayers(bytes:ByteArray, numLayers:Number):Array
	{
		var map:Array = new Array();
		var layerHeaders:Array = new Array();
		
		for(var i:Number = 0; i < numLayers; i++)
		{
			layerHeaders[i] = bytes.readInt();
		}
		
		for(i = 0; i < numLayers; i++)
		{
			var newLayer:TileLayer = readRawLayer(bytes, layerHeaders[i]);
			map[newLayer.layerID] = newLayer;
		}
		
		return map;
	}
	
	public function readRawLayer(bytes:ByteArray, length:Number):TileLayer
	{
		var width:Number = Math.floor(sceneWidth / tileWidth);
		var height:Number = Math.floor(sceneHeight / tileHeight);
		
		var layerID:Number = bytes.readInt();
		length -= 4;
		
		var zOrder:Number = bytes.readInt();
		length -= 4;
		
		var layer:TileLayer = new TileLayer(layerID, zOrder, this, width, height);
		
		var row:Number = 0;
		var col:Number = 0;
		
		var RLETILE_BYTE_COUNT:Number = 8;
		var numChunks:Number = length / RLETILE_BYTE_COUNT;
		
		for(var i:Number = 0; i < numChunks; i++)
		{
			//Unused value we have to keep for compatibility reasons.
			bytes.readShort();
			
			var tilesetID:Number = bytes.readShort();
			var tileID:Number = bytes.readShort();
			var runLength:Number = bytes.readShort();
			
			var tset:Tileset = Assets.get().resources[tilesetID] as Tileset;
			
			for(var runIndex:Number = 0; runIndex < runLength; runIndex++)
			{
				if(tset == null || tileID < 0 || tset == null)
				{
					layer.setTileAt(row, col, null);
				}
				
				else
				{
					layer.setTileAt(row, col, tset.tiles[tileID]);
					
					var tile:Tile = tset.tiles[tileID];
					
					//If animated tile, add to update list
					if (tile != null && tile.pixels != null && animatedTiles.indexOf(tile) == -1)
					{
						animatedTiles.push(tile);
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
	
	public function readBackgrounds(list:XMLList):Array
	{
		var map:Array = new Array();
		
		for each(var e:XML in list.children())
		{
			map.push(e.@id);
		}
		
		return map;
	}
	
	/*private var MAX_VERTICES:uint = 200;
	
	public function readWireframes(list:XMLList):Array
	{
		var map:Array = new Array();
		
		for each(var e:XML in list.children())
		{
			var x:Number = e.@x;
			var y:Number = e.@y;
			
			var shapeType:String = "wireframe";
			var shapeParams:Array = e.@pts.split(",");
			var shape:b2LoopShape = SpriteReader.createShape(shapeType, shapeParams, x, y) as b2LoopShape;
			
			map.push
			(
				new Wireframe
				(
					GameState.toPhysicalUnits(x), 
					GameState.toPhysicalUnits(y), 
					shape.width, 
					shape.height,
					shape
				)
			);
		}
		
		return map;
	}*/
	
	public function readActors(list:Iterator<Fast>):Array<ActorInstance>
	{
		var map:Array<ActorInstance> = new Array<ActorInstance>();
		
		for(e in list)
		{
			var ai:ActorInstance = readActorInstance(e);
			
			if(ai != null)
			{
				map[Std.parseInt(e.@aid)] = ai;
			}
		}
		
		return map;
	}
	
	public function readActorInstance(xml:Fast):ActorInstance
	{
		var elementID:Int = Std.parseInt(xml.att.aid);
		var x:Int = Std.parseInt(xml.att.x);
		var y:Int = Std.parseInt(xml.att.y);
		var scaleX:Float = Std.parseFloat(xml.att.sx);
		var scaleY:Float = Std.parseFloat(xml.att.sy);
		var layerID:Int = Std.parseInt(xml.att.z);
		var angle:Int = Std.parseInt(xml.att.a);
		var groupID:Int =  Std.parseInt(xml.att.group);
		var actorID:Int = Std.parseInt(xml.att.id);
		var isCustomized:Bool = Utils.toBoolean(xml.@c);
		
		var behaviors:Array = ActorTypeReader.readBehaviors(xml.nodes.snippets);
		
		if (scaleX == 0 || scaleY == 0)
		{
			scaleX = 1;
			scaleY = 1;
		}
		
		if(!isCustomized)
		{
			behaviors = null;
		}
		
		var ai:ActorInstance = new ActorInstance
		(
			elementID,
			x,
			y,
			scaleX,
			scaleY,
			layerID,
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
	
	public function getID():int
	{
		return ID;
	}
}
