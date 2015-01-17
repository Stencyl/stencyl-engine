package com.stencyl.graphics;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
	
/**
 * FlxBitmapFont
 * 
 * Ported to HaXe.
 * TODO - Make an alternate drawTiles-based implementation?
 * 
 * @author Richard Davey, Photon Storm, http://www.photonstorm.com
 * @author Jonathan Chung
 */
class BitmapFont extends Bitmap 
{	
	/**
	 * Alignment of the text when multiLine = true. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 */
	public var align:String;
	
	/**
	 * If set to true all carriage-returns in text will form new lines (see align). If false the font will only contain one single line of text (the default)
	 */
	public var multiLine:Bool;
	
	/**
	 * Automatically convert any text to upper case. Lots of old bitmap fonts only contain upper-case characters, so the default is true.
	 */
	public var autoUpperCase:Bool;
	
	/**
	 * Adds horizontal spacing between each character of the font, in pixels. Default is 0.
	 */
	public var customSpacingX:Int;
	
	/**
	 * Adds vertical spacing between each line of multi-line text, set in pixels. Default is 0.
	 */
	public var customSpacingY:Int;
	
	private var _text:String;
	
	/**
	 * Align each line of multi-line text to the left.
	 */
	public static var ALIGN_LEFT:String = "left";
	
	/**
	 * Align each line of multi-line text to the right.
	 */
	public static var ALIGN_RIGHT:String = "right";
	
	/**
	 * Align each line of multi-line text in the center.
	 */
	public static var ALIGN_CENTER:String = "center";
	
	/**
	 * Text Set 1 = !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
	 */
	public static inline var TEXT_SET1:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
	
	/**
	 * Text Set 2 =  !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static inline var TEXT_SET2:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	public static inline var TEXT_SET25:String = " !\"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 3 = ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 
	 */
	public static var TEXT_SET3:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
	
	/**
	 * Text Set 4 = ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
	 */
	public static var TEXT_SET4:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";
	
	/**
	 * Text Set 5 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789
	 */
	public static var TEXT_SET5:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,/() '!?-*:0123456789";
	
	/**
	 * Text Set 6 = ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' 
	 */
	public static var TEXT_SET6:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?:;0123456789\"(),-.' ";
	
	/**
	 * Text Set 7 = AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39
	 */
	public static var TEXT_SET7:String = "AGMSY+:4BHNTZ!;5CIOU.?06DJPV,(17EKQW\")28FLRX-'39";
	
	/**
	 * Text Set 8 = 0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static var TEXT_SET8:String = "0123456789 .ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 9 = ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!
	 */
	public static var TEXT_SET9:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ()-0123456789.:,'\"?!";
	
	/**
	 * Text Set 10 = ABCDEFGHIJKLMNOPQRSTUVWXYZ
	 */
	public static var TEXT_SET10:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	/**
	 * Text Set 11 = ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789
	 */
	public static var TEXT_SET11:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,\"-+!?()':;0123456789";
	
	/**
	 * Internval values. All set in the constructor. They should not be changed after that point.
	 */
	private var fontSet:BitmapData;
	private var offsetX:Int;
	private var offsetY:Int;
	private var characterWidth:Int;
	private var characterHeight:Int;
	private var characterSpacingX:Int;
	private var characterSpacingY:Int;
	private var characterPerRow:Int;
	private var grabData:Array<Rectangle>;
	
