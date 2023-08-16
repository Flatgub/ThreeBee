/// @description ScreenManager Step

if(global.MAIN_CAMERA != undefined) {
	//global.MOUSE_VECTOR = get_camera_mouse_vector(global.MAIN_CAMERA);
	}
else {
	global.MOUSE_VECTOR = r3_zero();
	}

if(recenterRequired == 0) {
	window_center()
	recenterRequired = -1;
	}
else if(recenterRequired>0) {recenterRequired--}
