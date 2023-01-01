/// @function vec2_rotate(point,angle);
/// @param {vec2}	point
/// @param {real}	angle
/// @param {vec2}	[out]	optional, an existing vector to put the modifications into
function point_rotate(point,angle) {
	var out = argument_count > 2 ? argument[2] : r2(0,0);
	var _x = point[COMP_X];
	var _y = point[COMP_Y];
	
	out[@ 0] = _x*dcos(angle) - _y*dsin(angle);
	out[@ 1] = _y*dcos(angle) + _x*dsin(angle);
	
	return out;
	}

/// @function angle_wrap(angle)
function angle_wrap(angle) {
	return (angle + 360) % 360;
	}
	
/// @function approach(value, target, speed)
function approach(value, target, _speed) {
	if (value < target) {
	    value += _speed;
	    if (value > target) {
			return target;
			}
		}
	else {
	    value -= _speed;
	    if (value < target) {
	        return target;
			}
		}
	return value;
	}

/// @function lazy_distance(x1,y1,x2,y2)
/// @param x1
/// @param y1
/// @param x2
/// @param y2
function lazy_distance(x1, y1, x2, y2) {
	gml_pragma("forceinline")
	var xx = x1 - x2;
	var yy = y1 - y2;
	return (xx*xx) + (yy*yy);
}

/// @function inverse_lerp(from, to, current)
function inverse_lerp(_from, _to, _value) {
	gml_pragma("forceinline");
	return (clamp(_value,_from,_to) - _from) / (_to - _from);
	}
	
function new_uuid() {
	var out = "";
	
	repeat(8) {out += string_char_at("1234567890abcdef",irandom_range(1,16))}
	out += "-"
	repeat(4) {out += string_char_at("1234567890abcdef",irandom_range(1,16))}
	out += "-"
	repeat(4) {out += string_char_at("1234567890abcdef",irandom_range(1,16))}
	out += "-"
	repeat(4) {out += string_char_at("1234567890abcdef",irandom_range(1,16))}
	out += "-"
	repeat(12) {out += string_char_at("1234567890abcdef",irandom_range(1,16))}
	
	return out;
	}
	
/// @function col_flip(col)
/// @param col
function col_flip(col) {
	return ((col & $FF) << 16) | (col & $FF00) | ((col & $FF0000) >> 16)
}


/// @function col_to_float_array(col)
/// @param col
function col_to_float_array(col) {
	return [color_get_red(col)/255, color_get_green(col)/255, color_get_blue(col)/255]
}

/// @function list_remove(list, value)
/// @param id
/// @param value
function list_remove(_list, _value) {
	var pos = ds_list_find_index(_list,_value)
	if(pos >= 0) {
		ds_list_delete(_list,pos)
		return true;
		}
	return false;
}

/// @function list_contains(list, value)
/// @param id
/// @param value
function list_contains(_list, _value) {
	return (ds_list_find_index(_list,_value) >= 0)
}


/// @function list_clone(list)
/// @param id
function list_clone(_list) {
	var newlist = ds_list_create();
	ds_list_copy(newlist,_list)
	return newlist;
}

/// @function array_clone(array)
function array_clone(_arr) {
	var l = array_length(_arr);
	var a = array_create(l);
	array_copy(a,0,_arr,0,l);
	return a;
	}

/// @function list_pop_random(_list)
/// @param id
function list_pop_random(list) {
	var index = irandom(ds_list_size(list)-1);
	var item = list[| index];
	ds_list_delete(list,index);
	return item;
}

/// @function list_get_random(_list)
/// @param id
function list_get_random(list) {
	var index = irandom(ds_list_size(list)-1);
	return list[| index];
}

/// @function list_pop_first(_list)
/// @param id
function list_pop_first(list) {
	var index = 0;
	var item = list[| index];
	ds_list_delete(list,index);
	return item;
}


/// @function foreach(list, function)
/// @description executes the function for each element of the list from start to end
//				 function must take the form func(element)
function foreach(_list, _func) {
	for(var i = 0; i < ds_list_size(_list); i++) {
		_func(_list[| i]);
		}
	} 
	
/// @function foreach_i(list, function)
/// @description executes the function for each element of the list from start to end, and provides the index as well
//				 function must take the form func(element, index)
function foreach_i(_list, _func) {
	for(var i = 0; i < ds_list_size(_list); i++) {
		_func(_list[| i], i);
		}
	} 
	
/// @function list_filter_first(list, testfunction)
/// @description executes the function for each element of the list from start to end, and returns the first element where
//				 the function returns true, else returns undefined;
//				 function must take the form func(element) and return a bool
function list_filter_first(_list, _testfunc) {
	for(var i = 0; i < ds_list_size(_list); i++) {
		if(_testfunc(_list[| i])) {return _list[| i];}
		}
	return undefined;
	}
	
/// @function array_find(array,value)
function array_find(_array,_value) {
	var size = array_length(_array);
	for(var i = 0; i < size; i++) {
		if(_array[@ i] == _value) {return i}
		}
	return -1;
	}
	
/// @function array_filter_first_index(array, testfunction)
/// @description executes the function for each element of the array from start to end, and returns the index of the 
//				 first element where the function returns true, else returns -1;
//				 function must take the form func(element) and return a bool
function array_filter_first_index(_array, _testfunc) {
	var size = array_length(_array);
	for(var i = 0; i < size; i++) {
		if(_testfunc(_array[@ i])) {return i}
		}
	return -1;
	}


///@function set_room_bg_col(colour)
///@param {Constant.Colour}	colour	the colour to set the room bg to
function set_room_bg_col(_colour) {
	layer_background_blend(layer_background_get_id("Background"), _colour);
	}
