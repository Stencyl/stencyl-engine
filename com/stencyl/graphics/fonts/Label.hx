package com.stencyl.graphics.fonts;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.geom.Point;

import com.stencyl.Config;
import com.stencyl.Engine;
import com.stencyl.models.Actor;
import com.stencyl.models.Font;
import com.stencyl.graphics.EngineScaleUpdateListener;
import com.stencyl.utils.ColorMatrix;
import com.stencyl.utils.Utils;

class Label extends Sprite implements EngineScaleUpdateListener
{
	private var _stencylFont:Font;
	private var _font:BitmapFont;
	private var _text:String;
	private var _color:Int;
	private var _useColor:Bool;
	private var _outline:Bool;
	private var _outlineColor:Int;
	private var _shadow:Bool;
	private var _shadowColor:Int;
	private var _background:Bool;
	private var _backgroundColor:Int;
	private var _alignment:Int;
	private var _padding:Int;
	
	private var _fontScale:Float;
	private var _autoUpperCase:Bool;
	private var _wordWrap:Bool;
	private var _fixedWidth:Bool;
	
	private var _pendingTextChange:Bool;
	private var _fieldWidth:Int;
	private var _multiLine:Bool;
	
	private var _alpha:Float;
	
	@:isVar public var labelX (get, set):Float;
	@:isVar public var labelY (get, set):Float;
	
	#if !use_tilemap
	public var bitmapData:BitmapData;
	private var _bitmap:Bitmap;
	
	private var _preparedTextGlyphs:Map<Int, BitmapData>;
	private var _preparedShadowGlyphs:Map<Int, BitmapData>;
	private var _preparedOutlineGlyphs:Map<Int, BitmapData>;
	#else
	public var _shadowTilemap:Tilemap;
	public var _outlineTilemap:Tilemap;
	public var _characterTilemap:Tilemap;
	#end

	public var cacheParentAnchor:Point = Utils.zero;
	
	/**
	 * Constructs a new text field component.
	 * @param pFont	optional parameter for component's font prop
	 */
	public function new(?pFont:BitmapFont = null) 
	{
		super();
		
		_text = "";
		_color = 0x0;
		_useColor = true;
		_outline = false;
		_outlineColor = 0x0;
		_shadow = false;
		_shadowColor = 0x0;
		_background = false;
		_backgroundColor = 0xFFFFFF;
		_alignment = TextAlign.LEFT;
		_padding = 0;
		_pendingTextChange = false;
		_fieldWidth = 1;
		_multiLine = false;
		
		_fontScale = 1;
		_autoUpperCase = false;
		_fixedWidth = true;
		_wordWrap = true;
		_alpha = 1;
		
		if (pFont == null || pFont == Font.defaultFont)
		{
			_font = Font.defaultFont;
			_fontScale = Engine.SCALE;
		}
		else
		{
			_font = pFont;
		}
		
		#if !use_tilemap
		updateGlyphs(true, _shadow, _outline);
		
		bitmapData = new BitmapData(1, 1, true);
		_bitmap = new Bitmap(bitmapData);
		this.addChild(_bitmap);
		#else
		cacheAsBitmap = true;
		#end
		
		_pendingTextChange = true;
		update();
	}
	
	/**
	 * Clears all resources used.
	 */
	public function destroy():Void 
	{
		_stencylFont = null;
		_font = null;
		#if !use_tilemap
		removeChild(_bitmap);
		_bitmap = null;
		bitmapData.dispose();
		bitmapData = null;
		
		clearPreparedGlyphs(_preparedTextGlyphs);
		clearPreparedGlyphs(_preparedShadowGlyphs);
		clearPreparedGlyphs(_preparedOutlineGlyphs);
		#else
		removeChildren();
		_outlineTilemap = null;
		_shadowTilemap = null;
		_characterTilemap = null;
		#end
	}
	
	/**
	 * Text to display.
	 */
	public var text(get, set):String;
	
	public function get_text():String
	{
		return _text;
	}
	
