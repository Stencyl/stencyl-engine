package com.newgrounds;

extern class SaveRating {
	var id(default,never) : UInt;
	var isFloat(default,never) : Bool;
	var maximum(default,never) : Float;
	var minimum(default,never) : Float;
	var name(default,never) : String;
	function new(p1 : String, p2 : UInt, p3 : Bool, p4 : Float, p5 : Float) : Void;
	function toString() : String;
	function validateValue(p1 : Dynamic) : Float;
}
