/// @description Light Instance Creation

ds_list_add(global.ALL_LIGHTS,self); //add self to known lights

z = 0;
light_colour = 0;
light_strength = 0;
light_radius_multiplier = 1;
enabled = true;

if(DEBUG_SHOW_LIGHTS) {
	debugVisual = new RenderComponent(id, false, false);
	debugVisual.lightSize = 2;
	debugVisual.renderTexture = sprite_get_texture(sprLight,0);
	debugVisual.customShader = new BasicShaderBillboard();
	debugVisual.renderBuffer = undefined;
	debugVisual.renderMatrix = matrix_build(x,y,z,0,0,0,1,1,1)	
	}

function update_debug_visual() {
	if(!DEBUG_SHOW_LIGHTS) {return;}

	if(debugVisual.renderBuffer != undefined) {
		vertex_delete_buffer(debugVisual.renderBuffer)
		}

	var vb = vertex_create_buffer()
	vertex_begin(vb,global.VERTEX_FORMAT)
	define_floor(vb,r3(debugVisual.lightSize,-debugVisual.lightSize,0),r3(-debugVisual.lightSize,debugVisual.lightSize,0),r2_zero(),r2(1,1),light_colour,1,0);
	vertex_end(vb);
	vertex_freeze(vb);
	debugVisual.renderBuffer = vb;

	debugVisual.renderMatrix = matrix_build(x,y,z,0,0,0,1,1,1)	
	}
