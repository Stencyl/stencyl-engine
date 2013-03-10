package com.stencyl.models.collision;

import com.stencyl.models.Actor;
import com.stencyl.models.Region;

import nme.geom.Point;


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
	public function new(width:Int = 1, height:Int = 1, x:Int = 0, y:Int = 0, solid:Bool=true)
	{
		super();
		_width = width;
		_height = height;
		_x = x;
		_y = y;
		this.solid = solid;
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}
	
	public function clone():Hitbox
	{
		return new Hitbox(_width, _height, _x, _y, solid);
	}

	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		if (parent.colX + _x + _width >= other.parent.colX
			&& parent.colY + _y + _height >= other.parent.colY
			&& parent.colX + _x <= other.parent.colX + other.parent.cacheWidth
			&& parent.colY + _y <= other.parent.colY + other.parent.cacheHeight)
		{
			if (Std.is(parent, Region) || Std.is(other.parent, Region) )
			{
				return true; 
			}
			
			var info:CollisionInfo = new CollisionInfo();
			
			info.solidCollision = solid && other.solid;
			info.maskA = this;
			info.maskB = other;			
			
			if (parent.isLightweight)
			{
				parent.addCollision(info);
			}
			
			if (other.parent.isLightweight)
			{
				other.parent.addCollision(info);
			}
			
			return true;	
		}
		
		return false;
	}

	/** @private Collides against a Hitbox. */
	private function collideHitbox(other:Hitbox):Bool
	{
		if (other.parent.alreadyCollided(this, other))
		{
			return false;
		}
		
		if (parent.colX + _x + _width >= other.parent.colX + other._x
			&& parent.colY + _y + _height >= other.parent.colY + other._y
			&& parent.colX + _x <= other.parent.colX + other._x + other._width
			&& parent.colY + _y <= other.parent.colY + other._y + other._height)
		{
			if (Std.is(parent, Region) || Std.is(other.parent, Region) )
			{
				return true; 
			}
			
			var info:CollisionInfo = new CollisionInfo();
			
			info.solidCollision = solid && other.solid;
			info.maskA = this;
			info.maskB = other;			
			
			if (parent.isLightweight)
			{
				parent.addCollision(info);
			}
			
			if (other.parent.isLightweight)
			{
				other.parent.addCollision(info);
			}
						
			return true;
		}
		
		return false;
	}

	/**
	 * X offset.
	 */
	public var x(getX, setX):Int;
	private function getX():Int { return _x; }
	private function setX(value:Int):Int
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
	public var y(getY, setY):Int;
	private function getY():Int { return _y; }
	private function setY(value:Int):Int
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
	public var width(getWidth, setWidth):Int;
	private function getWidth():Int { return _width; }
	private function setWidth(value:Int):Int
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
	public var height(getHeight, setHeight):Int;
	private function getHeight():Int { return _height; }
	private function setHeight(value:Int):Int
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