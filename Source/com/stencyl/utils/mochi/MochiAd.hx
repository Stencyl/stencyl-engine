package mochi.as3;

extern class MochiAd {
	function new() : Void;
	static function _allowDomains(p1 : String) : String;
	static function _cleanup(p1 : Dynamic) : Void;
	static function _getRes(p1 : Dynamic, p2 : Dynamic) : Array<Dynamic>;
	static function _isNetworkAvailable() : Bool;
	static function _parseOptions(p1 : Dynamic, p2 : Dynamic) : Dynamic;
	static function adShowing(p1 : Dynamic) : Void;
	static function createEmptyMovieClip(p1 : Dynamic, p2 : String, p3 : Float) : flash.display.MovieClip;
	static function doOnEnterFrame(p1 : flash.display.MovieClip) : Void;
	static function getValue(p1 : Dynamic, p2 : String) : Dynamic;
	static function getVersion() : String;
	static function load(p1 : Dynamic) : flash.display.MovieClip;
	static function rpc(p1 : Dynamic, p2 : Float, p3 : Dynamic) : Void;
	static function runMethod(p1 : Dynamic, p2 : String, p3 : Array<Dynamic>) : Dynamic;
	static function setValue(p1 : Dynamic, p2 : String, p3 : Dynamic) : Void;
	static function showClickAwayAd(p1 : Dynamic) : Void;
	static function showInterLevelAd(p1 : Dynamic) : Void;
	static function showPreGameAd(p1 : Dynamic) : Void;
	static function showPreloaderAd(p1 : Dynamic) : Void;
	static function showTimedAd(p1 : Dynamic) : Void;
	static function unload(p1 : Dynamic) : Bool;
}
