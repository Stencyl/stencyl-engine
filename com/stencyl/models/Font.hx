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
		/*
		var font:BitmapFont = new BitmapFont("assets/graphics/font.png", 32, 32, BitmapFont.TEXT_SET11 + "#", 9, 1, 1);
		font.text = "Stencyl 2.5";
		font.x = 10;
		font.y = 10;
		master.addChild(font);
		*/
	}		
	
	public function getHeight():Int
	{
		return 0;
	}
}
