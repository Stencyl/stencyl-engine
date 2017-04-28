package com.stencyl.graphics;

@:enum abstract Scale(Float)
{
	public var _1X = 1.0;
	public var _1_5X = 1.5;
	public var _2X = 2.0;
	public var _3X = 3.0;
	public var _4X = 4.0;
	
	@:from private static function fromString (value:String):Scale
	{
		return switch (value)
		{
			case "1x": _1X;
			case "1.5x": _1_5X;
			case "2x": _2X;
			case "3x": _3X;
			case "4x": _4X;
			default: _1X;
		}
	}
	
	@:to private static function toString (value:Float):String
	{
		return switch (value)
		{
			case Scale._1X: "1x";
			case Scale._1_5X: "1.5x";
			case Scale._2X: "2x";
			case Scale._3X: "3x";
			case Scale._4X: "4x";
			default: "1x";
		}
	}
}