package com.stencyl.graphics.fonts;

import com.stencyl.Config;

#if use_tilemap
import com.stencyl.graphics.TextureAtlas;
#end

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

#if flash
typedef PixelColor = UInt;
#else
typedef PixelColor = Int;
#end

/**
 * Holds information and bitmap glpyhs for a bitmap font.
 * @author Johan Peitz
 */
class BitmapFont 
{
	private static var _storedFonts:Map<String,BitmapFont> = new Map<String,BitmapFont>();
	
	private static var ZERO_POINT:Point = new Point();
	
	private var _glyphs:Map<Int,FontSymbol>;
	private var _num_letters:Int;
	#if use_tilemap
	private var _tileset:Tileset;
	#end
	private var _glyphString:String;
	
	#if !use_tilemap
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	#end
	
	private var _point:Point;
	
	public var isDefault = false;
	public var xSpacing = 0;
	public var ySpacing = 0;
	public var lineHeight = 0;
	public var baseline = 0;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 * @param	pBitmapData	The bitmap data to copy letters from.
	 * @param	pLetters	String of letters available in the bitmap data.
	 */
	public function new() 
	{
		_point = new Point();
		#if !use_tilemap
		_matrix = new Matrix();
		_colorTransform = new ColorTransform();
		#end
		_glyphs = new Map<Int,FontSymbol>();
		_num_letters = 0;
	}
	
	/**
	 * Loads font data in AngelCode's format
	 * @param	pBitmapData	font image source
	 * @param	pXMLData	font data in XML format
	 * @return				this font
	 */
	public function loadAngelCode(pBitmapData:BitmapData, pXMLData:Xml):BitmapFont
	{
		reset();
		
		if (pBitmapData != null) 
		{
			_glyphString = "";
			var rect:Rectangle = new Rectangle();
			var letterID:Int = 0;
			var charCode:Int;
			var charString:String;
			
			#if use_tilemap
			_tileset = new Tileset(pBitmapData);
			#end
			
			var chars:Xml = null;
			for (node in pXMLData.elements())
			{
				if (node.nodeName == "font")
				{
					for (nodeChild in node.elements())
					{
						if (nodeChild.nodeName == "info")
						{
							var spacing = [for(s in nodeChild.get("spacing").split(",")) Std.parseInt(s)];
							xSpacing = spacing[0];
							ySpacing = spacing[1];
						}
						else if (nodeChild.nodeName == "common")
						{
							lineHeight = Std.parseInt(nodeChild.get("lineHeight"));
							baseline = Std.parseInt(nodeChild.get("base"));
						}
						else if (nodeChild.nodeName == "chars")
						{
							chars = nodeChild;
						}
					}
				}
			}
			
			if (chars != null)
			{
				for (node in chars.elements())
				{
					if (node.nodeName == "char")
					{
						var symbol:FontSymbol = new FontSymbol();
						#if use_tilemap
						symbol.tileID = letterID;
						#end
						symbol.xoffset = Std.parseInt(node.get("xoffset"));
						symbol.yoffset = Std.parseInt(node.get("yoffset"));
						symbol.xadvance = Std.parseInt(node.get("xadvance"));
						
						rect.x = Std.parseInt(node.get("x"));
						rect.y = Std.parseInt(node.get("y"));
						rect.width = Std.parseInt(node.get("width"));
						rect.height = Std.parseInt(node.get("height"));
						
						charCode = Std.parseInt(node.get("id"));
						charString = String.fromCharCode(charCode);
						_glyphString += charString;
						
						#if !use_tilemap
						if (charString != " " && charString != "")
						{
							symbol.bitmap = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0x0);
							symbol.bitmap.copyPixels(pBitmapData, rect, ZERO_POINT, null, null, true);
						}
						else
						{
							symbol.bitmap = null;
						}
						
						var oldSymbol = _glyphs.get(charCode);
						if(oldSymbol != null && oldSymbol.bitmap != null)
							oldSymbol.bitmap.dispose();
						#else
						if (charString != " " && charString != "" && rect.width > 0 && rect.height > 0)
						{
							symbol.tileID = _tileset.addRect(rect);
						}
						else
						{
							symbol.tileID = -1;
						}
						#end
						
						_glyphs.set(charCode, symbol);
						_num_letters++;
						
						letterID++;
					}
				}
			}
		}
		
