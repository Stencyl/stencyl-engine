package com.stencyl.models.collision;

import com.stencyl.models.Actor;
import com.stencyl.models.Region;
import com.stencyl.models.GameModel;

import openfl.geom.Point;
import openfl.geom.Rectangle;


/** Uses parent's hitbox to determine collision.
 * This class is used * internally by FlashPunk, you don't need to use this class because
 * this is the default behaviour of Entities without a Mask object. */
class Hitbox extends Mask
{
	/**
	 * Constructor.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	x			X offset of the hitbox.
	 * @param	y			Y offset of the hitbox.
	 */
	public function new(width:Int = 1, height:Int = 1, x:Int = 0, y:Int = 0, solid:Bool=true, groupID:Int = 0)
	{
		super();
		lastBounds.width = _width = width;
		lastBounds.height = _height = height;
		_x = x;
		_y = y;
		this.solid = solid;
		this.groupID = groupID;
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}
	
	public function clone():Hitbox
	{
		return new Hitbox(_width, _height, _x, _y, solid, groupID);
	}

	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		if (parent.colX + _x + _width > other.parent.colX
			&& parent.colY + _y + _height > other.parent.colY
			&& parent.colX + _x < other.parent.colX + other.parent.cacheWidth
			&& parent.colY + _y < other.parent.colY + other.parent.cacheHeight)
		{	
			lastBounds.x = parent.colX + parent.cacheWidth;
			lastBounds.y = parent.colY + parent.cacheHeight;
			lastBounds.width = parent.cacheWidth;
			lastBounds.height = parent.cacheHeight;			
			lastCheckedMask = this;
			
			return true;	
		}
		
		return false;
	}

	/** @private Collides against a Hitbox. */
	private function collideHitbox(other:Hitbox):Bool
	{			
		if (parent.colX + _x + _width > other.parent.colX + other._x
			&& parent.colY + _y + _height > other.parent.colY + other._y
			&& parent.colX + _x < other.parent.colX + other._x + other._width
			&& parent.colY + _y < other.parent.colY + other._y + other._height)
		{			
			lastBounds.x = parent.colX + _x;
			lastBounds.y = parent.colY + _y;
			lastBounds.width = _width;
			lastBounds.height = _height;
			lastCheckedMask = this;
		
			return true;
		}
		
		return false;
	}

	/**
	 * X offset.
	 */
	public var x(get_x, set_x):Int;
	private function get_x():Int { return _x; }
	private function set_x(value:Int):Int
	{
		if (_x == value) return value;
		_x = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _x;
	}

	/**
	 * Y offset.
	 */
	public var y(get_y, set_y):Int;
	private function get_y():Int { return _y; }
	private function set_y(value:Int):Int
	{
		if (_y == value) return value;
		_y = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _y;
	}

	/**
	 * Width.
	 */
	public var width(get_width, set_width):Int;
	private function get_width():Int { return _width; }
	private function set_width(value:Int):Int
	{
		if (_width == value) return value;
		_width = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _width;
	}

	/**
	 * Height.
	 */
	public var height(get_height, set_height):Int;
	private function get_height():Int { return _height; }
	private function set_height(value:Int):Int
	{
		if (_height == value) return value;
		_height = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _height;
	}

	/** Updates the parent's bounds for this mask. */
	override public function update()
	{
		if (parent != null)
		{
			if (list != null)
				list.update();
		}
	}

	// Hitbox information.
	public var _width:Int;
	public var _height:Int;
	public var _x:Int;
	public var _y:Int;	
}