	/**
	 * Loads 'font' and prepares it for use by future calls to .text
	 * 
	 * @param	font		The font set graphic class (as defined by your embed)
	 * @param	width		The width of each character in the font set.
	 * @param	height		The height of each character in the font set.
	 * @param	chars		The characters used in the font set, in display order. You can use the TEXT_SET consts for common font set arrangements.
	 * @param	charsPerRow	The number of characters per row in the font set.
	 * @param	xSpacing	If the characters in the font set have horizontal spacing between them set the required amount here.
	 * @param	ySpacing	If the characters in the font set have vertical spacing between them set the required amount here
	 * @param	xOffset		If the font set doesn't start at the top left of the given image, specify the X coordinate offset here.
	 * @param	yOffset		If the font set doesn't start at the top left of the given image, specify the Y coordinate offset here.
	 */
    public function new(fontURL:String, width:Int, height:Int, chars:String, charsPerRow:Int, xSpacing:Int = 0, ySpacing:Int = 0, xOffset:Int = 0, yOffset:Int = 0):Void
    {
    	super();
    	
		align = "left";
		multiLine = false;
		autoUpperCase = true;
		customSpacingX = 0;
		customSpacingY = 0;
    
		//	Take a copy of the font for internal use
		fontSet = Assets.getBitmapData(fontURL);
		
		characterWidth = width;
		characterHeight = height;
		characterSpacingX = xSpacing;
		characterSpacingY = ySpacing;
		characterPerRow = charsPerRow;
		offsetX = xOffset;
		offsetY = yOffset;
		
		grabData = new Array();
		
		//	Now generate our rects for faster copyPixels later on
		var currentX:Int = offsetX;
		var currentY:Int = offsetY;
		var r:Int = 0;
		
		for(c in 0...chars.length)
		{
			//	The rect is hooked to the ASCII value of the character
			grabData[chars.charCodeAt(c)] = new Rectangle(currentX, currentY, characterWidth, characterHeight);
			
			r++;
			
			if (r == characterPerRow)
			{
				r = 0;
				currentX = offsetX;
				currentY += characterHeight + characterSpacingY;
			}
			else
			{
				currentX += characterWidth + characterSpacingX;
			}
		}
    }
    
    public var text(get_text, set_text):String;
	
	/**
	 * Set this value to update the text in this sprite. Carriage returns are automatically stripped out if multiLine is false. Text is converted to upper case if autoUpperCase is true.
	 * 
	 * @return	void
	 */ 
	public function set_text(content:String):String
	{
		if(autoUpperCase)
		{
			_text = content.toUpperCase();
		}
		else
		{
			_text = content;
		}
		
		removeUnsupportedCharacters(multiLine);
		
		buildBitmapFontText();
		
		return _text;
	}
	
	public function get_text():String
	{
		return _text;
	}
	
	/**
	 * A helper function that quickly sets lots of variables at once, and then updates the text.
	 * 
	 * @param	content				The text of this sprite
	 * @param	multiLines			Set to true if you want to support carriage-returns in the text and create a multi-line sprite instead of a single line (default is false).
	 * @param	characterSpacing	To add horizontal spacing between each character specify the amount in pixels (default 0).
	 * @param	lineSpacing			To add vertical spacing between each line of text, set the amount in pixels (default 0).
	 * @param	lineAlignment		Align each line of multi-line text. Set to FlxBitmapFont.ALIGN_LEFT (default), FlxBitmapFont.ALIGN_RIGHT or FlxBitmapFont.ALIGN_CENTER.
	 * @param	allowLowerCase		Lots of bitmap font sets only include upper-case characters, if yours needs to support lower case then set this to true.
	 */
	public function setText(content:String, multiLines:Bool = false, characterSpacing:Int = 0, lineSpacing:Int = 0, lineAlignment:String = "left", allowLowerCase:Bool = false):Void
	{
		customSpacingX = characterSpacing;
		customSpacingY = lineSpacing;
		align = lineAlignment;
		multiLine = multiLines;
		
		if (allowLowerCase)
		{
			autoUpperCase = false;
		}
		else
		{
			autoUpperCase = true;
		}
		
		text = content;
	}
	
