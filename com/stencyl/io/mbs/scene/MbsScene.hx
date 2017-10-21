package com.stencyl.io.mbs.scene;

import com.stencyl.io.mbs.scene.MbsActorInstance;
import com.stencyl.io.mbs.scene.physics.MbsRegion;
import com.stencyl.io.mbs.scene.physics.MbsTerrainRegion;
import com.stencyl.io.mbs.shape.MbsWireframe;
import com.stencyl.io.mbs.snippet.MbsSnippet;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsDynamicList;
import mbs.io.MbsListBase.MbsIntList;

class MbsScene extends MbsObject
{
	public static var retainAtlases:MbsField;
	public static var depth:MbsField;
	public static var description:MbsField;
	public static var eventSnippetID:MbsField;
	public static var extendedHeight:MbsField;
	public static var extendedWidth:MbsField;
	public static var extendedX:MbsField;
	public static var extendedY:MbsField;
	public static var format:MbsField;
	public static var gravityX:MbsField;
	public static var gravityY:MbsField;
	public static var height:MbsField;
	public static var id:MbsField;
	public static var name:MbsField;
	public static var revision:MbsField;
	public static var savecount:MbsField;
	public static var tileDepth:MbsField;
	public static var tileHeight:MbsField;
	public static var tileWidth:MbsField;
	public static var type:MbsField;
	public static var width:MbsField;
	public static var actorInstances:MbsField;
	public static var atlasMembers:MbsField;
	public static var layers:MbsField;
	public static var joints:MbsField;
	public static var regions:MbsField;
	public static var snippets:MbsField;
	public static var terrain:MbsField;
	public static var terrainRegions:MbsField;
	
