package com.newgrounds.components;

extern class MedalPopup extends flash.display.MovieClip, implements Dynamic {
	var _alwaysOnTop : Bool;
	var _medalQueue : Array<Dynamic>;
	var _medalScrollRect : flash.geom.Rectangle;
	var _unlockedMedal : com.newgrounds.Medal;
	var alwaysOnTop : String;
	var medalIcon : flash.display.MovieClip;
	var medalNameClip : flash.display.MovieClip;
	var medalPointsText : flash.text.TextField;
	function new() : Void;
	function frame1() : Dynamic;
	function frame105() : Dynamic;
	function frame15() : Dynamic;
	function frame23() : Dynamic;
	function frame84() : Dynamic;
	function medalPopupEnterFrame(p1 : flash.events.Event) : Void;
	function onMedalUnlocked(p1 : com.newgrounds.APIEvent) : Void;
	function showNextUnlock() : Void;
}
