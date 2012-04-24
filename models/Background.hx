package models;

import nme.display.Graphics;

interface Background 
{
	function update():Void;
	function draw(g:Graphics, cameraX:Int, cameraY:Int, screenWidth:Int, screenHeight:Int):Void;
}
