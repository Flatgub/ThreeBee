/// @function define_camera(view, width, height, fov, near, far, enabled, shader)
/// @param viewID
/// @param width
/// @param height
/// @param foV
/// @param near
/// @param far
/// @param enabled
/// @param shader
function define_camera(view, width, height, fov, near, far, vis, shader) {

	var newCamera = instance_create_layer(0,0,global.CAMERA_LAYER,oCamera);

	newCamera.view = view;
	newCamera.width = width;
	newCamera.height = height;
	newCamera.zNear = near;
	newCamera.zFar = far;
	newCamera.fov = fov;
	newCamera.enabled = vis;

	view_set_wport(view,width);
	view_set_hport(view,height);
	view_set_xport(view,0);
	view_set_yport(view,0);

	if vis {view_set_visible(view,true)}
	else {view_set_visible(view,false)}

	newCamera.gmCamera = camera_create();

	newCamera.aspect = -(width/height);

	newCamera.cameraMatrix = matrix_build_identity();
	newCamera.projectionMatrix = matrix_build_projection_perspective_fov(fov,(width/height),near,far);

	camera_set_proj_mat(newCamera.gmCamera,newCamera.projectionMatrix);

	view_set_camera(view, newCamera.gmCamera);

	camera_set_update_script(view_camera[view],update_camera);

	ds_map_set(global.VIEW_CAMERA_MAP,view,newCamera);
	ds_list_add(global.ALL_CAMERAS,newCamera);

	newCamera.cameraShader = shader;

	//if this is the first camera, make it the main camera
	if(global.MAIN_CAMERA == undefined) {newCamera.make_main()}

	return newCamera;
}

/// @function delete_camera(camera)
/// @param camera
function delete_camera(cam) {
	//if this is the main camera, unmark it as such
	if(global.MAIN_CAMERA == cam) {global.MAIN_CAMERA = undefined}
	
	ds_list_delete(global.ALL_CAMERAS,ds_list_find_index(global.ALL_CAMERAS,cam));
	ds_map_delete(global.VIEW_CAMERA_MAP,cam.view);

	view_set_visible(view,false);
	view_set_camera(view,-1);
	camera_destroy(cam.gmCamera);
	
	cam._dead = true;
	instance_destroy(cam);
	}

/// @function camera_enabled(camera, enabled)
/// @param cam
/// @param enabled
function camera_enabled(cam,enabled) {
	cam.enabled = enabled;
	view_set_visible(cam.view,enabled)
	camera_use_surface(cam,cam.targetSurface != undefined);
	}
	
/// @function camera_use_surface(camera,boolean)
/// @param cam
/// @param option
function camera_use_surface(cam,option) {
	if(option) {
		if(cam.targetSurface == undefined || (cam.targetSurface != undefined && !surface_exists(cam.targetSurface))) {
			cam.targetSurface = surface_create(cam.width,cam.height);
			}
		view_surface_id[cam.view] = cam.targetSurface; //render to the new surface
		}
	else{
		if(cam.targetSurface != undefined) {
			if(surface_exists(cam.targetSurface)) {surface_free(cam.targetSurface)};
			view_surface_id[cam.view] = -1; //render to the screen again;
			cam.targetSurface = undefined;
			}
		}
	}	

/// @function camera_ready(camera)
/// @param cam
function camera_ready(cam) {
	if(cam.targetSurface != undefined) {
		//regenerate the surface if its missing
		if(!surface_exists(cam.targetSurface)) {
			cam.targetSurface = surface_create(cam.width,cam.height);
			view_surface_id[cam.view] = cam.targetSurface; 
			}
		}
	}

/// @function get_camera_lookat_vector(camera) 
/// @param camera
function get_camera_lookat_vector(cam) {
	var tiltDegree = lengthdir_x(1,-(cam.pitch))

	var lookPosX = lengthdir_x(tiltDegree,cam.yaw)
	var lookPosY = lengthdir_y(tiltDegree,cam.yaw)
	var lookPosZ = lengthdir_y(1,-(cam.pitch))

	return r3(lookPosX,lookPosY,lookPosZ);
}

/// @function get_camera_mouse_vector(camera)
/// @param camera
function get_camera_mouse_vector(cam) {

	var lookat = get_camera_lookat_vector(cam);
	var up = get_camera_up_vector(cam);

	return project_mouse_vector(lookat,up,cam.fov,cam.aspect);
	//return proj(lookat,up,cam.aspect,cam.fov);
}

/// @function get_camera_position_vector(camera)
/// @param camera
function get_camera_position_vector(cam) {
	return r3(cam.x,cam.y,cam.z);
}

/// @function get_camera_up_vector(camera)
/// @param camera
function get_camera_up_vector(cam) {
	var upTiltDegree = lengthdir_x(1,-(cam.pitch-90))

	var upVecX = lengthdir_x(upTiltDegree,cam.yaw)
	var upVecY = lengthdir_y(upTiltDegree,cam.yaw)
	var upVecZ = lengthdir_y(1,-(cam.pitch-90))

	return r3(upVecX,upVecY,upVecZ);
}

/// @function camera_look_at(camera, _x, _y, _z)
/// @param camera
/// @param x
/// @param y
/// @param z
function camera_look_at(camera, _x, _y, _z) {
	var tx = _x;
	var ty = _y;
	var tz = _z;

	camera.yaw = point_direction(camera.x,camera.y,tx,ty);
	var dist = point_distance(camera.x,camera.y,tx,ty);

	camera.pitch = clamp(angle_difference(0,point_direction(0,0,dist,tz-camera.z)),-89.9,89.9);
}

