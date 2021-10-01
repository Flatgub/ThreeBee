/// @function SurfacePanel(width, height)
/// @param {real} width
/// @param {real} height
function SurfacePanel(_width,_height) constructor {
	surface = undefined;
	setWidth = _width;
	setHeight = _height;
	width = 1 << ceil(log2(_width));
	height = 1 << ceil(log2(_height));
	
	/// @function set_target()
	/// @description	use like surface_set_target(), ensures the surface exists before rendering
	static set_target = function() {
		if(is_undefined(surface) || !surface_exists(surface)) {
			surface = surface_create(width,height);
			}
		surface_set_target(surface);
		}
		
	/// @function check()
	/// @description basically surface_exists(), used to detect whether the surface has lost its contents
	static check = function() {
		if(is_undefined(surface) || !surface_exists(surface)) {
			return false;
			}
		return true;
		}
		
	/// @function draw(x, y)
	/// @param	{real}	x	the x position to draw the surface at
	/// @param	{real}	y	the y position to draw the surface at
	static draw = function(_x, _y) {
		if(!is_undefined(surface) && surface_exists(surface)) {
			draw_surface_part(surface,0,0,setWidth, setHeight, _x, _y);
			}
		}
		
	/// @function draw_ext(x, y, xscale, yscale, rot, col, alpha)
	/// @description	used exactly like draw_surface_ext
	static draw_ext = function(_x,_y,_xscale,_yscale,_rot,_col,_alpha) {
		if(!is_undefined(surface) && surface_exists(surface)) {
			draw_surface_general(surface, 0, 0, setWidth, setHeight, _x, _y, _xscale,_yscale,_rot,_col,_col,_col,_col,_alpha)
			}
		}
		
	/// @function draw_part(x, y, left, top, width, height)
	/// @description	used exactly like draw_surface_part
	static draw_part = function(_x,_y,_left,_top,_width,_height) {
		if(!is_undefined(surface) && surface_exists(surface)) {
			draw_surface_part(surface,_left,_top,_width,_height,_x,_y)
			}
		}
		
	/// @function resize(width, height, [copy])
	/// @description	used to resize the surfacePanel to a new size
	/// @param	{real}	width	the new width of the surface
	/// @param	{real}	height	the new heightof the surface
	/// @param	{bool}	[copy]	whether or not to keep the contents of the surface or allow it to be lost
	static resize = function(_width, _height) {
		var newWidth = 1 << ceil(log2(_width));
		var newHeight = 1 << ceil(log2(_height));
		var newSurface = surface_create(newWidth,newHeight);
		
		//draw the old surface onto the new surface is requested
		var copy = (argument_count == 3 ? argument[2] : false);
		if (copy && !is_undefined(surface) &&  surface_exists(surface)) {
			surface_set_target(newSurface)
			draw(0,0)
			surface_reset_target()
			}
			
		width = newWidth;
		height = newWidth;
		free()
		surface = newSurface;
		}
		
	/// @function to_buffer()
	/// @description	returns a new buffer with a copy of the surface's content
	static to_buffer = function() {
		var buffer = buffer_create(4 * width * height,buffer_grow,1);
		if(check()) {
			buffer_get_surface(buffer,surface,0)
			}
		
		buffer_seek(buffer,buffer_seek_start,0)
		return buffer;
		}
		
	/// @function from_buffer(buffer)
	/// @description	used to set the contents of the surface with a buffer
	///                 the buffer must be the same size as the surface, and be alignment 1
	/// @param	{buffer}	buffer	the buffer to copy data from
	static from_buffer = function(_buffer) {
		var surfacesize = 4 * width * height; //each pixel is 4 bytes
		if(buffer_get_size(_buffer) < surfacesize) {throw "buffer/surface size mismatch (expected " + string(surfacesize) + " bytes, got " + string(buffer_get_size(_buffer)) +")" }
		if(buffer_get_alignment(_buffer) != 1) {throw "buffer/surface alignment mismatch (buffer is not alignment 1)"}
		
		if(is_undefined(surface) || !surface_exists(surface)) {
			surface = surface_create(width,height);
			}
		buffer_set_surface(_buffer, surface, 0);
		}
		
		
	/// @function free()
	/// @description	use like surface_free()
	static free = function() {
		if(!is_undefined(surface) && surface_exists(surface)) {surface_free(surface);}
		}
	}
	