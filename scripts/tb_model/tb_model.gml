#region [ Data Structures ]
function Model() constructor {
	name = "undefined";
	parentFile = ""; //the file this model came from
	mesh_groups = [];
	frozen = false;
	texture = global.DEFAULT_TEXTURE; //fallback texture
	textureName = "unassigned"
	textureFrame = 0;
	
	/// @function add_meshgroup(group)
	function add_meshgroup(_mg) {
		array_push(mesh_groups, _mg);
		}
	
	/// @function bind_texture(name)
	/// @param	{string}	name	the name of the sprite to bind this model to
	function bind_texture(_name) {
		textureName = _name;
		var spr = asset_get_index(_name);
		if(spr == -1) {debug_alert("tried to bind to texture " + _name + " that can't be found!",CONSOLE_ERROR_COL); return;}
		texture = sprite_get_texture(spr, 0)
		}
	
	/// @function bind_texture_sprite(sprite)
	/// @param	{Asset.GMSprite}	sprite	the sprite to bind this model to
	function bind_texture_sprite(_spr) {
		texture = sprite_get_texture(_spr, 0)
		textureName = sprite_get_name(_spr);
		}
		
	/// @function bind_texture_direct(tex, name)
	/// @param	{Pointer.Texture}	tex		the texture page to bind this model to
	/// @param	{string}			name	the name to show for this texture
	function bind_texture_direct(_tex, _name) {
		texture = _tex;
		textureName = _name;
		}
	
	/// @function submit(mode, fallback)
	/// @param	{Constant.PrimitiveType}	mode				render mode
	/// @param	{Pointer.Texture}			[fallback]			the texture to use instead of the model's base texture for any mesh groups which dont have a texture assigned
	/// @param	{Bool}						[force_fallback]	whether to force the mesh to use the fallback texture
	function submit(mode, fallback_tex, force_fallback = false) {
		fallback_tex ??= texture;
		var groups = mesh_groups;
		for(var i = 0; i < array_length(groups); i++) {
			var group = groups[i];
			var tex;
			if(force_fallback) {tex = fallback_tex}
			else {tex = group.texture ?? fallback_tex}
			vertex_submit(group.vertexBuffer, mode, tex);
			}
		}
		
	function freeze() {
		if(!frozen) {
			array_foreach(mesh_groups, function(mg) {mg.freeze()});
			frozen = true;
			}
		}
		
	function cleanup() {
		array_foreach(mesh_groups, function(mg) {mg.cleanup()});
		}
	}

function _MeshGroup() constructor {
	name = "";
	texturename = "";
	texture = undefined;		//undefined means use the base texture
	vertexBuffer = undefined;
	rawBuffer = undefined;
	frozen = false;
	
	/// @function bind_texture(name)
	/// @param	{string}	name	the name of the sprite to bind this meshgroup to
	function bind_texture(_name) {
		texturename = _name;
		var spr = asset_get_index(_name);
		if(spr == -1) {debug_alert("tried to bind to texture " + _name + " that can't be found!",CONSOLE_ERROR_COL); return;}
		texture = sprite_get_texture(spr, 0)
		}
	
	/// @function bind_texture_sprite(sprite)
	/// @param	{Asset.GMSprite}	sprite	the sprite to bind this meshgroup to
	function bind_texture_sprite(_spr) {
		texture = sprite_get_texture(_spr, 0)
		texturename = sprite_get_name(_spr);
		}
		
	/// @function bind_texture_direct(tex, name)
	/// @param	{Pointer.Texture}	tex		the texture page to bind this meshgroup to
	/// @param	{string}			name	the name to show for this texture
	function bind_texture_direct(_tex, _name) {
		texture = _tex;
		texturename = _name;
		}
		
	/// @function freeze()
	function freeze() {
		if(!frozen) {
			frozen = true;
			vertex_freeze(vertexBuffer);
			}
		}
	
	/// @function cleanup()
	function cleanup() {
		if(vertexBuffer != undefined) {vertex_delete_buffer(vertexBuffer)}
		if(rawBuffer != undefined) {buffer_delete(rawBuffer)}
		}
	}

