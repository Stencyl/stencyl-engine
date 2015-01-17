package com.stencyl.models;

import openfl.Assets;
import com.stencyl.graphics.fonts.BitmapFont;

import com.stencyl.graphics.fonts.Label;
import com.stencyl.graphics.fonts.BitmapFont;
import com.stencyl.graphics.fonts.DefaultFontGenerator;

class Font extends Resource
{	
	public static var defaultFont:BitmapFont = null;
	
	public var font:BitmapFont;
	public var fontScale:Float;
	public var letterSpacing:Int;
	public var isDefault:Bool;

	public function new(ID:Int, atlasID:Int, name:String, isDefault:Bool)
	{	
		super(ID, name, atlasID);
		
		this.isDefault = isDefault;
		loadGraphics();
	}		
	
	public function getHeight():Int
	{
		if(font != null)
		{
			return font.getFontHeight();
		}
		
		else
		{
			return 0;
		}
	}
	
	//For Atlases
	
	override public function loadGraphics()
	{
		if(isDefault)
		{
			var textBytes = Assets.getText("assets/graphics/default-font.fnt");
			var xml = Xml.parse(textBytes);
			defaultFont = font = new BitmapFont().loadAngelCode(Assets.getBitmapData("assets/graphics/default-font.png"), xml);
			fontScale = 1 * Engine.SCALE;
			letterSpacing = 0;
		}
		
		else
		{
			var textBytes = Data.get().resourceAssets.get(ID + ".fnt");
			var xml = Xml.parse(textBytes);
			var img = Data.get().getGraphicAsset
			(
				ID + ".png",
				"assets/graphics/" + Engine.IMG_BASE + "/font-" + ID + ".png"
			);
			
			font = new BitmapFont().loadAngelCode(img, xml);
			fontScale = 1;
			letterSpacing = 0;
		}
	}
	
	override public function unloadGraphics()
	{
		//Use the default font - no extra memory, graceful fallback.
		font = defaultFont;
		fontScale = 1;
		letterSpacing = 0;
		
		Data.get().resourceAssets.remove(ID + ".png");
	}
	
	public function setLetterSpacing(spacing:Float)
	{
		letterSpacing = Std.int(spacing);
	}
}
