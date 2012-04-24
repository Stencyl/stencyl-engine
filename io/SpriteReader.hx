package io;

import haxe.xml.Fast;
import models.Resource;

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
		var defaultAnimation:Int = Std.parseInt(xml.att.default);
		
		var animations:Array<Animation> = new Array<Animation>();
		/*var sprite:Sprite = new Sprite(ID, name, width, height, defaultAnimation);
		
		for each(var e:XML in xml.children())
		{
			sprite.animations[e.@id] = readAnimation(e, sprite);
		}

		return sprite;*/
		
		return null;
	}
}
