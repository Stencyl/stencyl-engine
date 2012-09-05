package com.newgrounds.crypto;

extern class MD5 {
	function new() : Void;
	static var digest : flash.utils.ByteArray;
	static function hash(p1 : String) : String;
	static function hashBinary(p1 : flash.utils.ByteArray) : String;
	static function hashBytes(p1 : flash.utils.ByteArray) : String;
	static function rol(p1 : Int, p2 : Int) : Int;
	static function ror(p1 : Int, p2 : Int) : UInt;
	static function toHex(p1 : Int, p2 : Bool = false) : String;
}
