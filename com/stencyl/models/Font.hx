package com.stencyl.models;

import com.stencyl.graphics.G;
import com.stencyl.graphics.fonts.Label;
import com.stencyl.graphics.fonts.BitmapFont;
import com.stencyl.graphics.fonts.DefaultFontGenerator;
import com.stencyl.utils.Assets;

class Font extends Resource
{	
	public static var defaultFont:BitmapFont = null;
	
	public static function resetStatics():Void
	{
		defaultFont = null;
	}

	public var font:BitmapFont;
	public var fontScale:Float;
	public var letterSpacing:Int;
	public var isDefault:Bool;
	
	public var graphicsLoaded:Bool;

	public function new(ID:Int, atlasID:Int, name:String, isDefault:Bool)
	{	
		super(ID, name, atlasID);
		
		this.isDefault = isDefault;
		
		if(isAtlasActive())
		{
			loadGraphics();
		}
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
		if(graphicsLoaded)
			return;
		
		if(isDefault)
		{
			var textBytes = Assets.getText("assets/graphics/default-font.fnt");
			var xml = Xml.parse(textBytes);
			defaultFont = font = new BitmapFont().loadAngelCode(Assets.getBitmapData("assets/graphics/default-font.png"), xml);
			fontScale = 1 * Engine.SCALE;
			letterSpacing = 0;
			defaultFont.isDefault = true;
		}
		
		else
		{
			var textBytes = Assets.getText('assets/graphics/${Engine.IMG_BASE}/font-$ID.fnt');
			var xml = Xml.parse(textBytes);
			var img = Assets.getBitmapData
			(
				"assets/graphics/" + Engine.IMG_BASE + "/font-" + ID + ".png",
				false
			);
			
			font = new BitmapFont().loadAngelCode(img, xml);
			fontScale = 1;
			letterSpacing = 0;
		}
		
		graphicsLoaded = true;
	}
	
	override public function unloadGraphics()
	{
		if(!graphicsLoaded)
			return;
			
		//Use the default font - no extra memory, graceful fallback.
		font = defaultFont;
		fontScale = 1;
		letterSpacing = 0;
		
		graphicsLoaded = false;
	}

	@:access(com.stencyl.graphics.G.fontData)
	override public function reloadGraphics(subID:Int)
	{
		super.reloadGraphics(subID);
		
		#if (!use_tilemap)
		var g:G = Engine.engine.g;
		if(G.fontCache != null && G.fontCache.exists(ID))
		{
			G.fontCache.set(ID, font.getPreparedGlyphs(fontScale, 0x000000, isDefault));
		}
		if(g.font == this)
		{
			g.fontData = G.fontCache.get(ID);
		}
		#end
	}
	
	public function setLetterSpacing(spacing:Float)
	{
		letterSpacing = Std.int(spacing);
	}
	
	public function isBitmapFont(xml:Xml):Bool
	{
		for (node in xml.elements())
		{
			if (node.nodeName == "font")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "info")
					{
						for (att in nodeChild.attributes())
						{
							if (att == "lspace")
							{
								// Only bitmap fonts have this attribute.
								return true;
							}
						}
					}
				}
			}
		}
		return false;
	}
}