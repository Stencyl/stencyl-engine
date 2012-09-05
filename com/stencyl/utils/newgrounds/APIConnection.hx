package com.newgrounds;

extern class APIConnection {
	var apiId : String;
	var apiURL : String;
	var connected(default,never) : Bool;
	var connectionState : String;
	var debug : Bool;
	var encryptionKey : String;
	var hasUserSession(default,never) : Bool;
	var hostDomain : String;
	var hostURL : String;
	var initialized : Bool;
	var isNetworkHost(default,never) : Bool;
	var publisherId : UInt;
	var sandboxType(default,never) : String;
	var sessionId : String;
	var trackerId : UInt;
	var userEmail : String;
	var userId : UInt;
	var username : String;
	var userpageFormat : UInt;
	function new() : Void;
	function assertConnected() : Bool;
	function assertInitialized() : Bool;
	function loadInBrowser(p1 : String, p2 : Bool = true, ?p3 : Dynamic) : Void;
	function reset() : Void;
	function sendCommand(p1 : APICommand) : Void;
	function sendSimpleCommand(p1 : String, p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic) : Void;
	static var CONNECTED(default,never) : String;
	static var CONNECTING(default,never) : String;
	static var NOT_CONNECTED(default,never) : String;
}
