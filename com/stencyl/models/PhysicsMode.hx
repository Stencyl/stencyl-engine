package com.stencyl.models;

@:enum abstract PhysicsMode(Int) from Int to Int
{
	public var NORMAL_PHYSICS = 0;
	public var SIMPLE_PHYSICS = 1;
	public var MINIMAL_PHYSICS = 2;
	
	public function new(value:Int) this = value;

	@:from public static function fromInt (value:Int):PhysicsMode
	{
		return new PhysicsMode(value);
	}

	@:from public static function fromString (value:String):PhysicsMode
	{
		return switch (value)
		{
			case "NORMAL_PHYSICS": NORMAL_PHYSICS;
			case "SIMPLE_PHYSICS": SIMPLE_PHYSICS;
			case "MINIMAL_PHYSICS": MINIMAL_PHYSICS;
			default: NORMAL_PHYSICS;
		}
	}
	
	@:to public function toString ():String
	{
		return switch (this)
		{
			case NORMAL_PHYSICS: "NORMAL_PHYSICS";
			case SIMPLE_PHYSICS: "SIMPLE_PHYSICS";
			case MINIMAL_PHYSICS: "MINIMAL_PHYSICS";
			default: "NORMAL_PHYSICS";
		}
	}
}