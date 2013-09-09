/*
 *                            _/                                                    _/   
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/    
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/     
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/      
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/       
 *   _/                            _/        _/                                          
 *  _/                        _/_/      _/_/                                             
 *                                                                                       
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009-2010 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package com.stencyl.utils;

using com.stencyl.utils.Mathematics;

/**
 * <b>Static fields/methods:</b><br/>
 * A helper class for working with 24-bit color values expressed as a single integer value.
 * RGB values encoded in 24 bits per pixel (bpp) are specified using three 8-bit unsigned
 * integers (0..255) representing the intensities of red, green, and blue.
 * <br/>
 * <b>Non-static fields/methods:</b><br/>
 * Defines a 24-bit color value expressed as a RGB triplet (r,g,b) using three doubles in the range
 * 0 to 1 (255).
 */
class RGB
{
	/** 0x000000 */ inline public static var BLACK   = 0x000000;
	/** 0xffffff */ inline public static var WHITE   = 0xffffff;
	/** 0xff0000 */ inline public static var RED     = 0xff0000;
	/** 0x00ff00 */ inline public static var GREEN   = 0x00ff00;
	/** 0x0000ff */ inline public static var BLUE    = 0x0000ff;
	/** 0x00ffff */ inline public static var CYAN    = 0x00ffff;
	/** 0xff00ff */ inline public static var MAGENTA = 0xff00ff;
	/** 0xffff00 */ inline public static var YELLOW  = 0xffff00;
	
	/**
	 * Creates an 24-bit RGB color value using three 8-bit values <i>r</i>,<i>g</i>,<i>b</i> for the
	 * red, green and blue color channels, respectively.
	 */
	inline public static function setRGBi(r:Int, g:Int, b:Int):Int
	{
		return (r & 0xff) << 16 | (g & 0xff) << 8 | (b & 0xff);
	}
	
	/**
	 * Creates an 24-bit RGB color value using three float values in the range &#091;0,1&#093;
	 * for the red (<i>r</i>), green (<i>g</i>) and blue (<i>b</i>) color channels.
	 */
	inline public static function setRGBf(r:Float, g:Float, b:Float):Int
	{
		return setRGBi
		(
			(r.fclamp(0, 1) * 0xff).round(),
			(g.fclamp(0, 1) * 0xff).round(),
			(b.fclamp(0, 1) * 0xff).round()
		);
	}
	
	/** Gets the red color component as an 8-bit value in the range 0 to 255. */
	inline public static function getR(x:Int):Int { return x >>> 16 & 0xff; }
	/** Gets the red color component as a floating point value between 0 and 1 (255). */
	inline public static function getRf(x:Int):Float { return getR(x) * (1.0 / 255.0); }
	
	/** Gets the green color component as an 8-bit value in the range 0 to 255. */
	inline public static function getG(x:Int):Int { return x >>> 8 & 0xff; }
	/** Gets the green color component as a floating point value between 0 and 1 (255). */
	inline public static function getGf(x:Int):Float { return getG(x) * (1.0 / 255.0); }
	
	/** Gets the blue color component as an 8-bit value in the range 0 to 255. */
	inline public static function getB(x:Int):Int { return x & 0xff; }
	/** Gets the blue color component as a floating point value between 0 and 1 (255). */
	inline public static function getBf(x:Int):Float { return getB(x) * (1.0 / 255.0); }
	
	/** Sets the red color component of <i>x</i> to the 8-bit value of <i>r</i>. */
	inline public static function setR(x:Int, r:Int):Int { return (r & 0xff) << 16 | (x & 0xff00ffff); }
	/** Sets the red color component of <i>x</i> to the floating point value of <i>r</i> in the range &#091;0,1&#093;. */
	inline public static function setRf(x:Int, r:Float):Int { return setR(x, (r.fclamp(0.0, 1.0) * 0xff).round()); }
	
	/** Sets the green color component of <i>x</i> to the 8-bit value of <i>g</i>. */
	inline public static function setG(x:Int, g:Int):Int { return (g & 0xff) << 8 | (x & 0xffff00ff); }
	/** Sets the green color component of <i>x</i> to the floating point value of <i>g</i> in the range &#091;0,1&#093;. */
	inline public static function setGf(x:Int, g:Float):Int { return setG(x, (g.fclamp(0.0, 1.0) * 0xff).round()); }
	
	/** Sets the blue color component of <i>x</i> to the 8-bit value of <i>b</i>. */
	inline public static function setB(x:Int, b:Int):Int { return (b & 0xff) | (x & 0xffffff00); }
	/** Sets the blue color component of <i>x</i> to the floating point value of <i>b</i> in the range &#091;0,1&#093;. */
	inline public static function setBf(x:Int, b:Float):Int { return setB(x, (b.fclamp(0.0, 1.0) * 0xff).round()); }
	
	/** The value of the red color component in the range &#091;0,1&#093;. */
	public var r:Float;
	/** The value of the green color component in the range &#091;0,1&#093;. */
	public var g:Float;
	/** The value of the blue color component in the range &#091;0,1&#093;. */
	public var b:Float;
	
	/** Creates a new RGB color object using <i>r</i> for red, <i>g</i> for green and <i>b</i> for blue. */
	public function new(?r = 0.0, ?g = 0.0, ?b = 0.0)
	{
		this.r = r;
		this.g = g;
		this.b = b;
	}
	
	/** Assigns values for the red (<i>r</i>), green (<i>g</i>) and blue (<i>b</i>) component. */
	inline public function set(r:Float, g:Float, b:Float):Void { this.r = r; this.g = g; this.b = b; }
	
	/** Linearly interpolates between this and <i>input</i>: this = this + (<i>input</i>-this) * <i>t</i>. */
	inline public function lerp(input:RGB, output:RGB, t:Float):Void
	{
		output.r = r + (input.r - r) * t;
		output.g = g + (input.g - g) * t;
		output.b = b + (input.b - b) * t;
	}
	
	/** Converts the red color channel to an 8-bit unsigned integer. */
	inline public function getR8():Int { return (r * 0xff).round(); }
	/** Converts the green color channel to an 8-bit unsigned integer. */
	inline public function getG8():Int { return (g * 0xff).round(); }
	/** Converts the blue color channel to an 8-bit unsigned integer. */
	inline public function getB8():Int { return (b * 0xff).round(); }
	
	/** Converts the RGB triplet to an 24-bit integer. */
	inline public function get24():Int { return getR8() << 16 | getG8() << 8 | getB8(); }
	/** Assigns a red (<i>r</i>), green (<i>g</i>) and blue (<i>b</i>) color value using three 8-bit unsigned integers. */
	inline public function set24(r:Int, g:Int, b:Int):Void { set((r & 0xff) * (1.0 / 255.0), (g & 0xff) * (1.0 / 255.0), (b & 0xff) * (1.0 / 255.0)); }
	
	/** Copies the RGB triplet into <i>target</i> and returns <i>target</i>. */
	inline public function copy(target:RGB):RGB
	{
		target.r = r;
		target.g = g;
		target.b = b;
		return target;
	}
}