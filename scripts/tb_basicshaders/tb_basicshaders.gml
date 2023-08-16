var dt = [];
dt[0]  =  1.0/16.0; dt[1]  =  9.0/16.0; dt[2]  =  3.0/16.0; dt[3]  = 11.0/16.0;
dt[4]  = 13.0/16.0; dt[5]  =  5.0/16.0; dt[6]  = 15.0/16.0; dt[7]  =  7.0/16.0;
dt[8]  =  4.0/16.0; dt[9]  = 12.0/16.0; dt[10] =  2.0/16.0; dt[11] = 10.0/16.0;
dt[12] = 16.0/16.0; dt[13] =  8.0/16.0; dt[14] = 14.0/16.0; dt[15] =  6.0/16.0;
	
global.__DITHER_MATRIX = dt;

function BasicShader() : TBShader() constructor {
	
	fogStartUniform = shader_get_uniform(shrBasic,"u_fFogStart");
	fogEndUniform = shader_get_uniform(shrBasic,"u_fFogEnd");
	fogColourUniform = shader_get_uniform(shrBasic,"u_vFogColour")
	ditherMatrixUniform = shader_get_uniform(shrBasic,"u_fDitherMatrix");
	blendUniform = shader_get_uniform(shrBasic,"u_vBlend");
	
	fogStart = 200;
	fogEnd = 400;
	fogColour = [0,0,0];
		
	hasPerComponentUniforms = true;
	
	shader_use = function() {	
		shader_set(shrBasic);
		shader_set_uniform_f(fogStartUniform,fogStart);
		shader_set_uniform_f(fogEndUniform,fogEnd);
		shader_set_uniform_f(blendUniform, 1, 1, 1, 1);
		shader_set_uniform_f_array(fogColourUniform,fogColour);
		shader_set_uniform_f_array(ditherMatrixUniform, global.__DITHER_MATRIX);
		}
	
	update_uniforms = function(component) {
		var col = component.colour;
		
		var blendb = (col >> 16) & $FF;
		var blendg = (col >> 8) & $FF;
		var blendr = col & $FF;
		
		shader_set_uniform_f(blendUniform, blendr/255, blendg/255, blendb/255, component.alpha);
		}
	
	}
	
function BasicShaderBillboard() : TBShader() constructor {
	
	unlitFogStartUniform = shader_get_uniform(shrBasicBillboard,"u_fFogStart");
	unlitFogEndUniform = shader_get_uniform(shrBasicBillboard,"u_fFogEnd");
	unlitFogColourUniform = shader_get_uniform(shrBasicBillboard,"u_vFogColour")
	
	hasPerComponentUniforms = false;
	
	shader_use = function() {
		shader_set(shrBasicBillboard);
		shader_set_uniform_f(unlitFogStartUniform,global.FOG_START);
		shader_set_uniform_f(unlitFogEndUniform,global.FOG_END);
		shader_set_uniform_f_array(unlitFogColourUniform,global.FOG_COLOUR);
		}
	
	}
