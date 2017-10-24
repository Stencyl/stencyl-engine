package com.stencyl.models.scene;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Tileset as FLTileset;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class Tile
{
	public var tileID:Int;
	public var collisionID:Int;
	public var metadata:String;
	public var frameIndex:Int;
	public var parent:Tileset;

	//For autotiles
	public var autotileFormat:AutotileFormat;
	public var autotiles:Array<Tile>;
	public var autotileMergeSet:Map<Int,Int>;

	//For animated tiles
	public var pixels:BitmapData;
	public var durations:Array<Int>;
	public var frames:Array<Int>;
	public var currFrame:Int;
	public var currTime:Int;
	public var updateSource:Bool;
	
	public var data:FLTileset;
	
	public function new
	(
		tileID:Int,
		collisionID:Int,
		metadata:String,
		frameIndex:Int,
		durations:Array<Int>,
		autotileFormat:AutotileFormat,
		autotileMergeSet:Map<Int, Int>,
		parent:Tileset
	)
	{
		this.tileID = tileID;
		this.collisionID = collisionID;
		this.metadata = metadata;
		this.frameIndex = frameIndex;
		this.durations = durations;
		this.parent = parent;
		
		var atlas = GameModel.get().atlases.get(parent.atlasID);
		
		if(autotileFormat != null)
		{
			this.autotileFormat = autotileFormat;
			this.autotileMergeSet = autotileMergeSet;
			autotiles = [for (i in 0...autotileFormat.autotileArrayLength) new Tile(tileID, collisionID, metadata, frameIndex, durations, null, null, parent)];
		}

		if(atlas != null && atlas.active)
		{
			loadGraphics();
		}
		
		currFrame = 0;
		currTime = 0;
		updateSource = false;
	}
	
	public function update(elapsedTime:Float)
	{
		if(durations.length == 1)
		{
			return;
		}
		
		if (!Engine.paused)
		{
			currTime += Math.floor(elapsedTime);
			
			if(currTime > Std.int(durations[currFrame]))
			{
				currTime -= Std.int(durations[currFrame]);
				
				if(currFrame + 1 < durations.length)
				{
					currFrame++;					
				}
				
				else
				{
					currFrame = 0;
				}
				
				updateSource = true;
			
			}	
		}
	}
	
	//TODO: Don't return new Rectangle. Prebuild for animated tiles since it isn't the same.
	public function getSource(tileWidth:Int, tileHeight:Int):Rectangle
	{
		return new Rectangle(currFrame * tileWidth * Engine.SCALE, 0, tileWidth * Engine.SCALE, tileHeight * Engine.SCALE);
	}
	
	//For Atlases
	
	public function loadGraphics()
	{
		var imgData:BitmapData = null;
		
		if(durations.length > 1 || autotileFormat != null)
		{
			imgData = Data.get().getGraphicAsset
			(
				parent.ID + "-" + tileID + ".png",
				"assets/graphics/" + Engine.IMG_BASE + "/tileset-" + parent.ID + "-" + tileID + ".png"
			);
		}
		
		if(autotileFormat != null)
		{
			var i = 0;
			for(animSheet in createAutotileAnimations(imgData, autotileFormat))
			{
				autotiles[i++].loadAnimationPixels(animSheet);
			}
		}
		else
		{
			loadAnimationPixels(imgData);
		}
	}
	
	public function unloadGraphics()
	{
		pixels = null;
		data = null;
		
		if(autotiles != null)
		{
			for(t in autotiles)
			{
				t.pixels = null;
				t.data = null;
			}
		}

		if(durations.length > 1 || autotiles != null)
		{
			Data.get().resourceAssets.remove(parent.ID + "-" + tileID + ".png");				
		}
	}

	private function loadAnimationPixels(pixels:BitmapData)
	{
		if(pixels != null)
		{
			this.pixels = pixels;

			#if (cpp || neko)
			data = new FLTileset(pixels);
			
			for(i in 0 ... durations.length)
			{
				currFrame = i;
				data.addRect(getSource(parent.tileWidth, parent.tileHeight));
			}
			#end
		}
	}

	//Autotile Support

	public function createAutotileAnimations(imgData:BitmapData, format:AutotileFormat):Array<BitmapData>
	{
		var allAnimations = new Array<BitmapData>();
		
		var frames = durations.length;
		
		var tw:Int = Std.int(imgData.width / frames / format.tilesAcross);
		var th:Int = Std.int(imgData.height / format.tilesDown);
		
		var half_tw:Int = Std.int(tw / 2);
		var half_th:Int = Std.int(th / 2);

		dummyRect.width = half_tw;
		dummyRect.height = half_th;

		for(corners in format.animCorners)
		{
			var tileImg = new BitmapData(tw * frames, th);
			var copyPixels = tileImg.copyPixels.bind(imgData, _, _);
			
			for(frame in 0...frames)
			{
				var srcFrameOffset = tw * format.tilesAcross * frame;
				var destFrameOffset = tw * frame;
				
				copyPixels(sourceRect(corners.tl, srcFrameOffset), new Point(destFrameOffset + 0,       0));
				copyPixels(sourceRect(corners.tr, srcFrameOffset), new Point(destFrameOffset + half_tw, 0));
				copyPixels(sourceRect(corners.br, srcFrameOffset), new Point(destFrameOffset + half_tw, half_th));
				copyPixels(sourceRect(corners.bl, srcFrameOffset), new Point(destFrameOffset + 0,       half_th));
			}
			
			allAnimations.push(tileImg);
		}
		
		return allAnimations;
	}

	private static var dummyRect = new Rectangle();
	private inline function sourceRect(p:Point, srcFrameOffset:Int):Rectangle
	{
		dummyRect.x = srcFrameOffset + p.x * dummyRect.width;
		dummyRect.y = p.y * dummyRect.height;
		return dummyRect;
	}
}
