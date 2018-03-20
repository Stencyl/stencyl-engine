package com.stencyl.io.mbs.scene;

import com.stencyl.io.mbs.MbsResource;
import com.stencyl.io.mbs.scene.MbsTile;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsTileset extends MbsResource
{
	public static var across:MbsField;
	public static var down:MbsField;
	public static var readableImages:MbsField;
	public static var tileWidth:MbsField;
	public static var tileHeight:MbsField;
	public static var tiles:MbsField;
	
	public static var MBS_TILESET:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_TILESET != null) return;
		MbsResource.initializeType();
		
		MBS_TILESET = new ComposedType("MbsTileset");
		MBS_TILESET.setInstantiator(function(data) return new MbsTileset(data));
		MBS_TILESET.inherit(MbsResource.MBS_RESOURCE);
		
		across = MBS_TILESET.createField("across", INTEGER);
		down = MBS_TILESET.createField("down", INTEGER);
		readableImages = MBS_TILESET.createField("readableImages", BOOLEAN);
		tileWidth = MBS_TILESET.createField("tileWidth", INTEGER);
		tileHeight = MBS_TILESET.createField("tileHeight", INTEGER);
		tiles = MBS_TILESET.createField("tiles", LIST);
		
	}
	
	public static function new_MbsTileset_list(data:MbsIO):MbsList<MbsTileset>
	{
		return new MbsList<MbsTileset>(data, MBS_TILESET, new MbsTileset(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_TILESET;
	}
	
	private var _tiles:MbsList<MbsTile>;
	
	public function new(data:MbsIO)
	{
		super(data);
		_tiles = new MbsList<MbsTile>(data, MbsTile.MBS_TILE, new MbsTile(data));
	}
	
	override public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_TILESET.getSize()));
	}
	
	public function getAcross():Int
	{
		return data.readInt(address + across.address);
	}
	
	public function setAcross(_val:Int):Void
	{
		data.writeInt(address + across.address, _val);
	}
	
	public function getDown():Int
	{
		return data.readInt(address + down.address);
	}
	
	public function setDown(_val:Int):Void
	{
		data.writeInt(address + down.address, _val);
	}
	
	public function getReadableImages():Bool
	{
		return data.readBool(address + readableImages.address);
	}
	
	public function setReadableImages(_val:Bool):Void
	{
		data.writeBool(address + readableImages.address, _val);
	}
	
	public function getTileWidth():Int
	{
		return data.readInt(address + tileWidth.address);
	}
	
	public function setTileWidth(_val:Int):Void
	{
		data.writeInt(address + tileWidth.address, _val);
	}
	
	public function getTileHeight():Int
	{
		return data.readInt(address + tileHeight.address);
	}
	
	public function setTileHeight(_val:Int):Void
	{
		data.writeInt(address + tileHeight.address, _val);
	}
	
	public function getTiles():MbsList<MbsTile>
	{
		_tiles.setAddress(data.readInt(address + tiles.address));
		return _tiles;
	}
	
	public function createTiles(_length:Int):MbsList<MbsTile>
	{
		_tiles.allocateNew(_length);
		data.writeInt(address + tiles.address, _tiles.getAddress());
		return _tiles;
	}
	
}
