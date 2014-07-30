package com.stencyl.graphics;

import nme.display.Bitmap;
import nme.display.Sprite;

class BitmapWrapper extends Sprite
{
	public var img:Bitmap;

	private var offsetX:Float;
	private var offsetY:Float;

	@:isVar public var smoothing (get, set):Bool;
	@:isVar public var imgX (get, set):Float;
	@:isVar public var imgY (get, set):Float;

	public function new(img:Bitmap)
	{
		super();
		this.img = img;
		offsetX = 0;
		offsetY = 0;
		addChild(img);
	}

	public function set_imgX(x:Float):Float
	{
		return this.x = x + offsetX;
	}
	
	public function get_imgX():Float
	{
		return x - offsetX;
	}

	public function set_imgY(y:Float):Float
	{
		return this.y = y + offsetY;
	}
	
	public function get_imgY():Float
	{
		return y - offsetY;
	}

	public function set_smoothing(smoothing:Bool):Bool
	{
		return img.smoothing = smoothing;
	}
	
	public function get_smoothing():Bool
	{
		return img.smoothing;
	}

	public function setOrigin(x:Float, y:Float):Void
	{
		this.x += x - offsetX;
		this.y += y - offsetY;
		offsetX = x;
		offsetY = y;

		img.x = -x;
		img.y = -y;
	}
}