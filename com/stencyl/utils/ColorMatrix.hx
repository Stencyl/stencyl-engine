package com.stencyl.utils;

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
/**
 * ColorMatrix Class v2.1
 * 
 * released under MIT License (X11)
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * Author: Mario Klingemann
 * http://www.quasimondo.com
 * 
 * Copyright (c) 2008 Mario Klingemann

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import openfl.filters.ColorMatrixFilter;


using com.stencyl.utils.RGB;

/** Deficiency types used in <i>ColorMatrix.applyColorDeficiency()</i>*/
enum ColorDeficiencyTypes
{
	Protanopia;
	Protanomaly;
	Deuteranopia;
	Deuteranomaly;
	Tritanopia;
	Tritanomaly;
	Achromatopsia;
	Achromatomaly;
}

/**
 * A highly optimized HaXe port of the AS3 ColorMatrix Class by Mario Klingemann.<br/>
 * see <a href="http://www.quasimondo.com/archives/000565.php" target="_blank">http://www.quasimondo.com/archives/000565.php</a>
 */
class ColorMatrix
{
	inline public static function mulMatrixMatrix(A:ColorMatrix, B:ColorMatrix, C:ColorMatrix):ColorMatrix
	{
		var t11 = A.m11;
		var t12 = A.m12;
		var t13 = A.m13;
		var t14 = A.m14;
		
		C.m11 = A.m11*B.m11 + A.m12*B.m21 + A.m13*B.m31 + A.m14*B.m41;
		C.m12 = t11*B.m12   + A.m12*B.m22 + A.m13*B.m32 + A.m14*B.m42;
		C.m13 = t11*B.m13   +   t12*B.m23 + A.m13*B.m33 + A.m14*B.m43;
		C.m14 = t11*B.m14   +   t12*B.m24 +   t13*B.m34 + A.m14*B.m44;
		C.m15 = t11*B.m15   +   t12*B.m25 +   t13*B.m35 +   t14*B.m45;
		
		var t21 = A.m21;
		var t22 = A.m22;
		var t23 = A.m23;
		var t24 = A.m24;
		
		C.m21 = A.m21*B.m11 + A.m22*B.m21 + A.m23*B.m31 + A.m24*B.m41;
		C.m22 =   t21*B.m12 + A.m22*B.m22 + A.m23*B.m32 + A.m24*B.m42;
		C.m23 =   t21*B.m13 +   t22*B.m23 + A.m23*B.m33 + A.m24*B.m43;
		C.m24 =   t21*B.m14 +   t22*B.m24 +   t23*B.m34 + A.m24*B.m44;
		C.m25 =   t21*B.m15 +   t22*B.m25 +   t23*B.m35 +   t24*B.m45;
		
		var t31 = A.m31;
		var t32 = A.m32;
		var t33 = A.m33;
		var t34 = A.m34;
		
		C.m31 = A.m31*B.m11 + A.m32*B.m21 + A.m33*B.m31 + A.m34*B.m41;
		C.m32 =   t31*B.m12 + A.m32*B.m22 + A.m33*B.m32 + A.m34*B.m42;
		C.m33 =   t31*B.m13 +   t32*B.m23 + A.m33*B.m33 + A.m34*B.m43;
		C.m34 =   t31*B.m14 +   t32*B.m24 +   t33*B.m34 + A.m34*B.m44;
		C.m35 =   t31*B.m15 +   t32*B.m25 +   t33*B.m35 +   t34*B.m45;
		
		var t41 = A.m41;
		var t42 = A.m42;
		var t43 = A.m43;
		var t44 = A.m44;
		
		C.m41 = A.m41*B.m11 + A.m42*B.m21 + A.m43*B.m31 + A.m44*B.m41;
		C.m42 =   t41*B.m12 + A.m42*B.m22 + A.m43*B.m32 + A.m44*B.m42;
		C.m43 =   t41*B.m13 +   t42*B.m23 + A.m43*B.m33 + A.m44*B.m43;
		C.m44 =   t41*B.m14 +   t42*B.m24 +   t43*B.m34 + A.m44*B.m44;
		C.m45 =   t41*B.m15 +   t42*B.m25 +   t43*B.m35 +   t44*B.m45;
		
		return C;
	}
	
