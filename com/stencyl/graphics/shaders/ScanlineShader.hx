package com.stencyl.graphics.shaders;

class ScanlineShader extends BasicShader
{
	public function new(scale:Float = 1.0)
	{
		super();
		
		var script = "
			#ifdef GL_ES
				precision mediump float;
			#endif
			
			varying vec2 vTexCoord;
			uniform vec2 uResolution;
			uniform sampler2D uImage0;
			
			uniform float scale;
			
			void main()
			{
				if (mod(floor(vTexCoord.y * uResolution.y / scale), 2.0) == 0.0)
					gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
				else
					gl_FragColor = texture2D(uImage0, vTexCoord);
			}
		";
	
		model = new PostProcess(script, true);
		
		setScale(scale);
	}
	
	public function setScale(amount:Float)
	{
		setProperty("scale", amount);
	}
}