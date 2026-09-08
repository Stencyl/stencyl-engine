package com.stencyl.graphics.transitions;

import openfl.geom.Matrix;
import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Bitmap;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Log;

class SlideTransition extends Transition
{
	private var sceneSpr:Sprite;
	private var sceneCol:Shape;
	private var snapshot:TransitionSnapshot;

	private var captureBaseX:Float = 0;
	private var captureBaseY:Float = 0;
	private var rootBaseX:Float = 0;
	private var rootBaseY:Float = 0;
	private var sceneSprBaseX:Float = 0;
	private var sceneSprBaseY:Float = 0;
	private var sceneColBaseX:Float = 0;
	private var sceneColBaseY:Float = 0;

	public var oldSceneMatrix:Matrix;
	public var newSceneMatrix:Matrix;
	public var osm_xy:TweenFloat2;
	public var nsm_xy:TweenFloat2;
	private var tx:Float;
	private var ty:Float;
	private var slideDirection:String;

	public static var SLIDE_UP:String = "up";
	public static var SLIDE_DOWN:String = "down";
	public static var SLIDE_LEFT:String = "left";
	public static var SLIDE_RIGHT:String = "right";

	public var rect:Bitmap;

	public function new(sceneSpr:Sprite, sceneCol:Shape, duration:Float, slideDirection:String)
	{
		super(duration);
		this.sceneSpr = sceneSpr;
		this.sceneCol = sceneCol;
		this.slideDirection = slideDirection;

		oldSceneMatrix = new Matrix();
		newSceneMatrix = new Matrix();
		tx = 0;
		ty = 0;
	}

	override public function memoOldScene()
	{
		snapshot = TransitionSnapshot.capture(sceneSpr, sceneCol);
	}

	override public function start()
	{
		oldSceneMatrix.identity();
		newSceneMatrix.identity();
		tx = 0;
		ty = 0;

		var slideWidth:Float = snapshot.fromBackBuffer ? Engine.stage.stageWidth : Engine.screenWidth * Engine.SCALE;
		var slideHeight:Float = snapshot.fromBackBuffer ? Engine.stage.stageHeight : Engine.screenHeight * Engine.SCALE;

		if(slideDirection == SLIDE_UP)
		{
			newSceneMatrix.ty = -slideHeight;
			ty = slideHeight;
		}
		else if(slideDirection == SLIDE_DOWN)
		{
			newSceneMatrix.ty = slideHeight;
			ty = -slideHeight;
		}
		else if(slideDirection == SLIDE_LEFT)
		{
			newSceneMatrix.tx = -slideWidth;
			tx = slideWidth;
		}
		else if(slideDirection == SLIDE_RIGHT)
		{
			newSceneMatrix.tx = slideWidth;
			tx = -slideWidth;
		}
		else
		{
			Log.error("Invalid slide direction: " + slideDirection);
			complete = true;
			return;
		}

		active = true;
		rect = snapshot.createBitmap();
		captureBaseX = rect.x;
		captureBaseY = rect.y;

		if(snapshot.fromBackBuffer)
		{
			rootBaseX = Engine.engine.root.x;
			rootBaseY = Engine.engine.root.y;
			Engine.engine.root.x = rootBaseX + newSceneMatrix.tx;
			Engine.engine.root.y = rootBaseY + newSceneMatrix.ty;
		}
		else
		{
			sceneSprBaseX = sceneSpr.x;
			sceneSprBaseY = sceneSpr.y;
			sceneColBaseX = sceneCol.x;
			sceneColBaseY = sceneCol.y;
			sceneSpr.x = sceneSprBaseX + newSceneMatrix.tx;
			sceneSpr.y = sceneSprBaseY + newSceneMatrix.ty;
			sceneCol.x = sceneColBaseX + newSceneMatrix.tx;
			sceneCol.y = sceneColBaseY + newSceneMatrix.ty;
		}

		snapshot.addToDisplay(rect);

		osm_xy = new TweenFloat2();
		nsm_xy = new TweenFloat2();
		osm_xy.tween(oldSceneMatrix.tx, tx, oldSceneMatrix.ty, ty, Easing.linear, Std.int(duration * 1000));
		nsm_xy.tween(newSceneMatrix.tx, 0, newSceneMatrix.ty, 0, Easing.linear, Std.int(duration * 1000));
		nsm_xy.doOnComplete(stop);
	}

	override public function update(elapsedTime:Float)
	{
		if(osm_xy == null || nsm_xy == null) return;

		oldSceneMatrix.tx = osm_xy.value1;
		oldSceneMatrix.ty = osm_xy.value2;
		newSceneMatrix.tx = nsm_xy.value1;
		newSceneMatrix.ty = nsm_xy.value2;

		if(rect != null)
		{
			rect.x = captureBaseX + oldSceneMatrix.tx;
			rect.y = captureBaseY + oldSceneMatrix.ty;
		}

		if(snapshot.fromBackBuffer)
		{
			Engine.engine.root.x = rootBaseX + newSceneMatrix.tx;
			Engine.engine.root.y = rootBaseY + newSceneMatrix.ty;
		}
		else
		{
			sceneSpr.x = sceneSprBaseX + newSceneMatrix.tx;
			sceneSpr.y = sceneSprBaseY + newSceneMatrix.ty;
			sceneCol.x = sceneColBaseX + newSceneMatrix.tx;
			sceneCol.y = sceneColBaseY + newSceneMatrix.ty;
		}
	}

	override public function draw(g:Graphics) {}

	override public function cleanup()
	{
		if(snapshot != null && snapshot.fromBackBuffer)
		{
			Engine.engine.root.x = rootBaseX;
			Engine.engine.root.y = rootBaseY;
		}
		else if(sceneSpr != null && sceneCol != null)
		{
			sceneSpr.x = sceneSprBaseX;
			sceneSpr.y = sceneSprBaseY;
			sceneCol.x = sceneColBaseX;
			sceneCol.y = sceneColBaseY;
		}

		if(rect != null)
		{
			if(rect.parent != null) rect.parent.removeChild(rect);
			rect.bitmapData = null;
			rect = null;
		}

		if(snapshot != null)
		{
			snapshot.dispose();
			snapshot = null;
		}

		osm_xy = null;
		nsm_xy = null;
		sceneSpr = null;
		sceneCol = null;
	}
}
