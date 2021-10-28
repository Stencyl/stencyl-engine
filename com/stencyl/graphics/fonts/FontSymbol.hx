package com.stencyl.graphics.fonts;

import openfl.display.BitmapData;

class FontSymbol 
{
	#if use_tilemap
	
	/**
	 * tile id in tileSheet
	 */
	public var tileID:Int;
	
	#else
	
	/**
	 * symbol image
	 */
	public var bitmap:BitmapData;
	
	#end
	
	/**
	 * x offset to draw symbol with
	 */
	public var xoffset:Int;
	
	/**
	 * y offset to draw symbol with
	 */
	public var yoffset:Int;
	
	/**
	 * how much to advance cursor after drawing symbol
	 */
	public var xadvance:Int;
	
	public function new() 
	{
	}	
}
	