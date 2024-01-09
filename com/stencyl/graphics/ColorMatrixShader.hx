package com.stencyl.graphics;

import openfl.display.Shader;

#if !flash

class ColorMatrixShader extends Shader
{
	@:glFragmentSource(
	
		"varying float openfl_Alphav;
		varying vec2 openfl_TextureCoordv;
		uniform sampler2D openfl_Texture;
		
		uniform mat4 uMultipliers;
		uniform vec4 uOffsets;
		
		void main(void)
		{
			vec4 color = texture2D(openfl_Texture, openfl_TextureCoordv);
			
			if(color.a == 0.0)
			{
				gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
			}
			else
			{
				color = vec4(color.rgb / color.a, color.a);
				color = uOffsets + color * uMultipliers;
				
				gl_FragColor = vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
		}"
		
	)
	
	@:glVertexSource(
		
		"attribute float openfl_Alpha;
		attribute vec4 openfl_ColorMultiplier;
		attribute vec4 openfl_ColorOffset;
		attribute vec4 openfl_Position;
		attribute vec2 openfl_TextureCoord;
		varying float openfl_Alphav;
		varying vec2 openfl_TextureCoordv;
		
		uniform mat4 openfl_Matrix;
		uniform bool openfl_HasColorTransform;
		
		void main(void) {
			
			openfl_Alphav = openfl_Alpha;
			openfl_TextureCoordv = openfl_TextureCoord;
			
			gl_Position = openfl_Matrix * openfl_Position;
			
		}"
		
	)
	
	public function new()
	{
		super();
	}
	
	public function init(matrix:Array<Float> = null):Void
	{
		if(matrix == null || uMultipliers.value == null)
		{
			uMultipliers.value = [ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ];
			uOffsets.value = [ 0, 0, 0, 0 ];
		}
		
		if(matrix == null)
		{
			return;
		}
		
		var multipliers = uMultipliers.value;
		var offsets = uOffsets.value;
		
		multipliers[0] = matrix[0];
		multipliers[1] = matrix[1];
		multipliers[2] = matrix[2];
		multipliers[3] = matrix[3];
		multipliers[4] = matrix[5];
		multipliers[5] = matrix[6];
		multipliers[6] = matrix[7];
		multipliers[7] = matrix[8];
		multipliers[8] = matrix[10];
		multipliers[9] = matrix[11];
		multipliers[10] = matrix[12];
		multipliers[11] = matrix[13];
		multipliers[12] = matrix[15];
		multipliers[13] = matrix[16];
		multipliers[14] = matrix[17];
		multipliers[15] = matrix[18];
		
		offsets[0] = matrix[4] / 255.0;
		offsets[1] = matrix[9] / 255.0;
		offsets[2] = matrix[14] / 255.0;
		offsets[3] = matrix[19] / 255.0;
	}
}
#end
