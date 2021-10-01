///@func rnn(...)
///@desc Return a new square matrix up to 4 x 4 in size.
function rnn() {
	GMLINEAR_INLINE;
	switch (argument_count) {
		case 1:
			return [[argument[0]]];
		case 4:
			return [
				[argument[0], argument[1]],
				[argument[2], argument[3]],
			];
		case 9:
			return [
				[argument[0], argument[1], argument[2]],
				[argument[3], argument[4], argument[5]],
				[argument[6], argument[7], argument[8]],
			];
		case 16:
			return [
				[argument[0], argument[1], argument[2], argument[3]],
				[argument[4], argument[5], argument[6], argument[7]],
				[argument[8], argument[9], argument[10], argument[11]],
				[argument[12], argument[13], argument[14], argument[15]],
			];
		default:
			show_error("Expected 1, 4, 9 or 16 arguments, got " + string(argument_count) + ".", true);
	}
}

///@func rnn_identity(n)
///@arg {int} n
///@desc Return the nxn identity matrix.
function rnn_identity(n) {
	GMLINEAR_INLINE;
	var M = array_create(n);
	for (var i = n-1; i >= 0; --i) {
		var row = array_create(n, 0);
		row[@i] = 1;
		M[@i] = row;
	}
	return M;
}

///@func rnn_zero(n)
///@arg {int} n
///@desc Return the nxn zero matrix.
function rnn_zero(n) {
	GMLINEAR_INLINE;
	var M = array_create(n);
	for (var i = n-1; i >= 0; --i) {
		M[@i] = array_create(n, 0);
	}
	return M;
}

///@func rnn_clone(M, <Mout>)
///@arg {rnn} M The original nxn matrix
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If not specified, a new matrix will be created.
///@desc Return a clone of M.
function rnn_clone(M, Mout=rnn_zero(array_length(M))) {
	GMLINEAR_INLINE;
	var M_dim = array_length(M);
	for (var i = M_dim-1; i >= 0; --i) {
		array_copy(Mout[i], 0, M[i], 0, M_dim);
	}
	return Mout;
}
#macro rnn_clone_to rnn_clone

///@func rnn_add(M1, M2, <Mout>)
///@arg {rnn} M1 The first nxn matrix.
///@arg {rnn} M2 The second nxn matrix.
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If not specified, a new matrix will be created.
///@desc Return M1+M2.
function rnn_add(M1, M2, Mout=rnn_zero(array_length(M1))) {
	GMLINEAR_INLINE;
	var M_dim = array_length(M1);
	for (var i = M_dim-1; i >= 0; --i) {
		var M1_i = M1[i];
		var M2_i = M2[i];
		var Mout_i = Mout[i];
		for (var j = M_dim-1; j >= 0; --j) {
			Mout_i[@j] = M1_i[j]+M2_i[j];
		}
	}
	return Mout;
}
#macro rnn_add_to rnn_add

///@func rnn_subtract(M1, M2, <Mout>)
///@arg {rnn} M1 The first nxn matrix.
///@arg {rnn} M2 The second nxn matrix.
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If not specified, a new matrix will be created.
///@desc Return M1-M2.
function rnn_subtract(M1, M2, Mout=rnn_zero(array_length(M1))) {
	GMLINEAR_INLINE;
	var M_dim = array_length(M1);
	for (var i = M_dim-1; i >= 0; --i) {
		var M1_i = M1[i];
		var M2_i = M2[i];
		var Mout_i = Mout[i];
		for (var j = M_dim-1; j >= 0; --j) {
			Mout_i[@j] = M1_i[j]-M2_i[j];
		}
	}
	return Mout;
}
#macro rnn_subtract_to rnn_subtract

///@func rnn_scale(M, r, <Mout>)
///@arg {rnn} M The original nxn matrix
///@arg {real} r The scaling factor
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If not specified, a new matrix will be created.
///@desc Return rM.
function rnn_scale(M, r, Mout=rnn_zero(array_length(M))) {
	GMLINEAR_INLINE;
	var M_dim = array_length(M);
	for (var i = M_dim-1; i >= 0; --i) {
		var M_i = M[i];
		var Mout_i = Mout[i];
		for (var j = M_dim-1; j >= 0; --j) {
			Mout_i[@j] = r*M_i[j];
		}
	}
	return Mout;
}
#macro rnn_scale_to rnn_scale

