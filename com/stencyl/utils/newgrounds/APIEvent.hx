package com.newgrounds;

extern class APIEvent extends flash.events.Event {
	var data(default,never) : Dynamic;
	var error(default,never) : String;
	var success(default,never) : Bool;
	function new(p1 : String, ?p2 : Dynamic, ?p3 : String) : Void;
	static var API_CONNECTED(default,never) : String;
	static var COMMAND_COMPLETE(default,never) : String;
	static var ERROR_ALREADY_VOTED(default,never) : String;
	static var ERROR_BAD_FILE(default,never) : String;
	static var ERROR_BAD_RESPONSE(default,never) : String;
	static var ERROR_COMMAND_FAILED(default,never) : String;
	static var ERROR_HOST_BLOCKED(default,never) : String;
	static var ERROR_INVALID_ARGUMENT(default,never) : String;
	static var ERROR_NONE(default,never) : String;
	static var ERROR_NOT_CONNECTED(default,never) : String;
	static var ERROR_NOT_LOGGED_IN(default,never) : String;
	static var ERROR_SENDING_COMMAND(default,never) : String;
	static var ERROR_TIMED_OUT(default,never) : String;
	static var ERROR_UNKNOWN(default,never) : String;
	static var ERROR_WRONG_ENCRYPTION_KEY(default,never) : String;
	static var FILE_LOADED(default,never) : String;
	static var FILE_REQUESTED(default,never) : String;
	static var FILE_SAVED(default,never) : String;
	static var ICON_LOADED(default,never) : String;
	static var LOG(default,never) : String;
	static var MEDAL_UNLOCKED(default,never) : String;
	static var MEDAL_UNLOCK_CONFIRMED(default,never) : String;
	static var QUERY_COMPLETE(default,never) : String;
	static var SCORES_LOADED(default,never) : String;
	static var SCORE_POSTED(default,never) : String;
	static var VOTE_COMPLETE(default,never) : String;
}
