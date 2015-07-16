package com.stencyl.models.scene;

//import haxe.ds.HashMap;
import openfl.geom.Point;

class AutotileFormat
{
	public var autotileArrayLength:Int;
	public var defaultAnimationIndex:Int = 0;
	
	public var name:String;
	public var id:Int;
	
	public var tilesAcross:Int;
	public var tilesDown:Int;
	
	/** Maps full 0-255 autotile flag to its index in an array of animations / CornerSets. */
	public var animIndex:Array<Int> = [];
	
	/** Maps animation index to the set of corners needed for that animation. */
	public var animCorners:Array<Corners>;
	
	public function new(name:String, id:Int, tilesAcross:Int, tilesDown:Int, corners:Array<Corners>)
	{
		this.name = name;
		this.id = id;
		this.tilesAcross = tilesAcross;
		this.tilesDown = tilesDown;
		
		var arrayIndex = 0;
		
		//Can't use Haxe's HashMap because it only works with hashCode and not equality.
		//HashCode collisions cause this to break.
		var cornerIndices = new Map<Corners, Int>();
		
		for(i in 0x00...0xFF + 1)
		{
			if(cornerIndices.exists(corners[i]))
			{
				animIndex[i] = cornerIndices.get(corners[i]);
				continue;
			}
			
			animIndex[i] = arrayIndex;
			cornerIndices.set(corners[i], arrayIndex);
			++arrayIndex;
		}
		
		defaultAnimationIndex = animIndex[0xFF];
		autotileArrayLength = arrayIndex;
		
		animCorners = [];
		for(i in 0x00...0xFF + 1)
		{
			animCorners[animIndex[i]] = corners[i];
		}
	}
}

class Corners
{
	public function new(tl:Point, tr:Point, bl:Point, br:Point)
	{
		this.tl = tl;
		this.tr = tr;
		this.bl = bl;
		this.br = br;
	}
	
	public var tl:Point;
	public var tr:Point;
	public var bl:Point;
	public var br:Point;

	/*
	public function hashCode():Int
	{
		var result = 7;
		result = 17 * result + pointHash(tl);
		result = 17 * result + pointHash(tr);
		result = 17 * result + pointHash(bl);
		result = 17 * result + pointHash(br);
		return result;
	}

	private function pointHash(p:Point):Int
	{
		var result = 17;
		result = 37 * result + Std.int(p.x);
		result = 37 * result + Std.int(p.y);
		return result;
	}
	*/

	public function toString():String
	{
		return 'TL: $tl, TR: $tr, BL: $bl, BR: $br';
	}
}