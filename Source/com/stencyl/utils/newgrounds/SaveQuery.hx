package com.newgrounds;

extern class SaveQuery extends APIEventDispatcher {
	var files(default,never) : Array<Dynamic>;
	var group(default,never) : SaveGroup;
	var isRandomized : Bool;
	var page : UInt;
	var resultsPerPage : UInt;
	function new(p1 : SaveGroup) : Void;
	function addCondition(p1 : String, p2 : String, p3 : Dynamic) : Void;
	function clone() : SaveQuery;
	function execute() : Void;
	function nextPage() : Void;
	function prevPage() : Void;
	function reset() : Void;
	function sortOn(p1 : String, p2 : Bool = false) : Void;
	static var AUTHOR_ID(default,never) : String;
	static var AUTHOR_NAME(default,never) : String;
	static var CREATED_ON(default,never) : String;
	static var FILE_ID(default,never) : String;
	static var FILE_NAME(default,never) : String;
	static var FILE_STATUS(default,never) : String;
	static var FILE_VIEWS(default,never) : String;
	static var OPERATOR_BEGINS_WITH(default,never) : String;
	static var OPERATOR_CONTAINS(default,never) : String;
	static var OPERATOR_ENDS_WITH(default,never) : String;
	static var OPERATOR_EQUAL(default,never) : String;
	static var OPERATOR_GREATER_OR_EQUAL(default,never) : String;
	static var OPERATOR_GREATER_THAN(default,never) : String;
	static var OPERATOR_LESS_OR_EQUAL(default,never) : String;
	static var OPERATOR_LESS_THAN(default,never) : String;
	static var OPERATOR_NOT_BEGINS_WITH(default,never) : String;
	static var OPERATOR_NOT_CONTAINS(default,never) : String;
	static var OPERATOR_NOT_ENDS_WITH(default,never) : String;
	static var OPERATOR_NOT_EQUAL(default,never) : String;
	static var UPDATED_ON(default,never) : String;
}
