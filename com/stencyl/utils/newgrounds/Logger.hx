package com.newgrounds;

extern class Logger {
	function new() : Void;
	static var PRIORITY_ERROR(default,never) : UInt;
	static var PRIORITY_INTERNAL(default,never) : UInt;
	static var PRIORITY_MAX(default,never) : UInt;
	static var PRIORITY_MESSAGE(default,never) : UInt;
	static var PRIORITY_WARNING(default,never) : UInt;
	static function addEventListener(p1 : String, p2 : Dynamic) : Void;
	static function logError(?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic) : Void;
	static function logInternal(?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic) : Void;
	static function logMessage(?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic) : Void;
	static function logWarning(?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic) : Void;
}
