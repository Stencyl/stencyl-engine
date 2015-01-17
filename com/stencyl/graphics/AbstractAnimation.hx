package com.stencyl.graphics;

import openfl.display.BitmapData;

interface AbstractAnimation 
{
	public function update(elapsedTime:Float):Void;
	public function getCurrentFrame():Int;
	public function getNumFrames():Int;
	public function setFrame(frame:Int):Void;
	public function isFinished():Bool;
	public function reset():Void;
	public function needsBitmapUpdate():Bool;
	public function updateBitmap():Void;
	public function draw(g:G, x:Float, y:Float, angle:Float, alpha:Float):Void;
	public function getFrameDurations():Array<Int>;
	public function setFrameDurations(time:Int):Void;
	public function setFrameDuration(frame:Int, time:Int):Void;
	public function getCurrentImage():BitmapData;
}
