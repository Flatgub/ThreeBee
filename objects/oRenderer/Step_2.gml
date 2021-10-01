/// @description Renderer End Step

for(var i = 0; i < ds_list_size(global.ALL_CAMERAS); i++) {
	var cam = global.ALL_CAMERAS[| i];
	if(cam.enabled && cam.lightingEnabled) {calculate_active_lights(cam);}
	}