		return this;
	}
	
	#if use_tilemap
	/**
	 * Loads font data in AngelCode's format
	 * @param	pBitmapData	font image source
	 * @param	pXMLData	font data in XML format
	 * @return				this font
	 */
	public function loadAngelCodeWithAtlas(textureAtlas:TextureAtlas, fileID:String, pXMLData:Xml):BitmapFont
	{
		reset();
		
		_glyphString = "";
		var charCode:Int;
		var charString:String;
		
		_tileset = textureAtlas.tileset;

		var fileData = textureAtlas.getFileData(fileID);
		
		var chars:Xml = null;
		for (node in pXMLData.elements())
		{
			if (node.nodeName == "font")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "info")
					{
						var spacing = [for(s in nodeChild.get("spacing").split(",")) Std.parseInt(s)];
						xSpacing = spacing[0];
						ySpacing = spacing[1];
					}
					else if (nodeChild.nodeName == "common")
					{
						lineHeight = Std.parseInt(nodeChild.get("lineHeight"));
						baseline = Std.parseInt(nodeChild.get("base"));
					}
					else if (nodeChild.nodeName == "chars")
					{
						chars = nodeChild;
					}
				}
			}
		}
		
		if (chars != null)
		{
			for (node in chars.elements())
			{
				if (node.nodeName == "char")
				{
					var symbol:FontSymbol = new FontSymbol();
					symbol.tileID = fileData.regions[_num_letters].tileID;
					symbol.xoffset = Std.parseInt(node.get("xoffset"));
					symbol.yoffset = Std.parseInt(node.get("yoffset"));
					symbol.xadvance = Std.parseInt(node.get("xadvance"));
					
					charCode = Std.parseInt(node.get("id"));
					charString = String.fromCharCode(charCode);
					_glyphString += charString;
					
					_glyphs.set(charCode, symbol);
					_num_letters++;
				}
			}
		}
		
		return this;
	}
	#end
	
	/**
	 * internal function. Resets current font
	 */
	private function reset():Void
	{
		dispose();
		_glyphs = new Map<Int,FontSymbol>();
		_num_letters = 0;
		_glyphString = "";
	}
	
	public function prepareBitmapData(pBitmapData:BitmapData, pRects:Array<Rectangle>):BitmapData
	{
		var bgColor:Int = pBitmapData.getPixel(0, 0);
		var cy:Int = 0;
		var cx:Int;
		
		while (cy < pBitmapData.height)
		{
			var rowHeight:Int = 0;
			cx = 0;
			
			while (cx < pBitmapData.width)
			{
				if (Std.int(pBitmapData.getPixel(cx, cy)) != bgColor) 
				{
					// found non bg pixel
					var gx:Int = cx;
					var gy:Int = cy;
					// find width and height of glyph
					while (Std.int(pBitmapData.getPixel(gx, cy)) != bgColor)
					{
						gx++;
					}
					while (Std.int(pBitmapData.getPixel(cx, gy)) != bgColor)
					{
						gy++;
					}
					var gw:Int = gx - cx;
					var gh:Int = gy - cy;
					
					pRects.push(new Rectangle(cx, cy, gw, gh));
					
					// store max size
					if (gh > rowHeight) 
					{
						rowHeight = gh;
					}
					
					// go to next glyph
					cx += gw;
				}
				
				cx++;
			}
			// next row
			cy += (rowHeight + 1);
		}
		
		var resultBitmapData:BitmapData = pBitmapData.clone();
		
		var pixelColor:PixelColor;
		var bgColor32:PixelColor = pBitmapData.getPixel32(0, 0);
		
		cy = 0;
		while (cy < pBitmapData.height)
		{
			cx = 0;
			while (cx < pBitmapData.width)
			{
				pixelColor = pBitmapData.getPixel32(cx, cy);
				if (pixelColor == bgColor32)
				{
					resultBitmapData.setPixel32(cx, cy, 0x00000000);
				}
				cx++;
			}
			cy++;
		}
		
		return resultBitmapData;
	}
	
	#if !use_tilemap
	public function getPreparedGlyphs(pScale:Float, pColor:Int, ?pUseColorTransform:Bool = true):Map<Int, BitmapData>
	{
		var result:Map<Int, BitmapData> = new Map<Int,BitmapData>();
		
		_matrix.identity();
		_matrix.scale(pScale, pScale);
		
		var colorMultiplier:Float = 0.00392;
		_colorTransform.redOffset = 0;
		_colorTransform.greenOffset = 0;
		_colorTransform.blueOffset = 0;
		_colorTransform.redMultiplier = (pColor >> 16) * colorMultiplier;
		_colorTransform.greenMultiplier = (pColor >> 8 & 0xff) * colorMultiplier;
		_colorTransform.blueMultiplier = (pColor & 0xff) * colorMultiplier;
		
		var glyph:BitmapData;
		var preparedGlyph:BitmapData;
		#if haxe4
		for (i => glyph in _glyphs)
		{
		#else
		for (i in _glyphs.keys())
		{
			var glyph = _glyphs.get(i);
		#end
			if (glyph.bitmap != null)
			{
				preparedGlyph = new BitmapData(Math.floor(glyph.bitmap.width * pScale), Math.floor(glyph.bitmap.height * pScale), true, 0x00000000);
				if (pUseColorTransform)
				{
					preparedGlyph.draw(glyph.bitmap, _matrix, _colorTransform);
				}
				else
				{
					preparedGlyph.draw(glyph.bitmap, _matrix);
				}
				result.set(i, preparedGlyph);
			}
		}
		
		return result;
	}
	#end
	
	/**
	 * Clears all resources used by the font.
	 */
	public function dispose():Void 
	{
		#if !use_tilemap
		for (glyph in _glyphs) 
		{
			if(glyph.bitmap != null)
				glyph.bitmap.dispose();
		}
		#else
		_tileset = null;
		#end
		_num_letters = 0;
		_glyphs = null;
	}
	
	/**
	 * Renders a string of text onto bitmap data using the font.
	 * @param	pBitmapData	Where to render the text.
	 * @param	pText	Text to render.
	 * @param	pColor	Color of text to render.
	 * @param	pOffsetX	X position of text output.
	 * @param	pOffsetY	Y position of text output.
	 */
	#if !use_tilemap 
	public function render(pBitmapData:BitmapData, pFontData:Map<Int,BitmapData>, pText:String, pColor:PixelColor, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pScale:Float, ?pAngle:Float = 0):Void 
	#else
	public function render(tilemap:Tilemap, pText:String, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pScale:Float, ?pAngle:Float = 0):Void 
	#end
	{
		var curX:Float = pOffsetX;
		var curY:Float = pOffsetY;
		var glyph:FontSymbol;

		for (i in 0...(pText.length)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			
			glyph = _glyphs.get(charCode);
			if (glyph != null) 
			{
				_point.x = curX + glyph.xoffset * pScale;
				_point.y = curY + glyph.yoffset * pScale;
				
				#if !use_tilemap
				
				var glyphBitmap = pFontData.get(charCode);
				
				if(glyphBitmap != null)
				{
					if(pAlpha == 1 && pScale == 1)
					{
						pBitmapData.copyPixels(glyphBitmap, glyphBitmap.rect, _point, null, null, true);
					}
					
					else if(pScale == 1)
					{
						var colorTransformation = new ColorTransform(1,1,1,pAlpha,0,0,0,0);
						var copy = glyphBitmap.clone();
						copy.colorTransform(copy.rect, colorTransformation);
						pBitmapData.copyPixels(copy, copy.rect, _point, null, null, true);
					}

					else
					{
						var mtx = new Matrix();
						if (!isDefault) mtx.scale(pScale, pScale);
						mtx.translate(_point.x, _point.y);
						var colorTransformation = (pAlpha == 1 ? null : new ColorTransform(1,1,1,pAlpha,0,0,0,0));
						pBitmapData.draw(glyphBitmap, mtx, colorTransformation, null, null);
					}
				}
				
				#else
				
				if(glyph.tileID != -1)
				{
					var tile = new Tile(glyph.tileID, _point.x, _point.y);
					
					tile.scaleX = pScale;
					tile.scaleY = pScale;
					tile.alpha = pAlpha;
					tile.tileset = _tileset;
					
					tilemap.addTile(tile);
				}
				
				#end
				
				curX += (glyph.xadvance + xSpacing) * pScale;
			}
		}
	}

	#if use_tilemap
	public function renderToImg(pBitmapData:BitmapData, pText:String, pColor:PixelColor, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pScale:Float, ?pAngle:Float = 0, ?pUseColorTransform:Bool = true):Void 
	{
		var tilemap = new Tilemap(pBitmapData.width, pBitmapData.height, _tileset, Config.antialias);

		render(tilemap, pText, pAlpha, pOffsetX, pOffsetY, pScale, pAngle);

		if (pUseColorTransform)
		{
			var red:Float = (pColor >> 16 & 0xFF) / 255;
			var green:Float = (pColor >> 8 & 0xFF) / 255;
			var blue:Float = (pColor & 0xFF) / 255;

			pBitmapData.draw(tilemap, null, new ColorTransform(red, green, blue));
		}
		else
		{
			pBitmapData.draw(tilemap);
		}

		tilemap.removeTiles();
	}
	#end

	private function toARGB(rgb:Int, newAlpha:Int):Int
	{
		var argb = 0; 
		argb = (rgb); 
		argb += (newAlpha << 24); 
		
		return argb; 
	}
	
	/**
	 * Returns the width of a certain test string.
	 * @param	pText	String to measure.
	 * @param	pFontScale	"size" of the font
	 * @return	Width in pixels.
	 */
	public function getTextWidth(pText:String, ?pFontScale:Float = 1.0):Int 
	{
		var w:Int = 0;
		var textLength:Int = pText.length;
		for (i in 0...(textLength)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			
			var glyph:FontSymbol = _glyphs.get(charCode);
			if (glyph != null)
			{
				w += glyph.xadvance;
			}
		}
		
		if (textLength > 1)
		{
			w += (textLength - 1) * xSpacing;
		}
		
		w = Std.int(w * pFontScale);
		
		return w;
	}
	
	/**
	 * Returns height of font in pixels.
	 * @return Height of font in pixels.
	 */
	public function getFontHeight(?pFontScale:Float = 1.0):Int 
	{
		return Std.int(lineHeight * pFontScale);
	}
	
	/**
	 * Returns number of letters available in this font.
	 * @return Number of letters available in this font.
	 */
	public var numLetters(get, null):Int;
	
	public function get_numLetters():Int 
	{
		return _num_letters;
	}
	
	/**
	 * Stores a font for global use using an identifier.
	 * @param	pHandle	String identifer for the font.
	 * @param	pFont	Font to store.
	 */
	public static function store(pHandle:String, pFont:BitmapFont):Void 
	{
		_storedFonts.set(pHandle, pFont);
	}
	
	/**
	 * Retrieves a font previously stored.
	 * @param	pHandle	Identifier of font to fetch.
	 * @return	Stored font, or null if no font was found.
	 */
	public static function fetch(pHandle:String):BitmapFont 
	{
		var f:BitmapFont = _storedFonts.get(pHandle);
		return f;
	}

	public function containsCharacter(char:String):Bool
	{
		return _glyphString.indexOf(char) >= 0;
	}

	#if use_tilemap
	public function getTileset():Tileset
	{
		return _tileset;
	}
	#end
}
