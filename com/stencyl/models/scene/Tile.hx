package com.stencyl.models.scene;

#if use_tilemap
import com.stencyl.graphics.TextureAtlas;
#end
import com.stencyl.utils.Assets;

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
	public var frameIds:Array<Int>;
	public var useSubframes:Bool;
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
		if(durations.length == 1 && autotileFormat == null)
			return;
		
		var imageName = "assets/graphics/" + Engine.IMG_BASE + "/tileset-" + parent.ID + "-" + tileID + ".png";
		#if use_tilemap
		var textureAtlas = Assets.getAtlasForImage(imageName);
		if(textureAtlas != null)
		{
			var fileData = textureAtlas.getFileData(imageName);
			if(autotileFormat != null)
			{
				var i = 0;
				for(animSubFrames in createAutotileTilemapAnimations(textureAtlas, fileData, autotileFormat))
				{
					autotiles[i++].loadAnimationTiles(textureAtlas, animSubFrames, true);
				}
			}
			else
			{
				var animFrames = [for(region in fileData.regions) region.tileID];
				loadAnimationTiles(textureAtlas, animFrames, false);
			}
		}
		else
		#end
		{
			var imgData = Assets.getBitmapData(imageName, false);
			
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
	}
	
	public function unloadGraphics()
	{
		pixels = null;
		data = null;
		frameIds = null;
		
		if(autotiles != null)
		{
			for(t in autotiles)
			{
				t.pixels = null;
				t.data = null;
				t.frameIds = null;
			}
		}
	}

	private function loadAnimationPixels(pixels:BitmapData)
	{
		if(pixels != null)
		{
			this.pixels = pixels;
			
			#if use_tilemap
			frameIds = [];
			data = new FLTileset(pixels);
			
			for(i in 0 ... durations.length)
			{
				currFrame = i;
				frameIds.push(data.addRect(getSource(parent.tileWidth, parent.tileHeight)));
			}
			#end
		}
	}
	
	#if use_tilemap
	private function loadAnimationTiles(textureAtlas:TextureAtlas, animSubFrames:Array<Int>, useSubframes:Bool)
	{
		data = textureAtlas.tileset;
		frameIds = animSubFrames;
		this.useSubframes = useSubframes;
	}
	#end

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
	
	#if use_tilemap
	public function createAutotileTilemapAnimations(textureAtlas:TextureAtlas, fileData:FileData, format:AutotileFormat):Array<Array<Int>>
	{
		//for each autotile form
		  //for each frame of the animation a top-left, top-right, bottom-left, and bottom-right corner
		var allAnimations = [];
		
		var frames = durations.length;
		var numTiles = fileData.regions.length;
		
		var tw:Int = fileData.regions[0].width;
		var th:Int = fileData.regions[0].height;
		
		var half_tw:Int = Std.int(tw / 2);
		var half_th:Int = Std.int(th / 2);
		
		dummyRect.x = 0;
		dummyRect.y = 0;
		dummyRect.width = half_tw;
		dummyRect.height = half_th;
		
		var stride = frames * format.tilesAcross;
		
		var firstSubTileId = textureAtlas.tileset.getRectID(dummyRect);
		if(firstSubTileId == null)
		{
			firstSubTileId = textureAtlas.tileset.numRects;
			for(y in 0...format.tilesDown * 2)
			{
				for(x in 0...stride * 2)
				{
					var originalRegion = fileData.regions[Std.int(y / 2) * stride + Std.int(x / 2)];
					dummyRect.x = originalRegion.x + (x % 2) * half_tw;
					dummyRect.y = originalRegion.y + (y % 2) * half_th;
					textureAtlas.tileset.addRect(dummyRect);
				}
			}
		}
		
		var getTileId = function(halfCoord:Point) {
			var x = Std.int(halfCoord.x);
			var y = Std.int(halfCoord.y);
			return firstSubTileId + (stride * 2 * y) + x;
		};

		for(corners in format.animCorners)
		{
			var tileIds = [];
			
			for(frame in 0...frames)
			{
				tileIds.push(getTileId(corners.tl));
				tileIds.push(getTileId(corners.tr));
				tileIds.push(getTileId(corners.bl));
				tileIds.push(getTileId(corners.br));
			}
			
			allAnimations.push(tileIds);
		}
		
		return allAnimations;
	}
	#end

	private static var dummyRect = new Rectangle();
	private inline function sourceRect(p:Point, srcFrameOffset:Int):Rectangle
	{
		dummyRect.x = srcFrameOffset + p.x * dummyRect.width;
		dummyRect.y = p.y * dummyRect.height;
		return dummyRect;
	}
}
