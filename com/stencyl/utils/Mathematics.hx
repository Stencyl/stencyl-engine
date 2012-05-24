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

/**
 * Additional math functions and constants.
 */
class Mathematics
{
	/** Min value, signed byte.      */
	inline public static var   INT8_MIN =-0x80;
	/** Max value, signed byte.      */
	inline public static var   INT8_MAX = 0x7F;
	/** Max value, unsigned byte.    */
	inline public static var  UINT8_MAX = 0xFF;
	/** Min value, signed short.     */
	inline public static var  INT16_MIN =-0x8000;
	/** Max value, signed short.     */
	inline public static var  INT16_MAX = 0x7FFF;
	/** Max value, unsigned short.   */
	inline public static var UINT16_MAX = 0xFFFF;
	/** Min value, signed integer.   */
	inline public static var  INT32_MIN = 0x80000000;
	/** Max value, signed integer.   */
	inline public static var  INT32_MAX = 0x7fffffff;
	/** Max value, unsigned integer. */
	inline public static var UINT32_MAX = 0xffffffff;
	/** IEEE 754 NAN. */
	#if cpp
	inline public static var NaN = Math.NaN;
	#else
	inline public static var NaN = .0 / .0;
	#end
	/** IEEE 754 positive infinity. */
	#if cpp
	inline public static var POSITIVE_INFINITY = Math.POSITIVE_INFINITY;
	#else
	inline public static var POSITIVE_INFINITY = 1. / .0;
	#end
	/** IEEE 754 negative infinity. */
	#if cpp
	inline public static var NEGATIVE_INFINITY = Math.NEGATIVE_INFINITY;
	#else
	inline public static var NEGATIVE_INFINITY = -1. / .0;
	#end
	/** The largest representable number (single-precision IEEE-754). */
	inline public static var FLOAT_MAX = 3.40282346638528e+38;
	/** The smallest representable number (single-precision IEEE-754). */
	inline public static var FLOAT_MIN =-3.40282346638528e+38;
	/** The smallest representable number (double-precision IEEE-754). */
	inline public static var DOUBLE_MIN = 1.79769313486231e+308;
	/** The largest representable number (double-precision IEEE-754). */
	inline public static var DOUBLE_MAX =-1.79769313486231e+308; 
	
	/** Multiply value by this to convert from radians to degrees. */
	inline public static var RAD_DEG = 180 / PI;
	/** Multiply value by this to convert from degrees to radians. */
	inline public static var DEG_RAD = PI / 180;
	/** The natural logarithm of 2. */
	inline public static var LN2 = 0.6931471805599453;
	/** Math.PI/2 constant. */
	inline public static var PIHALF = 1.5707963267948966;
	/** Math.PI constant. */
	inline public static var PI = 3.141592653589793;
	/** 2 * Math.PI constant. */
	inline public static var PI2 = 6.283185307179586;
	/** Default system epsilon. */
	inline public static var EPS = 1e-6;
	
	#if (flash10 && !no_alchemy)
	/** Returns the 32-bit integer representation of a IEEE 754 single precision floating point. */
	inline public static function floatToInt(x:Float):Int
	{
		flash.Memory.setFloat(0, x); return flash.Memory.getI32(0);
	}
	
	/** Returns the IEEE 754 single precision floating point representation of a 32-bit integer. */
	inline public static function intToFloat(x:Int):Float
	{
		flash.Memory.setI32(0, x); return flash.Memory.getFloat(0);
	}
	#end
	
	/** Converts <i>deg</i> to radians. */
	inline public static function toRad(deg:Float):Float
	{
		return deg * Mathematics.DEG_RAD;
	}
	
	/** Converts <i>rad</i> to degrees. */
	inline public static function toDeg(rad:Float):Float
	{
		return rad * Mathematics.RAD_DEG;
	}
	
	/** Returns min(<i>x</i>, <i>y</i>). */
	inline public static function min(x:Int, y:Int):Int
	{
		return x < y ? x : y;
	}
	
	/** Returns max(<i>x</i>, <i>y</i>). */
	inline public static function max(x:Int, y:Int):Int
	{
		return x > y ? x : y;
	}
	
	/** Returns the absolute value of the integer <i>x</i>. */
	inline public static function abs(x:Int):Int
	{
		return x < 0 ? -x : x;
	}
	
	/** Returns the sign of the integer <i>x</i>. */
	inline public static function sgn(x:Int):Int
	{
		return (x > 0) ? 1 : (x < 0 ? -1 : 0);
	}
	
	/** Clamps the integer <i>x</i> to the interval &#091;<i>min</i>,<i>max</i>&#093; so <i>min</i> <= <i>x</i> <= <i>max</i>. */
	inline public static function clamp(x:Int, min:Int, max:Int):Int
	{
		return (x < min) ? min : (x > max) ? max : x;
	}
	
