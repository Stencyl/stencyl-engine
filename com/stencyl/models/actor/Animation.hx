package com.stencyl.models.actor;

import nme.display.BitmapData;

class Animation
{
	public var animID:Int;
	public var animName:String;
	
	public var parentID:Int;
	public var shapes:Array<Dynamic>;
	public var looping:Bool;
	public var durations:Array<Int>;
	
	public var imgData:Dynamic;
	public var imgWidth:Int;
	public var imgHeight:Int;
	
	public var framesAcross:Int;
	public var framesDown:Int;
	
	public var originX:Float;
	public var originY:Float;
	
	public function new
	(
		animID:Int,
		animName:String,
		parentID:Int, 
		shapes:Array<Dynamic>, 
		looping:Bool, 
		imgData:Dynamic,
		imgWidth:Int,
		imgHeight:Int,
		originX:Float,
		originY:Float,
		durations:Array<Int>, 
		framesAcross:Int, 
		framesDown:Int
	)
	{
		this.animID = animID;
		this.animName = animName;
		
		this.parentID = parentID;
		this.shapes = shapes;
		this.looping = looping;
		this.durations = durations;
		
		this.imgData = imgData;
		this.imgWidth = imgWidth;
		this.imgHeight = imgHeight;
		
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		
		this.originX = originX;
		this.originY = originY;
	}
}