/// @function audio_source_create(_x, _y, _z, min_distance, max_distance)
/// @param x
/// @param y
/// @param z
/// @param min_distance
/// @param max_distance
function audio_source_create(_x, _y, _z, min_distance, max_distance) {

	var source = instance_create_layer(_x,_y,"Instances",oAudioSource)
	source.z = _z;

	audio_emitter_falloff(source.emitter,min_distance,max_distance,1);

	//source.doppler = argument3;

	return source;
}

/// @function audio_listener_bind_to_camera(camera)
/// @param camera
function audio_listener_bind_to_camera(camera) {
	if !instance_exists(camera) {printf("cannot bind listener to camera " + string(camera) + ", does not exist");return;}

	global.LISTENER_CAMERA = camera;
}

/// @function audio_source_play(source, sound, loops, priority)
/// @param source
/// @param sound
/// @param loops
/// @param priority
function audio_source_play(source, sound, loops, priority) {
	if !instance_exists(source) {printf("audio_source_play failed: audio source %s doesn't exist",source);return -1;}

	return audio_play_sound_on(source.emitter,sound,loops,priority);

}

/// @function audio_source_set_gain(source, gain)
/// @param source
/// @param gain
function audio_source_set_gain(source, gain) {
	if !instance_exists(source) {printf("audio_source_set_gain failed: audio source %s doesn't exist",source);return;}

	audio_emitter_gain(source.emitter,gain)
}

/// @function audio_source_set_falloff(source, min_dist, max_dist)
/// @param source
/// @param min_dist
/// @param max_dist
function audio_source_set_falloff(source, min_dist, max_dist) {

	if !instance_exists(source) {printf("audio_source_set_falloff failed: audio source %s doesn't exist",source);return;}

	audio_emitter_falloff(source.emitter,min_dist,max_dist,1);
}

/// @function audio_source_set_pitch(source, pitch)
/// @param source
/// @param pitch
function audio_source_set_pitch(source, pitch) {
	if !instance_exists(source) {printf("audio_source_set_pitch failed: audio source %s doesn't exist",source);return;}

	audio_emitter_pitch(source.emitter,pitch)
}