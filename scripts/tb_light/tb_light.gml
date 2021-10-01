/// @function create_light(x, y, z, colour, strength);
/// @param x
/// @param y
/// @param z
/// @param colour
/// @param strenght
function create_light(_x, _y, _z, _colour, _strength) {

	var light = instance_create_layer(_x,_y,"Instances",oLight)
	light.z = _z;

	light.light_colour = _colour;
	light.light_strength = _strength;

	light.update_debug_visual();

	return light;
}


/// @param camera
function calculate_active_lights(camera) {
	if (!camera.lightingEnabled)  {return;}

	var queue = ds_priority_create();
	camera.numOfLights=0;


	var LIGHT_FOG_CLIPPING_DISTANCE = (global.FOG_END*global.FOG_END) + (200*200)

	for(var i = 0; i < ds_list_size(global.ALL_LIGHTS); i++) {
		var light = global.ALL_LIGHTS[| i];
	
		if !light.enabled {continue;}
	
		var dist = lazy_distance(camera.x,camera.y,light.x,light.y);
	
		//include all lights within a certain radius
		if dist <= LIGHT_DISTANCE_THRESHOLD { //why is this a macro?
			ds_priority_add(queue,light,dist);
			}
		//only include lights outside that radius which are within the camera's field of view (and aren't lost in the fog)
		else if dist <= LIGHT_FOG_CLIPPING_DISTANCE {
			var angle = point_direction(camera.x,camera.y,light.x,light.y)
			if abs(angle_difference(camera.yaw,angle)) < 90 {ds_priority_add(queue,light,dist);};
			}
	
		}
	
	var largeStep = 0;
	for(var i = 0; i < 8; i++) {
		if !ds_priority_empty(queue) { 
			var light = ds_priority_delete_min(queue);
			camera.activeLightPositions[largeStep] = light.x;
			camera.activeLightPositions[largeStep+1] = light.y;
			camera.activeLightPositions[largeStep+2] = light.z;
		
			camera.activeLightColours[largeStep] = light.light_colour & $FF;
			camera.activeLightColours[largeStep+1] = (light.light_colour >> 8) & $FF;
			camera.activeLightColours[largeStep+2] = (light.light_colour >> 16) & $FF;
			
			largeStep+=3;
		
			camera.activeLightStrengths[i] = light.light_strength;
			camera.numOfLights++;
			}	
		else { //pad the array with empty lights if there's less than 8
			camera.activeLightPositions[largeStep] = 0;
			camera.activeLightPositions[largeStep+1] = 0;
			camera.activeLightPositions[largeStep+2] = 0;
			camera.activeLightColours[largeStep] = 0;
			camera.activeLightColours[largeStep+1] = 0;
			camera.activeLightColours[largeStep+2] = 0;
			largeStep+=3;
			camera.activeLightStrengths[i] = 0;
			}
		}
	
	ds_priority_destroy(queue);


}