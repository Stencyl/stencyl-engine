package com.newgrounds;

extern class SaveGroup {
	var connection(default,never) : APIConnection;
	var id(default,never) : UInt;
	var keys(default,never) : Array<Dynamic>;
	var name(default,never) : String;
	var ratings(default,never) : Array<Dynamic>;
	var type(default,never) : UInt;
	function new(p1 : APIConnection, p2 : String, p3 : UInt, p4 : UInt, p5 : Array<Dynamic>, p6 : Array<Dynamic>) : Void;
	function getKey(p1 : String) : SaveKey;
	function getKeyById(p1 : UInt) : SaveKey;
	function getRating(p1 : String) : SaveRating;
	function getRatingById(p1 : UInt) : SaveRating;
	function toString() : String;
	static var TYPE_MODERATED(default,never) : UInt;
	static var TYPE_PRIVATE(default,never) : UInt;
	static var TYPE_PUBLIC(default,never) : UInt;
	static var TYPE_SYSTEM(default,never) : UInt;
}
