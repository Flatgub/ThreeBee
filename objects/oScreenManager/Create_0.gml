/// @description ScreenManager Create

//var w = 768;
//var h = 672;

#macro DEBUG_ENABLED true

//window_set_size(w,h);
//global.SCREEN_WIDTH = round(w/3);
//global.SCREEN_HEIGHT = round(h/3);

var w = window_get_width();
var h = window_get_height();
global.WINDOW_WIDTH = window_get_width();
global.WINDOW_HEIGHT = window_get_height();
global.SCREEN_WIDTH = round(w/3);
global.SCREEN_HEIGHT = round(h/3);
global.VIEWPORT_WIDTH = global.WINDOW_WIDTH;
global.VIEWPORT_HEIGHT = global.WINDOW_HEIGHT;

instance_create_depth(0,0,-10000,oDevConsole);

instance_create_layer(0,0,"Instances",oRenderer);
//instance_create_layer(0,0,"Instances",oCollisionManager);



//surface_resize(application_surface,global.SCREEN_WIDTH,global.SCREEN_HEIGHT)

//display_set_gui_size(global.SCREEN_WIDTH,global.SCREEN_HEIGHT)
//surface_resize(application_surface,global.SCREEN_WIDTH,global.SCREEN_HEIGHT);

show_debug_overlay(false)

#macro mouseSensitivityBase 60
#macro mouseSensitivityScale 1
// global.MOUSELOCK = false;
global.SCREEN_CENTER_X = global.WINDOW_WIDTH/2;
global.SCREEN_CENTER_Y = global.WINDOW_HEIGHT/2;
// window_mouse_set(global.SCREEN_CENTER_X,global.SCREEN_CENTER_Y);
// window_set_cursor(global.MOUSELOCK ? cr_none : cr_default);

global.OBJA_IMPORT_VERBOSE = false;

global.AMBIENT_LIGHT_COLOUR = [0.25, 0.25, 0.25]

create_light(16,16,16,c_white,500)

if(DEBUG_ENABLED) {
	instance_create_layer(0,0,"Instances",oThreeBeeDevTools);
	}