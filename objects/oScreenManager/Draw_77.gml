if(global.USE_POSTFX) {
		
	postFXPanel.set_target()
	global.POSTFX_SHADER.shader_use();

	draw_clear(c_white)
	draw_surface(application_surface,0,0);
	

	surface_reset_target();

	shader_reset()

	postFXPanel.draw_ext(0,0,global.WINDOW_SCALE,global.WINDOW_SCALE,0,c_white,1);
	}
	
