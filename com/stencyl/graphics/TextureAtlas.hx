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
	private var imgBase:String;
	private var id:String;
	
	public function new(imgBase:String, id:String)
	{
		this.imgBase = imgBase;
		this.id = id;
	}

	public function loadData()
	{
		var textBytes = Assets.getText('assets/atlases/$imgBase/atlas-$id.data');
		
		var atlasData:List<TileData> = haxe.Unserializer.run(textBytes);

		filemap = new Map<String, FileData>();
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
			#if haxe4
			if(tile.region >= filedata.regions.length)
				filedata.regions.resize(tile.region + 1);
			#else
			while(tile.region >= filedata.regions.length)
				filedata.regions.push(null);
			#end
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
		var img = Assets.getBitmapData('assets/atlases/$imgBase/atlas-$id.png', false);
		tileset = new Tileset(img);
		GLUtil.uploadTexture(img, true);
		for(tile in tilelist)
		{
			tileset.addRect(new Rectangle(tile.x, tile.y, tile.width, tile.height));
		}
		tileCache = new Map<String, BitmapData>();
	}
	
	public function getTile(filename:String, useCache:Bool=true):BitmapData
	{
		var img:BitmapData = null;
		if(useCache)
		{
			img = tileCache.get(filename);
			if(img != null)
				return img;
		}
		
		var regionData = getFileData(filename).regions[0];
		img = new BitmapData(0, 0, true, 0);
		img.__resize(regionData.width, regionData.height);
		
		var ts = new TileSource();
		ts.tileset = tileset;
		ts.tileID = regionData.tileID;
		ts.width = regionData.width;
		ts.height = regionData.height;
		img.__tileSource = ts;
		
		if(useCache)
			tileCache.set(filename, img);
		
		return img;
	}
	
	public function getTiles(filename:String):Array<BitmapData>
	{
		var imgs = [];
		
		var fileData = getFileData(filename);
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