	inline public static function blendMatrixMatrix(A:ColorMatrix, B:ColorMatrix, C:ColorMatrix, amount:Float):ColorMatrix
	{
		var inv_amount = (1 - amount);
		
		C.m11 = inv_amount * A.m11 + amount * B.m11;
		C.m12 = inv_amount * A.m12 + amount * B.m12;
		C.m13 = inv_amount * A.m13 + amount * B.m13;
		C.m14 = inv_amount * A.m14 + amount * B.m14;
		C.m15 = inv_amount * A.m15 + amount * B.m15;
		
		C.m21 = inv_amount * A.m21 + amount * B.m21;
		C.m22 = inv_amount * A.m22 + amount * B.m22;
		C.m23 = inv_amount * A.m23 + amount * B.m23;
		C.m24 = inv_amount * A.m24 + amount * B.m24;
		C.m25 = inv_amount * A.m25 + amount * B.m25;
		
		C.m31 = inv_amount * A.m31 + amount * B.m31;
		C.m32 = inv_amount * A.m32 + amount * B.m32;
		C.m33 = inv_amount * A.m33 + amount * B.m33;
		C.m34 = inv_amount * A.m34 + amount * B.m34;
		C.m35 = inv_amount * A.m35 + amount * B.m35;
		
		C.m41 = inv_amount * A.m41 + amount * B.m41;
		C.m42 = inv_amount * A.m42 + amount * B.m42;
		C.m43 = inv_amount * A.m43 + amount * B.m43;
		C.m44 = inv_amount * A.m44 + amount * B.m44;
		C.m45 = inv_amount * A.m45 + amount * B.m45;
		
		return C;
	}
	
	public static var LUMA_R = 0.212671;
	public static var LUMA_G = 0.71516;
	public static var LUMA_B = 0.072169;
	
	public static var LUMA_R2 = 0.3086;
	public static var LUMA_G2 = 0.6094;
	public static var LUMA_B2 = 0.0820;
	
	public static var INV3 = 1.0 / 3.0;
	
	public var m11:Float; var m12:Float; var m13:Float; var m14:Float; var m15:Float;
	public var m21:Float; var m22:Float; var m23:Float; var m24:Float; var m25:Float;
	public var m31:Float; var m32:Float; var m33:Float; var m34:Float; var m35:Float;
	public var m41:Float; var m42:Float; var m43:Float; var m44:Float; var m45:Float;
	
	public var matrix:Array<Float>;
	
	public var preHue:ColorMatrix;
	public var postHue:ColorMatrix;
	public var hueInitialized:Bool;
	
	public function new()
	{
		identity();
		matrix = new Array<Float>();
	}
	
	#if (flash || js)
	public function getFilter():ColorMatrixFilter
	{
		toArray(matrix);
		return new ColorMatrixFilter(matrix);
	}
	#end
	