/// @function camera_turn_by(camera, yaw, pitch)
/// @param camera
/// @param yaw
/// @param pitch
function camera_turn_by(cam, yaw, pitch) {
	cam.yaw += yaw;
	cam.pitch += pitch;

	cam.yaw = (cam.yaw + 360)%360; //keep yaw between 0 and 360 degrees
	cam.pitch = clamp(cam.pitch,-89.9,89.9); //clamp pitch to straight up/down to stop camera pitching upside down
	}

/// @function project_mouse_vector(lookAtVector, upVector, fov, aspect)
/// @param lookAtVector
/// @param upVector
/// @param fov
/// @param aspect
function project_mouse_vector(lookAtVector, upVector, fov, aspect) {

	// modified version of a script originally written by "Yourself" of the gamemaker forums long ago
	// although the original thread is lost.
	// source from https://pastebin.com/aihHXWhp

	var mm,dX,dY,dZ,uX,uY,uZ,vX,vY,vZ,mX,mY,mZ,width,height,tFOV,asp;
	asp=aspect;

	// normalize TO vector
	var toVec = lookAtVector;
	dX = toVec[0];
	dY = toVec[1];
	dZ = toVec[2];

	// fix UP vector and normalize it
	var upVec = upVector;
	uX = upVec[0];
	uY = upVec[1];
	uZ = upVec[2];

	// make x vector using TO and UP
	vX = uY*dZ-dY*uZ;
	vY = uZ*dX-dZ*uX;
	vZ = uX*dY-dX*uY;

	tFOV = tan(fov*pi/360);
	uX *= tFOV;
	uY *= tFOV;
	uZ *= tFOV;
	vX *= tFOV*asp;
	vY *= tFOV*asp;
	vZ *= tFOV*asp;

	var WW = window_get_width();
	var HH = window_get_height();

	//this assumes the viewport for this camera fills the screen.
	var MOUSE_X = window_mouse_get_x();
	var MOUSE_Y = HH-window_mouse_get_y();

	// add UP*MOUSE_Y and X*MOUSE_X vector to TO vector
	mX = dX+uX*(1-2*MOUSE_Y/HH)+vX*(2*MOUSE_X/WW-1);
	mY = dY+uY*(1-2*MOUSE_Y/HH)+vY*(2*MOUSE_X/WW-1);
	mZ = dZ+uZ*(1-2*MOUSE_Y/HH)+vZ*(2*MOUSE_X/WW-1);
	mm = sqrt(mX*mX+mY*mY+mZ*mZ);

	// normalize mouse direction vector
	return [mX/mm, mY/mm, mZ/mm];
}

/// @function camera_point_to_screenspace(camera, vec3)
/// @description convert a 3D position into 2D screenspace coordinates
function camera_point_to_screenspace(camera, vec3) {
	var p4 = r4(vec3[0],vec3[1],vec3[2],1);

	var viewProjMat = matrix_multiply(camera.cameraMatrix,camera.projectionMatrix)
	var screenpoint = mat_transform(viewProjMat,p4)

	if(screenpoint[2] < 0) {return undefined};

	
	screenpoint[0] = screenpoint[0]/screenpoint[3];
	screenpoint[1] = screenpoint[1]/screenpoint[3];
	
	var pX = ((screenpoint[0]+1.0)/2.0)*global.WINDOW_WIDTH;
	var pY = ((screenpoint[1]+1.0)/2.0)*global.WINDOW_HEIGHT;
	
	return [pX, pY, screenpoint[2]]
	}

/// @function update_camera()
function update_camera() {

	var multi = 5;

	var cam = global.VIEW_CAMERA_MAP[? view_current];
	var camX = cam.x;
	var camY = cam.y;
	var camZ = cam.z;
	
	//var camX = floor(cam.x*multi)/multi;
	//var camY = floor(cam.y*multi)/multi;
	//var camZ = floor(cam.z*multi)/multi;

	//cam.x = camX;
	//cam.y = camY;
	//cam.z = camZ;

	var tiltDegree = lengthdir_x(32,-cam.pitch)

	var lookPosX = camX+lengthdir_x(tiltDegree,cam.yaw)
	var lookPosY = camY+lengthdir_y(tiltDegree,cam.yaw)
	var lookPosZ = camZ+lengthdir_y(32,-cam.pitch)

	//var lookPosX = round((camX+lengthdir_x(32,cam.yaw))*multi)/multi;
	//var lookPosY = round((camY+lengthdir_y(32,cam.yaw))*multi)/multi;
	//var lookPosZ = round((camZ+lengthdir_y(32,cam.pitch))*multi)/multi;

	cam.cameraMatrix = matrix_build_lookat(camX,camY,camZ,lookPosX,lookPosY,lookPosZ,0,0,-1);

	//global.MOUSE_VECTOR = update_mouse_vector(camX,camY,camZ,lookPosX,lookPosY,lookPosZ,0,0,1,cam.fov,cam.aspect);

	camera_set_view_mat(view_camera[cam.view],cam.cameraMatrix);

	if global.LISTENER_CAMERA == cam {
	
		var upTiltDegree = lengthdir_x(32,-(cam.pitch-90))

		var upVecX = lengthdir_x(upTiltDegree,cam.yaw)
		var upVecY = lengthdir_y(upTiltDegree,cam.yaw)
		var upVecZ = lengthdir_y(32,-(cam.pitch-90))
	
		audio_listener_set_position(0,cam.x,cam.y,cam.z)
		audio_listener_set_orientation(0,lookPosX-camX,lookPosY-camY,lookPosZ-camZ,upVecX,upVecY,upVecZ);
		
		}
}