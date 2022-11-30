
/// @function __tb_create_camera(view, width, height, near, far, enabled, shader)
/// @description	INTERNAL does most of the common work for creating a camera without the proj matrix
///					the camera this returns IS NOT READY FOR USE
function __tb_create_camera(view, width, height, near, far, enabled, shader) {
	var newCamera = instance_create_layer(0,0,global.CAMERA_LAYER,oCamera);

	newCamera.view = view;
	newCamera.width = width;
	newCamera.height = height;
	newCamera.zNear = near;
	newCamera.zFar = far;
	newCamera.enabled = enabled;

	view_set_wport(view,width);
	view_set_hport(view,height);
	view_set_xport(view,0);
	view_set_yport(view,0);

	if(enabled) {view_set_visible(view,true);}
	else {view_set_visible(view,false);}

	newCamera.gmCamera = camera_create();

	newCamera.aspect = -(width/height);

	newCamera.cameraMatrix = matrix_build_identity();

	view_set_camera(view, newCamera.gmCamera);

	camera_set_update_script(view_camera[view],__tb_update_camera);

	ds_map_set(global.VIEW_CAMERA_MAP,view,newCamera);
	ds_list_add(global.ALL_CAMERAS,newCamera);

	newCamera.cameraShader = shader;

	//if this is the first camera, make it the main camera
	if(global.MAIN_CAMERA == undefined) {newCamera.make_main();}

	return newCamera;
	}

/// @function define_camera_perspective(view, width, height, fov, near, far, enabled, shader)
/// @param {Real}				viewID	The GM View ID to bind this camera to (0-7)
/// @param {Real}				width	The width of the viewport
/// @param {Real}				height	The height of the viewport
/// @param {Real}				foV		The field of vision for the camera (in degrees)
/// @param {Real}				near	The distance of the near clipping plane
/// @param {Real}				far		The distance of the far clipping plane
/// @param {Bool}				enabled	Whether the camera should start enabled or disabled
/// @param {Struct.TBShader}	shader	The shader to use for this camera
/// @returns {oCamera}
function define_camera_perspective(view, width, height, fov, near, far, enabled, shader) {

	var newCamera = __tb_create_camera(view, width, height, near, far, enabled, shader)
	newCamera.fov = fov;

	newCamera.projectionMode = TB_CameraModes.Perspective;	
	newCamera.projectionMatrix = matrix_build_projection_perspective_fov(fov,(width/height),near,far);
	camera_set_proj_mat(newCamera.gmCamera,newCamera.projectionMatrix);
	
	return newCamera;
}

/// @function define_camera_orthographic(view, width, height, near, far, enabled, shader)
/// @param {Real}				viewID	The GM View ID to bind this camera to (0-7)
/// @param {Real}				width	The width of the viewport
/// @param {Real}				height	The height of the viewport
/// @param {Real}				near	The distance of the near clipping plane
/// @param {Real}				far		The distance of the far clipping plane
/// @param {Bool}				enabled	Whether the camera should start enabled or disabled
/// @param {Struct.TBShader}	shader	The shader to use for this camera
/// @returns {oCamera}
function define_camera_orthographic(view, width, height, near, far, enabled, shader) {

	var newCamera = __tb_create_camera(view, width, height, near, far, enabled, shader)
	newCamera.fov = -1;

	newCamera.projectionMode = TB_CameraModes.Orthographic;	
	newCamera.projectionMatrix = matrix_build_projection_ortho(width,height,near,far);
	camera_set_proj_mat(newCamera.gmCamera,newCamera.projectionMatrix);
	
	return newCamera;
}

/// @function delete_camera(camera)
/// @param {Id.oCamera}	camera
function delete_camera(cam) {
	//if this is the main camera, unmark it as such
	if(global.MAIN_CAMERA == cam) {global.MAIN_CAMERA = undefined;}
	
	ds_list_delete(global.ALL_CAMERAS,ds_list_find_index(global.ALL_CAMERAS,cam));
	ds_map_delete(global.VIEW_CAMERA_MAP,cam.view);

	view_set_visible(cam.view,false);
	view_set_camera(cam.view,/*#cast*/ -1);
	camera_destroy(cam.gmCamera);
	
	if(cam.targetSurface != undefined && surface_exists(cam.targetSurface)) {
		surface_free(cam.targetSurface)
		}
	
	cam._dead = true;
	instance_destroy(cam);
	}

/// @function camera_enabled(camera, enabled)
/// @param {oCamera}	cam
/// @param {bool}		enabled
function camera_enabled(cam,enabled) {
	cam.enabled = enabled;
	view_set_visible(cam.view,enabled);
	camera_use_surface(cam,(cam.targetSurface != undefined));
	}
	
