package com.newgrounds.components;

extern class ScoreBrowser extends flash.display.MovieClip, implements Dynamic {
	var _listItems : Array<Dynamic>;
	var _loading : Bool;
	var _numScores : UInt;
	var _scoreBoard : com.newgrounds.ScoreBoard;
	var i : UInt;
	var listBox : flash.display.MovieClip;
	var nextButton : flash.display.SimpleButton;
	var pageText : flash.text.TextField;
	var period : String;
	var prevButton : flash.display.SimpleButton;
	var reloadButton : flash.display.SimpleButton;
	var score : com.newgrounds.Score;
	var scoreBoardName : String;
	var scoreClip : flash.display.MovieClip;
	var scoreContainer : flash.display.MovieClip;
	var title : String;
	var titleText : flash.text.TextField;
	function new() : Void;
	function _onListChange(p1 : Dynamic) : Void;
	function _onPageClick(p1 : flash.events.MouseEvent) : Void;
	function _onScoresLoaded(p1 : com.newgrounds.APIEvent) : Void;
	function frame1() : Dynamic;
	function frame11() : Dynamic;
	function frame2() : Dynamic;
	function frame21() : Dynamic;
	function frame30() : Dynamic;
	function loadScores() : Void;
	function onReloadClick(p1 : flash.events.MouseEvent) : Void;
	function onScoreClick(p1 : flash.events.MouseEvent) : Void;
}
