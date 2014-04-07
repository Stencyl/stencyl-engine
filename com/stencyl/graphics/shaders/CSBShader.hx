package com.stencyl.graphics.shaders;

class CSBShader extends BasicShader
{
	//Helper function for blocks
	public static function create(type:String = "contrast", amount:Float = 1.0):CSBShader
	{
		if(type == "contrast")
		{
			return new CSBShader(amount, 1.0, 1.0);
		}
		
		else if(type == "saturation")
		{
			return new CSBShader(1.0, 1.0, amount);
		}
		
		return new CSBShader(1.0, amount, 1.0);
	}

	public function new(contrast:Float = 1.0, brightness:Float = 1.0, saturation:Float = 1.0)
	{
		super();
		
		var script = "
			varying vec2 vTexCoord;
			uniform sampler2D uImage0;
			uniform float contrast;
			uniform float brightness;
			uniform float saturation;

			void main() 
			{
				vec3 color = texture2D(uImage0, vTexCoord).rgb;
				const vec3 luminanceCoefficient = vec3(0.2125, 0.7154, 0.0721);
				vec3 avgLuminance = vec3(0.5, 0.5, 0.5);
		
				vec3 brtColor = vec3(color.x * brightness, color.y * brightness, color.z * brightness);
				vec3 intensity = vec3(dot(brtColor, luminanceCoefficient));
				vec3 satColor = mix(intensity, brtColor, saturation);
				vec3 conColor = mix(avgLuminance, satColor, contrast);
		
				gl_FragColor = vec4(conColor, 1);
			}
			
			vec3 mix(vec3 a, vec3 b, float amount) 
			{ 
				return vec3(a.x * (1.0 - amount) + b.x * amount, a.y * (1.0 - amount) + b.y * amount, a.z * (1.0 - amount) + b.z * amount); 
			}
		";
	
		model = new PostProcess(script, true);
		
		setContrast(contrast);
		setBrightness(brightness);
		setSaturation(saturation);
	}
	
	public function setContrast(amount:Float)
	{
		setProperty("contrast", amount);
	}
	
	public function setBrightness(amount:Float)
	{
		setProperty("brightness", amount);
	}
	
	public function setSaturation(amount:Float)
	{
		setProperty("saturation", amount);
	}
}