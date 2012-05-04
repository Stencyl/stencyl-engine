package com.stencyl.models;

class Font extends Resource
{	
	//TODO:The actual font

	public function new(ID:Int, name:String, alphabet:String, offsets:Array<Int>, height:Int, rowHeight:Int, imgData:Dynamic) 
	{	
		super(ID, name);
		
		//TODO: Make the font.
	}		
	
	public function getHeight():Number
	{
		return 0;
	}
}