#endregion

#region [ Loading Models ]

function TBMeshImportSettings() constructor {
	/// whether to immediately freeze the vertex buffers as soon as they're created
	freeze_on_load = TB_OBJ_LOAD_DEFAULT_FREEZE_ON_LOAD
	/// whether to keep the raw model buffer instead of deleteing it
	preserve_buffer = TB_OBJ_LOAD_DEFAULT_PRESERVE_BUFFER
	/// the swizzle to transform all vertices by as part of the loading proces (for coordinate conversion)
	/// the digit refers to which index to use minus 1, so for example [1,2,3] is 0,1,2 or x,y,z, and [2,1,3] is 1,0,2 or y,x,z
	/// the sign of the digit refers to whether the value should be negated or not, so [2,-1,3] is y, -x, z
	converstion_swizzle = [1,2,3]
	}
	
global.__TB_DEFAULT_MESH_IMPORT_SETTINGS = new TBMeshImportSettings();

/// @function model_load_obj(path, [name], [settings])
/// @param {string} path					the path of the file
/// @param {string} [name]					the custom name to give the model
/// @param {Struct.TBMeshImportSettings}	[settings]	model import settings to use instead of the defaults
/// @returns	{Struct.Model | Array<Struct.Model>}
function model_load_obj(path, name, settings = undefined) {
	name ??= path;
	settings ??= global.__TB_DEFAULT_MESH_IMPORT_SETTINGS;

	var objects = ds_list_create();

	var currentObject = undefined;
	var currentGroup = undefined;
	
	//helper function
	var newGroup = function(_name) {
		var group = {};
		group.name = _name;
		group.texname = "";
		group.faces = [];
		return group;
		}
	
	if !file_exists(path) {show_error(string("Unable to load model at {0}, file does not exist",path),true);};

	var file = file_text_open_read(path);

	var line, type;
	
	var vCount = 0;
	var vtCount = 0;
	var vnCount = 0;

	//load all object data out of the file
	while(!file_text_eof(file)) {
		
		line = file_text_readln(file);
		if(string_char_at(line,1) == "#") {continue;} //skip comments
		var linelen = string_length(line)
		line = string_copy(line,1,linelen-1); //remove the LF
		
		line = string_split(line, " ");
		type = line[0]
		switch(type) {
		
			// Begin new object block
			case "o": {
										
				// vOff, vtOff and vnOff are used to counteract
				// the fact the id for each element type in the
				// obj file goes up across all objects in the file
				// but each object here starts at 0 again
				// so the Off variable is subtracted from the ids of
				// each object's relevant indexes
										
				currentObject = {}
				currentObject.name = line[1];
				currentObject.vertList = ds_list_create();
				currentObject.vOff = vCount;
				currentObject.uvList = ds_list_create();
				currentObject.vtOff = vtCount;
				currentObject.normalList = ds_list_create();
				currentObject.vnOff = vnCount;
				currentObject.groupList = ds_list_create();
				currentObject.numGroups = 0;
				
				//every object must have at least one meshgroup
				currentGroup = newGroup("default");
				ds_list_add(currentObject.groupList, currentGroup);
				
				ds_list_add(objects,currentObject);
				
				};break;
		
			// Vertex line
			case "v": {
				var vx = real(line[1]);
				var vy = real(line[2]);
				var vz = real(line[3]);
				// unofficial vertex colour handling
				if(array_length(line) == 7) {
					var vr = real(line[4]);
					var vg = real(line[5]);
					var vb = real(line[6]);
					ds_list_add(currentObject.vertList,[vx,vy,vz,vr,vg,vb]);
					}
				else {
					ds_list_add(currentObject.vertList,[vx,vy,vz,1,1,1]);
					}
				vCount++;
				};break;
		
			// Vertex texture line
			case "vt": {
				var u = real(line[1]);
				var v = 1.0-real(line[2]); //account for game maker uvs being topleft not bottomleft aligned
				ds_list_add(currentObject.uvList,[u,v]);	
				vtCount++;
				};break;
			
			// Vertex normal line
			case "vn": {
				var nx = real(line[1]);
				var ny = real(line[2]);
				var nz = real(line[3]);
				ds_list_add(currentObject.normalList,[nx,ny,nz]);
				vnCount++;
				};break;
				
			// face group line
			case "g": {
				//the first group should always reappropriate the default group
				var groupname = line[1];
				if(currentObject.numGroups == 0) {
					currentGroup.name = groupname;
					}
				else {
					var group = newGroup(groupname);
					ds_list_add(currentObject.groupList, group);
					currentGroup = group;
					}
				
				currentObject.numGroups++;
				};break;
				
			// material select line
			// note: usemtl is appropriated here to signify a texture name
			//		 the accompanying .mtl file isn't actually ever used
			case "usemtl": {
				currentGroup.texname = line[1];
				};break;
			
			// face tri definition
			case "f": {				
				var p1 = string_split(line[1],"/");
				var p2 = string_split(line[2],"/");
				var p3 = string_split(line[3],"/");
			
				var face = [real(p1[0])-1,real(p1[1])-1,real(p1[2])-1,
							real(p3[0])-1,real(p3[1])-1,real(p3[2])-1,
							real(p2[0])-1,real(p2[1])-1,real(p2[2])-1];			
							
				array_push(currentGroup.faces, face);
				};break;
			
			
			}
		}
	file_text_close(file)
	
	var modelOutput = [];
	
	//get filename on its own
	var split = string_split(path,"\\"); // split on directory markers
	var fname = split[ array_length(split)-1] //grab only the last component (the filename)
	
	//convert each object list collection into a model
	for(var oi = 0; oi < ds_list_size(objects); oi++) {
		var object = objects[| oi];
		var modelname = object.name;
		
		//early abort for double loaded models
		if(ds_map_exists(global.LOADED_MODELS,modelname)) {
			debug_alert("Attempted to load model '" + modelname + "' which is already loaded",c_red);
			continue;
			}	
			
		var multimesh = new Model();
		multimesh.name = modelname;
		multimesh.parentFile = fname;
		multimesh.frozen = settings.freeze_on_load;
			
		//make a submesh for each grouping
		for(var gi = 0; gi < ds_list_size(object.groupList); gi++) {
			var group = object.groupList[| gi];
			var groupname = group.name;
			var texname = group.texname;
			var faces = group.faces;
			
			var size = (12 + 4 + 8 + 12) * 3 * array_length(faces);
			var modelBuffer = buffer_create(size,buffer_fixed,4);
			
			var swizzle_x = abs(settings.converstion_swizzle[0])-1;
			var swizzle_y = abs(settings.converstion_swizzle[1])-1;
			var swizzle_z = abs(settings.converstion_swizzle[2])-1;
			var swizzle_x_sign = sign(settings.converstion_swizzle[0]);
			var swizzle_y_sign = sign(settings.converstion_swizzle[1]);
			var swizzle_z_sign = sign(settings.converstion_swizzle[2]);
			
			for(fi = 0; fi < array_length(faces); fi++) {
				var face = faces[fi];
				var o = 0;
				
				repeat(3) {
					var vo = face[o] - object.vOff;
					var v = object.vertList[| vo]; //vertex_position_3d
										
					buffer_write(modelBuffer,buffer_f32,v[swizzle_x] * swizzle_x_sign);
					buffer_write(modelBuffer,buffer_f32,v[swizzle_y] * swizzle_y_sign);
					buffer_write(modelBuffer,buffer_f32,v[swizzle_z] * swizzle_z_sign);
	
					//vertex_colour
					var colour = $FF000000 | (floor(255 * v[4]) << 16) | (floor(255 * v[4]) << 8) | floor(255 * v[3])
					buffer_write(modelBuffer,buffer_u32,colour);
	
					var uvo = face[1+o] - object.vtOff;
					var uv = object.uvList[| uvo]; //vertex_texcoord
					buffer_write(modelBuffer,buffer_f32,uv[0]);
					buffer_write(modelBuffer,buffer_f32,uv[1]);
	
					var no = face[2+o] - object.vnOff;
					var n = object.normalList[| no]; //vertex_normal
					
					buffer_write(modelBuffer,buffer_f32,n[swizzle_x]*swizzle_x_sign);
					buffer_write(modelBuffer,buffer_f32,n[swizzle_y]*swizzle_y_sign);
					buffer_write(modelBuffer,buffer_f32,n[swizzle_z]*swizzle_z_sign);
		
					o += 3;
					}
				}
				
			var submesh = new _MeshGroup();
			submesh.name = groupname;
			if(texname != "" && texname != "None") {submesh.bind_texture(texname);}
			
			submesh.vertexBuffer = vertex_create_buffer_from_buffer(modelBuffer, global.VERTEX_FORMAT)
			if(settings.freeze_on_load) {submesh.freeze()}
			if(settings.preserve_buffer) {submesh.rawBuffer = modelBuffer;} else {buffer_delete(modelBuffer);}
			
			multimesh.add_meshgroup(submesh);
			buffer_delete(modelBuffer);
			}
			
		ds_map_add(global.LOADED_MODELS,modelname,multimesh);
		debug_log("loaded '" + modelname + "'",c_gray)
		array_push(modelOutput,multimesh);
		}
		
	//cleanup
	for(var i = 0; i < ds_list_size(objects); i++) {
		var object = objects[| i];
		ds_list_destroy(object.vertList)
		ds_list_destroy(object.uvList)
		ds_list_destroy(object.normalList)
		ds_list_destroy(object.groupList)
		delete object;
		}
	ds_list_destroy(objects);
	
	//if the file only contained a single model, return just that model
	if(array_length(modelOutput) == 1) {
		return modelOutput[0];
		}

	//otherwise, return an array of all the models contained within the 
	return modelOutput;
	}
	
