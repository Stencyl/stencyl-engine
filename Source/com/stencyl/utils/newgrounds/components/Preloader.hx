package com.newgrounds.components;

extern class Preloader extends flash.display.MovieClip, implements Dynamic {
	var autoPlay : Bool;
	var className : String;
	var loadingBar : flash.display.MovieClip;
	var playButton : flash.display.MovieClip;
	function new() : Void;
	function _onPlayClick(p1 : flash.events.MouseEvent) : Void;
	function enterFrameHandler(p1 : flash.events.Event) : Void;
	function frame1() : Dynamic;
	function frame10() : Dynamic;
}
