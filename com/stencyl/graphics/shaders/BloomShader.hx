package com.stencyl.graphics.shaders;

//TODO: This isn't that great right now. Find something better.
class BloomShader extends BasicShader
{
	public function new
	(
		currPixelWeight:Float = 0.25,
		neighborPixelWeight:Float = 0.004,
		sampleX:Float = 4,
		sampleY:Float = 3,
		lowThreshold:Float = 0.4,
		mediumThreshold:Float = 0.6,
		lowMultiplier:Float = 0.012,
		mediumMultiplier:Float = 0.009,
		highMultiplier:Float = 0.0075
	)
	{
		super();
		
		#if desktop
		var script = "
			varying vec2 vTexCoord;
			uniform vec2 uResolution;
			uniform sampler2D uImage0;
			
			uniform float currPixelWeight;
			uniform float neighborPixelWeight;
			uniform float sampleX;
			uniform float sampleY;
			uniform float lowThreshold;
			uniform float mediumThreshold;
			uniform float lowMultiplier;
			uniform float mediumMultiplier;
			uniform float highMultiplier;

			void main(void)
			{
				vec4 sum = vec4(0.0);
				vec2 q1 = vTexCoord;
				vec4 oricol = texture2D(uImage0, vec2(q1.x, q1.y));
				vec3 col;
				
				for(int i = -int(sampleX); i < int(sampleX); i++) 
				{
					for(int j = -int(sampleY); j < int(sampleY); j++) 
					{
						sum += texture2D(uImage0, vec2(j, i) * neighborPixelWeight + vec2(q1.x, q1.y)) * currPixelWeight;
					}
			   	}
			 
			  	if(oricol.r < lowThreshold) 
			  	{
					gl_FragColor = sum * sum * lowMultiplier + oricol;
			  	} 
			  
			  	else 
			  	{
					if(oricol.r < mediumThreshold) 
					{
						gl_FragColor = sum * sum * mediumMultiplier + oricol;
				   	} 
				   	
				   	else 
				   	{
						gl_FragColor = sum * sum * highMultiplier + oricol;
				   	}
			   }
			}
		";
		#else
		var script = "
			varying vec2 vTexCoord;
			uniform vec2 uResolution;
			uniform sampler2D uImage0;
			
			uniform float currPixelWeight;
			uniform float neighborPixelWeight;
			uniform float lowThreshold;
			uniform float mediumThreshold;
			uniform float lowMultiplier;
			uniform float mediumMultiplier;
			uniform float highMultiplier;

			void main(void)
			{
				vec4 sum = vec4(0.0);
				vec2 q1 = vTexCoord;
				vec4 oricol = texture2D(uImage0, vec2(q1.x, q1.y));
				vec3 col;
				
				for(int i = -3; i < 3; i++) 
				{
					for(int j = -3; j < 3; j++) 
					{
						sum += texture2D(uImage0, vec2(j, i) * neighborPixelWeight + vec2(q1.x, q1.y)) * currPixelWeight;
					}
			   	}
			 
			  	if(oricol.r < lowThreshold) 
			  	{
					gl_FragColor = sum * sum * lowMultiplier + oricol;
			  	} 
			  
			  	else 
			  	{
					if(oricol.r < mediumThreshold) 
					{
						gl_FragColor = sum * sum * mediumMultiplier + oricol;
				   	} 
				   	
				   	else 
				   	{
						gl_FragColor = sum * sum * highMultiplier + oricol;
				   	}
			   }
			}
		";
		#end
	
		model = new PostProcess(script, true);
		
		setProperty("currPixelWeight", currPixelWeight);
		setProperty("neighborPixelWeight", neighborPixelWeight);
		setProperty("sampleX", sampleX);
		setProperty("sampleY", sampleY);
		setProperty("lowThreshold", lowThreshold);
		setProperty("mediumThreshold", mediumThreshold);
		setProperty("lowMultiplier", lowMultiplier);
		setProperty("mediumMultiplier", mediumMultiplier);
		setProperty("highMultiplier", highMultiplier);
	}
	
	/*public function setAmount(amount:Float)
	{
		setProperty("contrast", amount);
	}*/
}