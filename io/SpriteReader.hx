package io;

import haxe.xml.Fast;
import models.Resource;
import models.actor.Sprite;
import models.actor.Animation;

class SpriteReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == "sprite";
	}
	
	public function read(ID:Int, type:String, name:String, xml:Fast):Resource
	{
		trace("Reading Sprite (" + ID + ") - " + name);
		
		var width:Int = Std.parseInt(xml.att.width);
		var height:Int = Std.parseInt(xml.att.height);
		var defaultAnimation:Int = Std.parseInt(xml.att.defaultAnimation);
		
		var animations:Array<Animation> = new Array<Animation>();
		var sprite:Sprite = new Sprite(ID, name, width, height, defaultAnimation);
		
		for(e in xml.elements)
		{
			sprite.animations[Std.parseInt(e.att.id)] = readAnimation(e, sprite);
		}

		return sprite;
	}
}
