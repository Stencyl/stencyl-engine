package com.stencyl.models.actor;

import openfl.display.BitmapData;
#if use_actor_tilemap
import openfl.display.Tileset;
#end
import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Sprite;
import com.stencyl.graphics.DynamicTileset;
import com.stencyl.graphics.TileSource;
import com.stencyl.utils.Assets;
import com.stencyl.utils.Log;
import com.stencyl.utils.Utils;
import com.stencyl.Engine;
import box2D.dynamics.B2FixtureDef;

class Animation
{
	public var animID:Int;
	public var animName:String;
	
	public var parent:Sprite;
	public var simpleShapes:Map<Int,Dynamic>;
	public var physicsShapes:Map<Int,Dynamic>;
	public var looping:Bool;
	public var sync:Bool;
	public var durations:Array<Int>;
	public var frames:Array<BitmapData>;
	public var frameWidth:Int; //logical size
	public var frameHeight:Int; //logical size
	
	public var originX:Float;
	public var originY:Float;
	
	public var sharedTimer:Float = 0;
	public var sharedFrameIndex:Int = 0;
	
	//used for reading in animation strips from filesystem
	public var imgWidth:Int;
	public var imgHeight:Int;
	public var frameCount:Int;
	public var framesAcross:Int;
	public var framesDown:Int;
	
	public var graphicsLoaded:Bool;
	
	public static var allAnimations:Array<Animation> = new Array<Animation>();
	public static var UNLOADED(default, null):BitmapData;
	
	public static function resetStatics():Void
	{
		allAnimations = new Array<Animation>();
	}

	public function new
	(
		animID:Int,
		animName:String,
		parent:Sprite, 
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
		framesDown:Int
	)
	{
		this.animID = animID;
		this.animName = animName;
		
		this.parent = parent;
		this.simpleShapes = simpleShapes;
		this.physicsShapes = physicsShapes;
		this.looping = looping;
		this.sync = sync;
		this.durations = durations;
		
		//Graceful fallback - just a blank image that is numFrames across in px
		if(UNLOADED == null)
			UNLOADED = new BitmapData(1,1);
		this.frames = [for(i in 0...frameCount) UNLOADED];
		frameWidth = Std.int(imgWidth/framesAcross);
		frameHeight = Std.int(imgHeight/framesDown);
		
		this.imgWidth = imgWidth;
		this.imgHeight = imgHeight;
		this.frameCount = frameCount;
		this.framesAcross = framesAcross;
		this.framesDown = framesDown;
		
		this.originX = originX;
		this.originY = originY;
		
		if(parent == null)
		{
			frames = [UNLOADED];
		}
		else
		{
			var atlas = GameModel.get().atlases.get(parent.atlasID);
			
			if(atlas != null && atlas.active)
			{
				loadGraphics();
			}
			
			if(frameCount > 1 && looping)
			{
				allAnimations.push(this);
			}
		}
	}
	
	//For Atlases
	public function loadGraphics()
	{
		if(graphicsLoaded)
			return;
		
		var imgData = Assets.getBitmapData
		(
			"assets/graphics/" + Engine.IMG_BASE + "/sprite-" + parent.ID + "-" + animID + ".png",
			false
		);

		if(imgData.rect == null)
		{
			Log.error("Error: trying to load from a disposed BitmapData. " + Utils.printCallstackIfAvailable());
			imgData = null;
		}
		
		if(imgData == null)
		{
			frames = [for(i in 0...frameCount) UNLOADED];
			return;
		}
		
		if(frameCount == 1)
		{
			frames[0] = imgData;
		}
		else
		#if use_actor_tilemap
		{
			var fw = Std.int(frameWidth * Engine.SCALE);
			var fh = Std.int(frameHeight * Engine.SCALE);
			
			for(i in 0...frameCount)
			{
				frames[i] = TileSource.createSubImage(imgData, fw * (i % framesAcross), Math.floor(i / framesAcross) * fh, fw, fh);
			}
		}
		#else
		{
			var fw = Std.int(frameWidth * Engine.SCALE);
			var fh = Std.int(frameHeight * Engine.SCALE);
			
			var point = new Point(0, 0);
			
			for(i in 0...frameCount)
			{
				var sourceRect = new Rectangle(fw * (i % framesAcross), Math.floor(i / framesAcross) * fh, fw, fh);
				var frameImg = new BitmapData(fw, fh, true, 0);
				frameImg.copyPixels(imgData, sourceRect, point);
				frames[i] = frameImg;
			}
			
			imgData.dispose();
		}
		#end
		
		#if ((lime_opengl || lime_opengles || lime_webgl) && !use_dynamic_tilemap)
		if(Config.disposeImages && parent != null && !parent.readableImages)
		{
			#if use_actor_tilemap
			com.stencyl.graphics.GLUtil.uploadTexture(imgData, true);
			#else
			var i = 0;
			for(frame in frames)
			{
				com.stencyl.graphics.GLUtil.uploadTexture(frame, true);
				//@:privateAccess Log.verbose("Uploaded texture for " + parent.name + " frame " + (i++) + " to gpu texture " + frame.__texture.__textureID);
			}
			#end
		}
		#end
		
		graphicsLoaded = true;
	}

	public function unloadGraphics()
	{
		if(!graphicsLoaded)
			return;
		
		for(i in 0...frameCount)
		{
			#if !use_actor_tilemap
			if(frames[i].readable)
				frames[i].dispose();
			#end
			
			frames[i] = UNLOADED;
		}
		
		graphicsLoaded = false;
	}
	
	public function checkImageReadable():Bool
	{
		#if use_actor_tilemap
		if(TileSource.fromBitmapData(frames[0]).tileset.bitmapData.readable)
			return true;
		#else
		if(frames[0].readable)
			return true;
		#end
		
		#if stencyltools
		/*com.stencyl.utils.ToolsetInterface.instance.sendData
		(
			["Content-Type" => "Issue",
			"Issue" => "Disposed-Image-Access",
			"ID" => ""+parentID],
			null
		);*/
		//XXX: This is based on the assumption that the associated actorType is the previous resource ID
		Log.error("Can't get actor image with disposeImages enabled: " + Data.get().resources.get(parent.ID - 1).name);
		#else
		Log.error("Can't get actor image with disposeImages enabled: " + Data.get().resources.get(parent.ID - 1).name);
		#end
		
		return false;
	}
	
	#if (use_actor_tilemap && use_dynamic_tilemap)
	public var tilesetInitialized = false;
	
	public function initializeInTileset(tileset:DynamicTileset):Bool
	{
		if(!tileset.checkForSpace(Std.int(frameWidth * Engine.SCALE), Std.int(frameHeight * Engine.SCALE), frameCount))
		{
			return false;
		}
		
		var originalImg = frameCount == 0 ? null : TileSource.fromBitmapData(frames[0]).tileset.bitmapData;
		
		tileset.addFrames(frames);
		tilesetInitialized = true;
		
		Engine.engine.loadedAnimations.push(this);
		
		//@:privateAccess Log.verbose("Uploaded textures for " + parent.name + " (" + frameCount + " frames) to gpu texture " + tileset.tileset.bitmapData.__texture.__textureID);
		
		if(Config.disposeImages && parent != null && !parent.readableImages)
		{
			com.stencyl.graphics.GLUtil.disposeSoftwareBuffer(originalImg);
		}
		
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
	
	public function update(elapsedTime:Float)
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