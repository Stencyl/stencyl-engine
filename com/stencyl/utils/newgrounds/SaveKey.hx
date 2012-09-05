package com.newgrounds;

extern class SaveKey {
	var id(default,never) : UInt;
	var name(default,never) : String;
	var type(default,never) : UInt;
	function new(p1 : String, p2 : UInt, p3 : UInt) : Void;
	function toString() : String;
	function validateValue(p1 : Dynamic) : Dynamic;
	static var TYPE_BOOLEAN(default,never) : UInt;
	static var TYPE_FLOAT(default,never) : UInt;
	static var TYPE_INTEGER(default,never) : UInt;
	static var TYPE_STRING(default,never) : UInt;
}
