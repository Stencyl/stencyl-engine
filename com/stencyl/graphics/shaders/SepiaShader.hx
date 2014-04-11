package com.stencyl.graphics.shaders;

class SepiaShader extends BasicShader
{
	public function new()
	{
		super();
	
		var script = "
			#ifdef GL_ES
				precision mediump float;
			#endif
			
			varying vec2 vTexCoord;
			uniform sampler2D uImage0;
			
			void main(void)
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				gl_FragColor.r = dot(color, vec4(0.393,0.769,0.189,0));
				gl_FragColor.g = dot(color, vec4(0.349,0.686,0.168,0));
				gl_FragColor.b = dot(color, vec4(0.272,0.534,0.131,0));
				gl_FragColor.a = color.a;
			}
		";
	
		model = new PostProcess(script, true);
	}
}