package com.newgrounds;

extern class Medal extends APIEventDispatcher {
	var description(default,never) : String;
	var difficulty(default,never) : String;
	var icon(default,never) : flash.display.BitmapData;
	var id(default,never) : UInt;
	var name(default,never) : String;
	var secret(default,never) : Bool;
	var unlocked(default,never) : Bool;
	var value(default,never) : UInt;
	function new(p1 : APIConnection, p2 : UInt, p3 : String, p4 : String, p5 : Bool, p6 : Bool, p7 : UInt, p8 : UInt, p9 : String) : Void;
	function attachIcon(p1 : flash.display.DisplayObjectContainer) : flash.display.Sprite;
	function setUnlocked(p1 : Bool) : Void;
	function unlock() : Void;
	static var DEFAULT_ICON(default,never) : flash.display.BitmapData;
	static var DIFFICULTY_BRUTAL(default,never) : String;
	static var DIFFICULTY_CHALLENGING(default,never) : String;
	static var DIFFICULTY_DIFFICULT(default,never) : String;
	static var DIFFICULTY_EASY(default,never) : String;
	static var DIFFICULTY_MODERATE(default,never) : String;
	static var ICON_HEIGHT(default,never) : UInt;
	static var ICON_WIDTH(default,never) : UInt;
}
