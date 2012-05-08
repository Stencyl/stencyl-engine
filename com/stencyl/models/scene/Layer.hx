package com.stencyl.models.scene;

import nme.display.Sprite;
import nme.geom.ColorTransform;

class Layer extends Sprite
{
	private var tiles:TileLayer;
	
	public var ID:Int;
	public var order:Int;
	public var color:Int;
	
	function new(ID:Int, order:Int, tiles:TileLayer)
	{
		super();
		
		this.tiles = tiles;
		this.ID = ID;
		this.order = order;

		//scrollFactor.x = 0;
		//scrollFactor.y = 0;
		
		alpha = 255;
		color = 0x00ffffff;
	}
	
	public function render()
	{
		if(alpha <= 0) 
		{	
			return;
		}
		
		//Don't use draw! Set the property instead!
		//tiles.draw(FlxG.scroll.x, FlxG.scroll.y, _alpha);
		//renderMembers();
	}
}