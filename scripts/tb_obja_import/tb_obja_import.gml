function obja_load(_filename) {
	
	var file = file_text_open_read(_filename);
	
	
	var armature = new OBJA_Armature_Template();
	
	var line, type;
	
	var sf = 1;
	
	var verbose = global.OBJA_IMPORT_VERBOSE;
	
	importContext = {
		armature: armature,
		currentAnimation: undefined,
		currentFCurveGroup: undefined,
		currentFCurve: undefined,
		currentFCurveAxis: 0,
		currentFCurveType: 0,
		}
				
	var finalizeFCurve = function(_context)  {
		var t = _context.currentFCurveType;
		var a = _context.currentFCurveAxis;
		if(global.OBJA_IMPORT_VERBOSE) {printf(" Added FCurve for {0}.{1}[{2}] with {3} keyframes.",_context.currentFCurveGroup.boneid,t,a,array_length(_context.currentFCurve.allKeyframes))}
		switch(t) {
			case "loc": {_context.currentFCurveGroup.set_location_fcurve(_context.currentFCurve,a);};break;
			case "rot": {
				//blender stores w first, but we store w last
				var mapping = [QUAT_W,QUAT_X,QUAT_Y,QUAT_Z]
				_context.currentFCurveGroup.set_rotation_fcurve(_context.currentFCurve,mapping[a])
				};break;
			}
		_context.currentFCurve = undefined;
		_context.currentFCurveType = undefined;
		_context.currentFCurveAxis = undefined;
		}
		
	var finalizeFCurveGroup = function(_context) {
		//printf("Finalizing fcurve group for bone {0}...",_context.currentFCurveGroup.boneid)
		_context.currentAnimation.add_fcurve_group(_context.currentFCurveGroup)
		_context.currentFCurveGroup = undefined;
		}
	
	
	//find the name of the armature
	
	
	var split = string_split(_filename,"\\"); // split on directory markers
	var fname = split[ array_length(split)-1] //grab only the last component (the filename)
	armature.name = string_split(fname,".")[0]; //cut off the extension (the .obja)
	
	while(!file_text_eof(file)) {
		line = file_text_readln(file);
		if(string_char_at(line,1) == "#") {continue;} //skip comments
		var linelen = string_length(line)
		line = string_copy(line,1,linelen-2); //remove the CRLF
		
		if(line == "") {continue;}
		
		line = string_split(string_trim(line), " ");
		type = line[0];
				
		switch(type) {
			
			// Bone definition 
			//	 b id name headx heady headz axisx axisy axisz angle length
			case "b": {
				var boneid = real(line[1])
				var bonename = line[2]
				var bonehead = [real(line[3])*sf,real(line[4])*sf,real(line[5])*sf]
				var boneaxis = [real(line[6]),real(line[7]),real(line[8])]
				var boneangle = real(line[9])
				var bonelength = real(line[10])*sf
				var bone = new OBJA_Bone(boneid,bonename,importContext.armature,bonehead,boneaxis,boneangle,bonelength)
				importContext.armature.add_bone(bone)
				if(verbose) {printf("Loaded bone #{0}: {1}",boneid,bonename)}
				};break;
				
			// Bone relationship
			// br child [parent]
			case "br": {
				var child = real(line[1])
				if(array_length(line) > 2) {
					var par = real(line[2])
					importContext.armature.link_bones(child,par)
					if(verbose) {printf("attached {0} to {1}",child,par)}
					}
				else {
					//if there's only one number here, its the root bone
					if(verbose) {printf("{0} is now the root bone",child)}
					importContext.armature.rootBone = importContext.armature.allBones[child]
					}
				};break;
			
			// Mesh Pairing
			//	 mp modelname boneid offx offy offz axisx axisy axisz angle
			case "mp": {
				var meshname = line[1];
				var boneid = real(line[2])
				var off = [real(line[3])*sf,real(line[4])*sf,real(line[5])*sf]
				var axis = [real(line[6]),real(line[7]),real(line[8])]
				var angle = real(line[9])
				var bind = importContext.armature.add_mesh_binding(meshname,boneid,off,axis,angle)
				if(verbose) {printf("Defined mesh pairing for {0} to bone {1}",meshname,boneid)}
				};break;
			
			// Animation data
			//	 a name length fps
			case "a": {
				var name = line[1]
				var length = real(line[2])
				//var framerate = real(line[3]) //we dont use this right now
				if(verbose) {printf("Loading animation {0}",name)}
				
				var anim = new OBJA_Animation(name, importContext.armature)
				armature.add_animation(anim)
				importContext.currentAnimation = anim;
				};break;
			
			// F-Curve group
			//   fcg bone
			case "fcg": {	
				//if we're starting a new fcg block, finalize the last one
				if(importContext.currentFCurve != undefined) {finalizeFCurve(importContext)}
				if(importContext.currentFCurveGroup != undefined) {finalizeFCurveGroup(importContext)}
				
				var bone = real(line[1])
				importContext.currentFCurveGroup = new FCurve_Group(bone);
				if(verbose) {printf("starting fcurve group for {0}",bone)}
				};break;
			
			// F-Curve data
			//   fc type axis 
			case "fc": {
				//if we're starting a new fcurve, finalize the last one
				if(importContext.currentFCurve != undefined) {finalizeFCurve(importContext)}
				
				importContext.currentFCurve = new FCurve();				
				importContext.currentFCurveType = line[1]
				importContext.currentFCurveAxis = real(line[2])
				};break;
				
			// Keyframe data
			//   kf frame value ease interpolation [lhandlex lhandley rhandlex rhandley]
			case "kf": {
				var frame = real(line[1])
				var value = real(line[2])*sf
				var easing = global.EASE_VALUES[$ line[3]]
				var interp = global.INTERPOLATION_VALUES[$ line[4]]
				var kf;
				if(interp == INTERP_BEZIER) {
					var lhandle = [real(line[5]),real(line[6])*sf]
					var rhandle = [real(line[7]),real(line[8])*sf]
					kf = new FCurve_Keyframe(frame,value,interp,easing, lhandle, rhandle)
					}
				else {
					var kf = new FCurve_Keyframe(frame,value,interp,easing)
					}
				importContext.currentFCurve.add_keyframe(kf)
				
				};break;
			}
		}
		
	file_text_close(file)
		
	// Now we're at EOF, finalize whatever we were working on
		
	//finalize last FCurve into its group
	if(importContext.currentFCurve != undefined) {finalizeFCurve(importContext)}
		
	//finalize last FCurveGroup into its animation
	if(importContext.currentFCurveGroup != undefined) {
		finalizeFCurveGroup(importContext)
		}
		
	//bake animations before export;
	armature.rebake_animations();
	
	printf("finished loading '" + armature.name + "'");
	ds_map_add(global.LOADED_ARMATURES,armature.name,armature);
	
	return armature;
	}