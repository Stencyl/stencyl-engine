package com.stencyl.models.scene.layers;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.PixelSnapping;

class BackgroundLayer extends Bitmap 
{	
	public var cacheWidth:Float;
	public var cacheHeight:Float;

	public function new(?bitmapData:BitmapData) 
	{
		super(bitmapData, PixelSnapping.AUTO, true);
	}
}
