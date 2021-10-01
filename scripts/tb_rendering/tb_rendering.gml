function render_scene() {

	var transparent = ds_priority_create();
	var depthignore = ds_list_create();

	global.CURRENT_CAMERA = ds_map_find_value(global.VIEW_CAMERA_MAP,view_current);
	
	camera_ready(global.CURRENT_CAMERA);

	//activate the provided shader if the camera has one
	var cameraShader = global.CURRENT_CAMERA.cameraShader;
	if(cameraShader != undefined) {cameraShader.shader_use();}

	gpu_set_cullmode(CULL_DIRECTION)
	gpu_set_zwriteenable(true)
	gpu_set_ztestenable(true)

	#region render statics
	for(var i = 0; i < ds_list_size(global.STATIC_RENDER_REQUESTS); i++) {
		var rendComp = global.STATIC_RENDER_REQUESTS[| i];
		if rendComp.isTransparent {ds_priority_add(transparent,rendComp,rendComp.renderDepth); continue;} //dont render transparent things
		
		if(rendComp.dontRender) {continue;}
		
		if(rendComp.ignoreDepth) {
			ds_list_add(depthignore,rendComp);
			continue;
			}
		
		//reject objects that match an ignore flag with the camera
		if(global.CURRENT_CAMERA.ignoreFlags & rendComp.ignoreFlags != 0) {continue;}	
		
		// UPDATE THE SHADER
		
		var currentShader = cameraShader;
		//component shader overrides camera shader
		if(rendComp.customShader != undefined) {currentShader = rendComp.customShader;}
			
		//allow disabling the shader
		if(currentShader == NO_SHADER) {shader_reset();}
		else if(currentShader != undefined) {
			//apply the shader if it isn't the camera shader
			if(currentShader != cameraShader) {currentShader.shader_use();}
			//update the shader if it wants an update;
			if(currentShader.hasPerComponentUniforms) {currentShader.update_uniforms(rendComp);}
			}
			
		//use a custom render functioo if necesary
		if(rendComp.customRenderFunction == undefined) {
			vertex_submit(rendComp.renderBuffer,rendComp.renderMode,rendComp.renderTexture);
			}
		else {
			rendComp.customRenderFunction();
			}
		
		//reapply the camera shader if we had to swap;
		if(currentShader != cameraShader && cameraShader != undefined) {cameraShader.shader_use();}
		
		}
	#endregion
	
	#region render dynamics
	for(var i = 0; i < ds_list_size(global.DYNAMIC_RENDER_REQUESTS); i++) {
		var rendComp = global.DYNAMIC_RENDER_REQUESTS[| i];
	
		if(rendComp.dontRender) {continue;}
	
		if(rendComp.ignoreDepth) {
			ds_list_add(depthignore,rendComp);
			continue;
			}
	
		//reject objects that match an ignore flag with the camera
		if(global.CURRENT_CAMERA.ignoreFlags & rendComp.ignoreFlags != 0) {continue;}
	
		//dont render transparent things in this pass
		if rendComp.isTransparent {
			ds_priority_add(transparent,rendComp,rendComp.renderDepth);
			continue;
			} 
			
		// UPDATE THE SHADER
		
		var currentShader = cameraShader;
		//component shader overrides camera shader
		if(rendComp.customShader != undefined) {currentShader = rendComp.customShader;}
			
		//allow disabling the shader
		if(currentShader == NO_SHADER) {shader_reset();}
		else if(currentShader != undefined) {
			//apply the shader if it isn't the camera shader
			if(currentShader != cameraShader) {currentShader.shader_use();}
			//update the shader if it wants an update;
			if(currentShader.hasPerComponentUniforms) {currentShader.update_uniforms(rendComp);}
			}
		
		//use a custom render function if necessary
		if(rendComp.customRenderFunction == undefined) {
			matrix_set(matrix_world,rendComp.renderMatrix);
			vertex_submit(rendComp.renderBuffer,rendComp.renderMode,rendComp.renderTexture);
			}
		else {
			rendComp.customRenderFunction();
			}		
	
		//reapply the camera shader if we had to swap;
		if(currentShader != cameraShader && cameraShader != undefined) {cameraShader.shader_use();}
		
		
		}
#endregion
	
	gpu_set_zwriteenable(false)

	matrix_set(matrix_world,global.DEFAULT_MATRIX);

	#region render all transparent
	while(!ds_priority_empty(transparent)) {
	
		var rendComp = ds_priority_delete_max(transparent);
		
		//ds_list_add(depthlist,rendComp,rendComp.renderDepth);
		
		// UPDATE THE SHADER
		
		var currentShader = cameraShader;
		//component shader overrides camera shader
		if(rendComp.customShader != undefined) {currentShader = rendComp.customShader;}
			
		//allow disabling the shader
		if(currentShader == NO_SHADER) {shader_reset();}
		else if(currentShader != undefined) {
			//apply the shader if it isn't the camera shader
			if(currentShader != cameraShader) {currentShader.shader_use();}
			//update the shader if it wants an update;
			if(currentShader.hasPerComponentUniforms) {currentShader.update_uniforms(rendComp);}
			}
			
		
		if(rendComp.customRenderFunction == undefined) {
			if rendComp.isStatic {matrix_set(matrix_world,global.DEFAULT_MATRIX)} //statics rely on the default matrix
			else {matrix_set(matrix_world,rendComp.renderMatrix);}
			}
		else {
			rendComp.customRenderFunction();
			}
				
		vertex_submit(rendComp.renderBuffer,rendComp.renderMode,rendComp.renderTexture);
		
		//reapply the camera shader if we had to swap;
		if(currentShader != cameraShader && cameraShader != undefined) {cameraShader.shader_use();}
		}
	#endregion

	

	#region render all depthignore
	gpu_set_zwriteenable(true)
	gpu_set_ztestenable(false)
	for(var i = 0; i < ds_list_size(depthignore); i++) {
		var rendComp = depthignore[| i];
		
		// UPDATE THE SHADER
		
		var currentShader = cameraShader;
		//component shader overrides camera shader
		if(rendComp.customShader != undefined) {currentShader = rendComp.customShader;}
			
		//allow disabling the shader
		if(currentShader == NO_SHADER) {shader_reset();}
		else if(currentShader != undefined) {
			//apply the shader if it isn't the camera shader
			if(currentShader != cameraShader) {currentShader.shader_use();}
			//update the shader if it wants an update;
			if(currentShader.hasPerComponentUniforms) {currentShader.update_uniforms(rendComp);}
			}
		
		//use a custom render function if necessary
		if(rendComp.customRenderFunction == undefined) {
			matrix_set(matrix_world,rendComp.renderMatrix);
			vertex_submit(rendComp.renderBuffer,rendComp.renderMode,rendComp.renderTexture);
			}
		else {
			rendComp.customRenderFunction();
			}	
			
		//reapply the camera shader if we had to swap;
		if(currentShader != cameraShader && cameraShader != undefined) {cameraShader.shader_use();}
	}
	ds_list_destroy(depthignore);
	#endregion

	gpu_set_ztestenable(true)
	

	shader_reset();

	ds_priority_destroy(transparent)

	matrix_set(matrix_world,matrix_build_identity());

	gpu_set_cullmode(cull_noculling)

	
	//printf("total number of swaps: %s",global.swaps);


}