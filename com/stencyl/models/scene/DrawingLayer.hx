package com.stencyl.models.scene;

import com.stencyl.utils.Utils;

import openfl.display.Sprite;

class DrawingLayer extends Sprite
{
	public function new()
	{
		super();
	}
	
	public function clearFrame():Void
	{
		Utils.removeAllChildren(this);
		
		#if stencyl4_compat
		graphics.clear();
		#end
	}
}