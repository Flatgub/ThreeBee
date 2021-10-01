/// @function mat_create(x, y, z, toX, toY, toZ, upX, upY, upZ, xScale, yScale, zScale)
function mat_create(px, py, pz, toX, toY, toZ, upX, upY, upZ, scX, scY, scZ) {
	//Creates a 4x4 matrix with the to-direction as master
	/*
	Script made by TheSnidr
	www.thesnidr.com
	*/

	var l, dot;

	//Normalize to-vector
	l = sqrt(sqr(toX) + sqr(toY) + sqr(toZ));
	if (l > 0)
	{
		l = 1 / l;
	}
	else
	{
		show_debug_message("ERROR in script mat_create: Supplied zero-length vector for to-vector.");
	}
	toX *= l;
	toY *= l;
	toZ *= l;

	//Orthogonalize up-vector to to-vector
	dot = upX * toX + upY * toY + upZ * toZ;
	upX -= toX * dot;
	upY -= toY * dot;
	upZ -= toZ * dot;

	//Normalize up-vector
	l = sqrt(sqr(upX) + sqr(upY) + sqr(upZ));
	if (l > 0)
	{
		l = 1 / l;
	}
	else
	{
		show_debug_message("ERROR in script mat_create: Supplied zero-length vector for up-vector, or the up- and to-vectors are parallel.");
	}
	upX *= l;
	upY *= l;
	upZ *= l;

	//Create side vector
	var siX, siY, siZ;
	siX = upY * toZ - upZ * toY;
	siY = upZ * toX - upX * toZ;
	siZ = upX * toY - upY * toX;

	//Return a 4x4 matrix
	return [toX * scX, toY * scX, toZ * scX, 0,
			siX * scY, siY * scY, siZ * scY, 0,
			upX * scZ, upY * scZ, upZ * scZ, 0,
			px,  py,  pz,  1];


}

/// @function mat_create_from_dualquat(Q)
/// @param	Q	{DualQuaternion}
function mat_create_from_dualquat(Q) {
	//Dual quaternion must be normalized
	//Source: http://en.wikipedia.org/wiki/Dual_quaternion
	gml_pragma("forceinline");
	return [
		sqr(Q[3]) + sqr(Q[0]) - sqr(Q[1]) - sqr(Q[2]), 
		2 * (Q[0] * Q[1] + Q[2] * Q[3]), 
		2 * (Q[0] * Q[2] - Q[1] * Q[3]), 
		0,

		2 * (Q[0] * Q[1] - Q[2] * Q[3]), 
		sqr(Q[3]) - sqr(Q[0]) + sqr(Q[1]) - sqr(Q[2]), 
		2 * (Q[1] * Q[2] + Q[0] * Q[3]), 
		0,

		2 * (Q[0] * Q[2] + Q[1] * Q[3]), 
		2 * (Q[1] * Q[2] - Q[0] * Q[3]), 
		sqr(Q[3]) - sqr(Q[0]) - sqr(Q[1]) + sqr(Q[2]), 
		0,

		2 * (-Q[7] * Q[0] + Q[4] * Q[3] + Q[6] * Q[1] - Q[5] * Q[2]), 
		2 * (-Q[7] * Q[1] + Q[5] * Q[3] + Q[4] * Q[2] - Q[6] * Q[0]), 
		2 * (-Q[7] * Q[2] + Q[6] * Q[3] + Q[5] * Q[0] - Q[4] * Q[1]), 
		1];}


/// @function mat_transform(matrix, vec4)
function mat_transform(M, v) {
	gml_pragma("forceinline")
	return [v[0] * M[0] + v[1] * M[4] + v[2] * M[8] + v[3] * M[12],
			   v[0] * M[1] + v[1] * M[5] + v[2] * M[9] + v[3] * M[13],
			   v[0] * M[2] + v[1] * M[6] + v[2] * M[10] + v[3] * M[14],
			   v[0] * M[3] + v[1] * M[7] + v[2] * M[11] + v[3] * M[15]]
	}

