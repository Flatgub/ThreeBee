/// @description ScreenManager Step

if(global.MAIN_CAMERA != undefined) {
	global.MOUSE_VECTOR = get_camera_mouse_vector(global.MAIN_CAMERA);
	}
else {
	global.MOUSE_VECTOR = r3_zero();
	}


/* disabled raycasting
if mouse_check_button_pressed(mb_left) {
	var pos = get_camera_position_vector(global.MAIN_CAMERA);
	var dir = get_camera_mouse_vector(global.MAIN_CAMERA);
	
	var ray = benchmark_start("ray_cay_all")
	var result = ray_cast_all(pos,dir,COLLISION_GENERIC)
	benchmark_end(ray);
	delete ray;
	
	ds_list_destroy(result);
	
	ray = benchmark_start("ray_cast_nearest")
	var result = ray_cast_nearest(pos,dir,COLLISION_GENERIC,99)
	benchmark_end(ray);
	delete ray;
	
	if result[RAY_RESULT_OBJECT] != noone {
		result[RAY_RESULT_OBJECT].renderTexture = result[RAY_RESULT_OBJECT].tex3;
		}
	
	
	}/*
