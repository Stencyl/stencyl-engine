package com.stencyl.graphics.shaders;

class InlineShader extends BasicShader
{
	public function new(script:String)
	{
		super();
		model = new PostProcess(this, script, true);
	}
}