package com.stencyl.graphics.transitions;

import openfl.Vector;
import openfl.display.Graphics;
import openfl.display.GraphicsPathCommand;
import openfl.display.GraphicsPathWinding;
import openfl.display.Shape;

import com.stencyl.Engine;
import com.stencyl.utils.motion.*;

class CircleTransition extends Transition
{
	private static inline var KAPPA:Float = 0.5522847498307936;

	public var color:Int;
	public var radius:TweenFloat;

	private var beginRadius:Int;
	private var endRadius:Int;
	private var s:Shape;
	private var commands:Vector<Int>;
	private var data:Vector<Float>;

	public function new(direction:String, duration:Float, color:Int=0xff000000)
	{
		super(duration);
		this.color = color;
		this.direction = direction;
	}

	override public function start()
	{
		var maxRadius:Int = Std.int(Math.ceil(Math.sqrt(
			Math.pow(Engine.screenWidthHalf * Engine.SCALE, 2) +
			Math.pow(Engine.screenHeightHalf * Engine.SCALE, 2)
		)));

		if(direction == Transition.IN)
		{
			beginRadius = 0;
			endRadius = maxRadius;
		}
		else
		{
			beginRadius = maxRadius;
			endRadius = 0;
		}

		active = true;
		s = new Shape();
		commands = new Vector<Int>();
		data = new Vector<Float>();

		commands.push(GraphicsPathCommand.MOVE_TO);
		commands.push(GraphicsPathCommand.LINE_TO);
		commands.push(GraphicsPathCommand.LINE_TO);
		commands.push(GraphicsPathCommand.LINE_TO);
		commands.push(GraphicsPathCommand.LINE_TO);
		commands.push(GraphicsPathCommand.MOVE_TO);
		commands.push(GraphicsPathCommand.CUBIC_CURVE_TO);
		commands.push(GraphicsPathCommand.CUBIC_CURVE_TO);
		commands.push(GraphicsPathCommand.CUBIC_CURVE_TO);
		commands.push(GraphicsPathCommand.CUBIC_CURVE_TO);
		for(i in 0...36) data.push(0);

		radius = new TweenFloat();
		Engine.engine.transitionLayer.addChild(s);
		radius.tween(beginRadius, endRadius, Easing.linear, Std.int(duration * 1000)).doOnComplete(stop);
	}

	override public function draw(g:Graphics)
	{
		var screenWidth:Float = Engine.screenWidth * Engine.SCALE;
		var screenHeight:Float = Engine.screenHeight * Engine.SCALE;
		var cx:Float = screenWidth / 2;
		var cy:Float = screenHeight / 2;
		var r:Float = radius.value;
		var k:Float = r * KAPPA;

		data[0] = 0; data[1] = 0;
		data[2] = screenWidth; data[3] = 0;
		data[4] = screenWidth; data[5] = screenHeight;
		data[6] = 0; data[7] = screenHeight;
		data[8] = 0; data[9] = 0;

		data[10] = cx + r; data[11] = cy;
		data[12] = cx + r; data[13] = cy + k;
		data[14] = cx + k; data[15] = cy + r;
		data[16] = cx; data[17] = cy + r;
		data[18] = cx - k; data[19] = cy + r;
		data[20] = cx - r; data[21] = cy + k;
		data[22] = cx - r; data[23] = cy;
		data[24] = cx - r; data[25] = cy - k;
		data[26] = cx - k; data[27] = cy - r;
		data[28] = cx; data[29] = cy - r;
		data[30] = cx + k; data[31] = cy - r;
		data[32] = cx + r; data[33] = cy - k;
		data[34] = cx + r; data[35] = cy;

		var graphics = s.graphics;
		graphics.clear();
		graphics.beginFill(color);
		graphics.drawPath(commands, data, GraphicsPathWinding.EVEN_ODD);
		graphics.endFill();
	}

	override public function cleanup()
	{
		radius = null;
		commands = null;
		data = null;

		if(s != null)
		{
			if(s.parent != null) s.parent.removeChild(s);
			s.graphics.clear();
			s = null;
		}
	}
}
