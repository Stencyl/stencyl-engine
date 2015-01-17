package com.stencyl.models;

import openfl.display.Graphics;

interface Background 
{
	function update():Void;
	function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int):Void;
}
