package com.stencyl.models.collision;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.utils.Utils;

import openfl.geom.Rectangle;

/**
 * A Mask that can contain multiple Masks of one or various types.
 */
class Masklist extends Hitbox
{
	/**
	 * Constructor.
	 * @param	...mask		Masks to add to the list.
	 */
	public function new(masks:Array<Dynamic>, par:Actor) 
	{
		super();
		_masks = new Array<Mask>();
		_temp = new Array<Mask>();
		
		solid = false;
		parent = par;
		
		var m:Mask;
		for (m in masks) add(m);
	}
	
	/** @private Collide against a mask. */
	override public function collide(mask:Mask):Bool 
	{
		var m:Mask;
		for (m in _masks)
		{
			m.groupID = (m.groupID == GameModel.INHERIT_ID ? m.parent.groupID : m.groupID);
			
			if ((Std.is(mask, Masklist) || mask.groupID == -2 || GameModel.collisionMap[m.groupID][mask.groupID]) && m.collide(mask)) 
			{
				lastBounds.x = m.lastBounds.x;
				lastBounds.y = m.lastBounds.y;
				lastBounds.width = m.lastBounds.width;
				lastBounds.height = m.lastBounds.height;				
				
				lastCheckedMask = m;
				lastColID = mask.groupID;
				
				return true;
			}
		}
		return false;
	}
	
	/** @private Collide against a Masklist. */
	override private function collideMasklist(other:Masklist):Bool 
	{		
		var a:Mask;
		var b:Mask;
		for (a in _masks)
		{
			a.groupID = (a.groupID == GameModel.INHERIT_ID ? a.parent.groupID : a.groupID);
			
			for (b in other._masks)
			{
				b.groupID = (b.groupID == GameModel.INHERIT_ID ? b.parent.groupID : b.groupID);
				
				if (a.collide(b)) 
				{
					//Readjust since dealing with two masks?
					other.lastBounds.x = b.lastBounds.x;
					other.lastBounds.y = b.lastBounds.y;
					other.lastBounds.width = b.lastBounds.width;
					other.lastBounds.height = b.lastBounds.height;
					
					other.lastCheckedMask = b;
					other.lastColID = a.groupID;
					
					return true;
				}
			}
		}
		return true;
	}
	
	/**
	 * Adds a Mask to the list.
	 * @param	mask		The Mask to add.
	 * @return	The added Mask.
	 */
	public function add(mask:Mask):Mask
	{
		_masks[_count ++] = mask;
		mask.list = this;
		mask.parent = parent;		
		solid = solid || mask.solid;
		update();
		
		mask.groupID = (mask.groupID == GameModel.INHERIT_ID ? parent.groupID : mask.groupID);
		
		var colList:Array<Int> = GameModel.get().groupsCollidesWith.get(mask.groupID);		
		var i:Int;
		
		if(colList != null)
		{
			for (i in colList)
			{
				if (!Utils.contains(collideTypes, i))
				{
					collideTypes.push(i);
				}
			}
		}
		
		return mask;
	}
	
	/**
	 * Removes the Mask from the list.
	 * @param	mask		The Mask to remove.
	 * @return	The removed Mask.
	 */
	public function remove(mask:Mask):Mask
	{
		if (Lambda.indexOf(_masks, mask) < 0) return mask;
		Utils.clear(_temp);
		var m:Mask;
		for (m in _masks)
		{
			if (m == mask)
			{
				mask.list = null;
				mask.parent = null;
				_count --;
				update();
			}
			else _temp[_temp.length] = m;
		}
		var temp:Array<Mask> = _masks;
		_masks = _temp;
		_temp = temp;
		return mask;
	}
	
	/**
	 * Removes the Mask at the index.
	 * @param	index		The Mask index.
	 */
	public function removeAt(index:Int = 0)
	{
		Utils.clear(_temp);
		var i:Int = _masks.length;
		index %= i;
		while (i-- > 0)	
		{
			if (i == index)
			{
				_masks[index].list = null;
				_count --;
				update();
			}
			else _temp[_temp.length] = _masks[index];
		}
		var temp:Array<Mask> = _masks;
		_masks = _temp;
		_temp = temp;
	}
	
	/**
	 * Removes all Masks from the list.
	 */
	public function removeAll()
	{
		var m:Mask;
		for (m in _masks) m.list = null;
		_count = 0;
		Utils.clear(_masks);
		Utils.clear(_temp);
		update();
	}
	
	/**
	 * Gets a Mask from the list.
	 * @param	index		The Mask index.
	 * @return	The Mask at the index.
	 */
	public function getMask(index:Int = 0):Mask
	{
		return _masks[index % _masks.length];
	}
	
	override public function assignTo(parent:Actor):Void 
	{
		for (m in _masks) m.parent = parent;
		super.assignTo(parent);
	}
	
	/** @private Updates the parent's bounds for this mask. */
	override public function update() 
	{
		// find bounds of the contained masks
		var t:Int = 100000, l:Int = 100000, r:Int = 0, b:Int = 0, h:Hitbox, i:Int = _count;
		while (i-- > 0)
		{
			if ((h = cast(_masks[i], Hitbox)) != null)
			{
				if (h._x < l) l = h._x;
				if (h._y < t) t = h._y;
				if (h._x + h._width > r) r = h._x + h._width;
				if (h._y + h._height > b) b = h._y + h._height;
			}
		}
		
		// update hitbox bounds
		_x = l;
		_y = t;
		_width = r - l;
		_height = b - t;
		
		super.update();
	}
	
	/**
	 * Amount of Masks in the list.
	 */
	public var count(get_count, null):Int;
	private function get_count():Int { return _count; }
	
	// List information.
	private var _masks:Array<Mask>;
	private var _temp:Array<Mask>;
	private var _count:Int;
}