package com.stencyl.graphics.transitions;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.display.BitmapData;
import openfl.display.Shape;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Log;

class SlideTransition extends Transition
{
	private var sceneSpr:Sprite;
	private var sceneCol:Shape;
	private var oldBitmap:BitmapData;
	private var newBitmap:BitmapData;
	private var drawBitmap:BitmapData;
	private var graphics:Graphics;
	
	public var oldSceneMatrix:Matrix;
	public var newSceneMatrix:Matrix;
	public var osm_xy:TweenFloat2;
	public var nsm_xy:TweenFloat2;
	private var tx:Float;
	private var ty:Float;
	
	public static var SLIDE_UP:String = "up";
	public static var SLIDE_DOWN:String = "down";
	public static var SLIDE_LEFT:String = "left";
	public static var SLIDE_RIGHT:String = "right";
	
	public var rect:Shape;
	
	public function new(sceneSpr:Sprite, sceneCol:Shape, duration:Float, slideDirection:String) 
	{
		super(duration);
		
		this.sceneSpr = sceneSpr;
		this.sceneCol = sceneCol;
		
		oldSceneMatrix = new Matrix();
		newSceneMatrix = new Matrix();
		tx = 0;
		ty = 0;
			
		if(slideDirection == SLIDE_UP)
		{
			newSceneMatrix.ty = -Engine.screenHeight * Engine.SCALE;
			ty = Engine.screenHeight * Engine.SCALE;
		}
		else if(slideDirection == SLIDE_DOWN)
		{
			newSceneMatrix.ty = Engine.screenHeight * Engine.SCALE;
			ty = -Engine.screenHeight * Engine.SCALE;
		}
		else if(slideDirection == SLIDE_LEFT)
		{
			newSceneMatrix.tx = -Engine.screenWidth * Engine.SCALE;
			tx = Engine.screenWidth * Engine.SCALE;
		}
		else if(slideDirection == SLIDE_RIGHT)
		{
			newSceneMatrix.tx = Engine.screenWidth * Engine.SCALE;
			tx = -Engine.screenWidth * Engine.SCALE;
		}
		else
		{
			Log.error("Invalid slide direction: " + slideDirection);
			complete = true;
		}		
	}
	
	override public function start()
	{
		active = true;
		
		oldBitmap = new BitmapData(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		oldBitmap.draw(sceneCol);
		oldBitmap.draw(sceneSpr);
		
		newBitmap = new BitmapData(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		drawBitmap = new BitmapData(Std.int(Engine.screenWidth * Engine.SCALE), Std.int(Engine.screenHeight * Engine.SCALE));
		
		rect = new Shape();
		graphics = rect.graphics;		
		graphics.beginBitmapFill(oldBitmap);
		graphics.drawRect(0, 0, Engine.screenWidth * Engine.SCALE, Engine.screenHeight * Engine.SCALE);
		graphics.endFill();
		
		Engine.engine.transitionLayer.addChild(rect);
		
		osm_xy = new TweenFloat2();
		nsm_xy = new TweenFloat2();
		osm_xy.tween(oldSceneMatrix.tx, tx, oldSceneMatrix.ty, ty, Easing.linear, Std.int(duration*1000));
		nsm_xy.tween(newSceneMatrix.tx, 0, newSceneMatrix.ty, 0, Easing.linear, Std.int(duration*1000));
		nsm_xy.doOnComplete(stop);
	}
	
	override public function update(elapsedTime:Float)
	{
		oldSceneMatrix.tx = osm_xy.value1;
		oldSceneMatrix.ty = osm_xy.value2;
		newSceneMatrix.tx = nsm_xy.value1;
		newSceneMatrix.ty = nsm_xy.value2;
	}
	
	override public function draw(g:Graphics)	
	{
		graphics.clear();			
		
		newBitmap.draw(sceneCol);
		newBitmap.draw(sceneSpr);
		drawBitmap.draw(newBitmap, newSceneMatrix);
		drawBitmap.draw(oldBitmap, oldSceneMatrix);
		
		graphics.beginBitmapFill(drawBitmap);
		graphics.drawRect(0, 0, Engine.screenWidth * Engine.SCALE, Engine.screenHeight * Engine.SCALE);
		graphics.endFill();
	}
	
	override public function cleanup()
	{
		sceneSpr = null;
		
		if(rect != null)
		{
			Engine.engine.transitionLayer.removeChild(rect);
			rect = null;
		}
	}
	
}