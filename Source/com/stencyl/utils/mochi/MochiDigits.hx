package mochi.as3;

@:final extern class MochiDigits {
	var value : Float;
	function new(p1 : Float = 0, p2 : UInt = 0) : Void;
	function addValue(p1 : Float) : Void;
	function reencode() : Void;
	function setValue(p1 : Float = 0, p2 : UInt = 0) : Void;
	function toString() : String;
}
