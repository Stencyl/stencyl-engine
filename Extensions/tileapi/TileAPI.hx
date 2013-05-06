import box2D.collision.shapes.B2Shape;
import com.stencyl.Engine;
import com.stencyl.Data;
import com.stencyl.utils.Utils;
import com.stencyl.models.Actor;
import com.stencyl.models.scene.Tile;
import com.stencyl.models.scene.Tileset;
import com.stencyl.models.GameModel;

class TileAPI
{
	public static function setTileAt(row:Int, col:Int, layerID:Int, tilesetID:Int, tileID:Int)
	{
		var engine = Engine.engine;
		var tlayer = engine.tileLayers.get(layerID);
		
		if(tlayer == null)
		{
			return;
		}
		
		var tset = cast(Data.get().resources.get(tilesetID), Tileset);
		var tile:Tile = tset.tiles[tileID];
		
		//add the Tile to the TileLayer
		tlayer.setTileAt(row, col, tile);    
		
		//If animated tile, add to update list
		if(tile != null && tile.pixels != null && Utils.contains(engine.animatedTiles, tile))
		{
			engine.animatedTiles.push(tile);
		}
		
		//Now add the shape as a body
		if(tile != null && tile.collisionID != -1)
		{
			var tileShape = GameModel.get().shapes.get(tile.collisionID);
			var x = col * engine.scene.tileWidth;
			var y = row * engine.scene.tileHeight;
			
			if(tileShape != null)
			{
				createDynamicTile(tileShape, Engine.toPhysicalUnits(x), Engine.toPhysicalUnits(y), layerID, engine.scene.tileWidth, engine.scene.tileHeight);
			}
		}
		
		Engine.engine.tileUpdated = true;
	}
	
	public static function tileExistsAt(row:Int, col:Int, layerID:Int):Bool
	{
		return getTileAt(row, col, layerID) != null;
	}
	
	public static function getTileIDAt(row:Int, col:Int, layerID:Int):Int
	{
		var tile = getTileAt(row, col, layerID);
		
		if(tile == null)
		{
			return -1;
		}
		
		return tile.tileID;
	}
	
	public static function getTilesetIDAt(row:Int, col:Int, layerID:Int):Int
	{
		var tile = getTileAt(row, col, layerID);
		
		if(tile == null)
		{
			return -1;
		}
		
		return tile.parent.ID;
	}
	
	public static function getTileAt(row:Int, col:Int, layerID:Int):Tile
	{
		var engine = Engine.engine;
		var tlayer = engine.tileLayers.get(layerID);
		
		if(tlayer == null)
		{
			return null;
		}
		
		return tlayer.getTileAt(row, col);
	}
	
	public static function removeTileAt(row:Int, col:Int, layerID:Int)
	{
		var engine = Engine.engine;
		var tlayer = engine.tileLayers.get(layerID);
		
		if(tlayer == null)
		{
			return;
		}
		
		//grab the tile to get the shape
		var tile:Tile = getTileAt(row, col, layerID);
		
		//If we find a tile in this location
		if(tile != null)
		{
			//Remove the collision box
			if(tile.collisionID != -1)
			{
				var x = col * engine.scene.tileWidth;
				var y = row * engine.scene.tileHeight;
				var key = "ID" + "-" + x + "-" + y + "-" + layerID;
				var a = engine.dynamicTiles.get(key);
				
				if(a != null)
				{
					engine.removeActor(a);
					engine.dynamicTiles.remove(key);
				}
			}
			
			//Remove the tile image
			tlayer.setTileAt(row, col, null);
			
			Engine.engine.tileUpdated = true;
		}
	}
	
	//TODO: For simple physics, we stick in either a box or nothing at all - maybe it autohandles this?
	private static function createDynamicTile(shape:B2Shape, x:Float, y:Float, layerID:Int, width:Float, height:Float)
	{
		var engine = Engine.engine;
		
		var a:Actor = new Actor
		(
			engine, 
			Utils.INT_MAX,
			GameModel.TERRAIN_ID,
			x, 
			y, 
			layerID,
			width, 
			height, 
			null, //sprite
			null, //behavior values
			null, //actor type
			null, //body def
			false, //sensor?
			true, //stationary?
			false, //kinematic?
			false, //rotates?
			shape, //terrain shape
			-1, //typeID?
			false, //is lightweight?
			false //autoscale?
		);
		
		a.name = "Terrain";
		a.visible = false;
		
		engine.moveActorToLayer(a, layerID);

		var key = "ID" + "-" + Engine.toPixelUnits(x) + "-" + Engine.toPixelUnits(y) + "-" + layerID;

		engine.dynamicTiles.set(key, a);     
	}
}