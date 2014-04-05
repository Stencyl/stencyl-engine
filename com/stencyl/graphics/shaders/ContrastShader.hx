package com.stencyl.graphics.shaders;

class ContrastShader extends BasicShader
{
	public function new(amount:Float = 1.0)
	{
		super();
		
		var script = "
			varying vec2 vTexCoord;
			uniform sampler2D uImage0;
			uniform float contrast;

			void main() 
			{
				vec3 color = texture2D(uImage0, vTexCoord).rgb;
				const vec3 luminanceCoefficient = vec3(0.2125, 0.7154, 0.0721);
		
				vec3 avgLuminance = vec3(0.5, 0.5, 0.5);
		
				vec3 intensity = vec3(dot(color, luminanceCoefficient));
		
				// could substitute a uniform for this 1. and have variable saturation
				vec3 satColor = mix(intensity, color, 1.0);
				vec3 conColor = mix(avgLuminance, satColor, contrast);
		
				gl_FragColor = vec4(conColor, 1);
			}
			
			vec3 mix(vec3 a, vec3 b, float amount) 
			{ 
				return vec3(a.x * (1.0 - amount) + b.x * amount, a.y * (1.0 - amount) + b.y * amount, a.z * (1.0 - amount) + b.z * amount); 
			}
		";
	
		model = new PostProcess(script, true);
		
		setAmount(amount);
	}
	
	public function setAmount(amount:Float)
	{
		setProperty("contrast", amount);
	}
}