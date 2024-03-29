function RetroShader_Lit() : TBShader() constructor {
	
	shader = shrRetroLit;
	
	// LIGHTING
	ambientLightColourUniform = shader_get_uniform(shader,"u_vAmbientLightColour")
	lightPosUniform = shader_get_uniform(shader,"u_vLightPosition");
	lightColourUniform = shader_get_uniform(shader,"u_vLightColour");
	lightStrengthUniform =  shader_get_uniform(shader,"u_fLightStrength");
	lightRadiusMultiplierUniform =  shader_get_uniform(shader,"u_fLightRadiusMultiplier");
	lightMixUniform =  shader_get_uniform(shader,"u_fLightMix");

	desaturation = 0;
	
	// FOG
	litFogStartUniform = shader_get_uniform(shader,"u_fFogStart");
	litFogEndUniform = shader_get_uniform(shader,"u_fFogEnd");
	litFogColourUniform = shader_get_uniform(shader,"u_vFogColour")
	fogStart = 200;
	fogEnd = 400;
	fogColour = [0,0,0];
	
	// VERTEX CRUNCH
	geoResolution = 10;
	litGeoResUniform = shader_get_uniform(shader,"u_fGeoResolution")
	
	// DITHERING
	ditherMatrixUniform = shader_get_uniform(shader,"u_fDitherMatrix");
	
	// BLEND
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
		shader_set_uniform_f_array(lightRadiusMultiplierUniform,global.CURRENT_CAMERA.activeLightRadiusModifiers);
		
		//FOG
		shader_set_uniform_f(litFogStartUniform,fogStart);
		shader_set_uniform_f(litFogEndUniform,fogEnd);
		shader_set_uniform_f_array(litFogColourUniform,fogColour);
		
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
		shader_set_uniform_f(lightMixUniform, component.lightMix);
		}
	
	}
