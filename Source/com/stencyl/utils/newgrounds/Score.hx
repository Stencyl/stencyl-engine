package com.newgrounds;

extern class Score {
	var numericValue(default,never) : Float;
	var rank(default,never) : UInt;
	var score(default,never) : String;
	var tag(default,never) : String;
	var username(default,never) : String;
	function new(p1 : UInt, p2 : String, p3 : String, p4 : Float, p5 : String) : Void;
	function toString() : String;
}
