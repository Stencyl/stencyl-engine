package com.stencyl.graphics.shaders;

class ExternalShader extends BasicShader
{
	public function new(scriptPath:String)
	{
		super();
		scriptPath = "assets/data/" + scriptPath;
		model = new PostProcess(scriptPath);
	}
}