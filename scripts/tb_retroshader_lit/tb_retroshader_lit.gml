function RetroShader_Lit() constructor {
	
	shader = shrRetroLit;
	
	//LIGHTING
	ambientLightColourUniform = shader_get_uniform(shader,"u_vAmbientLightColour")
	lightPosUniform = shader_get_uniform(shader,"u_vLightPosition");
	lightColourUniform = shader_get_uniform(shader,"u_vLightColour");
	lightStrengthUniform =  shader_get_uniform(shader,"u_fLightStrength");
	
	//FOG
	litFogStartUniform = shader_get_uniform(shader,"u_fFogStart");
	litFogEndUniform = shader_get_uniform(shader,"u_fFogEnd");
	litFogColourUniform = shader_get_uniform(shader,"u_vFogColour")
	
	//VERTEX CRUNCH
	geoResolution = 5;
	litGeoResUniform = shader_get_uniform(shader,"u_fGeoResolution")
	
	//DITHERING
	ditherMatrixUniform = shader_get_uniform(shader,"u_fDitherMatrix");
	
	//BLEND
	litBlendUniform = shader_get_uniform(shader,"u_vBlend")
	
	hasPerComponentUniforms = true;
	
	shader_use = function() {
		shader_set(shader);
		
		//Ambient lights
		var ambLight = global.AMBIENT_LIGHT_COLOUR;
		shader_set_uniform_f(ambientLightColourUniform,ambLight[0],ambLight[1],ambLight[2]);
		
		//active lights (up to 8)
		shader_set_uniform_f_array(lightPosUniform,global.CURRENT_CAMERA.activeLightPositions);
		shader_set_uniform_f_array(lightColourUniform,global.CURRENT_CAMERA.activeLightColours);
		shader_set_uniform_f_array(lightStrengthUniform,global.CURRENT_CAMERA.activeLightStrengths);
		
		//FOG
		shader_set_uniform_f(litFogStartUniform,global.FOG_START);
		shader_set_uniform_f(litFogEndUniform,global.FOG_END);
		shader_set_uniform_f_array(litFogColourUniform,global.FOG_COLOUR);
		
		//vertex distortion
		shader_set_uniform_f(litGeoResUniform,geoResolution);
		
		shader_set_uniform_f_array(ditherMatrixUniform, global.__DITHER_MATRIX);
		}
		
	update_uniforms = function(component) {
		var col = component.colour;
		
		var blendb = (col >> 16) & $FF;
		var blendg = (col >> 8) & $FF;
		var blendr = col & $FF;
		
		shader_set_uniform_f(litBlendUniform, blendr/255, blendg/255, blendb/255, component.alpha);
		}
	
	}