package mochi.as3;

extern class MochiEventDispatcher {
	function new() : Void;
	function addEventListener(p1 : String, p2 : Dynamic) : Void;
	function removeEventListener(p1 : String, p2 : Dynamic) : Void;
	function triggerEvent(p1 : String, p2 : Dynamic) : Void;
}
