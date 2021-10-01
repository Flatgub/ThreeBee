function __get_all_armature_templates() {
	static all_armatures = ds_list_create();
	return all_armatures;
	}

function OBJA_Armature_Template() constructor{
	name = "";
	allBones = []
	rootBone = undefined;
	
	meshBindings = [];
	
	animationLibrary = {};
		
	/// @function add_bone(bone)
	static add_bone = function(_bone) {
		allBones[@ _bone.boneid] = _bone
		}
		
	/// @function add_mesh_binding(meshname, boneid, translation, rotationaxis, rotationangle)
	static add_mesh_binding = function(_meshname, _boneid, _translation, _rotationAxis, _rotationAngle) {
		var binding = new OBJA_MeshBinding(_meshname,allBones[_boneid],_translation, _rotationAxis, _rotationAngle);
		array_push(meshBindings, binding);
		//debug_log("bound " + _meshname + " to " + binding.bone.name)
		//meshBindingsByBoneID[? _boneid] = binding;
		//meshBindingsByMesh[? _meshname] = binding;
		}
		
	/// @function link_bones(childid,parentid)
	static link_bones = function(_childid,_parentid) {
		var child = allBones[_childid]
		var par = allBones[_parentid]
		child.parent = par;
		array_push(par.children,child)
		}
	
	/// @function add_animation(animation)
	static add_animation = function(_anim) {
		animationLibrary[$ _anim.name] = _anim;
		}
		
	static has_animation = function(_name) {
		return variable_struct_exists(animationLibrary, _name);
		}
		
	static get_animation = function(_name) {
		if(has_animation(_name)) {return animationLibrary[$ _name]}
		return undefined;
		}
	
	static rebake_animations = function() {
		var anims = variable_struct_get_names(animationLibrary)
		for(var i = 0; i < array_length(anims); i++) {
			var anim = animationLibrary[$ anims[i]];
			anim.clear_cached_samples();
			anim.generate_cached_samples();
			}
		}
	
	var all_arms = __get_all_armature_templates()
	ds_list_add(all_arms, self);
}

function OBJA_Armature_Instance(_armature) constructor {
	reference = _armature;
	var activeAnimName = variable_struct_get_names(_armature.animationLibrary)[0];
	activeAnimation = _armature.animationLibrary[$ activeAnimName];
	
	currentAnimationSample = new OBJA_Animation_Sample(activeAnimation,0)
	
	animationFinished = false; //whether the animation is finished or not
	animationFrame = 0; //what frame to display
	animationLoop = false; //whether the animation should loop automatically
	animationPaused = false; //whether the animation should continue to update
	animationSpeed = 1; //how many frames-per-frame should the animation progress at
	
	//used to update the animation automatically
	static update = function() {
		if(!animationPaused) {
			//loop if we should do that
			if(animationFinished && animationLoop) {
				animationFrame = 0;
				animationFinished = false;
				}
			
			if(!animationFinished) {
				//tick forwards
				animationFrame += animationSpeed;
				animationFrame = clamp(animationFrame, 0, activeAnimation.length);
			
				//mark finished if necessary
				if(animationFrame == activeAnimation.length) {animationFinished = true;}
			
				update_animation_sample();
				}
			}
		}
	
	static update_animation_sample = function() {
		activeAnimation.get_sample_at_frame(animationFrame, currentAnimationSample);
		}
	
	static has_animation = function(_name) {
		return reference.has_animation(_name);
		}
		
	static get_animation = function(_name) {
		return reference.get_animation(_name);
		}
	
	static set_animation = function(_name, _loop) {
		if(reference.has_animation(_name)) {
			animationFinished = false;
			animationFrame = 0;
			animationLoop = _loop;
			//speed and pause are preserved
			
			activeAnimation = reference.get_animation(_name);
						
			update_animation_sample();
			}
		else {
			throw "animation '" + _name  + "' does not exist for this armature!"
			}
		}
	
	static restart_animation = function() {
		animationFinished = false;
		animationFrame = 0;
		}
	
	update_animation_sample();
	
	}

function OBJA_MeshBinding(_meshname,_bone, _translation, _rotationAxis, _rotationAngle) constructor {
	meshname = _meshname
	bone = _bone;
	boneToMeshDQ = dq_create(_rotationAngle,_rotationAxis[0],_rotationAxis[1],_rotationAxis[2],_translation[0],_translation[1],_translation[2])
	}
	
function obja_rebake_all_animations() {
	debug_log("Rebaking all animations",CONSOLE_WARNING_COL)
	var b = benchmark_start("Rebaking all animations")
	var alltemplates = __get_all_armature_templates();
	for(var i = 0; i < ds_list_size(alltemplates); i++) {
		var template = alltemplates[| i];
		template.rebake_animations();
		}
	debug_log(benchmark_end(b),CONSOLE_WARNING_COL)
	}