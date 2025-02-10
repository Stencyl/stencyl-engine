package com.stencyl.models.scene;

import com.stencyl.Config;
import com.stencyl.graphics.G;
import com.stencyl.utils.Utils;

import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Sprite;
#if use_actor_tilemap
import openfl.display.Tilemap;
#end

class DrawingLayer extends #if use_actor_tilemap Tilemap #else Sprite #end
{
	#if (use_actor_tilemap)
	//only used with Config.drawToLayers
	//if use_actor_tilemap is not enabled, these are naturally present as members of Sprite
	public var shape:Shape;
	public var graphics:Graphics;
	#end
	
	public function new(width:Int, height:Int)
	{
		super(#if use_actor_tilemap width, height, null, Config.antialias #end);
		
		#if (use_actor_tilemap)
		if(Config.drawToLayers)
		{
			shape = new Shape();
			graphics = shape.graphics;
		}
		#end
	}
	
	public function clearFrame():Void
	{
		#if use_actor_tilemap
		Utils.removeAllTiles(this);
		#else
		Utils.removeAllChildren(this);
		#end
		
		if(Config.drawToLayers)
		{
			graphics.clear();
		}
	}
	
	public function renderFrame(g:G):Void
	{
		#if use_actor_tilemap
		if(Config.drawToLayers)
		{
			g.layer = this;
			g.drawShape(graphics);
		}
		#end
	}
}