package com.stencyl.io.mbs.game;

import com.stencyl.io.mbs.game.MbsAtlas;
import com.stencyl.io.mbs.game.MbsCollisionGroup;
import com.stencyl.io.mbs.game.MbsCollisionPair;
import com.stencyl.io.mbs.game.MbsCollisionShape;
import com.stencyl.io.mbs.game.autotile.MbsAutotileFormat;
import com.stencyl.io.mbs.snippet.MbsMapElement;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsGame extends MbsObject
{
	public static var name:MbsField;
	public static var width:MbsField;
	public static var height:MbsField;
	public static var defaultSceneID:MbsField;
	public static var shapes:MbsField;
	public static var atlases:MbsField;
	public static var autotileFormats:MbsField;
	public static var groups:MbsField;
	public static var cgroups:MbsField;
	public static var gameAttributes:MbsField;
	
	public static var MBS_GAME:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_GAME != null) return;
		MBS_GAME = new ComposedType("MbsGame");
		MBS_GAME.setInstantiator(function(data) return new MbsGame(data));
		
		name = MBS_GAME.createField("name", STRING);
		width = MBS_GAME.createField("width", INTEGER);
		height = MBS_GAME.createField("height", INTEGER);
		defaultSceneID = MBS_GAME.createField("defaultSceneID", INTEGER);
		shapes = MBS_GAME.createField("shapes", LIST);
		atlases = MBS_GAME.createField("atlases", LIST);
		autotileFormats = MBS_GAME.createField("autotileFormats", LIST);
		groups = MBS_GAME.createField("groups", LIST);
		cgroups = MBS_GAME.createField("cgroups", LIST);
		gameAttributes = MBS_GAME.createField("gameAttributes", LIST);
		
	}
	
	public static function new_MbsGame_list(data:MbsIO):MbsList<MbsGame>
	{
		return new MbsList<MbsGame>(data, MBS_GAME, new MbsGame(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_GAME;
	}
	
	private var _shapes:MbsList<MbsCollisionShape>;
	private var _atlases:MbsList<MbsAtlas>;
	private var _autotileFormats:MbsList<MbsAutotileFormat>;
	private var _groups:MbsList<MbsCollisionGroup>;
	private var _cgroups:MbsList<MbsCollisionPair>;
	private var _gameAttributes:MbsList<MbsMapElement>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_shapes = new MbsList<MbsCollisionShape>(data, MbsCollisionShape.MBS_COLLISION_SHAPE, new MbsCollisionShape(data));
		_atlases = new MbsList<MbsAtlas>(data, MbsAtlas.MBS_ATLAS, new MbsAtlas(data));
		_autotileFormats = new MbsList<MbsAutotileFormat>(data, MbsAutotileFormat.MBS_AUTOTILE_FORMAT, new MbsAutotileFormat(data));
		_groups = new MbsList<MbsCollisionGroup>(data, MbsCollisionGroup.MBS_COLLISION_GROUP, new MbsCollisionGroup(data));
		_cgroups = new MbsList<MbsCollisionPair>(data, MbsCollisionPair.MBS_COLLISION_PAIR, new MbsCollisionPair(data));
		_gameAttributes = new MbsList<MbsMapElement>(data, MbsMapElement.MBS_MAP_ELEMENT, new MbsMapElement(data));
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_GAME.getSize()));
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getWidth():Int
	{
		return data.readInt(address + width.address);
	}
	
	public function setWidth(_val:Int):Void
	{
		data.writeInt(address + width.address, _val);
	}
	
	public function getHeight():Int
	{
		return data.readInt(address + height.address);
	}
	
	public function setHeight(_val:Int):Void
	{
		data.writeInt(address + height.address, _val);
	}
	
	public function getDefaultSceneID():Int
	{
		return data.readInt(address + defaultSceneID.address);
	}
	
	public function setDefaultSceneID(_val:Int):Void
	{
		data.writeInt(address + defaultSceneID.address, _val);
	}
	
	public function getShapes():MbsList<MbsCollisionShape>
	{
		_shapes.setAddress(data.readInt(address + shapes.address));
		return _shapes;
	}
	
	public function createShapes(_length:Int):MbsList<MbsCollisionShape>
	{
		_shapes.allocateNew(_length);
		data.writeInt(address + shapes.address, _shapes.getAddress());
		return _shapes;
	}
	
	public function getAtlases():MbsList<MbsAtlas>
	{
		_atlases.setAddress(data.readInt(address + atlases.address));
		return _atlases;
	}
	
	public function createAtlases(_length:Int):MbsList<MbsAtlas>
	{
		_atlases.allocateNew(_length);
		data.writeInt(address + atlases.address, _atlases.getAddress());
		return _atlases;
	}
	
	public function getAutotileFormats():MbsList<MbsAutotileFormat>
	{
		_autotileFormats.setAddress(data.readInt(address + autotileFormats.address));
		return _autotileFormats;
	}
	
	public function createAutotileFormats(_length:Int):MbsList<MbsAutotileFormat>
	{
		_autotileFormats.allocateNew(_length);
		data.writeInt(address + autotileFormats.address, _autotileFormats.getAddress());
		return _autotileFormats;
	}
	
	public function getGroups():MbsList<MbsCollisionGroup>
	{
		_groups.setAddress(data.readInt(address + groups.address));
		return _groups;
	}
	
	public function createGroups(_length:Int):MbsList<MbsCollisionGroup>
	{
		_groups.allocateNew(_length);
		data.writeInt(address + groups.address, _groups.getAddress());
		return _groups;
	}
	
	public function getCgroups():MbsList<MbsCollisionPair>
	{
		_cgroups.setAddress(data.readInt(address + cgroups.address));
		return _cgroups;
	}
	
	public function createCgroups(_length:Int):MbsList<MbsCollisionPair>
	{
		_cgroups.allocateNew(_length);
		data.writeInt(address + cgroups.address, _cgroups.getAddress());
		return _cgroups;
	}
	
	public function getGameAttributes():MbsList<MbsMapElement>
	{
		_gameAttributes.setAddress(data.readInt(address + gameAttributes.address));
		return _gameAttributes;
	}
	
	public function createGameAttributes(_length:Int):MbsList<MbsMapElement>
	{
		_gameAttributes.allocateNew(_length);
		data.writeInt(address + gameAttributes.address, _gameAttributes.getAddress());
		return _gameAttributes;
	}
	
}