	public function identity():ColorMatrix
	{
		set
		(
			1.0, 0.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function invert():ColorMatrix
	{
		mul
		(
			-1.0,  0.0,  0.0, 0.0, 255,
			 0.0, -1.0,  0.0, 0.0, 255,
			 0.0,  0.0, -1.0, 0.0, 255,
			 0.0,  0.0,  0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function adjustSaturation(s:Float):ColorMatrix
	{
		var sInv  = 1.0 - s;
		var irlum = sInv * LUMA_R;
		var iglum = sInv * LUMA_G;
		var iblum = sInv * LUMA_B;
		
		mul
		(
			irlum + s, iglum    , iblum    , 0.0, 0.0,
			irlum    , iglum + s, iblum    , 0.0, 0.0,
			irlum    , iglum    , iblum + s, 0.0, 0.0,
			0.0      , 0.0      , 0.0      , 1.0, 0.0
		);
		return this;
	}
	
	public function adjustBrightness(x:Float):ColorMatrix
	{
		adjustBrightnessRGB(x, x, x);
		return this;
	}
	
	public function adjustBrightnessRGB(r:Float, g:Float, b:Float):ColorMatrix
	{
		mul
		(
			1.0, 0.0, 0.0, 0.0, r * 255, 
			0.0, 1.0, 0.0, 0.0, g * 255, 
			0.0, 0.0, 1.0, 0.0, b * 255, 
			0.0, 0.0, 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function adjustContrast(x:Float):ColorMatrix
	{
		adjustContrastRGB(x, x, x);
		return this;
	}
	
	public function adjustContrastRGB(r:Float, g:Float, b:Float):ColorMatrix
	{
		r += 1.0;
		g += 1.0;
		b += 1.0;
		
		mul
		(
			r  , 0.0, 0.0, 0.0, (128.0 * (1.0 - r)), 
			0.0, g  , 0.0, 0.0, (128.0 * (1.0 - g)), 
			0.0, 0.0, b  , 0.0, (128.0 * (1.0 - b)), 
			0.0, 0.0, 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function adjustHue(angle:Float):ColorMatrix
	{
		angle *= Utils.RAD;
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		
		mul
		(
			((LUMA_R + (c * (1.0 - LUMA_R))) + (s * -(LUMA_R)))   , ((LUMA_G + (c * -(LUMA_G))) + (s * -(LUMA_G))), ((LUMA_B + (c * -(LUMA_B))) + (s * (1.0 - LUMA_B))), 0.0, 0.0, 
			((LUMA_R + (c * -(LUMA_R))) + (s * 0.143))            , ((LUMA_G + (c * (1 - LUMA_G))) + (s * 0.14))  , ((LUMA_B + (c * -(LUMA_B))) + (s * -0.283))        , 0.0, 0.0, 
			((LUMA_R + (c * -(LUMA_R))) + (s * -((1.0 - LUMA_R)))), ((LUMA_G + (c * -(LUMA_G))) + (s * LUMA_G))   , ((LUMA_B + (c * (1 - LUMA_B))) + (s * LUMA_B))     , 0.0, 0.0, 
			0.0                                                   , 0.0                                           , 0.0                                                , 1.0, 0.0
		);
		return this;
	}
	
	public function luminance2Alpha():ColorMatrix
	{
		mul
		(
			0.0   , 0.0   , 0.0   , 0.0, 255.0, 
			0.0   , 0.0   , 0.0   , 0.0, 255.0, 
			0.0   , 0.0   , 0.0   , 0.0, 255.0, 
			LUMA_R, LUMA_G, LUMA_B, 0.0, 0.0
		);
		return this;
	}
    
	public function adjustAlphaContrast(amount:Float):ColorMatrix
	{
		amount += 1.0;
		
		mul
		(
			1.0, 0.0, 0.0, 0.0   , 0.0, 
			0.0, 1.0, 0.0, 0.0   , 0.0, 
			0.0, 0.0, 1.0, 0.0   , 0.0, 
			0.0, 0.0, 0.0, amount, (128.0 * (1.0 - amount))
		);
		return this;
	}
	
	public function colorize(rgb:Int, ?amount = 1.):ColorMatrix
	{
		var r = rgb.getRf();
		var g = rgb.getGf();
		var b = rgb.getBf();
		
		var inv_amount = (1 - amount);
		
		mul
		(
			(inv_amount + ((amount * r) * LUMA_R)), ((amount * r) * LUMA_G)               , ((amount * r) * LUMA_B)               , 0.0, 0.0, 
			((amount * g) * LUMA_R)               , (inv_amount + ((amount * g) * LUMA_G)), ((amount * g) * LUMA_B)               , 0.0, 0.0, 
			((amount * b) * LUMA_R)               , ((amount * b) * LUMA_G)               , (inv_amount + ((amount * b) * LUMA_B)), 0.0, 0.0, 
			0.0                                   , 0.0                                   , 0.0                                   , 1-0, 0.0
		);
		return this;
	}
	
	public function rotateHue(angle:Float):ColorMatrix
	{
		initHue();
		
		ColorMatrix.mulMatrixMatrix(this, preHue, this);
		rotateBlue(angle);
		ColorMatrix.mulMatrixMatrix(this, postHue, this);
		return this;
	}
	
	public function setChannels(?r = 1, ?g = 2, ?b = 4, ?a = 8):ColorMatrix
	{
		var t1, t2, t3, t4;
		
		t1 = (r & 1) == 1 ? 1 : 0;
		t2 = (r & 2) == 2 ? 1 : 0;
		t3 = (r & 4) == 4 ? 1 : 0;
		t4 = (r & 8) == 8 ? 1 : 0;
		
		var rf:Float = t1 + t2 + t3  + t4;
		if (rf > 0) rf = (1 / rf);
		
		t1 = (g & 1) == 1 ? 1 : 0;
		t2 = (g & 2) == 2 ? 1 : 0;
		t3 = (g & 4) == 4 ? 1 : 0;
		t4 = (g & 8) == 8 ? 1 : 0;
		
		var gf:Float = t1 + t2 + t3 + t4;
		if (gf > 0) gf = (1 / gf);
		
		t1 = (b & 1) == 1 ? 1 : 0;
		t2 = (b & 2) == 2 ? 1 : 0;
		t3 = (b & 4) == 4 ? 1 : 0;
		t4 = (b & 8) == 8 ? 1 : 0;
		
		var bf:Float = t1 + t2 + t3 + t4;
		if (bf > 0) bf = (1 / bf);
		
		t1 = (a & 1) == 1 ? 1 : 0;
		t2 = (a & 2) == 2 ? 1 : 0;
		t3 = (a & 4) == 4 ? 1 : 0;
		t4 = (a & 8) == 8 ? 1 : 0;
		
		var af:Float = t1 + t2 + t3 + t4;
		if (af > 0) af = (1 / af);
		
		mul
		(
			(((r & 1) == 1)) ? rf : 0, (((r & 2) == 2)) ? rf : 0, (((r & 4) == 4)) ? rf : 0, (((r & 8) == 8)) ? rf : 0, 0,
			(((g & 1) == 1)) ? gf : 0, (((g & 2) == 2)) ? gf : 0, (((g & 4) == 4)) ? gf : 0, (((g & 8) == 8)) ? gf : 0, 0,
			(((b & 1) == 1)) ? bf : 0, (((b & 2) == 2)) ? bf : 0, (((b & 4) == 4)) ? bf : 0, (((b & 8) == 8)) ? bf : 0, 0,
			(((a & 1) == 1)) ? af : 0, (((a & 2) == 2)) ? af : 0, (((a & 4) == 4)) ? af : 0, (((a & 8) == 8)) ? af : 0, 0
		);
		return this;
	}
	
	public function average(?r = 0.33333333, ?g = 0.33333333, ?b = 0.33333333):ColorMatrix
	{
		mul
		(
			r  , g  , b  , 0.0, 0.0, 
			r  , g  , b  , 0.0, 0.0, 
			r  , g  , b  , 0.0, 0.0, 
			0.0, 0.0, 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function threshold(threshold:Float, ?factor = 256.):ColorMatrix
	{
		mul
		(
			LUMA_R * factor, LUMA_G * factor, LUMA_B * factor, 0.0, -(factor) * threshold, 
			LUMA_R * factor, LUMA_G * factor, LUMA_B * factor, 0.0, -(factor) * threshold, 
			LUMA_R * factor, LUMA_G * factor, LUMA_B * factor, 0.0, -(factor) * threshold, 
			0.0            , 0.0            , 0.0            , 1.0, 0.0
		);
		return this;
	}
	
	public function desaturate():ColorMatrix
	{
		mul
		(
			LUMA_R, LUMA_G, LUMA_B, 0.0, 0.0, 
			LUMA_R, LUMA_G, LUMA_B, 0.0, 0.0, 
			LUMA_R, LUMA_G, LUMA_B, 0.0, 0.0, 
			0.0   , 0.0   , 0.0   , 1.0, 0.0
		);
		return this;
	}
	
	public function setMultiplicators(?red = 1., ?green = 1., ?blue = 1., ?alpha = 1.):ColorMatrix
	{
		mul
		(
			red, 0.0  , 0.0 , 0.0  , 0.0,
			0.0, green, 0.0 , 0.0  , 0.0,
			0.0, 0.0  , blue, 0.0  , 0.0,
			0.0, 0.0  , 0.0 , alpha, 0.0
		);
		return this;
	}
	
	public function clearChannels(?red = false, ?green = false, ?blue = false, ?alpha = false):ColorMatrix
	{
		if (red)
		{
			m11 = m12 = m13 = m14 = m15 = 0.0;
		}
		if (green)
		{
			m21 = m22 = m23 = m24 = m25 = 0.0;
		}
		if (blue)
		{
			m31 = m32 = m33 = m34 = m35 = 0.0;
		}
		if (alpha)
		{
			m41 = m42 = m43 = m44 = m45 = 0.0;
		}
		return this;
	}
	
	public function thresholdAlpha(threshold:Float, ?factor = 256.):ColorMatrix
	{
		mul
		(
			1.0, 0.0, 0.0, 0.0   , 0.0, 
			0.0, 1.0, 0.0, 0.0   , 0.0, 
			0.0, 0.0, 1.0, 0.0   , 0.0, 
			0.0, 0.0, 0.0, factor, (-factor * threshold)
		);
		return this;
	}
	
	public function averageRGB2Alpha():ColorMatrix
	{
		mul
		(
			0.0 , 0.0 , 0.0 , 0.0, 255.0, 
			0.0 , 0.0 , 0.0 , 0.0, 255.0, 
			0.0 , 0.0 , 0.0 , 0.0, 255.0,
			INV3, INV3, INV3, 0.0, 0.0
		);
		return this;
	}

	public function invertAlpha():ColorMatrix
	{
		mul
		(
			1.0, 0.0, 0.0, 0.0, 0.0, 
			0.0, 1.0, 0.0, 0.0, 0.0, 
			0.0, 0.0, 1.0, 0.0, 0.0, 
			0.0, 0.0, 0.0,-1.0, 255.0
		);
			return this;
	}
	
	public function rgb2Alpha(r:Float, g:Float, b:Float):ColorMatrix
	{
		mul(
			0.0, 0.0, 0.0, 0.0, 255.0,
			0.0, 0.0, 0.0, 0.0, 255.0,
			0.0, 0.0, 0.0, 0.0, 255.0,
			r  , g  , b  , 0.0, 0.0
		);
		return this;
	}
    
	public function setAlpha(alpha:Float):ColorMatrix
	{
		mul
		(
			1.0, 0.0, 0.0, 0.0  , 0.0,
			0.0, 1.0, 0.0, 0.0  , 0.0,
			0.0, 0.0, 1.0, 0.0  , 0.0, 
			0.0, 0.0, 0.0, alpha, 0.0
		);
		return this;
	}
	
	public function rotateRed(angle:Float):ColorMatrix
	{
		angle *= Utils.RAD;
		var c = Math.cos(angle);
		var s = Math.cos(angle);
		
		set
		(
			1.0, 0.0, 0.0, 0.0, 0.0,
			0.0, c  ,-s  , 0.0, 0.0,
			0.0, s  , c  , 0.0, 0.0,
			0.0, 0.0, 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function rotateGreen(angle:Float):ColorMatrix
	{
		angle *= Utils.RAD;
		var c = Math.cos(angle);
		var s = Math.cos(angle);
		
		set
		(
			c  , 0.0, s  , 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0, 0.0,
			-s , 0.0, c  , 0.0, 0.0,
			0.0, 0.0, 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function rotateBlue(angle:Float):ColorMatrix
	{
		angle *= Utils.RAD;
		var c = Math.cos(angle);
		var s = Math.cos(angle);
		
		set
		(
			c  ,-s  , 0.0, 0.0, 0.0,
			s  , c  , 0.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function shearRed(green:Float, blue:Float):ColorMatrix
	{
		set
		(
			1.0, green, blue, 0.0, 0.0,
			0.0, 1.0  , 0.0 , 0.0, 0.0,
			0.0, 0.0  , 1.0 , 0.0, 0.0,
			0.0, 0.0  , 0.0 , 1.0, 0.0
		);
		return this;
	}
	
	public function shearGreen(red:Float, blue:Float):ColorMatrix
	{
		set
		(
			1.0, 0.0, 0.0 , 0.0, 0.0,
			red, 1.0, blue, 0.0, 0.0,
			0.0, 0.0, 1.0 , 0.0, 0.0,
			0.0, 0.0, 0.0 , 1.0, 0.0
		);
		return this;
	}
	
	public function shearBlue(red:Float, green:Float):ColorMatrix
	{
		set
		(
			1.0, 0.0  , 0.0, 0.0, 0.0,
			0.0, 1.0  , 0.0, 0.0, 0.0,
			red, green, 1.0, 0.0, 0.0,
			0.0, 0.0  , 0.0, 1.0, 0.0
		);
		return this;
	}
	
	public function applyColorDeficiency(type:ColorDeficiencyTypes):ColorMatrix
	{
		//the values of this method are copied from http://www.nofunc.com/Color_Matrix_Library/ 
		switch (type)
		{
			case Protanopia:    mul(0.567,0.433,0,0,0, 0.558,0.442,0,0,0, 0,0.242,0.758,0,0, 0,0,0,1,0);
			case Protanomaly:   mul(0.817,0.183,0,0,0, 0.333,0.667,0,0,0, 0,0.125,0.875,0,0, 0,0,0,1,0);
			case Deuteranopia:  mul(0.625,0.375,0,0,0, 0.7,0.3,0,0,0, 0,0.3,0.7,0,0, 0,0,0,1,0);
			case Deuteranomaly: mul(0.8,0.2,0,0,0, 0.258,0.742,0,0,0, 0,0.142,0.858,0,0, 0,0,0,1,0);
			case Tritanopia:    mul(0.95,0.05,0,0,0, 0,0.433,0.567,0,0, 0,0.475,0.525,0,0, 0,0,0,1,0);
			case Tritanomaly:   mul(0.967,0.033,0,0,0, 0,0.733,0.267,0,0, 0,0.183,0.817,0,0, 0,0,0,1,0);
			case Achromatopsia: mul(0.299,0.587,0.114,0,0, 0.299,0.587,0.114,0,0, 0.299,0.587,0.114,0,0, 0,0,0,1,0);
			case Achromatomaly: mul(0.618,0.320,0.062,0,0, 0.163,0.775,0.062,0,0, 0.163,0.320,0.516,0,0, 0,0,0,1,0);
		}
		return this;
	}

	public function applyMatrix(argb:ARGB, out:ARGB):ARGB
	{
		var a = argb.a;
		var r = argb.r;
		var g = argb.g;
		var b = argb.b;
		
		var a2 = Utils.clamp(Std.int(0.5 + r * m41 + g * m42 + b * m43 + a * m44 + m45), 0, 255);
		var r2 = Utils.clamp(Std.int(0.5 + r * m11 + g * m12 + b * m13 + a * m14 + m15), 0, 255);
		var g2 = Utils.clamp(Std.int(0.5 + r * m21 + g * m22 + b * m23 + a * m24 + m25), 0, 255);
		var b2 = Utils.clamp(Std.int(0.5 + r * m31 + g * m32 + b * m33 + a * m34 + m35), 0, 255);
		
		out.set(a2, r2, g2, b2);
		return out;
	}
	
	#if flash10
	public function transformVector(values:flash.Vector<Float>):flash.Vector<Float>
	#else
	public function transformVector(values:Array<Float>):Array<Float>
	#end
	{
		var v0 = values[0];
		var v1 = values[1];
		var v2 = values[2];
		var v3 = values[3];
		
		var r = v0 * m11 + v1 * m12 + v2 * m13 + v3 * m14 + m15;
		var g = v0 * m21 + v1 * m22 + v2 * m23 + v3 * m24 + m25;
		var b = v0 * m31 + v1 * m32 + v2 * m33 + v3 * m34 + m35;
		var a = v0 * m41 + v1 * m42 + v2 * m43 + v3 * m44 + m45;
		
		values[0] = r;
		values[1] = g;
		values[2] = b;
		values[3] = a;
		
		return values;
	}
	
	inline function initHue():Void
	{
		var greenRotation = 39.182655;
		
		if (!hueInitialized)
		{
			hueInitialized = true;
			preHue = new ColorMatrix();
			preHue.rotateRed(45.0);
			preHue.rotateGreen(-greenRotation);
			
			#if flash10
			var lum = new flash.Vector<Float>(4, true);
			#else
			var lum = new Array<Float>();
			#end
			lum[0] = LUMA_R2;
			lum[1] = LUMA_G2;
			lum[2] = LUMA_B2;
			lum[3] = 1.0;
			
			preHue.transformVector(lum);
			
			var red = lum[0] / lum[2];
			var green = lum[1] / lum[2];
			
			preHue.shearBlue(red, green);
			
			postHue = new ColorMatrix();
			postHue.shearBlue(-red, -green);
			postHue.rotateGreen(greenRotation);
			postHue.rotateRed(-45.0);
		}
	}
	
	public inline function toArray(out:Array<Float>):Array<Float>
	{
		out[ 0] = m11; out[ 1] = m12; out[ 2] = m13; out[ 3] = m14; out[ 4] = m15;
		out[ 5] = m21; out[ 6] = m22; out[ 7] = m23; out[ 8] = m24; out[ 9] = m25;
		out[10] = m31; out[11] = m32; out[12] = m33; out[13] = m34; out[14] = m35;
		out[15] = m41; out[16] = m42; out[17] = m43; out[18] = m44; out[19] = m45;
		return out;
	}
	
	inline function set
	(
		i11:Float, i12:Float, i13:Float, i14:Float, i15:Float,
		i21:Float, i22:Float, i23:Float, i24:Float, i25:Float,
		i31:Float, i32:Float, i33:Float, i34:Float, i35:Float,
		i41:Float, i42:Float, i43:Float, i44:Float, i45:Float
	)
	{
		m11 = i11; m12 = i12; m13 = i13; m14 = i14; m15 = i15;
		m21 = i21; m22 = i22; m23 = i23; m24 = i24; m25 = i25;
		m31 = i31; m32 = i32; m33 = i33; m34 = i34; m35 = i35;
		m41 = i41; m42 = i42; m43 = i43; m44 = i44; m45 = i45;
	}
	
	inline function mul
	(
		i11:Float, i12:Float, i13:Float, i14:Float, i15:Float,
		i21:Float, i22:Float, i23:Float, i24:Float, i25:Float,
		i31:Float, i32:Float, i33:Float, i34:Float, i35:Float,
		i41:Float, i42:Float, i43:Float, i44:Float, i45:Float
	)
	{
		var t11 = m11;
		var t12 = m12;
		var t13 = m13;
		var t14 = m14;
		
		m11 = m11*i11 + m12*i21 + m13*i31 + m14*i41;
		m12 = t11*i12 + m12*i22 + m13*i32 + m14*i42;
		m13 = t11*i13 + t12*i23 + m13*i33 + m14*i43;
		m14 = t11*i14 + t12*i24 + t13*i34 + m14*i44;
		m15 = t11*i15 + t12*i25 + t13*i35 + t14*i45;
		
		var t21 = m21;
		var t22 = m22;
		var t23 = m23;
		var t24 = m24;
		
		m21 = m21*i11 + m22*i21 + m23*i31 + m24*i41;
		m22 = t21*i12 + m22*i22 + m23*i32 + m24*i42;
		m23 = t21*i13 + t22*i23 + m23*i33 + m24*i43;
		m24 = t21*i14 + t22*i24 + t23*i34 + m24*i44;
		m25 = t21*i15 + t22*i25 + t23*i35 + t24*i45;
		
		var t31 = m31;
		var t32 = m32;
		var t33 = m33;
		var t34 = m34;
		
		m31 = m31*i11 + m32*i21 + m33*i31 + m34*i41;
		m32 = t31*i12 + m32*i22 + m33*i32 + m34*i42;
		m33 = t31*i13 + t32*i23 + m33*i33 + m34*i43;
		m34 = t31*i14 + t32*i24 + t33*i34 + m34*i44;
		m35 = t31*i15 + t32*i25 + t33*i35 + t34*i45;
		
		var t41 = m41;
		var t42 = m42;
		var t43 = m43;
		var t44 = m44;
		
		m41 = m41*i11 + m42*i21 + m43*i31 + m44*i41;
		m42 = t41*i12 + m42*i22 + m43*i32 + m44*i42;
		m43 = t41*i13 + t42*i23 + m43*i33 + m44*i43;
		m44 = t41*i14 + t42*i24 + t43*i34 + m44*i44;
		m45 = t41*i15 + t42*i25 + t43*i35 + t44*i45;
	}
}
