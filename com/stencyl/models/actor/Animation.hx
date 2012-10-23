package com.stencyl.models.actor;

import nme.display.BitmapData;
import box2D.dynamics.B2FixtureDef;

class Animation
{
	public var animID:Int;
	public var animName:String;
	
	public var parentID:Int;
	public var shapes:IntHash<Dynamic>;
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
		shapes:IntHash<Dynamic>, 
		looping:Bool, 
		imgWidth:Int,
		imgHeight:Int,
		originX:Float,
		originY:Float,
		durations:Array<Int>, 
		framesAcross:Int, 
		framesDown:Int,
		atlasID:Int
	)
	{
		this.animID = animID;
		this.animName = animName;
		
		this.parentID = parentID;
		this.shapes = shapes;
		this.looping = looping;
		this.durations = durations;

		this.imgWidth = imgWidth;
		this.imgHeight = imgHeight;
		
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		
		this.originX = originX;
		this.originY = originY;
		
		var atlas = GameModel.get().atlases.get(atlasID);
			
		if(atlas != null && atlas.active)
		{
			loadGraphics();
		}
	}
	
	//For Atlases
	
	public function loadGraphics()
	{
		imgData = Data.get().getGraphicAsset
		(
			parentID + "-" + animID + ".png",
			"assets/graphics/" + Engine.IMG_BASE + "/sprite-" + parentID + "-" + animID + ".png"
		);
	}
	
	public function unloadGraphics()
	{
		//Graceful fallback - just a blank image that is numFrames across in px
		imgData = new BitmapData(framesAcross, 1);
		Data.get().resourceAssets.remove(parentID + "-" + animID + ".png");
	}
}