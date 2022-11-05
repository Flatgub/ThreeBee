/// @description update tracked raycast objects

for(var i = 0; i < ds_list_size(global.RAYCAST_OBJECTS); i++) {
	global.RAYCAST_OBJECTS[| i].update()
	}