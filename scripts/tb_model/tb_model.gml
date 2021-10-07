function Model() constructor {
	name = "undefined";
	modelBuffer = undefined;
	vertexBuffer = undefined;
	baked = false;
	texture = global.DEFAULT_TEXTURE;
	textureFrame = 0;
	
	/// @function bake()
	/// @description converts the model's data buffer into a frozen vertex buffer. this makes the model
	//				 faster to render, but means the model cannot be modified in any way without rewriting
	//				 the vertex buffer entirely. To save memory, the modelbuffer is discarded after baking
	bake = function() {
		if(baked) {
			logger_warn("tried to bake " + name + " but model is already baked",true);
			return;
			}
			
		if(modelBuffer == undefined) {
			logger_error("Tried to bake nonexistent model", true)
			}
		

		vertexBuffer = vertex_create_buffer_from_buffer(modelBuffer,global.VERTEX_FORMAT);
		vertex_freeze(vertexBuffer);
		 
		buffer_delete(modelBuffer)
		baked = true;
		modelBuffer = undefined;
		}
	
	/// @function bind_to_texture(sprite, [frame])
	/// @description sets the texture and textureFrame varables on the model, and then modifies the 
	//				 modelBuffer so that the UVs of the model (likely 0.0 to 1.0) are adjusted to
	//				 where the sprite exists on the texture page, so that all models can be rendered
	//				 using the same page. note that this process can't be undone.
	bind_to_texture = function(_sprite) {
		if(baked) {logger_warn("tried to fit " + name + " to texture, but model is already baked",true);return;}
		
		var noSub = true;
		var subimage = 0;
		
		if(argument_count == 2) {subimage = argument[1]; noSub = false}
		
		texture = sprite_get_texture(_sprite,subimage);
		textureFrame = subimage;

		var uvs = sprite_get_uvs(_sprite,subimage);

		var uPos = uvs[0];
		var vPos = uvs[1];
		var uSize = uvs[2]-uPos;
		var vSize = uvs[3]-vPos;

		buffer_seek(modelBuffer,buffer_seek_end,0);

		var endSeek = buffer_tell(modelBuffer);

		buffer_seek(modelBuffer,buffer_seek_start,0);

		while(buffer_tell(modelBuffer)!=endSeek) {
			buffer_seek(modelBuffer,buffer_seek_relative,16); //skip the position data and the colour	
	
			//scale uv coordinates
			var uIn = buffer_read(modelBuffer,buffer_f32);
			var vIn = buffer_read(modelBuffer,buffer_f32);
		
			var uOut = uPos + (uIn * uSize);
			var vOut = vPos + (vIn * vSize);
	
			buffer_seek(modelBuffer,buffer_seek_relative,-8); //go back to before the uv positions so we can rewrite them
			buffer_write(modelBuffer,buffer_f32,uOut);
			buffer_write(modelBuffer,buffer_f32,vOut);
	
	
			buffer_seek(modelBuffer,buffer_seek_relative,12); //skip the normal dat
			}

		}
	
	/// @function clone(new_name)
	/// @description returns a new deep copy of this model with a new name. Because names are used
	//				 to identify models, the new name must be unique. Baked models cannot be cloned.
	clone = function(newName) {
		if(baked) {throw "Tried to clone " + name + " but the model is baked.";}
		if(ds_map_exists(global.LOADED_MODELS, newName)) {throw "Tried to clone " + name + " but '" + newName + "' is not a unique identifier";}
		
		var newModel = new Model();
		newModel.name = newName;
		var newBuffer = buffer_create(buffer_get_size(modelBuffer),buffer_fixed,4);
		newModel.modelBuffer = newBuffer;
		
		//copy contents across
		buffer_copy(modelBuffer,0,buffer_get_size(modelBuffer),newBuffer,0);
		
		ds_map_add(global.LOADED_MODELS,newName,newModel);
		return newModel;
		}
	}


