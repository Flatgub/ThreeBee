function PostFXShader() : TBShader() constructor {
	
	shader = shrRetroPostFX

	ditherMatrixUniform = shader_get_uniform(shader ,"u_fDitherMatrix");
	
	hasPerComponentUniforms = false;
	
	shader_use = function() {	
		shader_set(shader );
		shader_set_uniform_f_array(ditherMatrixUniform, global.__DITHER_MATRIX);
		}

	}