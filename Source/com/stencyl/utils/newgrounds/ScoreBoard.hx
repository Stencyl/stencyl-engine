package com.newgrounds;

extern class ScoreBoard extends APIEventDispatcher {
	var firstResult : UInt;
	var name(default,never) : String;
	var numResults : UInt;
	var page(default,never) : UInt;
	var period : String;
	var scores(default,never) : Array<Dynamic>;
	var tag : String;
	function new(p1 : APIConnection, p2 : String, p3 : UInt) : Void;
	function loadScores() : Void;
	function nextPage() : Void;
	function postScore(p1 : Float, ?p2 : String) : Void;
	function prevPage() : Void;
	static var ALL_TIME(default,never) : String;
	static var THIS_MONTH(default,never) : String;
	static var THIS_WEEK(default,never) : String;
	static var THIS_YEAR(default,never) : String;
	static var TODAY(default,never) : String;
}
