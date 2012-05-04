package com.stencyl.models.scene

import nme.geom.ColorTransform;

class Layer extends FlxGroup
{
	private var tiles:TileLayer;
	
	public var order:Number;
	public var _alpha:Number;

	var _color:uint;
	
	function Layer(ID:Number, order:Number, tiles:TileLayer)
	{
		super();
		
		this.tiles = tiles;
		this.ID = ID;
		this.order = order;

		scrollFactor.x = 0;
		scrollFactor.y = 0;
		
		_alpha = 255;
		_color = 0x00ffffff;
	}
	
	public function set alpha(Alpha:Number):void
	{
		_alpha = Alpha;
	}
	
	public function get alpha():Number
	{
		return _alpha;
	}
	
	override public function render():void
	{
		if (_alpha <= 0.0) return;
		
		//Don't use draw! Set the property instead!
		tiles.draw(FlxG.scroll.x, FlxG.scroll.y, _alpha);
		renderMembers();
	}
}