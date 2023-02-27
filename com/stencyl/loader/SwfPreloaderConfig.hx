package com.stencyl.loader;

#if flash
class SwfPreloaderConfig
{
	public function new()
	{

	}

	public function setFields(data:Dynamic)
	{
		swfLoc = data.swfLoc;
		swfX = data.swfX;
		swfY = data.swfY;
		swfWidth = data.swfWidth;
		swfHeight = data.swfHeight;
	}

	public var swfLoc:String;
	public var swfX:Int;
	public var swfY:Int;
	public var swfWidth:Int;
	public var swfHeight:Int;
}
#end