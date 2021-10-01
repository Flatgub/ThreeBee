/// @description Light Cleanup

ds_list_delete(global.ALL_LIGHTS,ds_list_find_index(global.ALL_LIGHTS,id)); //remove self from known lights
if(DEBUG_SHOW_LIGHTS) {
	debugVisual.cleanup();
	}