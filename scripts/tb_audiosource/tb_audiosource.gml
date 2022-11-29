//possibly wont need these forever
#macro EFFECT_BITCRUSH	AudioEffectType.Bitcrusher
#macro EFFECT_DELAY		AudioEffectType.Delay
#macro EFFECT_GAIN		AudioEffectType.Gain
#macro EFFECT_LOWPASS	AudioEffectType.LPF2
#macro EFFECT_HIGHPASS	AudioEffectType.HPF2
#macro EFFECT_REVERB	AudioEffectType.Reverb1



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
	if !instance_exists(source) {printf("audio_source_play failed: audio source {0} doesn't exist",source);return -1;}

	return audio_play_sound_on(source.emitter,sound,loops,priority);

}

/// @function audio_source_set_gain(source, gain)
/// @param source
/// @param gain
function audio_source_set_gain(source, gain) {
	if !instance_exists(source) {printf("audio_source_set_gain failed: audio source {0} doesn't exist",source);return;}

	audio_emitter_gain(source.emitter,gain)
}

/// @function audio_source_set_falloff(source, min_dist, max_dist)
/// @param source
/// @param min_dist
/// @param max_dist
function audio_source_set_falloff(source, min_dist, max_dist) {

	if !instance_exists(source) {printf("audio_source_set_falloff failed: audio source {0} doesn't exist",source);return;}

	audio_emitter_falloff(source.emitter,min_dist,max_dist,1);
}

/// @function audio_source_set_pitch(source, pitch)
/// @param source
/// @param pitch
function audio_source_set_pitch(source, pitch) {
	if !instance_exists(source) {printf("audio_source_set_pitch failed: audio source {0} doesn't exist",source);return;}

	audio_emitter_pitch(source.emitter,pitch)
}
	
/// @function audio_source_assign_bus(source, bus)
/// @param	{Id.oAudioSource}	source	
/// @param	{Struct.AudioBus}	bus
function audio_source_assign_bus(source, bus) {
	if !instance_exists(source) {printf("audio_source_assign_bus failed: audio source {0} doesn't exist",source);return;}
	
	if(!is_undefined(source.effects_bus)) {
		delete source.effects_bus;
		}
	
	audio_emitter_bus(source.emitter, bus);
	source.effects_bus = bus;
	}
	
/// @function audio_source_reset_bus(source)
/// @param	{Id.oAudioSource}	source
function audio_source_reset_bus(source) {
	if !instance_exists(source) {printf("audio_source_reset_bus failed: audio source {0} doesn't exist",source);return;}
	
	audio_emitter_bus(source.emitter,audio_bus_main);
	source.effects_bus = undefined;
	}
	
/// @function audio_source_set_effect(source, effect, slot)
/// @param	{Id.oAudioSource}		source
/// @param	{Struct.AudioEffect}	effect	the audio effect to assign (from audio_effect_create)
/// @param	{Real}					slot	the slot to assign
function audio_source_set_effect(source, effect, slot) {
	if !instance_exists(source) {printf("audio_source_set_effect failed: audio source {0} doesn't exist",source);return;}
	if is_undefined(source.effects_bus) {printf("audio_source_set_effect failed: audio source {0} doesn't have an effect bus",source);return;}
	if slot < 0 || slot >= 8 {printf("audio_source_set_effect failed: effect slot {0} is out of range 0-7",slot);return;}
	
	source.effects_bus.effects[slot] = effect;
	}

/// @function audio_source_reset_effect(source, slot)
/// @param	{Id.oAudioSource}		source
/// @param	{Real}					slot	the slot to reset
function audio_source_reset_effect(source, slot) {
	if !instance_exists(source) {printf("audio_source_reset_effect failed: audio source {0} doesn't exist",source);return;}
	if is_undefined(source.effects_bus) {printf("audio_source_reset_effect failed: audio source {0} doesn't have an effect bus",source);return;}
	if slot < 0 || slot >= 8 {printf("audio_source_reset_effect failed: effect slot {0} is out of range 0-7",slot);return;}
	
	source.effects_bus.effects[slot] = undefined;
	}
	
/// @function audio_source_reset_effect(source, slot)
/// @param	{Id.oAudioSource}		source
/// @param	{Real}					slot	the slot to assign
/// @returns	{Struct.AudioEffect}
function audio_source_get_effect(source, slot) {
	if !instance_exists(source) {printf("audio_source_get_effect failed: audio source {0} doesn't exist",source);return undefined;}
	if is_undefined(source.effects_bus) {printf("audio_source_get_effect failed: audio source {0} doesn't have an effect bus",source);return undefined;}
	if slot < 0 || slot >= 8 {printf("audio_source_get_effect failed: effect slot {0} is out of range 0-7",slot);return undefined;}
	
	return source.effects_bus.effects[slot];
	}