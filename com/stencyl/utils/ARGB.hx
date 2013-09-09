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

using Std;
using com.stencyl.utils.ARGB;
using com.stencyl.utils.Mathematics;

/**
 * <b>Static fields/methods:</b><br/>
 * A helper class for working with 32-bit color values expressed as a single unsigned value.
 * The additional eight bits are used to store the alpha channel.
 * <br/>
 * <b>Non-static fields/methods:</b><br/>
 * Defines a 32-bit color value expressed as a RGB triplet (r,g,b) using three doubles in the range
 * 0 to 1 (255) to store the red, green, and blue intensity and a fourth double to store the alpha
 * channel.
 */
class ARGB
{
	/** 0xff000000 */ inline public static var BLACK   = 0xff000000;
	/** 0xffffffff */ inline public static var WHITE   = 0xffffffff;
	/** 0xffff0000 */ inline public static var RED     = 0xffff0000;
	/** 0xff00ff00 */ inline public static var GREEN   = 0xff00ff00;
	/** 0xff0000ff */ inline public static var BLUE    = 0xff0000ff;
	/** 0xff00ffff */ inline public static var CYAN    = 0xff00ffff;
	/** 0xffff00ff */ inline public static var MAGENTA = 0xffff00ff;
	/** 0xffffff00 */ inline public static var YELLOW  = 0xffffff00;
	
	/**
	 * Creates an 32-bit ARGB color value using four 8-bit values <i>a</i>,<i>r</i>,<i>g</i>,<i>b</i>
	 * for the alpha, red, green and blue components, respectively.
	 */
	inline public static function setARGBi(a:Int, r:Int, g:Int, b:Int):Int
	{
		return (a & 0xff) << 24 | (r & 0xff) << 16 | (g & 0xff) << 8 | (b & 0xff);
	}
	
	/**
	 * Creates an 32-bit ARGB color value using four double values <i>a</i>,<i>r</i>,<i>g</i>,<i>b</i>
	 * in the range &#091;0,1&#093; for the alpha, red, green and blue components, respectively.
	 */
	inline public static function setARGBf(a:Float, r:Float, g:Float, b:Float):Int
	{
		return setARGBi
		(
			(a.fclamp(0, 1) * 0xff).round(),
			(r.fclamp(0, 1) * 0xff).round(),
			(g.fclamp(0, 1) * 0xff).round(),
			(b.fclamp(0, 1) * 0xff).round()
		);
	}
	
	inline public static function toARGB(x:Int):ARGB
	{
		return new ARGB(x.getAf(), x.getRf(), x.getGf(), x.getBf());
	}
	
	/** Returns the RGB portion. */
	inline public static function getRGB(x:Int):Int { return (x & 0x00ffffff); }
	/** Sets the RGB portion using <i>r</i>,<i>g</i>,<i>b</i> for the red, green and blue component, respectively. */
	inline public static function setRGB(x:Int, r:Int, g:Int, b:Int):Int { return (r << 16 | g << 8 | b) | (x & 0xff000000); }
	
	/** Gets the alpha component as an 8-bit value in the range 0 to 255. */
	inline public static function getA(x:Int):Int { return x >>> 24; }
	/** Gets the alpha component as a floating point value between 0 and 1 (255). */
	inline public static function getAf(x:Int):Float { return getA(x) * (1.0 / 255.0); }
	
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
	
	/** Sets the alpha component of <i>x</i> to the 8-bit value of <i>a</i>. */
	inline public static function setA(x:Int, a:Int):Int { return (a << 24) | (x & 0x00ffffff); }
	/** Sets the alpha component of <i>x</i> to the floating point value of <i>a</i> in the range &#091;0,1&#093;. */
	inline public static function setAf(x:Int, a:Float):Int { return setA(x, (a.fclamp(0.0, 1.0) * 0xff).round()); }
	
	/** Sets the red color component of <i>x</i> to the 8-bit value of <i>r</i>. */
	inline public static function setR(x:Int, r:Int):Int { return ((r & 0xff) << 16) | (x & 0xff00ffff); }
	/** Sets the red color component of <i>x</i> to the floating point value of <i>r</i> in the range &#091;0,1&#093;. */
	inline public static function setRf(x:Int, r:Float):Int { return setR(x, (r.fclamp(0.0, 1.0) * 0xff).round()); }
	