/// @function model_load_obj(path, [name])
/// @param path
/// @param name
function model_load_obj(path) {
	var name = (argument_count == 2) ? argument[1] : path;

	var objects = ds_list_create();

	var currentObject = undefined;
	
	if !file_exists(path) {show_error(sprintf("Unable to load model at %s, file does not exist",path),true);};

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
		
		line = string_split(line);
		type = line[0]
		switch(type) {
		
			// Begin new object block
			case "o": {
				//printf("hit o block for %s",line[1]);
				if(currentObject != undefined) {
					//printf("- stashed " + currentObject.name);
					ds_list_add(objects,currentObject);
					}
										
				currentObject = {}
				currentObject.name = line[1];
				currentObject.vertList = ds_list_create();
				currentObject.vOff = vCount;
				currentObject.uvList = ds_list_create();
				currentObject.vtOff = vtCount;
				currentObject.normalList = ds_list_create();
				currentObject.vnOff = vnCount;
				currentObject.faceList = ds_list_create();
				//printf("  new datablock has origin %s,%s,%s",vCount,vtCount,vnCount);
				};break;
		
			// Vertex line
			case "v": {
				var vx = real(line[1]);
				var vy = real(line[2]);
				var vz = real(line[3]);
				ds_list_add(currentObject.vertList,[vx,vy,vz]);
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
			
			// face tri definition
			case "f": {
				var p1 = string_split(line[1],"/");
				var p2 = string_split(line[2],"/");
				var p3 = string_split(line[3],"/");
			
				ds_list_add(currentObject.faceList,[real(p1[0])-1,real(p1[1])-1,real(p1[2])-1,
									                real(p3[0])-1,real(p3[1])-1,real(p3[2])-1,
									                real(p2[0])-1,real(p2[1])-1,real(p2[2])-1]);			
				};break;
			
			
			}
		}
	file_text_close(file)
	
	//add the last object to the list
	//printf("stashed " + currentObject.name);
	
	ds_list_add(objects,currentObject);
	currentObject = undefined;
	
	//printf("parse complete, parsed %s objects", ds_list_size(objects));
	
	//printf("\nbeginning model conversion");
	
	var modelOutput = [];
	
	//convert each object list collection into a model
	for(var oi = 0; oi < ds_list_size(objects); oi++) {
		var object = objects[| oi];
		var modelname = object.name;
		
		//printf("converting model '%s'",modelname);
		
		//early abort for double loaded models
		if(ds_map_exists(global.LOADED_MODELS,modelname)) {
			logger_warn("Attempted to load model '" + modelname + "' which is already loaded, skipping");
			continue;
			}	
		
		//printf("  model has %s faces", ds_list_size(object.faceList));
		
		var size = (12 + 4 + 8 + 12) * 3 * ds_list_size(object.faceList);
		var modelBuffer = buffer_create(size,buffer_fixed,4);
		
		//write vertex data to buffer
		for(var i = 0; i < ds_list_size(object.faceList); i++) {
			var f = object.faceList[| i];
			var o = 0;
			repeat(3) {
				var vo = f[o] - object.vOff;
				var v = object.vertList[| vo]; //vertex_position_3d
				buffer_write(modelBuffer,buffer_f32,v[0]);
				buffer_write(modelBuffer,buffer_f32,v[1]);
				buffer_write(modelBuffer,buffer_f32,v[2]);
	
				//vertex_colour
				buffer_write(modelBuffer,buffer_u32,$FFFFFFFF);
				//buffer_write(modelBuffer,buffer_f32,1.0);
	
				var uvo = f[1+o] - object.vtOff;
				var uv = object.uvList[| uvo]; //vertex_texcoord
				buffer_write(modelBuffer,buffer_f32,uv[0]);
				buffer_write(modelBuffer,buffer_f32,uv[1]);
	
				var no = f[2+o] - object.vnOff;
				var n = object.normalList[| no]; //vertex_normal
				buffer_write(modelBuffer,buffer_f32,n[0]);
				buffer_write(modelBuffer,buffer_f32,n[1]);
				buffer_write(modelBuffer,buffer_f32,n[2]);
		
				o += 3;
				}
			}		
		
		var model = new Model();
		model.name = modelname;
		model.modelBuffer = modelBuffer;
		
		ds_map_add(global.LOADED_MODELS,modelname,model);
		debug_log("loaded '" + modelname + "'",c_gray)
		array_push(modelOutput,model);
		//printf("conversion complete, modeloutput is now %s",array_length(modelOutput));
		}

	//cleanup
	for(var i = 0; i < ds_list_size(objects); i++) {
		var object = objects[| i];
		ds_list_destroy(object.vertList)
		ds_list_destroy(object.uvList)
		ds_list_destroy(object.normalList)
		ds_list_destroy(object.faceList)
		delete object;
		}
	ds_list_destroy(objects);
	//printf("performed cleanup");

	//if the file only contained a single model, return just that model
	if(array_length(modelOutput) == 1) {
		//printf("doing return singular");
		return modelOutput[0];
		}

	//otherwise, return an array of all the models contained within the 
	//printf("doing return multiple");
	return modelOutput;
}
	
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