	public static var MBS_SCENE:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_SCENE != null) return;
		MBS_SCENE = new ComposedType("MbsScene");
		MBS_SCENE.setInstantiator(function(data) return new MbsScene(data));
		
		retainAtlases = MBS_SCENE.createField("retainAtlases", BOOLEAN);
		depth = MBS_SCENE.createField("depth", INTEGER);
		description = MBS_SCENE.createField("description", STRING);
		eventSnippetID = MBS_SCENE.createField("eventSnippetID", INTEGER);
		extendedHeight = MBS_SCENE.createField("extendedHeight", INTEGER);
		extendedWidth = MBS_SCENE.createField("extendedWidth", INTEGER);
		extendedX = MBS_SCENE.createField("extendedX", INTEGER);
		extendedY = MBS_SCENE.createField("extendedY", INTEGER);
		format = MBS_SCENE.createField("format", STRING);
		gravityX = MBS_SCENE.createField("gravityX", FLOAT);
		gravityY = MBS_SCENE.createField("gravityY", FLOAT);
		height = MBS_SCENE.createField("height", INTEGER);
		id = MBS_SCENE.createField("id", INTEGER);
		name = MBS_SCENE.createField("name", STRING);
		revision = MBS_SCENE.createField("revision", STRING);
		savecount = MBS_SCENE.createField("savecount", INTEGER);
		tileDepth = MBS_SCENE.createField("tileDepth", INTEGER);
		tileHeight = MBS_SCENE.createField("tileHeight", INTEGER);
		tileWidth = MBS_SCENE.createField("tileWidth", INTEGER);
		type = MBS_SCENE.createField("type", STRING);
		width = MBS_SCENE.createField("width", INTEGER);
		actorInstances = MBS_SCENE.createField("actorInstances", LIST);
		atlasMembers = MBS_SCENE.createField("atlasMembers", LIST);
		layers = MBS_SCENE.createField("layers", LIST);
		joints = MBS_SCENE.createField("joints", LIST);
		regions = MBS_SCENE.createField("regions", LIST);
		snippets = MBS_SCENE.createField("snippets", LIST);
		terrain = MBS_SCENE.createField("terrain", LIST);
		terrainRegions = MBS_SCENE.createField("terrainRegions", LIST);
		
	}
	
	public static function new_MbsScene_list(data:MbsIO):MbsList<MbsScene>
	{
		return new MbsList<MbsScene>(data, MBS_SCENE, new MbsScene(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_SCENE;
	}
	
	private var _actorInstances:MbsList<MbsActorInstance>;
	private var _atlasMembers:MbsIntList;
	private var _layers:MbsDynamicList;
	private var _joints:MbsDynamicList;
	private var _regions:MbsList<MbsRegion>;
	private var _snippets:MbsList<MbsSnippet>;
	private var _terrain:MbsList<MbsWireframe>;
	private var _terrainRegions:MbsList<MbsTerrainRegion>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_actorInstances = new MbsList<MbsActorInstance>(data, MbsActorInstance.MBS_ACTOR_INSTANCE, new MbsActorInstance(data));
		_atlasMembers = new MbsIntList(data);
		_layers = new MbsDynamicList(data);
		_joints = new MbsDynamicList(data);
		_regions = new MbsList<MbsRegion>(data, MbsRegion.MBS_REGION, new MbsRegion(data));
		_snippets = new MbsList<MbsSnippet>(data, MbsSnippet.MBS_SNIPPET, new MbsSnippet(data));
		_terrain = new MbsList<MbsWireframe>(data, MbsWireframe.MBS_WIREFRAME, new MbsWireframe(data));
		_terrainRegions = new MbsList<MbsTerrainRegion>(data, MbsTerrainRegion.MBS_TERRAIN_REGION, new MbsTerrainRegion(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_SCENE.getSize()));
	}
	
	public function getRetainAtlases():Bool
	{
		return data.readBool(address + retainAtlases.address);
	}
	
	public function setRetainAtlases(_val:Bool):Void
	{
		data.writeBool(address + retainAtlases.address, _val);
	}
	
	public function getDepth():Int
	{
		return data.readInt(address + depth.address);
	}
	
	public function setDepth(_val:Int):Void
	{
		data.writeInt(address + depth.address, _val);
	}
	
	public function getDescription():String
	{
		return data.readString(address + description.address);
	}
	
	public function setDescription(_val:String):Void
	{
		data.writeString(address + description.address, _val);
	}
	
	public function getEventSnippetID():Int
	{
		return data.readInt(address + eventSnippetID.address);
	}
	
	public function setEventSnippetID(_val:Int):Void
	{
		data.writeInt(address + eventSnippetID.address, _val);
	}
	
	public function getExtendedHeight():Int
	{
		return data.readInt(address + extendedHeight.address);
	}
	
	public function setExtendedHeight(_val:Int):Void
	{
		data.writeInt(address + extendedHeight.address, _val);
	}
	
	public function getExtendedWidth():Int
	{
		return data.readInt(address + extendedWidth.address);
	}
	
	public function setExtendedWidth(_val:Int):Void
	{
		data.writeInt(address + extendedWidth.address, _val);
	}
	
	public function getExtendedX():Int
	{
		return data.readInt(address + extendedX.address);
	}
	
	public function setExtendedX(_val:Int):Void
	{
		data.writeInt(address + extendedX.address, _val);
	}
	
	public function getExtendedY():Int
	{
		return data.readInt(address + extendedY.address);
	}
	
	public function setExtendedY(_val:Int):Void
	{
		data.writeInt(address + extendedY.address, _val);
	}
	
	public function getFormat():String
	{
		return data.readString(address + format.address);
	}
	
	public function setFormat(_val:String):Void
	{
		data.writeString(address + format.address, _val);
	}
	
	public function getGravityX():Float
	{
		return data.readFloat(address + gravityX.address);
	}
	
	public function setGravityX(_val:Float):Void
	{
		data.writeFloat(address + gravityX.address, _val);
	}
	
	public function getGravityY():Float
	{
		return data.readFloat(address + gravityY.address);
	}
	
	public function setGravityY(_val:Float):Void
	{
		data.writeFloat(address + gravityY.address, _val);
	}
	
	public function getHeight():Int
	{
		return data.readInt(address + height.address);
	}
	
	public function setHeight(_val:Int):Void
	{
		data.writeInt(address + height.address, _val);
	}
	
	public function getId():Int
	{
		return data.readInt(address + id.address);
	}
	
	public function setId(_val:Int):Void
	{
		data.writeInt(address + id.address, _val);
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getRevision():String
	{
		return data.readString(address + revision.address);
	}
	
	public function setRevision(_val:String):Void
	{
		data.writeString(address + revision.address, _val);
	}
	
	public function getSavecount():Int
	{
		return data.readInt(address + savecount.address);
	}
	
	public function setSavecount(_val:Int):Void
	{
		data.writeInt(address + savecount.address, _val);
	}
	
	public function getTileDepth():Int
	{
		return data.readInt(address + tileDepth.address);
	}
	
	public function setTileDepth(_val:Int):Void
	{
		data.writeInt(address + tileDepth.address, _val);
	}
	
	public function getTileHeight():Int
	{
		return data.readInt(address + tileHeight.address);
	}
	
	public function setTileHeight(_val:Int):Void
	{
		data.writeInt(address + tileHeight.address, _val);
	}
	
	public function getTileWidth():Int
	{
		return data.readInt(address + tileWidth.address);
	}
	
	public function setTileWidth(_val:Int):Void
	{
		data.writeInt(address + tileWidth.address, _val);
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
	}
	
	public function getWidth():Int
	{
		return data.readInt(address + width.address);
	}
	
	public function setWidth(_val:Int):Void
	{
		data.writeInt(address + width.address, _val);
	}
	
	public function getActorInstances():MbsList<MbsActorInstance>
	{
		_actorInstances.setAddress(data.readInt(address + actorInstances.address));
		return _actorInstances;
	}
	
	public function createActorInstances(_length:Int):MbsList<MbsActorInstance>
	{
		_actorInstances.allocateNew(_length);
		data.writeInt(address + actorInstances.address, _actorInstances.getAddress());
		return _actorInstances;
	}
	
	public function getAtlasMembers():MbsIntList
	{
		_atlasMembers.setAddress(data.readInt(address + atlasMembers.address));
		return _atlasMembers;
	}
	
	public function createAtlasMembers(_length:Int):MbsIntList
	{
		_atlasMembers.allocateNew(_length);
		data.writeInt(address + atlasMembers.address, _atlasMembers.getAddress());
		return _atlasMembers;
	}
	
	public function getLayers():MbsDynamicList
	{
		_layers.setAddress(data.readInt(address + layers.address));
		return _layers;
	}
	
	public function createLayers(_length:Int):MbsDynamicList
	{
		_layers.allocateNew(_length);
		data.writeInt(address + layers.address, _layers.getAddress());
		return _layers;
	}
	
	public function getJoints():MbsDynamicList
	{
		_joints.setAddress(data.readInt(address + joints.address));
		return _joints;
	}
	
	public function createJoints(_length:Int):MbsDynamicList
	{
		_joints.allocateNew(_length);
		data.writeInt(address + joints.address, _joints.getAddress());
		return _joints;
	}
	
	public function getRegions():MbsList<MbsRegion>
	{
		_regions.setAddress(data.readInt(address + regions.address));
		return _regions;
	}
	
	public function createRegions(_length:Int):MbsList<MbsRegion>
	{
		_regions.allocateNew(_length);
		data.writeInt(address + regions.address, _regions.getAddress());
		return _regions;
	}
	
	public function getSnippets():MbsList<MbsSnippet>
	{
		_snippets.setAddress(data.readInt(address + snippets.address));
		return _snippets;
	}
	
	public function createSnippets(_length:Int):MbsList<MbsSnippet>
	{
		_snippets.allocateNew(_length);
		data.writeInt(address + snippets.address, _snippets.getAddress());
		return _snippets;
	}
	
	public function getTerrain():MbsList<MbsWireframe>
	{
		_terrain.setAddress(data.readInt(address + terrain.address));
		return _terrain;
	}
	
	public function createTerrain(_length:Int):MbsList<MbsWireframe>
	{
		_terrain.allocateNew(_length);
		data.writeInt(address + terrain.address, _terrain.getAddress());
		return _terrain;
	}
	
	public function getTerrainRegions():MbsList<MbsTerrainRegion>
	{
		_terrainRegions.setAddress(data.readInt(address + terrainRegions.address));
		return _terrainRegions;
	}
	
	public function createTerrainRegions(_length:Int):MbsList<MbsTerrainRegion>
	{
		_terrainRegions.allocateNew(_length);
		data.writeInt(address + terrainRegions.address, _terrainRegions.getAddress());
		return _terrainRegions;
	}
	
}
