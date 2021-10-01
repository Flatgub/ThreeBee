/// @description Camera Cleanup

if(!_dead) {
	debug_alert("WARN: destroyed a camera instance without calling delete_camera() on it first!",CONSOLE_ERROR_COL);
	printf("WARN: destroyed a camera instance without calling delete_camera() on it first!");
	}