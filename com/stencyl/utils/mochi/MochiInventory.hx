package mochi.as3;

extern class MochiInventory extends flash.utils.Proxy, implements Dynamic {
	function new() : Void;
	function release() : Void;
	static var ERROR : String;
	static var IO_ERROR : String;
	static var NOT_READY : String;
	static var READY : String;
	static var VALUE_ERROR : String;
	static var WRITTEN : String;
	static function addEventListener(p1 : String, p2 : Dynamic) : Void;
	static function removeEventListener(p1 : String, p2 : Dynamic) : Void;
	static function triggerEvent(p1 : String, p2 : Dynamic) : Void;
}
