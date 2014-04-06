package com.stencyl.graphics.shaders;

import com.stencyl.utils.Utils;

class TintShader extends BasicShader
{
	public function new(color:Int, amount:Float = 1.0)
	{
		super();
		
		var script = "
			varying vec2 vTexCoord;
			uniform sampler2D uImage0;
			uniform float amount;
			uniform float red;
			uniform float green;
			uniform float blue;

			void main() 
			{
				vec3 color = texture2D(uImage0, vTexCoord).rgb;
				vec3 endColor = mix(color, vec3(red, green, blue), amount);
				gl_FragColor = vec4(endColor.x, endColor.y, endColor.z, 1);
			}
			
			vec3 mix(vec3 a, vec3 b, float amount) 
			{ 
				return vec3(a.x * (1.0 - amount) + b.x * amount, a.y * (1.0 - amount) + b.y * amount, a.z * (1.0 - amount) + b.z * amount); 
			}
		";
	
		model = new PostProcess(script, true);
		
		setColor(color);
		setAmount(amount);
	}
	
	public function setAmount(amount:Float)
	{
		setProperty("amount", amount);
	}
	
	public function setColor(color:Int)
	{
		setProperty("red", Utils.getRed(color)/255.0);
		setProperty("green", Utils.getGreen(color)/255.0);
		setProperty("blue", Utils.getBlue(color)/255.0);
	}
}