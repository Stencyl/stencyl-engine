package com.newgrounds.components;

extern class VoteBar extends flash.display.MovieClip, implements Dynamic {
	var _numButtons : UInt;
	var _rating : com.newgrounds.SaveRating;
	var fileMode : String;
	var i : UInt;
	var ratingName : String;
	var saveFile : com.newgrounds.SaveFile;
	var title : String;
	var titleText : flash.text.TextField;
	var voteButton : Dynamic;
	var voteMenu : flash.display.MovieClip;
	function new() : Void;
	function _onNewFile(p1 : com.newgrounds.APIEvent) : Void;
	function _onVoteClick(p1 : flash.events.MouseEvent) : Void;
	function _onVoteComplete(p1 : com.newgrounds.APIEvent) : Void;
	function frame1() : Dynamic;
	function frame2() : Dynamic;
	function frame59() : Dynamic;
	function start() : Void;
}
