package com.stencyl.graphics;

import openfl.display.Bitmap;
import openfl.display.Sprite;

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
		this.x = x + offsetX;

		return imgX = x;
	}
	
	public function get_imgX():Float
	{
		return imgX;
	}

	public function set_imgY(y:Float):Float
	{
		this.y = y + offsetY;

		return imgY = y;
	}
	
	public function get_imgY():Float
	{
		return imgY;
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