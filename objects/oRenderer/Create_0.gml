/// @description oRenderer Create

#macro LIGHT_DISTANCE_THRESHOLD 128*128
#macro VEC3_ZERO r3_zero()
#macro VEC3_ONE r3(1,1,1)

#macro VEC2_ZERO r2_zero()
#macro VEC2_ONE r2(1,1)

#macro CULL_DIRECTION cull_counterclockwise



define_vertex_format()

// ### RENDERING ###
layer_force_draw_depth(true,0);
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_alphatestref(5);

global.STATIC_RENDER_REQUESTS = ds_list_create(); //things that dont move, can be rendered in a batch without changing the world matrix
global.DYNAMIC_RENDER_REQUESTS = ds_list_create(); //things that need the world matrix updated per object
depthlist = ds_list_create();

global.DEFAULT_BASIC_SHADER = new BasicShader();
global.__BACKFACE_CULLING_ENABLED = true;

// ### CAMERAS ###

audio_falloff_set_model(audio_falloff_linear_distance)

view_enabled=true;
global.CAMERA_LAYER = layer_create(-200); 
global.ALL_CAMERAS = ds_list_create();
global.VIEW_CAMERA_MAP = ds_map_create();
global.MAIN_CAMERA = undefined;
global.CURRENT_CAMERA = undefined;
global.LISTENER_CAMERA = undefined;


// ### LIGHTING & FOG ###
global.ALL_LIGHTS = ds_list_create();
global.AMBIENT_LIGHT_COLOUR = [0.01,0.01,0.01];

//TODO: fog is a shader property, not a global property, these shouldn't be here
global.FOG_COLOUR = [0,0,0];
global.FOG_START = 200;
global.FOG_END = 400;

// ### MODELS ###
global.LOADED_MODELS = ds_map_create();

// ### ARMATURES ###
global.LOADED_ARMATURES = ds_map_create();

//model_load_raw("models/mdl_unknown.mdl","mdl_unknown");
//model_to_vbuffer("cube");
//vertex_freeze(global.DEFAULT_MODEL);


global.DEFAULT_TEXTURE = sprite_get_texture(texMissing,0);
global.DEFAULT_MATRIX = matrix_build_identity();

defaultmodel = model_load_obj("models/suzanne.obj")
defaultmodel.freeze();

global.DEFAULT_MODEL = defaultmodel;
global.DEFAULT_VERTEX_BUFFER = defaultmodel.mesh_groups[0].vertexBuffer;

//model_load_obj("models/mdl_cube.obj","mdl_cube");

#region OBJA debug meshes
var vb = vertex_create_buffer()
var bonebox = 0.4;

global.__BONE_BOX_MESH = vb;
vertex_begin(vb,global.VERTEX_FORMAT)
define_line_cube(vb,[0,0,0],bonebox,c_white,1)
vertex_end(vb)
vertex_freeze(vb)

//arrow
var arrowlen = 1;
var arrowoff = 1/8;
var vb = vertex_create_buffer()
global.__BONE_ARROW_MESH = vb;
vertex_begin(vb,global.VERTEX_FORMAT)
define_line(vb,[0,0,0],[0,arrowlen,0],c_aqua,1)
define_line(vb,[0,arrowlen,0],[-arrowoff,arrowlen-(arrowlen*arrowoff),0],c_aqua,1)
define_line(vb,[0,arrowlen,0],[ arrowoff,arrowlen-(arrowlen*arrowoff),0],c_aqua,1)
define_line(vb,[0,arrowlen,0],[0   ,arrowlen-(arrowlen*arrowoff),-arrowoff],c_aqua,1)
define_line(vb,[0,arrowlen,0],[0   ,arrowlen-(arrowlen*arrowoff), arrowoff],c_aqua,1)
vertex_end(vb)
vertex_freeze(vb)

var vb = vertex_create_buffer()
global.__BONE_ARROW_MESH_WHITE = vb;
vertex_begin(vb,global.VERTEX_FORMAT)
define_line(vb,[0,0,0],[0,arrowlen,0],c_white,1)
define_line(vb,[0,arrowlen,0],[-arrowoff,arrowlen-(arrowlen*arrowoff),0],c_white,1)
define_line(vb,[0,arrowlen,0],[ arrowoff,arrowlen-(arrowlen*arrowoff),0],c_white,1)
define_line(vb,[0,arrowlen,0],[0   ,arrowlen-(arrowlen*arrowoff),-arrowoff],c_white,1)
define_line(vb,[0,arrowlen,0],[0   ,arrowlen-(arrowlen*arrowoff), arrowoff],c_white,1)
vertex_end(vb)
vertex_freeze(vb)
#endregion
		
/// ### MISC STUFF ###
global.MOUSE_VECTOR = [0,0,0];

global.swaps = 0;

pulse = 0;

dev_register_command("tb_backface_culling", 
	function (args) {
		try {
			global.__BACKFACE_CULLING_ENABLED = real(args[0]);
			}
		catch (e) {
			debug_log("argument must be 1 or 0!",CONSOLE_ERROR_COL);
			show_debug_message("caught :" + string(e));
			}
		},1, "enable or disable backface culling", "[bool]")