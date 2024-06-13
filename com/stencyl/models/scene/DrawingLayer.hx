package com.stencyl.models.scene;

import com.stencyl.Config;
import com.stencyl.graphics.G;
import com.stencyl.utils.Utils;

import openfl.display.Graphics;
import openfl.display.Sprite;
#if use_actor_tilemap
import openfl.display.Tilemap;
#end

class DrawingLayer extends #if use_actor_tilemap Tilemap #else Sprite #end
{
	#if (stencyl4_compat && use_actor_tilemap)
	public var sprite:Sprite;
	public var graphics:Graphics;
	#end
	
	public function new(width:Int, height:Int)
	{
		super(#if use_actor_tilemap width, height, null, Config.antialias #end);
		
		#if (stencyl4_compat && use_actor_tilemap)
		sprite = new Sprite();
		graphics = sprite.graphics;
		#end
	}
	
	public function clearFrame():Void
	{
		#if use_actor_tilemap
		Utils.removeAllTiles(this);
		#else
		Utils.removeAllChildren(this);
		#end
		
		#if stencyl4_compat
		graphics.clear();
		#end
	}
	
	#if stencyl4_compat
	public function renderFrame(g:G):Void
	{
		#if use_actor_tilemap
		g.layer = this;
		g.drawShape(graphics);
		#end
	}
	#end
}