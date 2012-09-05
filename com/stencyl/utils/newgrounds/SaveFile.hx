package com.newgrounds;

extern class SaveFile extends APIEventDispatcher {
	var authorId(default,never) : UInt;
	var authorName(default,never) : String;
	var bytesLoaded(default,never) : UInt;
	var bytesTotal(default,never) : UInt;
	var createdDate(default,never) : String;
	var data : Dynamic;
	var description : String;
	var draft : Bool;
	var group(default,never) : SaveGroup;
	var icon : flash.display.BitmapData;
	var iconLoaded(default,never) : Bool;
	var id(default,never) : UInt;
	var keys(default,never) : Dynamic;
	var name : String;
	var ratings(default,never) : Dynamic;
	var readOnly(default,never) : Bool;
	var updatedDate(default,never) : String;
	var views(default,never) : UInt;
	function new(p1 : SaveGroup) : Void;
	function attachIcon(p1 : flash.display.DisplayObjectContainer) : flash.display.Sprite;
	function clone() : SaveFile;
	function createIcon(p1 : flash.display.IBitmapDrawable) : Void;
	function load() : Void;
	function save() : Void;
	function sendVote(p1 : String, p2 : Float) : Void;
	static var DEFAULT_ICON(default,never) : flash.display.BitmapData;
	static var ICON_HEIGHT(default,never) : UInt;
	static var ICON_WIDTH(default,never) : UInt;
	static var _imageFilePath : String;
	static var _saveFilePath : String;
	static var currentFile(default,never) : SaveFile;
	static function fromObject(p1 : SaveGroup, p2 : Dynamic) : SaveFile;
}