	/**
	 * Updates the BitmapData of the Sprite with the text
	 * 
	 * @return	void
	 */
	private function buildBitmapFontText():Void
	{
		var temp:BitmapData;
		
		if (multiLine)
		{
			var lines:Array<String> = _text.split("\n");
			
			var cx:Int = 0;
			var cy:Int = 0;
		
			temp = new BitmapData(getLongestLine() * (characterWidth + customSpacingX), (lines.length * (characterHeight + customSpacingY)) - customSpacingY, true, 0xf);
			
			//	Loop through each line of text
			for(i in 0...lines.length)
			{
				//	This line of text is held in lines[i] - need to work out the alignment
				if(align == ALIGN_LEFT)
				{
					cx = 0;
				}
				
				else if(align == ALIGN_RIGHT)
				{
					cx = temp.width - (lines[i].length * (characterWidth + customSpacingX));
				}
				
				else if(align == ALIGN_CENTER)
				{
					cx = Math.floor((temp.width / 2) - ((lines[i].length * (characterWidth + customSpacingX)) / 2));
					cx += Math.floor(customSpacingX / 2);
				}
				
				//Haxe 3 doesn't like this
				/*switch (align)
				{
					case ALIGN_LEFT:
						cx = 0;
						break;
						
					case ALIGN_RIGHT:
						cx = temp.width - (lines[i].length * (characterWidth + customSpacingX));
						break;
						
					case ALIGN_CENTER:
						cx = Math.floor((temp.width / 2) - ((lines[i].length * (characterWidth + customSpacingX)) / 2));
						cx += Math.floor(customSpacingX / 2);
						break;
				}*/
				
				pasteLine(temp, lines[i], cx, cy, customSpacingX);
				
				cy += characterHeight + customSpacingY;
			}
		}
		else
		{
			temp = new BitmapData(_text.length * (characterWidth + customSpacingX), characterHeight, true, 0xf);
		
			pasteLine(temp, _text, 0, 0, customSpacingX);
		}
		
		this.bitmapData = temp;
	}
	
	/**
	 * Returns a single character from the font set as an FlxsSprite.
	 * 
	 * @param	char	The character you wish to have returned.
	 * 
	 * @return	An <code>FlxSprite</code> containing a single character from the font set.
	 */
	public function getCharacter(char:String):Bitmap
	{
		var output:Bitmap = new Bitmap();
		
		var temp:BitmapData = new BitmapData(characterWidth, characterHeight, true, 0xf);

		if(Std.is(grabData[char.charCodeAt(0)], Rectangle) && char.charCodeAt(0) != 32)
		{
			temp.copyPixels(fontSet, grabData[char.charCodeAt(0)], new Point(0, 0));
		}
		
		output.bitmapData = temp;
		
		return output;
	}
	
	/**
	 * Internal function that takes a single line of text (2nd parameter) and pastes it into the BitmapData at the given coordinates.
	 * Used by getLine and getMultiLine
	 * 
	 * @param	output			The BitmapData that the text will be drawn onto
	 * @param	line			The single line of text to paste
	 * @param	x				The x coordinate
	 * @param	y
	 * @param	customSpacingX
	 */
	private function pasteLine(output:BitmapData, line:String, x:Int = 0, y:Int = 0, customSpacingX:Int = 0):Void
	{
		for(c in 0...line.length)
		{
			//	If it's a space then there is no point copying, so leave a blank space
			if(line.charAt(c) == " ")
			{
				x += characterWidth + customSpacingX;
			}
			
			else
			{
				//	If the character doesn't exist in the font then we don't want a blank space, we just want to skip it
				if(Std.is(grabData[line.charCodeAt(c)], Rectangle))
				{
					output.copyPixels(fontSet, grabData[line.charCodeAt(c)], new Point(x, y));
					x += characterWidth + customSpacingX;
				}
			}
		}
	}
	
	/**
	 * Works out the longest line of text in _text and returns its length
	 * 
	 * @return	A value
	 */
	private function getLongestLine():Int
	{
		var longestLine:Int = 0;
		
		if(_text.length > 0)
		{
			var lines:Array<String> = _text.split("\n");
			
			for(i in 0...lines.length)
			{
				if(lines[i].length > longestLine)
				{
					longestLine = lines[i].length;
				}
			}
		}
		
		return longestLine;
	}
	
	/**
	 * Internal helper function that removes all unsupported characters from the _text String, leaving only characters contained in the font set.
	 * 
	 * @param	stripCR		Should it strip carriage returns as well? (default = true)
	 * 
	 * @return	A clean version of the string
	 */
	private function removeUnsupportedCharacters(stripCR:Bool = true):String
	{
		var newString:String = "";
		
		for(c in 0..._text.length)
		{
			if(Std.is(grabData[_text.charCodeAt(c)], Rectangle) || _text.charCodeAt(c) == 32 || (stripCR == false && _text.charAt(c) == "\n"))
			{
				newString = newString + _text.charAt(c);
			}
		}
		
		return newString;
	}
}