///@func rnn_transpose(M, <Mout>)
///@arg {rnn} M The original nxn matrix
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If not specified, a new matrix will be created.
///@desc Return a transpose of M.
function rnn_transpose(M, Mout=rnn_zero(array_length(M))) {
	GMLINEAR_INLINE;
	var M_dim = array_length(M);
	for (var i = 0; i < M_dim; ++i) {
		var M_i = M[i];
		var Mout_i = Mout[i];
		for (var j = 0; j <= i; ++j) {
			var tmp = M_i[j];
			Mout_i[@j] = M[j][i];
			Mout[j][@i] = tmp;
		}
	}
	return Mout;
}
#macro rnn_transpose_to rnn_transpose

///@func rnn_multiply(M1, M2, <Mout>)
///@arg {rnn} M1 The first nxn matrix.
///@arg {rnn} M2 The second nxn matrix.
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If not specified, a new matrix will be created.
///@desc Return M1*M2.
function rnn_multiply(M1, M2, Mout=rnn_zero(array_length(M1))) {
	GMLINEAR_INLINE;
	var n = array_length(M1);
	var result = (Mout == M1 || Mout == M2) ? rnn_zero(n) : Mout;
	for (var i = n-1; i >= 0; --i) {
		var result_i = result[i];
		var M1_i = M1[i];
		for (var j = n-1; j >= 0; --j) {
			result_i[@j] = 0;
			for (var k = n-1; k >= 0; --k) {
				result_i[@j] += M1_i[k]*M2[k][j];
			}
		}
	}
	if (Mout == M1 || Mout == M2) {
		for (var i = n-1; i >= 0; --i) {
			array_copy(Mout[i], 0, result[i], 0, n);
		}
	}
	return Mout;
}
#macro rnn_multiply_to rnn_multiply

///@func rnn_transform(M, v, <vout>)
///@arg {rnn} M The nxn matrix.
///@arg {rn} v The n-dimensional vector to transform.
///@arg {rn} <vout> (Optional) The output n-dimensional vector to overwrite. If not specified, a new vector will be created.
///@desc Return Mv.
function rnn_transform(M, v, vout=[]) {
	GMLINEAR_INLINE;
	var n = array_length(M);
	var result = (v == vout) ? array_create(n, 0) : vout;
	for (var i = n-1; i >= 0; --i) {
		var M_i = M[i];
		result[@i] = 0;
		for (var j = n-1; j >= 0; --j) {
			result[@i] += M_i[j]*v[j];
		}
	}
	if (v == vout) {
		array_copy(vout, 0, result, 0, n);
	}
	return vout;
}
#macro rnn_transform_to rnn_transform

///@func rnn_invert(M, <Mout>)
///@arg {rnn} M The original nxn matrix
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If not specified, a new matrix will be created.
///@desc Return a inverse of M. If singular, return undefined.
function rnn_invert(M, Mout=rnn_zero(array_length(M))) {
	GMLINEAR_INLINE;
	var n = array_length(M);
	var original = rnn_clone(M);
	var result = rnn_identity(n);
	// For each row
	for (var i = 0; i < n; ++i) {
		//Find highest row among i through n-1 by absolute value of its ith entry
		var highest_row_i = i;
		var original_i = original[i];
		var result_i = result[i];
		var highest_row_abs = abs(original_i[i]);
		var current_row_abs;
		for (var ii = i+1; ii < n; ii++) {
			current_row_abs = abs(original[ii][i]);
			if (current_row_abs > highest_row_abs) {
				highest_row_i = ii;
				highest_row_abs = current_row_abs;
			}
		}
		//It is singular if the entire remaining column is 0
		if (highest_row_abs == 0) {
			return undefined;
		}
		//Swap the row on both the original and the result
		if (i != highest_row_i) {
			var original_highest_row_i = original[highest_row_i];
			var result_highest_row_i = result[highest_row_i];
			for (var j = 0; j < n; j++) {
				var tmp;
				tmp = original_i[j];
				original_i[@j] = original_highest_row_i[j];
				original_highest_row_i[@j] = tmp;
				tmp = result_i[j];
				result_i[@j] = result_highest_row_i[j];
				result_highest_row_i[@j] = tmp;
			}
		}
		//Scale down ith row on both the original and the result
		var scale_factor = original[i, i];
		for (var j = i+1; j < n; j++) {
			original_i[@j] /= scale_factor;
		}
		for (var j = 0; j < n; j++) {
			result_i[@j] /= scale_factor;
		}
		original_i[@i] = 1;
		//Do row subtraction on every other row, on the original and the result
		for (var ii = 0; ii < n; ii++) {
			if (ii != i) {
				var original_ii = original[ii];
				var result_ii = result[ii];
				var factor = original_ii[i];
				for (var j = i+1; j < n; j++) {
					original_ii[@j] -= factor*original_i[j];
				}
				for (var j = 0; j < n; j++) {
					result_ii[@j] -= factor*result_i[j];
				}
				original_ii[@i] = 0;
			}
		}
	}
	rnn_clone(result, Mout);
	return Mout;
}
#macro rnn_invert_to rnn_invert

