package com.stencyl.io;

import com.stencyl.models.collision.Hitbox;
import com.stencyl.utils.Utils;

import com.stencyl.io.mbs.actortype.*;
import com.stencyl.io.mbs.actortype.MbsSprite.*;
import com.stencyl.io.mbs.shape.*;
import com.stencyl.models.Resource;
import com.stencyl.models.actor.Sprite;
import com.stencyl.models.actor.Animation;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.B2AABB;
import box2D.common.math.B2Transform;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;

import mbs.core.MbsObject;

class SpriteReader implements AbstractReader
{
	public function new() 
	{
	}		

	public function accepts(type:String):Bool
	{
		return type == MBS_SPRITE.getName();
	}
	
	public function read(obj:Dynamic):Resource
	{
		//trace("Reading Sprite (" + ID + ") - " + name);
		
		var r:MbsSprite = cast obj;
		
		var defaultAnimation = r.getDefaultAnimation();
		var readableImages = r.getReadableImages();
		var animations = new Array<Animation>();
		var sprite = new Sprite(r.getId(), r.getAtlasID(), r.getName(), defaultAnimation, readableImages);
		
		var animList = r.getAnimations();
		for(i in 0...animList.length())
		{
			var animReader = animList.getNextObject();
			var anim = readAnimation(animReader, sprite);
			sprite.animations.set(anim.animID, anim);
		}

		return sprite;
	}
	
	public function readAnimation(r:MbsAnimation, parent:Sprite):Animation
	{
		var animID = r.getId();
		var animName = r.getName();
			
		var imgWidth = r.getWidth();
		var imgHeight = r.getHeight();
		
		var originX:Float = r.getOriginX();
		var originY:Float = r.getOriginY();
		
		var frameCount = r.getNumFrames();
		var framesAcross = r.getAcross();
		var framesDown = r.getDown();
		
		var simpleShapes = readSimpleShapes(r, Std.int(imgWidth/framesAcross), Std.int(imgHeight/framesDown));
		var physicsShapes = readShapes(r, Std.int(imgWidth/framesAcross), Std.int(imgHeight/framesDown));
		var looping = r.getLoop();
		var sync = r.getSync();
		var durations = new Array<Int>();
		var counter = 0;
		
		var s = r.getDurations();
		
		for(counter in 0...s.length())
		{
			//Round to the nearest 10ms - there's no more granularity than this and makes it much easier for me.
			durations[counter] = s.readInt();
			
			durations[counter] = Math.floor(durations[counter] / 10);
			durations[counter] *= 10;
		}

		return new Animation
		(
			animID,
			animName,
			parent, 
			simpleShapes,
			physicsShapes,
			looping, 
			sync,
			imgWidth,
			imgHeight,
			originX,
			originY,
			durations, 
			frameCount,
			framesAcross, 
			framesDown
		);
	}
	
	public function readSimpleShapes(r:MbsAnimation, imgWidth:Float, imgHeight:Float):Map<Int,Dynamic>
	{
		var shapes = new Map<Int,Dynamic>();
		
		var shapeList = r.getShapes();

		for(i in 0...shapeList.length())
		{
			var shape = shapeList.getNextObject();

			var shapeID = shape.getId();
			var groupID = shape.getGroupID();
			var sensor = shape.getSensor();
			
			var shapeData = shape.getShape();
			
			if (Std.is(shapeData, MbsPolygon))
			{
				var polygon:MbsPolygon = cast shapeData;
				var points = polygon.getPoints();
				if(points.length() != 4)
					continue;
				
				var pt = points.getNextObject();
				var vIndex:Int = 0;
				var i:Int = 1;
				var x0:Int = 10000000;
				var y0:Int = 10000000;
				var x1:Int = 0;
				var y1:Int = 0;
				var x:Int = Std.int(pt.getX());
				var y:Int = Std.int(pt.getY());
					
				while(vIndex < points.length())
				{
					x0 = Std.int(Math.min(x0, pt.getX()));
					y0 = Std.int(Math.min(y0, pt.getY()));
					x1 = Std.int(Math.max(x1, pt.getX()));
					y1 = Std.int(Math.max(y1, pt.getY()));

					vIndex++;
					if(vIndex < points.length())
						pt = points.getNextObject();
				}
				
				var w:Int = x1 - x0;
				var h:Int = y1 - y0;			
				
				shapes.set(shapeID, new Hitbox(w, h, x, y, !sensor, groupID));
			}				
		}
		
		return shapes;
	}
	
	public function readShapes(r:MbsAnimation, imgWidth:Int, imgHeight:Int):Map<Int,Dynamic>
	{
		var shapes = new Map<Int,Dynamic>();
		
		//TODO - We should load a custom hitbox instead based on the AABB of the actual shape
		//so that smaller boxes are supported!
						
		var shapeList = r.getShapes();

		for(i in 0...shapeList.length())
		{
			var shapeReader = shapeList.getNextObject();

			var shapeID = shapeReader.getId();
			var groupID = shapeReader.getGroupID();
			var sensor = shapeReader.getSensor();

			var shapeData:MbsObject = cast shapeReader.getShape();
			
			var shape:Dynamic;

			if(Std.is(shapeData, MbsCircle))
			{
				var circle:MbsCircle = cast shapeData;
				shape = ShapeReader.createCircle(circle.getRadius(), circle.getPosition().getX(), circle.getPosition().getY(), imgWidth, imgHeight);
			}
			else
			{
				var polygon:MbsPolygon = cast shapeData;
				shape = ShapeReader.createPolygon(shapeData.getMbsType().getName(), ShapeReader.readPoints(polygon.getPoints()).toArray(), imgWidth, imgHeight);
			}
			
			var fixtureDef = new B2FixtureDef();
			fixtureDef.shape = shape;
			
			fixtureDef.density = shapeReader.getDensity();

			//These have no effect.
			fixtureDef.friction = shapeReader.getFriction();
			fixtureDef.restitution = shapeReader.getRestitution();
			
			fixtureDef.isSensor = sensor;
			fixtureDef.groupID = shapeReader.getGroupID();
			
			shapes.set(shapeID, fixtureDef);
		}
		
		return shapes;
	}
}
