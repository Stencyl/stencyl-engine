package com.stencyl.graphics.shaders;

import com.stencyl.Engine;

class BasicShader
{
	public var model:PostProcess;
	
	public function new()
	{
	}
	
	public function setProperty(name:String, value:Float)
	{
		model.setUniform(name, value);
	}
	
	public function tweenProperty(name:String, targetValue:Float, duration:Float = 1, easing:Dynamic = null)
	{
		//TODO - How to pull this off?
	}
	
	public function enable()
	{
		Engine.engine.clearShaders();
		Engine.engine.addShader(model);
	}
	
	public function disable()
	{
		Engine.engine.clearShaders();
	}
}