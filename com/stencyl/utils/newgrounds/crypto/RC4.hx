package com.newgrounds.crypto;

extern class RC4 {
	function new() : Void;
	static function decrypt(p1 : String, p2 : String) : String;
	static function encrypt(p1 : String, p2 : String) : String;
	static function encryptbin(p1 : String, p2 : String) : Array<Dynamic>;
}
