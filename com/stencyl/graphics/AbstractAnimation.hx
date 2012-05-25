package com.stencyl.graphics;

interface AbstractAnimation 
{
	public function update(elapsedTime:Float):Void;
	public function getCurrentFrame():Int;
	public function getNumFrames():Int;
	public function setFrame(frame:Int):Void;
	public function isFinished():Bool;
	public function reset():Void;
	public function draw(g:G, x:Float, y:Float):Void;
}
