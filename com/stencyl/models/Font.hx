package com.stencyl.models;

import nme.Assets;
import com.stencyl.graphics.fonts.BitmapFont;

import com.stencyl.graphics.fonts.Label;
import com.stencyl.graphics.fonts.BitmapFont;
import com.stencyl.graphics.fonts.DefaultFontGenerator;

class Font extends Resource
{	
	public var font:BitmapFont;
	public var fontScale:Float;

	public function new(ID:Int, name:String, isDefault:Bool)
	{	
		super(ID, name);
		
		if(isDefault)
		{
			//TODO: Make a 1.5, 2 and 4 version of this
			var textBytes = Assets.getText("assets/graphics/default-font.fnt");
			var xml = Xml.parse(textBytes);
			font = new BitmapFont().loadAngelCode(Assets.getBitmapData("assets/graphics/default-font.png"), xml);
			fontScale = 1;
		}
		
		else
		{
			var textBytes = Data.get().resourceAssets.get(ID + ".fnt");
			var xml = Xml.parse(textBytes);
			font = new BitmapFont().loadAngelCode(Data.get().resourceAssets.get(ID + ".png"), xml);
			fontScale = 1;
		}
	}		
	
	public function getHeight():Int
	{
		return font.getFontHeight();
	}
}
