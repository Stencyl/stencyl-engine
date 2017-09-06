package com.stencyl.graphics;

class Scale
{
	public static var _1X = new Scale(1.0);
	public static var _1_5X = new Scale(1.5);
	public static var _2X = new Scale(2.0);
	public static var _3X = new Scale(3.0);
	public static var _4X = new Scale(4.0);
	
	public var value(default, null):Float;

	public function new(value:Float)
	{
		this.value = value;
	}

	public static function fromString (value:String):Scale
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
	
	public function toString():String
	{
		return
			value == 1.0 ? "1x" :
			value == 1.5 ? "1.5x" :
			value == 2.0 ? "2x" :
			value == 3.0 ? "3x" :
			value == 4.0 ? "4x" :
			"";
	}
}