	public function set_text(pText:String):String 
	{
		var tmp:String = pText;
		tmp = tmp.split("\\n").join("\n");
		if (tmp != _text)
		{
			_text = pText;
			_text = _text.split("\\n").join("\n");
			if (_autoUpperCase)
			{
				_text = _text.toUpperCase();
			}
			_pendingTextChange = true;
			update();
		}
		return _text;
	}
	
	/**
	 * Internal method for updating the view of the text component
	 */
	private function updateBitmapData():Void 
	{
		if (_font == null)
		{
			return;
		}
		
		var sFieldWidth = Std.int(_fieldWidth * Engine.SCALE);
		var sPadding = Std.int(_padding * Engine.SCALE);
		
		var calcFieldWidth:Int = sFieldWidth;
		var rows:Array<String> = [];
		
		var alignment:Int = _alignment;
		
		// cut text into pices
		var lineComplete:Bool;
		
		// get words
		var lines:Array<String> = _text.split("\n");
		var i:Int = -1;
		var j:Int = -1;
		if (!_multiLine)
		{
			lines = [lines[0]];
		}
		
		var wordLength:Int;
		var word:String;
		var tempStr:String;
		while (++i < lines.length) 
		{
			if (_fixedWidth)
			{
				lineComplete = false;
				var words:Array<String> = lines[i].split(" ");
				
				if (words.length > 0) 
				{
					var wordPos:Int = 0;
					var txt:String = "";
					while (!lineComplete) 
					{
						word = words[wordPos];
						var currentRow:String = txt + word + " ";
						var changed:Bool = false;
						
						if (_wordWrap)
						{
							if (_font.getTextWidth(currentRow, _fontScale) > sFieldWidth) 
							{
								if (txt == "")
								{
									words.splice(0, 1);
								}
								else
								{
									rows.push(txt.substr(0, txt.length - 1));
								}
								
								txt = "";
								if (_multiLine)
								{
									words.splice(0, wordPos);
								}
								else
								{
									words.splice(0, words.length);
								}
								wordPos = 0;
								changed = true;
							}
							else
							{
								txt += word + " ";
								wordPos++;
							}
							
						}
						else
						{
							if (_font.getTextWidth(currentRow, _fontScale) > sFieldWidth) 
							{
								j = 0;
								tempStr = "";
								wordLength = word.length;
								while (j < wordLength)
								{
									currentRow = txt + word.charAt(j);
									if (_font.getTextWidth(currentRow, _fontScale) > sFieldWidth) 
									{
										rows.push(txt.substr(0, txt.length - 1));
										txt = "";
										word = "";
										wordPos = words.length;
										j = wordLength;
										changed = true;
									}
									else
									{
										txt += word.charAt(j);
									}
									j++;
								}
							}
							else
							{
								txt += word + " ";
								wordPos++;
							}
						}
						
						if (wordPos >= words.length) 
						{
							if (!changed) 
							{
								var subText:String = txt.substr(0, txt.length - 1);
								calcFieldWidth = Math.floor(Math.max(calcFieldWidth, _font.getTextWidth(subText, _fontScale)));
								rows.push(subText);
							}
							lineComplete = true;
						}
					}
				}
				else
				{
					rows.push("");
				}
			}
			else
			{
				calcFieldWidth = Math.floor(Math.max(calcFieldWidth, _font.getTextWidth(lines[i], _fontScale)));
				rows.push(lines[i]);
			}
		}
		
		var finalWidth:Int = calcFieldWidth + sPadding * 2 + (_outline ? 2 : 0);
		var finalHeight:Int = Math.floor(
			sPadding * 2 +
			Math.max(1, (rows.length * _font.lineHeight * _fontScale + (_shadow ? 1 : 0)) + (_outline ? 2 : 0)) +
			((rows.length >= 1) ? _font.ySpacing * (rows.length - 1) * _fontScale : 0)
		);
		
		#if !use_tilemap
		if (bitmapData != null) 
		{
			if (finalWidth != bitmapData.width || finalHeight != bitmapData.height) 
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
		
		if (bitmapData == null) 
		{
			bitmapData = new BitmapData(finalWidth, finalHeight, !_background, _backgroundColor);
		} 
		else 
		{
			bitmapData.fillRect(bitmapData.rect, _backgroundColor);
		}
		bitmapData.lock();
		#else
		graphics.clear();
		if (_background == true)
		{
			graphics.beginFill(_backgroundColor, _alpha);
			graphics.drawRect(0, 0, finalWidth, finalHeight);
			graphics.endFill();
		}
		removeChildren();
		if (_outline)
		{
			_outlineTilemap = new Tilemap(finalWidth, finalHeight, _font.getTileset(), Config.antialias);
			tint(_outlineTilemap, _outlineColor);
			addChild(_outlineTilemap);
		}
		if (_shadow)
		{
			_shadowTilemap = new Tilemap(finalWidth, finalHeight, _font.getTileset(), Config.antialias);
			tint(_shadowTilemap, _shadowColor);
			addChild(_shadowTilemap);
		}
		_characterTilemap = new Tilemap(finalWidth, finalHeight, _font.getTileset(), Config.antialias);
		if(_useColor)
		{
			tint(_characterTilemap, _color);
		}
		addChild(_characterTilemap);
		#end
		
		// render text
		var row:Int = 0;
		
		for (t in rows) 
		{
			var ox:Int = 0; // LEFT
			var oy:Int = 0;
			if (alignment == TextAlign.CENTER) 
			{
				if (_fixedWidth)
				{
					ox = Math.floor((sFieldWidth - _font.getTextWidth(t, _fontScale)) / 2);
				}
				else
				{
					ox = Math.floor((finalWidth - _font.getTextWidth(t, _fontScale)) / 2);
				}
			}
			if (alignment == TextAlign.RIGHT) 
			{
				if (_fixedWidth)
				{
					ox = sFieldWidth - Math.floor(_font.getTextWidth(t, _fontScale));
				}
				else
				{
					ox = finalWidth - Math.floor(_font.getTextWidth(t, _fontScale)) - 2 * sPadding;
				}
			}
			ox += sPadding;
			oy += sPadding + Std.int(row * (_font.lineHeight + _font.ySpacing) * _fontScale);
			if (_outline) 
			{
				for (py in 0...(2 + 1)) 
				{
					for (px in 0...(2 + 1)) 
					{
						#if !use_tilemap
						_font.render(bitmapData, _preparedOutlineGlyphs, t, _outlineColor, _alpha, ox + px, oy + py, _fontScale);
						#else
						_font.render(_outlineTilemap, t, _alpha, ox + px, oy + py, _fontScale);
						#end
					}
				}
				ox += 1;
				oy += 1;
			}
			if (_shadow) 
			{
				#if !use_tilemap
				_font.render(bitmapData, _preparedShadowGlyphs, t, _shadowColor, _alpha, ox + 1, oy + 1, _fontScale);
				#else
				_font.render(_shadowTilemap, t, _alpha, ox + 1, oy + 1, _fontScale);
				#end
			}
			#if !use_tilemap
			_font.render(bitmapData, _preparedTextGlyphs, t, _color, _alpha, ox, oy, _fontScale);
			#else
			_font.render(_characterTilemap, t, _alpha, ox, oy, _fontScale);
			#end
			row++;
		}
		#if !use_tilemap
		bitmapData.unlock();
		#end
		
		_pendingTextChange = false;
	}
	
	/**
	 * Updates the bitmap data for the text field if any changes has been made.
	 */
	public function update():Void 
	{
		if (_pendingTextChange) 
		{
			updateBitmapData();
			#if !use_tilemap
			_bitmap.bitmapData = bitmapData;
			#end
		}
	}
	
	/**
	 * Specifies whether the text field should have a filled background.
	 */
	public var background(get, set):Bool;
	
	public function get_background():Bool
	{
		return _background;
	}
	
	public function set_background(value:Bool):Bool 
	{
		if (_background != value)
		{
			_background = value;
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Specifies the color of the text field background.
	 */
	public var backgroundColor(get, set):Int;
	
	public function get_backgroundColor():Int
	{
		return _backgroundColor;
	}
	
	public function set_backgroundColor(value:Int):Int
	{
		if (_backgroundColor != value)
		{
			_backgroundColor = value;
			if (_background)
			{
				_pendingTextChange = true;
				update();
			}
		}
		return value;
	}
	
	/**
	 * Specifies whether the text should have a shadow.
	 */
	public var shadow(get, set):Bool;
	
	public function get_shadow():Bool
	{
		return _shadow;
	}
	
	public function set_shadow(value:Bool):Bool
	{
		if (_shadow != value)
		{
			_shadow = value;
			_outline = false;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
			update();
		}
		
		return value;
	}
	
	/**
	 * Specifies the color of the text field shadow.
	 */
	public var shadowColor(get, set):Int;
	
	public function get_shadowColor():Int
	{
		return _shadowColor;
	}
	
	public function set_shadowColor(value:Int):Int 
	{
		if (_shadowColor != value)
		{
			_shadowColor = value;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
			update();
		}
		
		return value;
	}
	
	/**
	 * Sets the padding of the text field. This is the distance between the text and the border of the background (if any).
	 */
	public var padding(get, set):Int;
	
	public function get_padding():Int
	{
		return _padding;
	}
	
	public function set_padding(value:Int):Int 
	{
		if (_padding != value)
		{
			_padding = value;
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Sets the color of the text.
	 */
	public var color(get, set):Int;
	
	public function get_color():Int
	{
		return _color;
	}
	
	public function set_color(value:Int):Int 
	{
		if (_color != value)
		{
			_color = value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	public var useColor(get, set):Bool;
	
	private function get_useColor():Bool 
	{
		return _useColor;
	}
	
	private function set_useColor(value:Bool):Bool 
	{
		if (_useColor != value)
		{
			_useColor = value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	public function setWidth(pWidth:Int):Int 
	{
		if (pWidth < 1) 
		{
			pWidth = 1;
		}
		if (pWidth != _fieldWidth)
		{
			_fieldWidth = pWidth;
			_pendingTextChange = true;
			update();
		}
		
		return pWidth;
	}
	
	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	public var alignment(get, set):Int;
	
	public function get_alignment():Int
	{
		return _alignment;
	}
	
	public function set_alignment(pAlignment:Int):Int 
	{
		if (_alignment != pAlignment)
		{
			_alignment = pAlignment;
			_pendingTextChange = true;
			update();
		}
		return pAlignment;
	}
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	public var multiLine(get, set):Bool;
	
	public function get_multiLine():Bool
	{
		return _multiLine;
	}
	
	public function set_multiLine(pMultiLine:Bool):Bool 
	{
		if (_multiLine != pMultiLine)
		{
			_multiLine = pMultiLine;
			_pendingTextChange = true;
			update();
		}
		return pMultiLine;
	}
	
	/**
	 * Specifies whether the text should have an outline.
	 */
	public var outline(get, set):Bool;
	
	public function get_outline():Bool
	{
		return _outline;
	}
	
	public function set_outline(value:Bool):Bool 
	{
		if (_outline != value)
		{
			_outline = value;
			_shadow = false;
			updateGlyphs(false, false, true);
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Specifies whether color of the text outline.
	 */
	public var outlineColor(get, set):Int;
	
	public function get_outlineColor():Int
	{
		return _outlineColor;
	}
	
	public function set_outlineColor(value:Int):Int 
	{
		if (_outlineColor != value)
		{
			_outlineColor = value;
			updateGlyphs(false, false, _outline);
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Sets which font to use for rendering.
	 */
	public var font(get, set):BitmapFont;
	
	public function get_font():BitmapFont
	{
		return _font;
	}
	
	public function set_font(pFont:BitmapFont):BitmapFont 
	{
		if (_font != pFont)
		{
			_font = pFont;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
			update();
		}
		return pFont;
	}

	/**
	 * Sets which font to use for rendering.
	 */
	public var stencylFont(get, set):Font;
	
	public function get_stencylFont():Font
	{
		return _stencylFont;
	}
	
	public function set_stencylFont(pFont:Font):Font 
	{
		if (_stencylFont != pFont)
		{
			_stencylFont = pFont;
			if(pFont == null)
			{
				_font = Font.defaultFont;
				_fontScale = Engine.SCALE;
			}
			else
			{
				_font = pFont.font;
				_fontScale = pFont.fontScale;
			}
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
			update();
		}
		return pFont;
	}
	
	public function setAlpha(pAlpha:Float):Void
	{
		if (_alpha != pAlpha)
		{
			_alpha = pAlpha;
			#if !use_tilemap
			this.alpha = _alpha;
			#else
			_pendingTextChange = true;
			update();
			#end
		}
	}
	
	public function getAlpha():Float
	{
		return _alpha;
	}
	
	/**
	 * Sets the "font size" of the text
	 */
	public var fontScale(get, set):Float;
	
	public function get_fontScale():Float
	{
		return _fontScale;
	}
	
	public function set_fontScale(pScale:Float):Float
	{
		var tmp:Float = Math.abs(pScale);
		if (tmp != _fontScale)
		{
			_fontScale = tmp;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
			update();
		}
		return pScale;
	}
	
	public var autoUpperCase(get, set):Bool;
	
	private function get_autoUpperCase():Bool 
	{
		return _autoUpperCase;
	}
	
	private function set_autoUpperCase(value:Bool):Bool 
	{
		if (_autoUpperCase != value)
		{
			_autoUpperCase = value;
			if (_autoUpperCase)
			{
				text = _text.toUpperCase();
			}
		}
		return _autoUpperCase;
	}
	
	public var wordWrap(get, set):Bool;
	
	private function get_wordWrap():Bool 
	{
		return _wordWrap;
	}
	
	private function set_wordWrap(value:Bool):Bool 
	{
		if (_wordWrap != value)
		{
			_wordWrap = value;
			_pendingTextChange = true;
			update();
		}
		return _wordWrap;
	}
	
	public var fixedWidth(get, set):Bool;
	
	private function get_fixedWidth():Bool 
	{
		return _fixedWidth;
	}
	
	private function set_fixedWidth(value:Bool):Bool 
	{
		if (_fixedWidth != value)
		{
			_fixedWidth = value;
			_pendingTextChange = true;
			update();
		}
		return _fixedWidth;
	}

	public function set_labelX(x:Float):Float
	{
		this.x = x * Engine.SCALE;

		return labelX = x;
	}
	
	public function get_labelX():Float
	{
		return labelX;
	}

	public function set_labelY(y:Float):Float
	{
		this.y = y * Engine.SCALE;

		return labelY = y;
	}
	
	public function get_labelY():Float
	{
		return labelY;
	}

	public function updatePosition():Void
	{
		x = labelX * Engine.SCALE - cacheParentAnchor.x;
		y = labelY * Engine.SCALE - cacheParentAnchor.y;
	}

	public function updateScale():Void
	{
		updatePosition();
		if(_stencylFont != null)
		{
			set_font(_stencylFont.font);
		}
		else if(_font == Font.defaultFont)
		{
			set_fontScale(Engine.SCALE);
		}
	}
	
	private function updateGlyphs(?textGlyphs:Bool = false, ?shadowGlyphs:Bool = false, ?outlineGlyphs:Bool = false):Void
	{
		#if !use_tilemap
		if (textGlyphs)
		{
			clearPreparedGlyphs(_preparedTextGlyphs);
			_preparedTextGlyphs = _font.getPreparedGlyphs(_fontScale, _color, _useColor);
		}
		
		if (shadowGlyphs)
		{
			clearPreparedGlyphs(_preparedShadowGlyphs);
			_preparedShadowGlyphs = _font.getPreparedGlyphs(_fontScale, _shadowColor);
		}
		
		if (outlineGlyphs)
		{
			clearPreparedGlyphs(_preparedOutlineGlyphs);
			_preparedOutlineGlyphs = _font.getPreparedGlyphs(_fontScale, _outlineColor);
		}
		#end
	}
	
	#if !use_tilemap
	private function clearPreparedGlyphs(pGlyphs:Map<Int, BitmapData>):Void
	{
		if (pGlyphs != null)
		{
			for (bmd in pGlyphs)
			{
				if (bmd != null)
				{
					bmd.dispose();
				}
			}
			pGlyphs = null;
		}
	}
	#else
	private function tint(tilemap:Tilemap, color:Int):Void
	{
		var cm:ColorMatrix = new ColorMatrix();
		cm.colorize(color, 1);
		tilemap.filters = [cm.getFilter()];
	}
	#end

}