/// @function camera_use_surface(camera, enabled)
/// @description controls whether a camera should output to a surface instead of the screen
/// @param {Id.oCamera}	camera	the camera to use
/// @param {bool}		enabled	whether the camera should output to a surface
function camera_use_surface(cam,enabled) {
	if(enabled) {
		if(cam.targetSurface == undefined || (cam.targetSurface != undefined && !surface_exists(cam.targetSurface))) {
			cam.targetSurface = surface_create(cam.width,cam.height);
			}
		view_surface_id[cam.view] = cam.targetSurface; //render to the new surface
		}
	else{
		if(cam.targetSurface != undefined) {
			if(surface_exists(cam.targetSurface)) {surface_free(cam.targetSurface);};
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
/// @param {oCamera}	cam
function get_camera_lookat_vector(cam) {
	var tiltDegree = lengthdir_x(1,-(cam.pitch));

	var lookPosX = lengthdir_x(tiltDegree,cam.yaw);
	var lookPosY = lengthdir_y(tiltDegree,cam.yaw);
	var lookPosZ = lengthdir_y(1,-(cam.pitch));

	return r3(lookPosX,lookPosY,lookPosZ);
}

/// @function get_camera_mouse_vector(camera)
/// @param {Id.oCamera}	cam
function get_camera_mouse_vector(cam) {

	var lookat = get_camera_lookat_vector(cam);
	var up = get_camera_up_vector(cam);

	return project_mouse_vector(lookat,up,cam.fov,cam.aspect);
	//return proj(lookat,up,cam.aspect,cam.fov);
}

/// @function get_camera_position_vector(camera)
/// @param {Id.oCamera}	cam
function get_camera_position_vector(cam) {
	return r3(cam.x,cam.y,cam.z);
}

/// @function get_camera_up_vector(camera)
/// @param {Id.oCamera}	cam	
function get_camera_up_vector(cam) {
	var upTiltDegree = lengthdir_x(1,-(cam.pitch-90));

	var upVecX = lengthdir_x(upTiltDegree,cam.yaw);
	var upVecY = lengthdir_y(upTiltDegree,cam.yaw);
	var upVecZ = lengthdir_y(1,-(cam.pitch-90));

	return r3(upVecX,upVecY,upVecZ);
}

/// @function camera_look_at(camera, _x, _y, _z)
/// @description turn the given camera to face towards the point
/// @param {Id.oCamera}	camera	The camera to turn
/// @param {Real}	x			The x coordinate to look at
/// @param {Real}	y			The y coordinate to look at
/// @param {Real}	z			The z coordinate to look at
function camera_look_at(camera, _x, _y, _z) {
	var tx = _x;
	var ty = _y;
	var tz = _z;

	camera.yaw = point_direction(camera.x,camera.y,tx,ty);
	var dist = point_distance(camera.x,camera.y,tx,ty);

	camera.pitch = clamp(angle_difference(0,point_direction(0,0,dist,tz-camera.z)),-89.9,89.9);
}

/// @function camera_turn_by(camera, yaw, pitch)
/// @description turn the camera relatively by a given yaw and pitch
/// @param {Id.oCamera}	camera	The camera to turn
/// @param {Real}		yaw		The amount to rotate the camera around the z axis (in degrees)
/// @param {Real}		pitch	The amount to tilt the camera up or down (in degrees)
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
	//TODO: this only works with projection cameras

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
	var MOUSE_X = WW-window_mouse_get_x();
	var MOUSE_Y = HH-window_mouse_get_y();

	// add UP*MOUSE_Y and X*MOUSE_X vector to TO vector
	mX = dX+uX*(1-2*MOUSE_Y/HH)+vX*(2*MOUSE_X/WW-1);
	mY = dY+uY*(1-2*MOUSE_Y/HH)+vY*(2*MOUSE_X/WW-1);
	mZ = dZ+uZ*(1-2*MOUSE_Y/HH)+vZ*(2*MOUSE_X/WW-1);
	mm = sqrt(mX*mX+mY*mY+mZ*mZ);

	// normalize mouse direction vector
	return [mX/mm, mY/mm, mZ/mm];
}

/// @function camera_point_to_screenspace(camera, point)
/// @description convert a 3D position into 2D screenspace coordinates
/// @param	{Id.oCamera}	camera	The camera to do the transformation using
/// @param	{Array<Real>}	point	The point to convert to 2D space
/// @returns	{Array<Real>}
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

/// @function __tb_update_camera()
/// @description	INTERNAL the update function assigned to each camera
function __tb_update_camera() {

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
		audio_listener_set_orientation(0,lookPosX-camX,lookPosY-camY,lookPosZ-camZ,upVecX,upVecY,-upVecZ);
		
		}
}
