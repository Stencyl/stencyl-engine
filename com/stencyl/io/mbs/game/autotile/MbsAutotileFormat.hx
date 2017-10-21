package com.stencyl.io.mbs.game.autotile;

import com.stencyl.io.mbs.game.autotile.MbsCorners;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;
import mbs.io.MbsListBase.MbsIntList;

class MbsAutotileFormat extends MbsObject
{
	public static var id:MbsField;
	public static var name:MbsField;
	public static var across:MbsField;
	public static var down:MbsField;
	public static var corners:MbsField;
	public static var flags:MbsField;
	
	public static var MBS_AUTOTILE_FORMAT:ComposedType;
	public static function initializeType():Void
	{
		if(MBS_AUTOTILE_FORMAT != null) return;
		MBS_AUTOTILE_FORMAT = new ComposedType("MbsAutotileFormat");
		MBS_AUTOTILE_FORMAT.setInstantiator(function(data) return new MbsAutotileFormat(data));
		
		id = MBS_AUTOTILE_FORMAT.createField("id", INTEGER);
		name = MBS_AUTOTILE_FORMAT.createField("name", STRING);
		across = MBS_AUTOTILE_FORMAT.createField("across", INTEGER);
		down = MBS_AUTOTILE_FORMAT.createField("down", INTEGER);
		corners = MBS_AUTOTILE_FORMAT.createField("corners", LIST);
		flags = MBS_AUTOTILE_FORMAT.createField("flags", LIST);
		
	}
	
	public static function new_MbsAutotileFormat_list(data:MbsIO):MbsList<MbsAutotileFormat>
	{
		return new MbsList<MbsAutotileFormat>(data, MBS_AUTOTILE_FORMAT, new MbsAutotileFormat(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_AUTOTILE_FORMAT;
	}
	
	private var _corners:MbsList<MbsCorners>;
	private var _flags:MbsIntList;
	
	public function new(data:MbsIO)
	{
		super(data);
		_corners = new MbsList<MbsCorners>(data, MbsCorners.MBS_CORNERS, new MbsCorners(data));
		_flags = new MbsIntList(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_AUTOTILE_FORMAT.getSize()));
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
	
	public function getCorners():MbsList<MbsCorners>
	{
		_corners.setAddress(data.readInt(address + corners.address));
		return _corners;
	}
	
	public function createCorners(_length:Int):MbsList<MbsCorners>
	{
		_corners.allocateNew(_length);
		data.writeInt(address + corners.address, _corners.getAddress());
		return _corners;
	}
	
	public function getFlags():MbsIntList
	{
		_flags.setAddress(data.readInt(address + flags.address));
		return _flags;
	}
	
	public function createFlags(_length:Int):MbsIntList
	{
		_flags.allocateNew(_length);
		data.writeInt(address + flags.address, _flags.getAddress());
		return _flags;
	}
	
}