#endregion

// --- raw data models ---

/// @function model_load_raw(path, name)
/// @param path
/// @param name
function model_load_raw(path, name) {
	
	if !file_exists(path) {printf("the file " + path + " does not exist");}
	else {
		var modelBuffer = buffer_create((12 + 4 + 8 + 12) * 3 * 12,buffer_grow,4) //the initial size is equivilant to one 12 faced cube
	
		buffer_load_ext(modelBuffer,path,0)
	
		ds_map_add(global.LOADED_MODELS,name,modelBuffer);
		}

}

/// @function model_export_raw(path, name)
/// @param name
/// @param path
function model_export_raw(path, name) {

	if !ds_map_exists(global.LOADED_MODELS,name) {show_error("Unknown model " + string(name),false);return;}

	var buff = global.LOADED_MODELS[? name];

	buffer_save(buff,path + "/" + name + ".mdl");


}

// --- model manipulation

/// @function model_tint(name, colour) 
/// @param name
/// @param colour
function model_tint(name, colour) {
	if !ds_map_exists(global.LOADED_MODELS,name) {show_error("Unknown model " + string(name),true);return;}
	var modelBuffer = global.LOADED_MODELS[? name];
	
	buffer_seek(modelBuffer,buffer_seek_end,0);
	var endSeek = buffer_tell(modelBuffer);
	buffer_seek(modelBuffer,buffer_seek_start,0);
	
	//iterate over each vertex
	while(buffer_tell(modelBuffer)<endSeek) {
		buffer_seek(modelBuffer,buffer_seek_relative,12); //skip the position data 
	
		//WRITE NEW COLOUR
		buffer_write(modelBuffer,buffer_u32,$FF000000 | colour);
		
		buffer_seek(modelBuffer,buffer_seek_relative,20); //skip uv and normal data
		}	
	}
