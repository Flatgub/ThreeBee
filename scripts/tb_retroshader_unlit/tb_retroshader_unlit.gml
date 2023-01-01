function RetroShader_Unlit() : TBShader() constructor {
	
	shader = shrRetroUnlit;
	
	// FOG
	unlitFogStartUniform = shader_get_uniform(shader,"u_fFogStart");
	unlitFogEndUniform = shader_get_uniform(shader,"u_fFogEnd");
	unlitFogColourUniform = shader_get_uniform(shader,"u_vFogColour")
	fogStart = 200;
	fogEnd = 400;
	fogColour = [0,0,0];
	
	// VERTEX CRUNCH
	unlitGeoResUniform = shader_get_uniform(shader,"u_fGeoResolution")
	unlitBlendUniform = shader_get_uniform(shader,"u_vBlend")
	
	// DITHERING
	ditherMatrixUniform = shader_get_uniform(shader,"u_fDitherMatrix");
	
	hasPerComponentUniforms = true;
	
	//geoResolution = 10;
	geoResolution = 5;
		
	shader_use = function() {
		shader_set(shader);
		shader_set_uniform_f(unlitFogStartUniform,fogStart);
		shader_set_uniform_f(unlitFogEndUniform,fogEnd);
		shader_set_uniform_f_array(unlitFogColourUniform,fogColour);
		shader_set_uniform_f(unlitGeoResUniform,geoResolution);
		shader_set_uniform_f_array(ditherMatrixUniform, global.__DITHER_MATRIX);
		}
		
	update_uniforms = function(component) {
		var col = component.colour;
		
		var blendb = (col >> 16) & $FF;
		var blendg = (col >> 8) & $FF;
		var blendr = col & $FF;
		
		shader_set_uniform_f(unlitBlendUniform, blendr/255, blendg/255, blendb/255, component.alpha);
		}
	
	}