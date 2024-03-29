#macro QUAT_X 0
#macro QUAT_Y 1
#macro QUAT_Z 2
#macro QUAT_COS 3
#macro QUAT_W 3

#macro QUAT_I 0
#macro QUAT_J 1
#macro QUAT_K 2
#macro QUAT_R 3

/// @description quat_create(angle, ax, ay, az,)
/// @param angle
/// @param ax
/// @param ay
/// @param az
function quat_create(angle, ax, ay, az) {
	//Creates a quaternion from axis angle
	gml_pragma("forceinline");
	angle /= 2;
	var s = sin(angle);
	return [ax * s, ay * s, az * s, cos(angle)];
}

function quat_multiply(R, S) {
	gml_pragma("forceinline");
	return [R[3] * S[0] + R[0] * S[3] + R[1] * S[2] - R[2] * S[1], 
			R[3] * S[1] + R[1] * S[3] + R[2] * S[0] - R[0] * S[2], 
			R[3] * S[2] + R[2] * S[3] + R[0] * S[1] - R[1] * S[0], 
			R[3] * S[3] - R[0] * S[0] - R[1] * S[1] - R[2] * S[2]]
	}
	
function quat_normalize(quat) {
	var l = 1 / sqrt(sqr(quat[0]) + sqr(quat[1]) + sqr(quat[2]) + sqr(quat[3]));
	quat[@ 0] *= l
	quat[@ 1] *= l
	quat[@ 2] *= l
	quat[@ 3] *= l
	}
	
function quat_to_euler(Q) {
	//adapted from wikipedia (https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles)
	var out = []
	
	// roll (x-axis rotation)
    var sinr_cosp = 2 * (Q[QUAT_W] * Q[QUAT_X] + Q[QUAT_Y] * Q[QUAT_Z]);
    var cosr_cosp = 1 - 2 * (Q[QUAT_X] * Q[QUAT_X] + Q[QUAT_Y] * Q[QUAT_Y]);
    out[0] = arctan2(sinr_cosp, cosr_cosp);
	
	
	// pitch (y-axis rotation)
    var sinp = sqrt(1 + 2 * (Q[QUAT_W] * Q[QUAT_Y] - Q[QUAT_X] * Q[QUAT_Z]));
    var cosp = sqrt(1 - 2 * (Q[QUAT_W] * Q[QUAT_Y] - Q[QUAT_X] * Q[QUAT_Z]));

    out[1] = 2 * arctan2(sinp, cosp) - pi / 2;
	
	// yaw (z-axis rotation)
    var siny_cosp = 2 * (Q[QUAT_W] * Q[QUAT_Z] + Q[QUAT_X] * Q[QUAT_Y]);
    var cosy_cosp = 1 - 2 * (Q[QUAT_Y] * Q[QUAT_Y] + Q[QUAT_Z] * Q[QUAT_Z]);
    out[2] = arctan2(siny_cosp, cosy_cosp);
	
	return out;
	}
