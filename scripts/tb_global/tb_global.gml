function tb_init() {
	//WINDOW
	global.VIEWPORT_WIDTH = window_get_width();
	global.VIEWPORT_HEIGHT = window_get_height();	
	
	global.WINDOW_WIDTH = window_get_width();
	global.WINDOW_HEIGHT = window_get_height();
	global.WINDOW_SCALE = 1;
	
	global.SCREEN_CENTER_X = global.WINDOW_WIDTH/2;
	global.SCREEN_CENTER_Y = global.WINDOW_HEIGHT/2;
		
	//POSTFX
	global.USE_POSTFX = false;
	global.POSTFX_SHADER = undefined;
	
	oScreenManager.postFXPanel = new SurfacePanel(global.VIEWPORT_WIDTH, global.VIEWPORT_HEIGHT)
	}

/// @function tb_resize_window(width, height, scaleFactor)
/// @description set the size of the window along with pixel perfect scaling
/// @param	{Real}	width	the width of the window
/// @param	{Real}	height	the height of the window
/// @param	{Real}	scale	the factor to zoom the viewport by
function tb_resize_window(_width,_height,_scale) {
	
	global.VIEWPORT_WIDTH = _width;
	global.VIEWPORT_HEIGHT = _height;	

	surface_resize(application_surface,global.VIEWPORT_WIDTH,global.VIEWPORT_HEIGHT)

	var windowwidth = _width*_scale;
	var windowheight = _height*_scale;
	window_set_size(windowwidth,windowheight);
			
	global.WINDOW_WIDTH = windowwidth;
	global.WINDOW_HEIGHT = windowheight;	
	global.WINDOW_SCALE = _scale;
	
	global.SCREEN_CENTER_X = global.WINDOW_WIDTH/2;
	global.SCREEN_CENTER_Y = global.WINDOW_HEIGHT/2;
		
	display_set_gui_size(windowwidth, windowheight)
	
	oScreenManager.recenterRequired = 10;
	oScreenManager.postFXPanel.resize(global.VIEWPORT_WIDTH, global.VIEWPORT_HEIGHT)
	
	}
	
///@function tb_set_postfx(enabled, [shader])
///@param	{bool}			enabled		whether or not to use a postFX shader
///@param	{Struct.TBShader}	[shader]	the postFX shader to use
function tb_set_postfx(_enabled, _shader) {
	global.USE_POSTFX = _enabled
	application_surface_draw_enable(!_enabled)
	if(_enabled) {
		if(_shader != undefined) {global.POSTFX_SHADER = _shader}
		}
	}