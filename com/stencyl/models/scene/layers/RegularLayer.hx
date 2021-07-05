package com.stencyl.models.scene.layers;

import openfl.display.BlendMode;
import openfl.display.Sprite;

import com.stencyl.utils.motion.*;

class RegularLayer extends Sprite 
{
	public var ID:Int;
	public var layerName:String;
	public var order:Int;
	public var scrollFactorX:Float;
	public var scrollFactorY:Float;
	public var opacity:Float;
	
	public var alphaTween:TweenFloat;
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode) 
	{
		super();
		this.ID = ID;
		this.name = name;
		this.layerName = name;
		this.order = order;
		this.scrollFactorX = scrollFactorX;
		this.scrollFactorY = scrollFactorY;
		alpha = opacity;
		this.blendMode = blendMode;
	}

	public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{

	}
}

		