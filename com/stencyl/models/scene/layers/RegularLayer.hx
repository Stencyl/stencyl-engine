package com.stencyl.models.scene.layers;

import openfl.display.BlendMode;
import openfl.display.Sprite;

import openfl.display.BlendMode;

class RegularLayer extends Sprite 
{
	public var ID:Int;
	public var layerName:String;
	public var order:Int;
	public var scrollFactorX:Float;
	public var scrollFactorY:Float;
	public var opacity:Float;
	
	public function new(ID:Int, name:String, order:Int, scrollFactorX:Float, scrollFactorY:Float, opacity:Float, blendMode:BlendMode) 
	{
		super();
		this.ID = ID;
		this.layerName = name;
		this.order = order;
		this.scrollFactorX = scrollFactorX;
		this.scrollFactorY = scrollFactorY;
		alpha = opacity;
		#if (cpp || neko)
		//blendName is implemented in Layer.hx
		#elseif flash
		this.blendMode = blendMode;
		#end
	}

	public function updatePosition(x:Float, y:Float, elapsedTime:Float)
	{

	}
}

		