package com.stencyl.graphics;

import com.stencyl.utils.Log;

import haxe.io.Bytes;

import lime.graphics.Image;
import lime.graphics.opengl.GLTexture;
import lime.utils.UInt8Array;

import openfl.display.BitmapData;
import openfl.display.Tileset;
import openfl.display3D.textures.TextureBase;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.Vector;

@:access(openfl.display.BitmapData)
@:access(openfl.display.Tileset)
@:access(openfl.display3D.textures.TextureBase)

class TilesetUtils
{
	public static function getSubFrame(tileset:Tileset, frameId:Int, x:Int, y:Int, width:Int, height:Int):Int
	{
		var frameRect = tileset.getRect(frameId);
		var innerRect = new Rectangle(frameRect.x + x, frameRect.y + y, width, height);
		var existingInnerRectId = tileset.getRectID(innerRect);
		if(existingInnerRectId != null)
			return existingInnerRectId;
		return tileset.addRect(innerRect);
	}
	
	public static function updateFrameData(tileset:Tileset, frameId:Int, frameData:Image):Void
	{
		var gl = GLUtil.gl;
		var internalFormat = TextureBase.__textureInternalFormat;
		var format = TextureBase.__textureFormat;

		var textureBase = tileset.bitmapData.__texture;
		if(textureBase == null)
			textureBase = tileset.bitmapData.getTexture(GLUtil.context3D);
		var textureID = textureBase.__textureID;
		
		gl.bindTexture (gl.TEXTURE_2D, textureID);
		
		var r = tileset.getRect(frameId);
		
		gl.texSubImage2D(gl.TEXTURE_2D, 0, Std.int(r.x), Std.int(r.y), Std.int(r.width), Std.int(r.height), format, gl.UNSIGNED_BYTE, frameData.data);
	}
}