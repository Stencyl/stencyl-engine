package com.stencyl.graphics;

import openfl.display.Bitmap;
import openfl.display.Sprite;

import com.stencyl.Engine;

class BitmapWrapper extends Sprite implements EngineScaleUpdateListener
{
	public var img:Bitmap;

	private var offsetX:Float;
	private var offsetY:Float;

	private var autoscale:Bool = false;

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

		autoscale = Config.autoscaleImages;
	}

	public function set_imgX(x:Float):Float
	{
		this.x = (x + offsetX) * Engine.SCALE;

		return imgX = x;
	}
	
	public function get_imgX():Float
	{
		return imgX;
	}

	public function set_imgY(y:Float):Float
	{
		this.y = (y + offsetY) * Engine.SCALE;

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
		this.x += (x - offsetX) * Engine.SCALE;
		this.y += (y - offsetY) * Engine.SCALE;
		offsetX = x;
		offsetY = y;

		img.x = -x;
		img.y = -y;
	}

	public function setAutoscale(value:Bool):Void
	{
		if(autoscale != value)
		{
			autoscale = value;
			updateScale();
		}
	}

	public function updatePosition():Void
	{
		x = (imgX + offsetX) * Engine.SCALE;
		y = (imgY + offsetY) * Engine.SCALE;
	}

	public function updateScale():Void
	{
		if(autoscale)
		{
			var mtx = transform.matrix;
			mtx.identity();
			mtx.scale(Engine.SCALE, Engine.SCALE);
			transform.matrix = mtx;
		}

		updatePosition();
	}
}