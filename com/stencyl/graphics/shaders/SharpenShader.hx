package com.stencyl.graphics.shaders;

class SharpenShader extends BasicShader
{
	public function new(amount:Float = 2.0)
	{
		super();
		
		var script = "
			varying vec2 vTexCoord;
			uniform sampler2D uImage0;
			uniform vec2 uResolution;
			
			uniform float amount;
			
			void main()
			{
				//this will be our RGBA sum
				vec4 sum = vec4(0.0);
				
				//our original texcoord for this fragment
				vec2 tc = vTexCoord;
				
				float reach = 1.0 / uResolution.x;

				//current pixel
				sum += texture2D(uImage0, vec2(tc.x, tc.y));
				
				//sharpen
				sum += (texture2D(uImage0, vec2(tc.x, tc.y)) - texture2D(uImage0, vec2(tc.x + 1.0 * reach, tc.y))) * amount;
				sum += (texture2D(uImage0, vec2(tc.x, tc.y)) - texture2D(uImage0, vec2(tc.x - 1.0 * reach, tc.y))) * amount;
				sum += (texture2D(uImage0, vec2(tc.x, tc.y)) - texture2D(uImage0, vec2(tc.x, tc.y + 1.0 * reach))) * amount;
				sum += (texture2D(uImage0, vec2(tc.x, tc.y)) - texture2D(uImage0, vec2(tc.x, tc.y - 1.0 * reach))) * amount;
				
				gl_FragColor = vec4(sum.rgb, 1.0);
			}
		";
	
		model = new PostProcess(script, true);
		
		setAmount(amount);
	}
	
	public function setAmount(amount:Float)
	{
		setProperty("amount", amount);
	}
}