package com.stencyl.graphics;

import openfl.display.BlendMode;

class BlendModes
{
	private static var stringBlendMap:Map<String, BlendMode> =
	{
		var m = new Map<String, BlendMode>();
		m.set("add", BlendMode.ADD);
		m.set("alpha", BlendMode.ALPHA);
		m.set("darken", BlendMode.DARKEN);
		m.set("difference", BlendMode.DIFFERENCE);
		m.set("erase", BlendMode.ERASE);
		m.set("hardlight", BlendMode.HARDLIGHT);
		m.set("invert", BlendMode.INVERT);
		m.set("lighten", BlendMode.LIGHTEN);
		m.set("multiply", BlendMode.MULTIPLY);
		m.set("normal", BlendMode.NORMAL);
		m.set("overlay", BlendMode.OVERLAY);
		m.set("screen", BlendMode.SCREEN);
		m.set("subtract", BlendMode.SUBTRACT);
		m;
	}

	public static function get(blendName:String):BlendMode
	{
		return stringBlendMap.get(blendName);
	}
}