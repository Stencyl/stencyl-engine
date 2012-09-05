package com.newgrounds.components;

extern class FlashAdBase extends flash.display.MovieClip {
	var SIMPLE_ADS : String;
	var VIDEO_ADS : String;
	var _adContainer(default,never) : flash.display.Sprite;
	var _newgroundsButton(default,never) : flash.display.DisplayObject;
	var adType : String;
	var fullScreen : Bool;
	var showBorder : Bool;
	var showPlayButton : Bool;
	function new() : Void;
	function removeAd() : Void;
}
