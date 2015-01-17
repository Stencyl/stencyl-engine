package com.stencyl.models.collision;

import openfl.display.Graphics;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

import com.stencyl.utils.Utils;

/**
 * A bitmap mask used for pixel-perfect collision. 
 */
class Pixelmask extends Hitbox
{
	/**
	 * Alpha threshold of the bitmap used for collision.
	 */
	public var threshold:Int;
	
	/**
	 * Constructor.
	 * @param	source		The image to use as a mask.
	 * @param	x			X offset of the mask.
	 * @param	y			Y offset of the mask.
	 */
	public function new(source:Dynamic, x:Int = 0, y:Int = 0)
	{
		super();
		
		// fetch mask data
		if (Std.is(source, BitmapData)) _data = source;
		//else _data = Utils.getBitmap(source);
		if (_data == null) throw "Invalid Pixelmask source image.";
		
		threshold = 1;
		
		_rect = Utils.rect;
		_point = Utils.point;
		_point2 = Utils.point2;
		
		// set mask properties
		_width = data.width;
		_height = data.height;
		_x = x;
		_y = y;
		
		// set callback functions
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Pixelmask), collidePixelmask);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}
	
	/** @private Collide against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		_point.x = parent.colX + _x;
		_point.y = parent.colY + _y;
		_rect.x = other.parent.colX;
		_rect.y = other.parent.colY;
		_rect.width = other.parent.cacheWidth;
		_rect.height = other.parent.cacheHeight;
		#if flash
		return _data.hitTest(_point, threshold, _rect);
		#else
		return false;
		#end
	}
	
	/** @private Collide against a Hitbox. */
	override private function collideHitbox(other:Hitbox):Bool
	{
		_point.x = parent.colX + _x;
		_point.y = parent.colY + _y;
		_rect.x = other.parent.colX + other._x;
		_rect.y = other.parent.colY + other._y;
		_rect.width = other._width;
		_rect.height = other._height;
		#if flash
		return _data.hitTest(_point, threshold, _rect);
		#else
		return false;
		#end
	}
	
	/** @private Collide against a Pixelmask. */
	private function collidePixelmask(other:Pixelmask):Bool
	{
		_point.x = parent.colX + _x;
		_point.y = parent.colY + _y;
		_point2.x = other.parent.colX + other._x;
		_point2.y = other.parent.colY + other._y;
		#if flash
		return _data.hitTest(_point, threshold, other._data, _point2, other.threshold);
		#else
		return false;
		#end
	}
	
	/**
	 * Current BitmapData mask.
	 */
	public var data(get_data, set_data):BitmapData;
	private function get_data():BitmapData { return _data; }
	private function set_data(value:BitmapData):BitmapData
	{
		_data = value;
		_width = value.width;
		_height = value.height;
		update();
		return _data;
	}
	
	// Pixelmask information.
	private var _data:BitmapData;
	
	// Global objects.
	private var _rect:Rectangle;
	private var _point:Point;
	private var _point2:Point;
}