///@func rnn_encode_string(M)
///@arg {rnn} M The nxn matrix to encode.
///@desc Return the string form of M.
function rnn_encode_string(M) {
	GMLINEAR_INLINE;
	var result = "";
	var n = array_length(M);
	for (var i = 0; i < n; ++i) {
		var M_i = M[i];
		for (var j = 0; j < n; ++j) {
			if (j > 0) result += ",";
			result += string_format(M_i[j], 15, 14);
		}
		if (i < n-1) {
			result += ";";
		}
	}
	return string_replace_all(result, " ", "");
}

///@func rnn_decode_string(str)
///@arg {string} str The string to decode.
///@arg {r44} <Mout> (Optional) The output nxn matrix to overwrite. If unspecified, return a new matrix.
///@desc Return the decoded form of str.
function rnn_decode_string(_str, Mout=rnn_zero(string_count(";", _str)+1)) {
	var str = _str;
	var i_dim = string_count(";", str);
	var cpos, spos, rowstr, j_dim, Mout_i;
	for (var i = 0; i < i_dim; i++) {
		spos = string_pos(";", str);
		rowstr = string_copy(str, 1, spos-1);
		str = string_delete(str, 1, spos);
		j_dim = string_count(",", rowstr);
		Mout_i = Mout[i];
		for (var j = 0; j < j_dim; j++) {
			cpos = string_pos(",", rowstr);
			Mout_i[@j] = real(string_copy(rowstr, 1, cpos-1));
			rowstr = string_delete(rowstr, 1, cpos);
		}
		Mout_i[@j_dim] = real(rowstr);
	}
	Mout_i = Mout[i_dim];
	for (var j = 0; j < j_dim; j++) {
		cpos = string_pos(",", str);
		Mout_i[@j] = real(string_copy(str, 1, cpos-1));
		str = string_delete(str, 1, cpos);
	}
	Mout_i[@j_dim] = real(str);
	return Mout;
}
#macro rnn_decode_string_to rnn_decode_string

///@func rnn_encode_base64(M)
///@arg {rnn} M The nxn matrix to encode.
///@desc Return the base64 form of nxn matrix M.
function rnn_encode_base64(M) {
	GMLINEAR_INLINE;
	var n = array_length(M);
	var nn8 = n*n*8;
	var buffer = buffer_create(nn8, buffer_fixed, 1);
	for (var i = 0; i < n; i++) {
		var M_i = M[i];
		for (var j = 0; j < n; j++) {
			buffer_write(buffer, buffer_f64, M_i[j]);
		}
	}
	var result = buffer_base64_encode(buffer, 0, nn8);
	buffer_delete(buffer);
	return result;
}

///@func rnn_decode_base64(enc, n, <Mout>)
///@arg {string} enc The string to decode.
///@arg {int} n
///@arg {rnn} <Mout> (Optional) The output nxn matrix to overwrite. If unspecified, return a new matrix.
///@desc Return the base64-decoded form of str.
function rnn_decode_base64(enc, n, Mout=rnn_zero(n)) {
	GMLINEAR_INLINE;
	var buffer = buffer_create(128, buffer_fixed, 1);
	buffer_base64_decode_ext(buffer, enc, 0);
	for (var i = 0; i < n; i++) {
		var Mout_i = Mout[i];
		for (var j = 0; j < n; j++) {
			Mout_i[@j] = buffer_read(buffer, buffer_f64);
		}
	}
	buffer_delete(buffer);
	return Mout;
}
#macro rnn_decode_base64_to rnn_decode_base64