/// @function mat_invert(matrix)
/// @desc Returns the inverse of a 4x4 matrix
/// @param matrix
function mat_invert(M) {

	var inv = array_create(16);
	inv[0] = M[5]  * M[10] * M[15] - 
	        M[5]  * M[11] * M[14] - 
	        M[9]  * M[6]  * M[15] + 
	        M[9]  * M[7]  * M[14] +
	        M[13] * M[6]  * M[11] - 
	        M[13] * M[7]  * M[10];

	inv[4] = -M[4]  * M[10] * M[15] + 
	            M[4]  * M[11] * M[14] + 
	            M[8]  * M[6]  * M[15] - 
	            M[8]  * M[7]  * M[14] - 
	            M[12] * M[6]  * M[11] + 
	            M[12] * M[7]  * M[10];

	inv[8] = M[4]  * M[9] * M[15] - 
	            M[4]  * M[11] * M[13] - 
	            M[8]  * M[5] * M[15] + 
	            M[8]  * M[7] * M[13] + 
	            M[12] * M[5] * M[11] - 
	            M[12] * M[7] * M[9];

	inv[12] = -M[4]  * M[9] * M[14] + 
	            M[4]  * M[10] * M[13] +
	            M[8]  * M[5] * M[14] - 
	            M[8]  * M[6] * M[13] - 
	            M[12] * M[5] * M[10] + 
	            M[12] * M[6] * M[9];

	inv[1] = -M[1]  * M[10] * M[15] + 
	            M[1]  * M[11] * M[14] + 
	            M[9]  * M[2] * M[15] - 
	            M[9]  * M[3] * M[14] - 
	            M[13] * M[2] * M[11] + 
	            M[13] * M[3] * M[10];

	inv[5] = M[0]  * M[10] * M[15] - 
	            M[0]  * M[11] * M[14] - 
	            M[8]  * M[2] * M[15] + 
	            M[8]  * M[3] * M[14] + 
	            M[12] * M[2] * M[11] - 
	            M[12] * M[3] * M[10];

	inv[9] = -M[0]  * M[9] * M[15] + 
	            M[0]  * M[11] * M[13] + 
	            M[8]  * M[1] * M[15] - 
	            M[8]  * M[3] * M[13] - 
	            M[12] * M[1] * M[11] + 
	            M[12] * M[3] * M[9];

	inv[13] = M[0]  * M[9] * M[14] - 
	            M[0]  * M[10] * M[13] - 
	            M[8]  * M[1] * M[14] + 
	            M[8]  * M[2] * M[13] + 
	            M[12] * M[1] * M[10] - 
	            M[12] * M[2] * M[9];

	inv[2] = M[1]  * M[6] * M[15] - 
	            M[1]  * M[7] * M[14] - 
	            M[5]  * M[2] * M[15] + 
	            M[5]  * M[3] * M[14] + 
	            M[13] * M[2] * M[7] - 
	            M[13] * M[3] * M[6];

	inv[6] = -M[0]  * M[6] * M[15] + 
	            M[0]  * M[7] * M[14] + 
	            M[4]  * M[2] * M[15] - 
	            M[4]  * M[3] * M[14] - 
	            M[12] * M[2] * M[7] + 
	            M[12] * M[3] * M[6];

	inv[10] = M[0]  * M[5] * M[15] - 
	            M[0]  * M[7] * M[13] - 
	            M[4]  * M[1] * M[15] + 
	            M[4]  * M[3] * M[13] + 
	            M[12] * M[1] * M[7] - 
	            M[12] * M[3] * M[5];

	inv[14] = -M[0]  * M[5] * M[14] + 
	            M[0]  * M[6] * M[13] + 
	            M[4]  * M[1] * M[14] - 
	            M[4]  * M[2] * M[13] - 
	            M[12] * M[1] * M[6] + 
	            M[12] * M[2] * M[5];

	inv[3] = -M[1] * M[6] * M[11] + 
	            M[1] * M[7] * M[10] + 
	            M[5] * M[2] * M[11] - 
	            M[5] * M[3] * M[10] - 
	            M[9] * M[2] * M[7] + 
	            M[9] * M[3] * M[6];

	inv[7] = M[0] * M[6] * M[11] - 
	            M[0] * M[7] * M[10] - 
	            M[4] * M[2] * M[11] + 
	            M[4] * M[3] * M[10] + 
	            M[8] * M[2] * M[7] - 
	            M[8] * M[3] * M[6];

	inv[11] = -M[0] * M[5] * M[11] + 
	            M[0] * M[7] * M[9] + 
	            M[4] * M[1] * M[11] - 
	            M[4] * M[3] * M[9] - 
	            M[8] * M[1] * M[7] + 
	            M[8] * M[3] * M[5];

	inv[15] = M[0] * M[5] * M[10] - 
	            M[0] * M[6] * M[9] - 
	            M[4] * M[1] * M[10] + 
	            M[4] * M[2] * M[9] + 
	            M[8] * M[1] * M[6] - 
	            M[8] * M[2] * M[5];

	var _det = M[0] * inv[0] + M[1] * inv[4] + M[2] * inv[8] + M[3] * inv[12];
	if ( _det == 0 ) {
	    show_error( "The determinant is zero.", false );
	    return M;
	}

	_det = 1 / _det;
	for( var i = 0; i < 16; i++ ){inv[i] *= _det;}
	return inv;


}