package com.stencyl.graphics.fonts;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using lime._internal.unifill.Unifill;

#if (flash)
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
	
	#if (!use_tilemap)
	private var _glyphs:Array<BitmapData>;
	#else
	private var _glyphs:Map<Int,FontSymbol>;
	private var _num_letters:Int;
	private var _tileset:Tileset;
	#end
	private var _glyphString:String;
	private var _maxHeight:Int;
	
	#if (!use_tilemap)
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	#end
	
	private var _point:Point;
	
	public var isDefault = false;
	public var lineSpacing = 0;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 * @param	pBitmapData	The bitmap data to copy letters from.
	 * @param	pLetters	String of letters available in the bitmap data.
	 */
	public function new() 
	{
		_maxHeight = 0;
		_point = new Point();
		#if (!use_tilemap)
		_matrix = new Matrix();
		_colorTransform = new ColorTransform();
		_glyphs = [];
		#else
		_glyphs = new Map<Int,FontSymbol>();
		_num_letters = 0;
		#end
	}
	
	/**
	 * Loads font data in Pixelizer's format
	 * @param	pBitmapData	font source image
	 * @param	pLetters	all letters contained in this font
	 * @return				this font
	 */
	public function loadPixelizer(pBitmapData:BitmapData, pLetters:String):BitmapFont
	{
		reset();
		_glyphString = pLetters;
		
		if (pBitmapData != null) 
		{
			var tileRects:Array<Rectangle> = [];
			var result:BitmapData = prepareBitmapData(pBitmapData, tileRects);
			var currRect:Rectangle;
			
			#if (use_tilemap)
			_tileset = new Tileset(result);
			#end
			
			for (letterID in 0...(tileRects.length))
			{
				currRect = tileRects[letterID];
				
				// create glyph
				#if (!use_tilemap)
				var bd:BitmapData = new BitmapData(Math.floor(currRect.width), Math.floor(currRect.height), true, 0x0);
				bd.copyPixels(pBitmapData, currRect, ZERO_POINT, null, null, true);
				
				// store glyph
				setGlyph(_glyphString.charCodeAt(letterID), bd);
				#else
				setGlyph(_glyphString.charCodeAt(letterID), currRect, letterID, 0, 0, Math.floor(currRect.width));
				#end
			}
		}
		
		return this;
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
			var point:Point = new Point();
			var bd:BitmapData;
			var letterID:Int = 0;
			var charCode:Int;
			var charString:String;
			
			#if (use_tilemap)
			_tileset = new Tileset(pBitmapData);
			#end
			
			var chars:Xml = null;
			for (node in pXMLData.elements())
			{
				if (node.nodeName == "font")
				{
					for (nodeChild in node.elements())
					{
						if (nodeChild.nodeName == "common")
						{
							lineSpacing = Std.parseInt(nodeChild.get("lineHeight"));
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
						rect.x = Std.parseInt(node.get("x"));
						rect.y = Std.parseInt(node.get("y"));
						rect.width = Std.parseInt(node.get("width"));
						rect.height = Std.parseInt(node.get("height"));
						
						point.x = Std.parseInt(node.get("xoffset"));
						point.y = Std.parseInt(node.get("yoffset"));
						
						charCode = Std.parseInt(node.get("id"));
						charString = String.fromCharCode(charCode);
						_glyphString += charString;
						
						var xadvance:Int = Std.parseInt(node.get("xadvance"));
						//var padding:Int = Std.parseInt(node.get("padding"));
						
						var charWidth:Int = xadvance;

						if(rect.width > xadvance)
						{
							charWidth = Std.int(rect.width);
							point.x = 0;
						}
						
						// create glyph
						#if (!use_tilemap)
						bd = null;
						if (charString != " " && charString != "")
						{
							bd = new BitmapData(charWidth, Std.parseInt(node.get("height")) + Std.parseInt(node.get("yoffset")), true, 0x0);
						}
						else
						{
							bd = new BitmapData(charWidth, 1, true, 0x0);
						}
						bd.copyPixels(pBitmapData, rect, point, null, null, true);
						
						// store glyph
						setGlyph(charCode, bd);
						#else
						if (charString != " " && charString != "")
						{
							setGlyph(charCode, rect, letterID, Math.floor(point.x), Math.floor(point.y), charWidth);
						}
						else
						{
							setGlyph(charCode, rect, letterID, Math.floor(point.x), 1, charWidth);
						}
						#end
						
						letterID++;
					}
				}
			}
		}
		
		return this;
	}
	
	/**
	 * internal function. Resets current font
	 */
	private function reset():Void
	{
		dispose();
		_maxHeight = 0;
		#if (!use_tilemap)
		_glyphs = [];
		#else
		_glyphs = new Map<Int,FontSymbol>();
		#end
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
					if (gh > _maxHeight) 
					{
						_maxHeight = gh;
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
	
	#if (!use_tilemap)
	public function getPreparedGlyphs(pScale:Float, pColor:Int, ?pUseColorTransform:Bool = true):Array<BitmapData>
	{
		var result:Array<BitmapData> = [];
		
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
		for (i in 0...(_glyphs.length))
		{
			glyph = _glyphs[i];
			if (glyph != null)
			{
				preparedGlyph = new BitmapData(Math.floor(glyph.width * pScale), Math.floor(glyph.height * pScale), true, 0x00000000);
				if (pUseColorTransform)
				{
					preparedGlyph.draw(glyph,  _matrix, _colorTransform);
				}
				else
				{
					preparedGlyph.draw(glyph,  _matrix);
				}
				result[i] = preparedGlyph;
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
		#if (!use_tilemap)
		var bd:BitmapData;
		for (i in 0...(_glyphs.length)) 
		{
			bd = _glyphs[i];
			if (bd != null) 
			{
				_glyphs[i].dispose();
			}
		}
		#else
		_tileset = null;
		_num_letters = 0;
		#end
		_glyphs = null;
	}
	
	#if (!use_tilemap)
	/**
	 * Serializes font data to cryptic bit string.
	 * @return	Cryptic string with font as bits.
	 */
	public function getFontData():String 
	{
		var output:String = "";
		for (i in 0...(_glyphString.length)) 
		{
			var charCode:Int = _glyphString.charCodeAt(i);
			var glyph:BitmapData = _glyphs[charCode];
			output += _glyphString.substr(i, 1);
			output += glyph.width;
			output += glyph.height;
			for (py in 0...(glyph.height)) 
			{
				for (px in 0...(glyph.width)) 
				{
					output += (glyph.getPixel32(px, py) != 0 ? "1":"0");
				}
			}
		}
		return output;
	}
	#end
	
	#if (!use_tilemap)
	private function setGlyph(pCharID:Int, pBitmapData:BitmapData):Void 
	{
		if (_glyphs[pCharID] != null) 
		{
			_glyphs[pCharID].dispose();
		}
		
		_glyphs[pCharID] = pBitmapData;
		
		if (pBitmapData.height > _maxHeight) 
		{
			_maxHeight = pBitmapData.height;
		}
	}
	#else
	private function setGlyph(pCharID:Int, pRect:Rectangle, pGlyphID:Int, ?pOffsetX:Int = 0, ?pOffsetY:Int = 0, ?pAdvanceX:Int = 0):Void 
	{
		if(pRect.width == 0)
			pRect.width = 1;
		if(pRect.height == 0)
			pRect.height = 1;
		_tileset.addRect(pRect);
		
		var symbol:FontSymbol = new FontSymbol();
		symbol.tileID = pGlyphID;
		symbol.xoffset = pOffsetX;
		symbol.yoffset = pOffsetY;
		symbol.xadvance = pAdvanceX;
		
		_glyphs.set(pCharID, symbol);
		_num_letters++;
		
		if ((Math.floor(pRect.height) + pOffsetY) > _maxHeight) 
		{
			_maxHeight = Math.floor(pRect.height) + pOffsetY;
		}
	}
	#end
	
	/**
	 * Renders a string of text onto bitmap data using the font.
	 * @param	pBitmapData	Where to render the text.
	 * @param	pText	Text to render.
	 * @param	pColor	Color of text to render.
	 * @param	pOffsetX	X position of text output.
	 * @param	pOffsetY	Y position of text output.
	 */
	#if (!use_tilemap) 
	public function render(pBitmapData:BitmapData, pFontData:Array<BitmapData>, pText:String, pColor:PixelColor, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int, pScale:Float, ?pAngle:Float = 0):Void 
	#else
	public function render(tilemap:Tilemap, pText:String, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int, pScale:Float, ?pAngle:Float = 0):Void 
	#end
	{
		_point.x = pOffsetX;
		_point.y = pOffsetY;
		#if (!use_tilemap)
		var glyph:BitmapData;
		#else
		var glyph:FontSymbol;
		var glyphWidth:Int;
		#end

		for (c in pText.uIterator()) 
		{		
			var charCode:Int = c.toInt();
			
			#if (!use_tilemap)
			glyph = pFontData[charCode];
			if (glyph != null) 
			#else
			glyph = _glyphs.get(charCode);
			if (_glyphs.exists(charCode))
			#end
			{
				#if (!use_tilemap)

				if(pAlpha == 1 && pScale == 1)
				{
					pBitmapData.copyPixels(glyph, glyph.rect, _point, null, null, true);
				}
				
				else if(pScale == 1)
				{
					var colorTransformation = new ColorTransform(1,1,1,pAlpha,0,0,0,0);
					var copy = glyph.clone();
					copy.colorTransform(copy.rect, colorTransformation);
					pBitmapData.copyPixels(copy, copy.rect, _point, null, null, true);
				}

				else
				{
					var mtx = new Matrix();
					if (!isDefault) mtx.scale(pScale, pScale);
					mtx.translate(_point.x, _point.y);
					var colorTransformation = (pAlpha == 1 ? null : new ColorTransform(1,1,1,pAlpha,0,0,0,0));
					pBitmapData.draw(glyph, mtx, colorTransformation, null, new Rectangle(_point.x, _point.y, glyph.width * pScale, glyph.height * pScale));
				}
				
				var scaledWidth = glyph.width * Math.min(pScale, 1);
				_point.x += scaledWidth + pLetterSpacing;
				#else
				glyphWidth = glyph.xadvance;
				
				if(charCode != 32)
				{
					var tile = new Tile(glyph.tileID, _point.x + glyph.xoffset * pScale, _point.y + glyph.yoffset * pScale);
					
					tile.scaleX = pScale;
					tile.scaleY = pScale;
					tile.alpha = pAlpha;

					tilemap.addTile(tile);
				}
				
				_point.x += glyphWidth * pScale + pLetterSpacing;
				#end
			}
		}
	}

	#if (use_tilemap)
	public function renderToImg(pBitmapData:BitmapData, pText:String, pColor:PixelColor, pAlpha:Float, pOffsetX:Int, pOffsetY:Int, pLetterSpacing:Int, pScale:Float, ?pAngle:Float = 0, ?pUseColorTransform:Bool = true):Void 
	{
		var tilemap = new Tilemap(pBitmapData.width, pBitmapData.height, _tileset);

		render(tilemap, pText, pAlpha, pOffsetX, pOffsetY, pLetterSpacing, pScale, pAngle);

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
	 * @param	pLetterSpacing	distance between letters
	 * @param	pFontScale	"size" of the font
	 * @return	Width in pixels.
	 */
	public function getTextWidth(pText:String, ?pLetterSpacing:Int = 0, ?pFontScale:Float = 1.0):Int 
	{
		var w:Int = 0;
		var realCount = 0;
		var textLength:Int = pText.length;
		for (i in 0...(textLength)) 
		{
			if(i < realCount)
			{
				continue;
			}
			
			var charCode:Int = pText.charCodeAt(i);
			
			//Pseudo Unicode
			if(charCode == 126)
			{
				if(pText.charAt(i + 1) == 'x')
				{
					var unicodeChar = pText.substring(i + 2, i + 6);
					charCode = Std.parseInt("0x" + unicodeChar);
					realCount += 5;
				}
			}
			
			#if (!use_tilemap)
			var glyph:BitmapData = _glyphs[charCode];
			if (glyph != null) 
			{
				w += glyph.width;
			}
			#else
			if (_glyphs.exists(charCode)) 
			{
				
				w += _glyphs.get(charCode).xadvance;
			}
			#end
			
			realCount++;
		}
		
		w = Math.round(w * pFontScale);
		
		if (textLength > 1)
		{
			w += (textLength - 1) * pLetterSpacing;
		}
		
		return w;
	}
	
	/**
	 * Returns height of font in pixels.
	 * @return Height of font in pixels.
	 */
	public function getFontHeight():Int 
	{
		return _maxHeight;
	}
	
	/**
	 * Returns number of letters available in this font.
	 * @return Number of letters available in this font.
	 */
	public var numLetters(get, null):Int;
	
	public function get_numLetters():Int 
	{
		#if (!use_tilemap)
		return _glyphs.length;
		#else
		return _num_letters;
		#end
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

	#if (use_tilemap)
	public function getTileset():Tileset
	{
		return _tileset;
	}
	#end
}
