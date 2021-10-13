/// @function OBJA_ArmatureRenderComponent(parent, armature_instance)
function OBJA_ArmatureRenderComponent(_p, _arm) : RenderComponent(_p,false,false) constructor {
	armature = _arm
	referenceArmature = armature.reference;
	
	totalBindings = array_length(referenceArmature.meshBindings)
	relevantMeshes = {}
	
	//collect all the meshes we need for rendering
	for(var i = 0; i < totalBindings; i++) {
		var pair = referenceArmature.meshBindings[i];
		if(!variable_struct_exists(relevantMeshes,pair.meshname)) {
			var model = global.LOADED_MODELS[? pair.meshname];
			if(model == undefined) {show_error("failed to find mesh '" + pair.meshname + "'",true)}
			relevantMeshes[$ pair.meshname] = model;
			}
		}
	
	render = method(self, function() {
		//perhaps don't do this every render call? only when the frame changes?
		armature.update_animation_sample()
		var sample = armature.currentAnimationSample;
		
		var pair, model, sampledq, finaldq, finalmat;
		var finaldq = [0,0,0,1,0,0,0,0]
		
		//submit the models for each binding at their respective locations
		for(var i = 0; i < totalBindings; i++) {
			pair = referenceArmature.meshBindings[i];
			model = relevantMeshes[$ pair.meshname];
			sampledq = sample.cachedBones[pair.bone.boneid];
			finaldq = dq_multiply(sampledq, pair.boneToMeshDQ, finaldq)
			finalmat = matrix_multiply(dq_to_matrix(finaldq), renderMatrix)
			
			matrix_set(matrix_world,finalmat);
			model.submit(pr_trianglelist, model.texture)
			//vertex_submit(model.vertexBuffer,pr_trianglelist,model.texture);
			}
			
		});
		
	customRenderFunction = render;
}
	
/// @function OBJA_SkeletonRenderComponent(parent, armature)
function OBJA_SkeletonRenderComponent(_p, _arm) : RenderComponent(_p,false,false) constructor {
	armature = _arm
		
	renderMode = pr_linelist;
	renderTexture = -1;
	ignoreDepth = true;	
	
	render = method(self, function() {
		var sample = armature.currentAnimationSample;
		
		//render each bone using the cached locations
		for(var i = 0; i < array_length(armature.reference.allBones); i++) {
			var bone = armature.reference.allBones[i];
			var sampleDQ = sample.cachedBones[bone.boneid];
			var mat = matrix_multiply(dq_to_matrix(sampleDQ), renderMatrix);
			bone.render(mat);
			}
		});
		
	customRenderFunction = render;

		
	static renderLabels = function() {
		var sample = armature.currentAnimationSample;
		for(var i = 0; i < array_length(armature.reference.allBones); i++) {
			var bone = armature.reference.allBones[i];
			var sampleDQ = sample.cachedBones[bone.boneid];
			var mat = matrix_multiply(dq_to_matrix(sampleDQ), renderMatrix);
			var bonepoint = matrix_transform_vertex(mat,0,0,0)
			var screenpoint = camera_point_to_screenspace(global.MAIN_CAMERA,bonepoint)
			if(bone == oAnimationDemonstration.selectedBone) {continue;}
			if(screenpoint != undefined) {
				var pX = screenpoint[0];	
				var pY = screenpoint[1];	
			
				//var dq = bone.poseDQ;
				var bname = bone.name;
				draw_set_valign(fa_middle)
				draw_set_colour(c_black)
				draw_text(pX+15,pY,bname)
				draw_text(pX+17,pY,bname)
				draw_text(pX+16,pY+1,bname)
				draw_text(pX+16,pY-1,bname)
				draw_set_colour(c_white)
				draw_text(pX+16,pY,bname)
				draw_set_valign(fa_top)
				}
			}
		draw_set_valign(fa_top)

		}
}