	/** Clamps the integer <i>x</i> to the interval &#091;<i>-i</i>,<i>+i</i>&#093; so <i>-i</i> <= <i>x</i> <= <i>i</i>. */
	inline public static function clampSym(x:Int, i:Int):Int
	{
		return (x < -i) ? -i : (x > i) ? i : x;
	}
	
	/** Wraps the integer <i>x</i> to the interval &#091;<i>min</i>,<i>max</i>&#093; so min <= x <= max. */
	inline public static function wrap(x:Int, min:Int, max:Int):Int
	{
		return x < min ? (x - min) + max + 1: ((x > max) ? (x - max) + min - 1: x);
	}
	
	/** Fast replacement for Math.min(<i>x</i>, <i>y</i>). */
	inline public static function fmin(x:Float, y:Float):Float
	{
		return x < y ? x : y;
	}
	
	/** Fast replacement for Math.max(<i>x</i>, <i>y</i>). */
	inline public static function fmax(x:Float, y:Float):Float
	{
		return x > y ? x : y;
	}
	
	/** Fast replacement for Math.abs(<i>x</i>). */
	inline public static function fabs(x:Float):Float
	{
		return x < 0 ? -x : x;
	}
	
	/** Extracts the sign of the number <i>x</i>. */
	inline public static function fsgn(x:Float):Int
	{
		return x >= .0 ? 1 : -1;
	}
	
	/** Clamps a number to the interval &#091;<i>min</i>,<i>max</i>&#093; so <i>min</i> <= <i>x</i> <= <i>max</i>. */
	inline public static function fclamp(x:Float, min:Float, max:Float):Float
	{
		return (x < min) ? min : (x > max) ? max : x;
	}
	
	/** Clamps a number to the interval &#091;<i>-i</i>,<i>+i</i>&#093; so -<i>i</i> <= <i>x</i> <= <i>i</i>. */
	inline public static function fclampSym(x:Float, i:Float):Float
	{
		return (x < -i) ? -i : (x > i) ? i : x;
	}
	
	/** Wraps a number to the interval &#091;<i>min</i>,<i>max</i>&#093; so <i>min</i> <= <i>x</i> <= <i>max</i>. */
	inline public static function fwrap(x:Float, min:Float, max:Float):Float
	{
		return x < min ? (x - min) + max + 1. : ((x > max) ? (x - max) + min - 1. : x);
	}

	/** Returns true if the sign of <i>x</i> and <i>y</i> is equal. */
	inline public static function eqSgn(x:Int, y:Int):Bool
	{
		return (x ^ y) >= 0;
	}
	
	/** Returns true if <i>x</i> is even. */
	inline public static function isEven(x:Int):Bool
	{
		return (x & 1) == 0;
	}
	
	/** Returns true if <i>x</i> is a power of two. */
	inline public static function isPow2(x:Int):Bool
	{
		return x > 0 && (x & (x - 1)) == 0;
	}
	
	/** Linear interpolation over interval &#091;<i>a</i>,<i>b</i>&#093; with t = &#091;0,1&#093;. */
	inline public static function lerp(a:Float, b:Float, t:Float):Float
	{
		return a + (b - a) * t;
	}
	
	/**
	 * Spherically interpolates between two angles.
	 * see http://www.paradeofrain.com/2009/07/interpolating-2d-rotations/
	 */
	inline public static function slerp(a:Float, b:Float, t:Float)
	{
		var m = Math;
		
        var c1 = m.sin(a * .5);
        var r1 = m.cos(a * .5);
		var c2 = m.sin(b * .5);
        var r2 = m.cos(b * .5);
        
       var c = r1 * r2 + c1 * c2;
        
        if (c < 0.)
		{
			if ((1. + c) > Mathematics.EPS)
			{
				var o = m.acos(-c);
				var s = m.sin(o);
				var s0 = m.sin((1 - t) * o) / s;
				var s1 = m.sin(t * o) / s;
				return m.atan2(s0 * c1 - s1 * c2, s0 * r1 - s1 * r2) * 2.;
			}
			else
			{
				var s0 = 1 - t;
				var s1 = t;
				return m.atan2(s0 * c1 - s1 * c2, s0 * r1 - s1 * r2) * 2;
			}
		}
		else
		{
			if ((1 - c) > Mathematics.EPS)
			{
				var o = m.acos(c);
				var s = m.sin(o);
				var s0 = m.sin((1 - t) * o) / s;
				var s1 = m.sin(t * o) / s;
				return m.atan2(s0 * c1 + s1 * c2, s0 * r1 + s1 * r2) * 2.;
			}
			else
			{
				var s0 = 1 - t;
				var s1 = t;
				return m.atan2(s0 * c1 + s1 * c2, s0 * r1 + s1 * r2) * 2;
			}
		}
	}
	
	/** Calculates the next highest power of 2.*/
	inline public static function nextPow2(x:Int):Int
	{
		var t = x;
		t |= (t >> 0x01);
		t |= (t >> 0x02);
		t |= (t >> 0x03);
		t |= (t >> 0x04);
		t |= (t >> 0x05);
		return t + 1;
	}
	
