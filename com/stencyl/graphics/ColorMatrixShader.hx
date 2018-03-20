package com.stencyl.graphics;

import openfl.display.DisplayObjectShader;

class ColorMatrixShader extends DisplayObjectShader
{
	@:glFragmentSource(
	
		"varying float vAlpha;
		varying vec2 openfl_vTexCoord;
		uniform sampler2D texture0;
		
		uniform mat4 uMultipliers;
		uniform vec4 uOffsets;
		
		void main(void)
		{
			vec4 color = texture2D(texture0, openfl_vTexCoord);
			
			if(color.a == 0.0)
			{
				gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
			}
			else
			{
				color = vec4(color.rgb / color.a, color.a);
				color = uOffsets + color * uMultipliers;
				
				gl_FragColor = vec4(color.rgb * color.a * vAlpha, color.a * vAlpha);
			}
		}"
		
	)
	
	@:glVertexSource(
		
		"attribute float alpha;
		attribute vec4 colorMultipliers;
		attribute vec4 colorOffsets;
		attribute vec4 openfl_Position;
		attribute vec2 openfl_TexCoord;
		varying float vAlpha;
		varying vec2 openfl_vTexCoord;
		
		uniform mat4 openfl_Matrix;
		uniform bool openfl_HasColorTransform;
		
		void main(void) {
			
			vAlpha = alpha;
			openfl_vTexCoord = openfl_TexCoord;
			
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