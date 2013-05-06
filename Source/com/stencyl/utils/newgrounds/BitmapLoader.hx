package com.newgrounds;

extern class BitmapLoader extends APIEventDispatcher {
	var bitmapData : flash.display.BitmapData;
	var loaded(default,never) : Bool;
	var url : String;
	function new(p1 : flash.display.BitmapData, p2 : String) : Void;
	function attachBitmap(p1 : flash.display.DisplayObjectContainer) : flash.display.Sprite;
	function load() : Void;
	static var _cacheSeed : UInt;
}
