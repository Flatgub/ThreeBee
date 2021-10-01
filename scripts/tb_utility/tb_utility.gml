/// @function point_rotate(point,angle);
/// @param point
/// @param angle
function point_rotate(point,angle) {
	var _x = point[COMP_X];
	var _y = point[COMP_Y];
	
	var _dx = _x*dcos(angle) - _y*dsin(angle);
	var _dy = _y*dcos(angle) + _x*dsin(angle);
	
	return r2(_dx,_dy);
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