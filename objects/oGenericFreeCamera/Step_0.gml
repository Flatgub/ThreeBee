/// @description GenericFreeCam step

//automatic mouselock release
if(os_is_paused() || !window_has_focus() || global.CONSOLE_OPEN) {
	mouseLock = false;
	window_set_cursor(mouseLock ? cr_none : cr_default);
	}

//mouselock toggle
if(keyboard_check_pressed(vk_tab) && !global.CONSOLE_OPEN) {
	mouseLock = !mouseLock
	//window_mouse_set(global.SCREEN_CENTER_X,global.SCREEN_CENTER_Y);
	window_set_cursor(mouseLock ? cr_none : cr_default);
	
	if(mouseLock) {
		var cx = window_get_width()/2;
		var cy = window_get_height()/2;
		window_mouse_set(cx,cy);
		}
	}
	
//mouselook
if(mouseLock){
	var cx = window_get_width()/2;
	var cy = window_get_height()/2;
	var xAmnt = -(window_mouse_get_x() - cx)/window_get_width();
	var yAmnt = -(window_mouse_get_y() - cy)/window_get_height();
	
	var horiTurn = xAmnt * (mouseSensitivityBase + (mouseSensitivityBase*mouseSensitivityScale));
	var vertTurn = yAmnt * (mouseSensitivityBase + (mouseSensitivityBase*mouseSensitivityScale));
	
	camera_turn_by(thisCamera,-horiTurn,vertTurn);
	
	window_mouse_set(cx,cy);
	
	if thisCamera.pitch > 89 {thisCamera.pitch = 89;}
	}

facingDirection = thisCamera.yaw;


var targetX = 0
var targetY = 0
var targetZ = 0

if !global.CONSOLE_OPEN {
	if keyboard_check(vk_space) {targetZ = maxVerticalSpeed;}
	if keyboard_check(vk_shift) {targetZ = -maxVerticalSpeed;}

	if keyboard_check(ord("W")) {targetX = maxHorizontalSpeed;}
	if keyboard_check(ord("S")) {targetX = -maxHorizontalSpeed;}

	if keyboard_check(ord("A")) {targetY = maxHorizontalSpeed;}
	if keyboard_check(ord("D")) {targetY = -maxHorizontalSpeed;}
	}
	
var motionMagintude = point_distance(0,0,targetX,targetY);
var motionVector = point_direction(0,0,targetX,targetY);
		
desiredX = lengthdir_x(motionMagintude,facingDirection+motionVector);
desiredY = lengthdir_y(motionMagintude,facingDirection+motionVector);

xSpeed = approach(xSpeed,desiredX,horizontalAcceleration)
ySpeed = approach(ySpeed,desiredY,horizontalAcceleration)
zSpeed = approach(zSpeed,targetZ,verticalAcceleration);

//var oldX = x;
//var oldY = y;
//var oldZ = z;

x += xSpeed;
y += ySpeed;
z += zSpeed;

thisCamera.x = x;
thisCamera.y = y;
thisCamera.z = z;