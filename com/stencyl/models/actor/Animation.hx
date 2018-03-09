package com.stencyl.models.actor;

import openfl.display.BitmapData;
import com.stencyl.graphics.DynamicTileset;
import box2D.dynamics.B2FixtureDef;

class Animation
{
	public var animID:Int;
	public var animName:String;
	
	public var parentID:Int;
	public var simpleShapes:Map<Int,Dynamic>;
	public var physicsShapes:Map<Int,Dynamic>;
	public var looping:Bool;
	public var sync:Bool;
	public var durations:Array<Int>;
	
	public var imgData:BitmapData;
	public var imgWidth:Int;
	public var imgHeight:Int;
	
	public var frameCount:Int;
	public var framesAcross:Int;
	public var framesDown:Int;
	
	public var originX:Float;
	public var originY:Float;
	
	public var sharedTimer:Float = 0;
	public var sharedFrameIndex:Int = 0;
	
	public static var allAnimations:Array<Animation> = new Array<Animation>();
	private static var UNLOADED:BitmapData;
	
	public static function resetStatics():Void
	{
		allAnimations = new Array<Animation>();
	}

	public function new
	(
		animID:Int,
		animName:String,
		parentID:Int, 
		simpleShapes:Map<Int,Dynamic>, 
		physicsShapes:Map<Int,Dynamic>, 
		looping:Bool, 
		sync:Bool,
		imgWidth:Int,
		imgHeight:Int,
		originX:Float,
		originY:Float,
		durations:Array<Int>, 
		frameCount:Int,
		framesAcross:Int, 
		framesDown:Int,
		atlasID:Int
	)
	{
		this.animID = animID;
		this.animName = animName;
		
		this.parentID = parentID;
		this.simpleShapes = simpleShapes;
		this.physicsShapes = physicsShapes;
		this.looping = looping;
		this.sync = sync;
		this.durations = durations;

		this.imgData = UNLOADED;
		this.imgWidth = imgWidth;
		this.imgHeight = imgHeight;
		
		this.frameCount = frameCount;
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		
		this.originX = originX;
		this.originY = originY;
		
		var atlas = GameModel.get().atlases.get(atlasID);
			
		if(atlas != null && atlas.active)
		{
			loadGraphics();
		}
		
		if(frameCount > 1 && looping)
		{
			allAnimations.push(this);
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
		if(UNLOADED == null)
			UNLOADED = new BitmapData(1,1);
		imgData = UNLOADED;
		Data.get().resourceAssets.remove(parentID + "-" + animID + ".png");
	}
	
	#if (use_actor_tilemap)
	public var tilesetInitialized = false;
	public var tileset:DynamicTileset = null;
	public var frameIndexOffset:Int;
	
	public function initializeInTileset(tileset:DynamicTileset):Bool
	{
		var frameWidth = Std.int(imgWidth / framesAcross);
		var frameHeight = Std.int(imgHeight / framesDown);
		if(!tileset.checkForSpace(frameWidth, frameHeight, frameCount))
		{
			return false;
		}
		
		frameIndexOffset = tileset.addFrames(imgData, frameWidth, frameHeight, framesAcross, frameCount);
		this.tileset = tileset;
		tilesetInitialized = true;
		return true;
	}
	#end
	
	public static function updateAll(elapsedTime:Float)
	{
		for(a in allAnimations)
		{
			a.update(elapsedTime);
		}
	}
	
	public inline function update(elapsedTime:Float)
	{
		sharedTimer += elapsedTime;
		
		if(frameCount > 1 && sharedTimer > durations[sharedFrameIndex])
		{
			var old = sharedFrameIndex;
		
			sharedTimer -= durations[sharedFrameIndex];
			
			sharedFrameIndex++;
			
			if(sharedFrameIndex >= frameCount)
			{
				if(looping)
				{
					sharedFrameIndex = 0;
				}
				
				else
				{	
					sharedFrameIndex--;
				}
			}
		}
	}
}