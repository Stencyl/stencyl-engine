package com.stencyl.models;

import com.stencyl.graphics.BitmapFont;

class Font extends Resource
{	
	//TODO:The actual font
	public var font:BitmapFont;

	public function new(ID:Int, name:String, alphabet:String, offsets:Array<Int>, height:Int, rowHeight:Int, imgData:Dynamic) 
	{	
		super(ID, name);
		
		//TODO: Make the font.
		
		//master.addChild(font);
	}		
	
	public function getHeight():Int
	{
		return 0;
	}
}