	/** Sets the green color component of <i>x</i> to the 8-bit value of <i>g</i>. */
	inline public static function setG(x:Int, g:Int):Int { return (g << 8) | (x & 0xffff00ff); }
	/** Sets the green color component of <i>x</i> to the floating point value of <i>g</i> in the range &#091;0,1&#093;. */
	inline public static function setGf(x:Int, g:Float):Int { return setG(x, (g.fclamp(0.0, 1.0) * 0xff).round()); }
	
	/** Sets the blue color component of <i>x</i> to the 8-bit value of <i>b</i>. */
	inline public static function setB(x:Int, b:Int):Int { return b | (x & 0xffffff00); }
	/** Sets the blue color component of <i>x</i> to the floating point value of <i>b</i> in the range &#091;0,1&#093;. */
	inline public static function setBf(x:Int, b:Float):Int { return setB(x, (b.fclamp(0.0, 1.0) * 0xff).round()); }
	
	/** The value of the alpha component in the range &#091;0,1&#093;. */
	public var a:Float;
	/** The value of the red color component in the range &#091;0,1&#093;. */
	public var r:Float;
	/** The value of the green color component in the range &#091;0,1&#093;. */
	public var g:Float;
	/** The value of the blue color component in the range &#091;0,1&#093;. */
	public var b:Float;
	
	/** Creates a new 32-bit ARGB color object using <i>a</i> for alpha, <i>r</i> for red,
	 * <i>g</i> for green and <i>b</i> for blue. */
	public function new(?a = 0.0, ?r = 0.0, ?g = 0.0, ?b = 0.0)
	{
		this.a = a;
		this.r = r;
		this.g = g;
		this.b = b;
	}
	
	/** Assigns values for the alpha <i>a</i>, red (<i>r</i>), green (<i>g</i>) and blue (<i>b</i>) component. */
	inline public function set(a:Float, r:Float, g:Float, b:Float):Void { this.a = a; this.r = r; this.g = g; this.b = b; }
	
	/** Linearly interpolates between this and <i>input</i>: this = this + (<i>input</i>-this) * <i>t</i>. */
	inline public function lerp(input:ARGB, t:Float, output:ARGB):Void
	{
		output.a = a + (input.a - a) * t;
		output.r = r + (input.r - r) * t;
		output.g = g + (input.g - g) * t;
		output.b = b + (input.b - b) * t;
	}
	
	/** Converts the alpha channel to an 8-bit unsigned integer. */
	inline public function getA8():Int { return (a * 0xff).round(); }
	/** Converts the red color channel to an 8-bit unsigned integer. */
	inline public function getR8():Int { return (r * 0xff).round(); }
	/** Converts the green color channel to an 8-bit unsigned integer. */
	inline public function getG8():Int { return (g * 0xff).round(); }
	/** Converts the blue color channel to an 8-bit unsigned integer. */
	inline public function getB8():Int { return (b * 0xff).round(); }
	
	/** Converts the ARGB color object to an 24-bit unsigned integer. */
	inline public function get24():Int { return getR8() << 16 | getG8() << 8 | getB8(); }
	/** Assigns a red (<i>r</i>), green (<i>g</i>) and blue (<i>b</i>) value using three 8-bit unsigned integers. */
	inline public function set24(r:Int, g:Int, b:Int):Void { set(a, (r & 0xff) * (1.0 / 255.0), (g & 0xff) * (1.0 / 255.0), (b & 0xff) * (1.0 / 255.0)); }
	
	/** Converts the ARGB color object to an 32-bit unsigned integer. */
	inline public function get32():Int { return getA8() << 24 | getR8() << 16 | getG8() << 8 | getB8(); }
	/** Assigns an alpha (<i>a</i>), red (<i>r</i>), green (<i>g</i>) and blue (<i>b</i>) value using three 8-bit unsigned integers. */
	inline public function set32(a:Int, r:Int, g:Int, b:Int):Void { set((a & 0xff) * (1.0 / 255.0), (r & 0xff) * (1.0 / 255.0), (g & 0xff) * (1.0 / 255.0), (b & 0xff) * (1.0 / 255.0)); }
	
	/** Copies the values of the ARGB object into <i>target</i> and returns <i>target</i>. */
	inline public function copy(target:ARGB):ARGB
	{
		target.a = a;
		target.r = r;
		target.g = g;
		target.b = b;
		return target;
	}
}