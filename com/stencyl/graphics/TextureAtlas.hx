package com.stencyl.graphics;

import com.stencyl.utils.Assets;

import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.geom.Rectangle;

typedef TileData = {
	filename:String,
	region:Int,
	x:Int,
	y:Int,
	width:Int,
	height:Int
}

typedef RegionData = {
	tileID:Int,
	x:Int,
	y:Int,
	width:Int,
	height:Int
};

typedef FileData = {
	name:String,
	regions:Array<RegionData>
};

@:access(openfl.display.BitmapData)

class TextureAtlas
{
	public var tileset:Tileset;
	private var tilelist:Array<TileData>;
	private var filemap:Map<String, FileData>;
	private var tileCache:Map<String, BitmapData>;
	private var id:Int;
	
	public function new(id:Int)
	{
		this.id = id;
	}

	public function loadData()
	{
		var textBytes = Assets.getText('assets/atlases/${Engine.IMG_BASE}/atlas-$id.data');
		
		var atlasData:List<TileData> = haxe.Unserializer.run(textBytes);

		filemap = [];
		tilelist = [];
		
		var tileID = 0;
		for(tile in atlasData)
		{
			var filedata:FileData = null;
			if(!filemap.exists(tile.filename))
			{
				filedata = {name:tile.filename, regions: []};
				filemap.set(tile.filename, filedata);
			}
			else
			{
				filedata = filemap.get(tile.filename);
			}
			if(tile.region >= filedata.regions.length)
				filedata.regions.resize(tile.region + 1);
			filedata.regions[tile.region] = {
				tileID: tileID,
				x: tile.x,
				y: tile.y,
				width: tile.width,
				height: tile.height
			};
			tilelist.push(tile);
			++tileID;
		}
	}
	
	public function loadImage()
	{
		var img = Assets.getBitmapData('assets/atlases/${Engine.IMG_BASE}/atlas-$id.png', false);
		tileset = new Tileset(img);
		GLUtil.uploadTexture(img, true);
		for(tile in tilelist)
		{
			tileset.addRect(new Rectangle(tile.x, tile.y, tile.width, tile.height));
		}
		tileCache = [];
	}
	
	public function getTile(id:String, useCache:Bool=true):BitmapData
	{
		var img:BitmapData = null;
		if(useCache)
		{
			img = tileCache.get(id);
			if(img != null)
				return img;
		}
		
		var regionData = getFileData(id).regions[0];
		img = new BitmapData(0, 0, true, 0);
		img.__resize(regionData.width, regionData.height);
		
		var ts = new TileSource();
		ts.tileset = tileset;
		ts.tileID = regionData.tileID;
		ts.width = regionData.width;
		ts.height = regionData.height;
		img.__tileSource = ts;
		
		if(useCache)
			tileCache.set(id, img);
		
		return img;
	}
	
	public function getTiles(id:String):Array<BitmapData>
	{
		var imgs = [];
		
		var fileData = getFileData(id);
		for(regionData in fileData.regions)
		{
			if(regionData == null)
			{
				imgs.push(null);
				continue;
			}
			var img:BitmapData = null;
			img = new BitmapData(0, 0, true, 0);
			img.__resize(regionData.width, regionData.height);
			
			var ts = new TileSource();
			ts.tileset = tileset;
			ts.tileID = regionData.tileID;
			ts.width = regionData.width;
			ts.height = regionData.height;
			img.__tileSource = ts;
			imgs.push(img);
		}
		
		return imgs;
	}

	public function unload()
	{
		tileset = null;
		tileCache = null;
	}

	public function listFiles():Iterator<String>
	{
		return filemap.keys();
	}

	public function getFileData(filename:String):FileData
	{
		return filemap.get(filename);
	}
}