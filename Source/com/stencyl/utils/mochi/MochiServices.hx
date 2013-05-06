package mochi.as3;

extern class MochiServices {
	function new() : Void;
	static var CONNECTED : String;
	static var childClip(default,never) : Dynamic;
	static var clip(default,never) : Dynamic;
	static var comChannelName(never,default) : String;
	static var connected(default,never) : Bool;
	static var id(default,never) : String;
	static var netup : Bool;
	static var netupAttempted : Bool;
	static var onError : Dynamic;
	static var widget : Bool;
	static function addEventListener(p1 : String, p2 : Dynamic) : Void;
	static function addLinkEvent(p1 : String, p2 : String, p3 : flash.display.DisplayObjectContainer, ?p4 : Dynamic) : Void;
	static function allowDomains(p1 : String) : String;
	static function bringToTop(?p1 : flash.events.Event) : Void;
	static function connect(p1 : String, p2 : Dynamic, ?p3 : Dynamic) : Void;
	static function connectWait(p1 : flash.events.TimerEvent) : Void;
	static function disconnect() : Void;
	static function doClose() : Void;
	static function getVersion() : String;
	static function isNetworkAvailable() : Bool;
	static function removeEventListener(p1 : String, p2 : Dynamic) : Void;
	static function send(p1 : String, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic) : Void;
	static function setContainer(?p1 : Dynamic, p2 : Bool = true) : Void;
	static function stayOnTop() : Void;
	static function triggerEvent(p1 : String, p2 : Dynamic) : Void;
	static function warnID(p1 : String, p2 : Bool) : Void;
}
