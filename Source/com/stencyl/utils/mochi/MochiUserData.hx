package mochi.as3;

extern class MochiUserData extends flash.events.EventDispatcher {
	var _loader : flash.net.URLLoader;
	var callback : Dynamic;
	var data : Dynamic;
	var error : flash.events.Event;
	var key : String;
	var operation : String;
	function new(?p1 : String, ?p2 : Dynamic) : Void;
	function close() : Void;
	function completeHandler(p1 : flash.events.Event) : Void;
	function deserialize(p1 : flash.utils.ByteArray) : Dynamic;
	function errorHandler(p1 : flash.events.IOErrorEvent) : Void;
	function getEvent() : Void;
	function performCallback() : Void;
	function putEvent(p1 : Dynamic) : Void;
	function request(p1 : String, p2 : flash.utils.ByteArray) : Void;
	function securityErrorHandler(p1 : flash.events.SecurityErrorEvent) : Void;
	function serialize(p1 : Dynamic) : flash.utils.ByteArray;
	static function get(p1 : String, p2 : Dynamic) : Void;
	static function put(p1 : String, p2 : Dynamic, p3 : Dynamic) : Void;
}
