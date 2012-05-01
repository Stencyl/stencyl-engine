package io;

import haxe.xml.Fast;
import utils.Utils;

import models.Resource;
import models.actor.Sprite;
import models.actor.Animation;

class SpriteReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == "sprite";
	}
	
	public function read(ID:Int, type:String, name:String, xml:Fast):Resource
	{
		//trace("Reading Sprite (" + ID + ") - " + name);
		
		var width:Int = Std.parseInt(xml.att.width);
		var height:Int = Std.parseInt(xml.att.height);
		var defaultAnimation:Int = Std.parseInt(xml.att.defaultAnimation);
		
		var animations:Array<Animation> = new Array<Animation>();
		var sprite:Sprite = new Sprite(ID, name, width, height, defaultAnimation);
		
		for(e in xml.elements)
		{
			sprite.animations[Std.parseInt(e.att.id)] = readAnimation(e, sprite);
		}

		return sprite;
	}
	
	public function readAnimation(xml:Fast, parent:Sprite):Animation
	{
		var animID:Int = Std.parseInt(xml.att.id);
		var animName:String = xml.att.name;
			
		var imgWidth:Int = Std.parseInt(xml.att.width);
		var imgHeight:Int = Std.parseInt(xml.att.height);
		
		var originX:Float = Std.parseFloat(xml.att.originx);
		var originY:Float = Std.parseFloat(xml.att.originy);
		
		var framesAcross:Int = Std.parseInt(xml.att.across);
		var framesDown:Int = Std.parseInt(xml.att.down);
		
		var parentID:Int = parent.ID;
		var shapes:Array<Dynamic> = null; //readShapes(xml, imgWidth/framesAcross, imgHeight/framesDown);
		var looping:Bool = Utils.toBoolean(xml.att.loop);
		var imgData:Dynamic = Data.get().resourceAssets.get(parentID + "-" + animID + ".png");
		var durations:Array<Int> = new Array<Int>();
		var counter:Int = 0;
		
		var s:String = xml.att.durations;
		var frames:Array<String> = s.split(",");
		
		for(f in frames)
		{
			//Round to the nearest 10ms - there's no more granularity than this and makes it much easier for me.
			durations[counter] = Std.parseInt(f);
			
			durations[counter] = Math.floor(durations[counter] / 10);
			durations[counter] *= 10;
			
			counter++;
		}

		return new Animation
		(
			animID,
			animName,
			parentID, 
			shapes, 
			looping, 
			imgData,
			imgWidth,
			imgHeight,
			originX,
			originY,
			durations, 
			framesAcross, 
			framesDown
		);
	}
	
	/*public function readShapes(xml:XML, imgWidth:Number, imgHeight:Number):Array
	{
		var shapes:Array = new Array();
		
		for each(var e:XML in xml.children())
		{
			var shapeID:Number = e.@id;
			var groupID:Number = e.@gid;
			
			var shapeType:String = e.name();
			var shapeParams:Array = e.@data.split(",");
			var shape:b2Shape = createShape(shapeType, shapeParams, 0, 0, imgWidth, imgHeight);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = shape;
			
			fixtureDef.density = e.@density;

			//These have no effect.
			fixtureDef.friction = e.@fric;
			fixtureDef.restitution = e.@rest;
			
			fixtureDef.isSensor = Util.toBoolean(e.@sensor);
			fixtureDef.groupID = e.@gid;
			
			shapes[shapeID] = fixtureDef;
		}
		
		return shapes;
	}*/
	
	/*public static function createShape(type:String, params:Array, xOffset:Number=0, yOffset:Number=0, imgWidth:Number=-1, imgHeight:Number=-1):b2Shape
	{
		var x:Number = 0;
		var y:Number = 0;
		var w:Number = 0;
		var h:Number = 0;
		
		if(type == "circle")
		{
			var radius:Number = params[0];
			x = params[1];
			y = params[2];
			
			var diameter:Number = radius * 2;
			
			var c:b2CircleShape = new b2CircleShape();
			c.m_radius = GameState.toPhysicalUnits(radius);
			c.m_p.x = GameState.toPhysicalUnits(x - (imgWidth - diameter)/2);
			c.m_p.y = GameState.toPhysicalUnits(y - (imgHeight - diameter)/2);
			
			return c;
		}
		
		else if(type == "poly" || type == "polyregion")
		{			
			var vertices:Vector.<V2> = new Vector.<V2>();
			
			var numVertices:Number = params[0];
			var vIndex:Number = 0;
			var i:Number = 1;
			
			
			var x0:Number = 0;
			var y0:Number = 0;
			if (type == "polyregion")
			{
				x0 = int.MAX_VALUE;
				y0 = int.MAX_VALUE;
			}
			var x1:Number = 0;
			var y1:Number = 0;
			
			while(vIndex < numVertices)
			{
				x = GameState.toPhysicalUnits(params[i]);
				y = GameState.toPhysicalUnits(params[i + 1]);
				
				x0 = Math.min(x0, params[i]);
				y0 = Math.min(y0, params[i + 1]);
				x1 = Math.max(x1, params[i]);
				y1 = Math.max(y1, params[i + 1]);
				
				vertices[vIndex] = new V2(x, y);
				vIndex++;
				i += 2;
			}
											
			b2PolygonShape.EnsureCorrectVertexDirection(vertices);
							
			w = x1 - x0;
			h = y1 - y0;
			var xDiff:Number = x0 - GameState.toPixelUnits(xOffset);
			var yDiff:Number = y0 - GameState.toPixelUnits(yOffset);

			var hw:int = w/2;
			var hh:int = h/2;

			//Axis-orient the polygon otherwise it rotates around the wrong point.
			var s:b2PolygonShape = new b2PolygonShape();
			s.Set(vertices);

			var aabb:AABB = new AABB();
			var t:XF = new XF();
			t.setIdentity();
			
			s.ComputeAABB(aabb, t); 
						
			//Account for origin and subtract by half the difference.
			if(w < imgWidth)
			{	
				if(type ==  "polyregion") x0 += Math.abs(imgWidth - w) / 2;
				else x0 += GameState.toPhysicalUnits(Math.abs(imgWidth - w) / 2);
			}
			
			if(h < imgHeight)
			{
				if(type == "polyregion") y0 += Math.abs(imgHeight - h) / 2;
				else y0 += GameState.toPhysicalUnits(Math.abs(imgHeight - h) / 2);
			}
			
			//Reconstruct a new polygon that's axis-oriented.
			vIndex = 0;
			i = 1;

			while(vIndex < numVertices)
			{
				if (type == "polyregion")
				{
					var vX:Number = GameState.toPhysicalUnits(params[i] - hw - x0 + xDiff);
					var vY:Number = GameState.toPhysicalUnits(params[i + 1] - hh  - y0 + yDiff);
					vertices[vIndex] = new V2(vX, vY);
				}
				else
				{
					vertices[vIndex] = new V2(GameState.toPhysicalUnits(params[i] - hw) - x0, 
					                      GameState.toPhysicalUnits(params[i + 1] - hh) - y0);
				}						  

				vIndex++;
				i += 2;
			}

			b2PolygonShape.EnsureCorrectVertexDirection(vertices);			

			var p:b2PolygonShape = new b2PolygonShape();
			p.Set(vertices);
			
			return p;
		}
		
		else if(type == "wireframe")
		{
			var polyline:b2LoopShape = new b2LoopShape();
			var vertices:Vector.<V2> = new Vector.<V2>();
			
			var numVertices2:Number = params[0];
			var vIndex2:Number = 0;
			var i2:Number = 1;
			
			while(vIndex2 < numVertices2)
			{
				vertices.push(new V2(GameState.toPhysicalUnits(params[i2]), GameState.toPhysicalUnits(params[i2 + 1])));
				vIndex2++;
				i2 += 2;
			}
			
			w = getWidth(vertices);
			h = getHeight(vertices);
			
			//Now pass through again and shift by a half dimension
			for each(var v:V2 in vertices)
			{
				v.x = v.x + GameState.toPhysicalUnits(xOffset);
				v.y = v.y + GameState.toPhysicalUnits(yOffset);
			}

			polyline.m_vertices = vertices;
			polyline.width = w;
			polyline.height = h;
			
			return polyline;				
		}
		
		return null;
	}
	
	public static function decomposeShape(params:Array):Vector.<b2PolygonShape>
	{
		var vlist:Vector.<Number> = new Vector.<Number>();
		var numVertices:Number = params[0];
		var vIndex:Number = 0;
		var i:Number = 0;
			
		while(vIndex < numVertices)
		{			
			vlist[i] = params[i+1];
		    vlist[i + 1] = params[i + 2];
			vIndex++;
			i += 2;
		}

		var pshapes:Vector.<b2PolygonShape> = b2PolygonShape.Decompose(vlist);
		
		return pshapes;
	}
	
	public static function getWidth(m_vertices:Vector.<V2>):Number
	{
		var minX:Number = int.MAX_VALUE;
		var maxX:Number = 0;
		
		for each(var v:V2 in m_vertices)
		{
			minX = Math.min(minX, v.x);
			maxX = Math.max(maxX, v.x);
		}
		
		return maxX - minX;
	}
	
	public static function getHeight(m_vertices:Vector.<V2>):Number
	{
		var minY:Number = int.MAX_VALUE;
		var maxY:Number = 0;
		
		for each(var v:V2 in m_vertices)
		{
			minY = Math.min(minY, v.y);
			maxY = Math.max(maxY, v.y);
		}
		
		return maxY - minY;
	}*/
}
