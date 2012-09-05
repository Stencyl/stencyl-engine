package com.newgrounds;

extern class APICommand extends APIEventDispatcher {
	var command : String;
	var hasSecureParameters(default,never) : Bool;
	var hasTimeout : Bool;
	var parameters : Dynamic;
	var preventCache : Bool;
	var secureParameters : Dynamic;
	function new(p1 : String) : Void;
	function addFile(p1 : String, p2 : flash.utils.ByteArray, p3 : String, ?p4 : String) : Void;
	function clearFiles() : Void;
	function close() : Void;
	function loadInBrowser(p1 : APIConnection, p2 : Bool) : Void;
	function removeFile(p1 : String) : Void;
	function send(p1 : APIConnection) : Void;
	static var bridge : Bridge;
	static function stopPendingCommands() : Void;
}