	/** Fast integer exponentiation for base <i>a</i> and exponent <i>n</i>. */
	inline public static function exp(a:Int, n:Int):Int
	{
		var t = 1;
		var r = 0;
		while (true)
		{
			if (n & 1 != 0) t = a * t;
			n >>= 1;
			if (n == 0)
			{
				r = t;
				break;
			}
			else
				a *= a;
		}
		return r;
	}
	
	/** Rounds the number <i>x</i> to the iterval <i>y</i>. */
	inline public static function roundTo(x:Float, y:Float):Float
	{
		return round(x / y) * y;
	}
	
	/** Fast replacement for Math.round(<i>x</i>). */
	inline public static function round(x:Float):Int
	{
		return Std.int(x > 0 ? x + .5 : x < 0 ? x - .5 : 0);
	}
	
	/** Fast replacement for Math.ceil(<i>x</i>). */
	inline public static function ceil(x:Float):Int
	{
		if (x > .0)
		{
			var t = Std.int(x + .5);
			return (t < x) ? t + 1 : t;
		}
		else
		if (x < .0)
		{
			var t = Std.int(x - .5);
			return (t < x) ? t + 1 : t;
		}
		else
			return 0;
	}
	
	/** Fast replacement for Math.floor(<i>x</i>). */
	inline public static function floor(x:Float):Int
	{
		if (x > .0)
		{
			var t = Std.int(x + .5);
			return (t < x) ? t : t - 1;
		}
		else
		if (x < .0)
		{
			var t = Std.int(x - .5);
			return (t > x) ? t - 1 : t;
		}
		else
			return 0;
	}
	
	/**
	 * Computes a fast inverse square root of <i>x</i>.
	 * @throws de.polygonal.core.util.AssertionError <i>x</i> > 0 (<i>if debug flag is set</i>).
	 */
	inline public static function invSqrt(x:Float):Float
	{
		#if (flash10 && !no_alchemy)
		var xt = x;
		var half = .5 * xt;
		var i = floatToInt(xt);
		i = 0x5f3759df - (i >> 1);
		var xt = intToFloat(i);
		return xt * (1.5 - half * xt * xt);
		#else
		return 1 / Math.sqrt(x);
		#end
	}
	
	/** Compares <i>x</i> and <i>y</i> using an absolute tolerance of <i>eps</i>. */
	inline public static function cmpAbs(x:Float, y:Float, eps:Float):Bool
	{
		var d = x - y;
		return d > 0 ? d < eps : -d < eps;
	}
	
	/** Compares <i>x</i> to zero using an absolute tolerance of <i>eps</i>. */
	inline public static function cmpZero(x:Float, eps:Float):Bool
	{
		return x > 0 ? x < eps : -x < eps;
	}
	
	/** Snaps <i>x</i> to the grid <i>y</i>. */
	inline public static function snap(x:Float, y:Float):Float
	{
		return floor((x + y * .5) / y);
	}
	
	/** Returns true if <i>min</i> <= <i>x</i> <= <i>max</i>. */
	inline public static function inRange(x:Float, min:Float, max:Float):Bool
	{
		return x >= min && x <= max;
	}
	
	/** Returns a pseudo-random integral value x, where 0 <= x < 0x7fffffff. */
	inline public static function rand():Int
	{
		return Std.int(Math.random() * Mathematics.INT32_MAX);
	}
	
	/** Returns a pseudo-random integral value x, where <i>min</i> <= x < <i>max</i>. */
	inline public static function randRange(min:Int, max:Int):Int
	{
		return Mathematics.round((min - .4999) + ((max + .4999) - (min - .4999)) * frand());
	}
	
	/** Returns a pseudo-random double value x, where -<i>range</i> <= x < <i>range</i>. */
	inline public static function randRangeSym(range:Int):Float
	{
		return randRange(-range, range);
	}
	
	/** Returns a pseudo-random double value x, where 0 <= x < 1. */
	inline public static function frand():Float
	{
		return Math.random();
	}
	
	/** Returns a pseudo-random double value x, where <i>min</i> <= x < <i>max</i>. */
	inline public static function frandRange(min:Float, max:Float):Float
	{
		return min + (max - min) * Math.random();
	}
	
	/** Returns a pseudo-random double value x, where -<i>range</i> <= x < <i>range</i>. */
	inline public static function frandRangeSym(range:Float):Float
	{
		return frandRange(-range, range);
	}
	
	/**
	 * Wraps an angle <i>x</i> to the range -PI...PI by adding the correct multiple of 2 PI.
	 * @throws de.polygonal.core.util.AssertionError Input angle outside range (-2PI...PI) (<i>if debug flag is set</i>).
	 */
	inline public static function wrapToPi(x:Float):Float
	{
		var t = round(x / PI2);
		return (x < -PI) ? (x - t * PI2) : (x > PI ? x - t * PI2 : x);
	}
}