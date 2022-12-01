/// @description Animation Example Create

var f = ini_open(working_directory + "lastOpen.ini")

#region obj mesh region
var fname = ini_read_string("last","obj_filepath","NONE")
var file;

//determine autoload
if(fname == "NONE") {var file = get_open_filename("OBJ Model|*.obj","");}
else {file = fname; debug_log("reloading mesh file " +fname);}
	
//actually load the meshes
var b = benchmark_start("loading meshes")
meshes = model_load_obj(file)
debug_log(string("loaded {0} models from '{1}'",array_length(meshes),file))
for(var i = 0; i < array_length(meshes); i++) {
	meshes[i].freeze();
	meshes[i].bind_texture_sprite(sprPistolTex)
	//meshes[i].texture = sprite_get_texture(sprPistolTex,0)
	printf("loaded '{0}'",meshes[i].name);
	}
benchmark_end(b)
	
ini_write_string("last","obj_filepath",file)

#endregion

#region obja animation section

var fname = ini_read_string("last","obja_filepath","NONE")

var file;
if(fname == "NONE") {var file = get_open_filename("OBJA Animation|*.obja","");}
else {file = fname; debug_log("reloading animation file " +fname);}

var b = benchmark_start("loading rig")
armature = obja_load(file)
benchmark_end(b)

ini_write_string("last","obja_filepath",file)
ini_close();
var out = "found "
var keys = variable_struct_get_names(armature.animationLibrary)
out += string(array_length(keys)) + " animations: "
for(var i = 0; i < array_length(keys ); i++) {
	out += keys[i] + ", ";
	}
benchmark_end(b)
debug_log(out, c_gray);

armInst = new OBJA_Armature_Instance(armature)

skeletonrenderer = new OBJA_SkeletonRenderComponent(id, armInst)
skeletonrenderer.dontRender = true;
skeletonrenderer.customShader = global.DEFAULT_BASIC_SHADER 

paused = true;
showLabels = false;

renderer = new OBJA_ArmatureRenderComponent(id, armInst)

#endregion

//dev_register_command("toggle_labels",function(args) {showLabels = !showLabels},0,"toggle labels","")

dev_register_command("toggle_show_skeleton",function(args) {skeletonrenderer.dontRender = !skeletonrenderer.dontRender},0,"toggle skeleton renderer","")

dev_register_command("toggle_interpolation",function(args) {
	global.OBJA_ANIM_USE_INTERPOLATION = !global.OBJA_ANIM_USE_INTERPOLATION;
	debug_log("Sample interpolation is now " + (s ? "on" : "off"),$88ffff)
	},0,"toggle sample interpolation","")

dev_register_command("load_new_anim",function(args) {
	var file = get_open_filename("*.obja","");
	delete armature;
	armature = obja_load(file);
	armInst = new OBJA_Armature_Instance(armature)
	skeletonrenderer.armature = armature;
	//skeletonRenderer.renderMatrix = matrix_build(0,0,0,0,0,0,1,1,1)
	ini_open(working_directory + "lastOpen.ini")
	ini_write_string("last","obja_filepath",file)
	ini_close();
	var out = "found "
	var keys = variable_struct_get_names(armature.animationLibrary)
	out += string(array_length(keys)) + " animations: "
	for(var i = 0; i < array_length(keys ); i++) {
		out += keys[i] + ", ";
		}
	benchmark_end(b)
	debug_log(out, c_gray);
	}, 0, "load a new armature", "");
	
dev_register_command("set_anim", function(args) {
	var animname = args[0];
	var loop = (array_length(args) == 2) ? real(args[1]) : true;
	if(armInst.has_animation(animname)) {
		armInst.set_animation(animname, loop);
		}
	else {
		logger_error("armature does not contain animation " + animname, CONSOLE_ERROR_COL);
		}
	}, 2, "sets the animation", "<name> <loop>");

dev_register_command("set_sample_method",function(args) {
	var mode = args[0];
	switch(mode) {
		case "smart": {
			global.OBJA_ANIM_USE_SMART_SAMPLING = true;
			obja_rebake_all_animations()
			};break;
		
		case "basic": {
			global.OBJA_ANIM_USE_SMART_SAMPLING = false;
			obja_rebake_all_animations()
			};break;
			
		default: {
			debug_log(mode + " isn't a valid sample mode",c_red);
			}
		}
	},1,"set the sample placement method of the active animation","[smart,basic]")

dev_register_command("set_sample_interval",function(args) {
	try {
		var rate = floor(real(args[0]))
		if(rate < 1) {debug_log("ERR: interval must be greater or equal to 1",c_red);return;}
		global.OBJA_ANIM_DEFAULT_SAMPLE_INTERVAL = rate;
		obja_rebake_all_animations()
		}
	catch (_) {
		debug_log("ERR: interval must be an integer",c_red)
		}
	},1,"set the animation cache sample interval","interval")


var a = {bee: "bap", boo: 8.39, bop: [1,2,3,{hello: "world"}]}
var out = json_stringify(a);
var reconstruct = json_parse(out)
show_debug_message(out)
show_debug_message(reconstruct)

out = json_beautify(out)
var reconstruct = json_parse(out)
show_debug_message(out)
show_debug_message(reconstruct)
