/// @description AudioSource Step

audio_emitter_position(emitter,x,y,z)

/*
if doppler {
	audio_emitter_velocity(emitter,x-lastX,y-lastY,z-lastZ);
	}
*/ 

lastX = x;
lastY = y;
lastZ = z;