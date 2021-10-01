#macro INTERP_CONSTANT 0
#macro INTERP_LINEAR 1
#macro INTERP_BEZIER 2
#macro INTERP_SINE 3
#macro INTERP_QUAD 4
#macro INTERP_CUBIC 5
#macro INTERP_QUART 6
#macro INTERP_QUINT 7
#macro INTERP_EXPO 8
#macro INTERP_CIRC 9
#macro INTERP_BACK 10
#macro INTERP_BOUNCE 11
#macro INTERP_ELASTIC 12

global.INTERPOLATION_NAMES = ["CONSTANT","LINEAR","BEZIER","SINE","QUAD","CUBIC","QUART","QUINT","EXPO","CIRC","BACK","BOUNCE","ELASTIC"]
global.INTERPOLATION_VALUES = {
	CONSTANT: 0, LINEAR: 1, BEZIER: 2,
	SINE: 3, QUAD: 4, CUBIC: 5,
	QUART: 6, QUINT: 7, EXPO: 8,
	CIRC: 9, BACK: 10, BOUNCE: 11, ELASTIC: 12}
	


#macro EASE_IN 1
#macro EASE_OUT 2
#macro EASE_INOUT 3
#macro EASE_AUTO EASE_IN

global.EASE_NAMES = ["EASE_IN","EASE_OUT","EASE_IN_OUT"]
global.EASE_VALUES = {}
global.EASE_VALUES[$ "EASE_IN"] = 1
global.EASE_VALUES[$ "EASE_OUT"] = 2
global.EASE_VALUES[$ "EASE_IN_OUT"] = 3
global.EASE_VALUES[$ "AUTO"] = 1


//	General purpose easing functions
//	Formulas from: http://gizma.com/easing
//	Adapted by Flatgub

/// @function lerp_inverse(from, to, current)
function lerp_inverse(_from, _to, _value) {
	gml_pragma("forceinline");
	return (clamp(_value,_from,_to) - _from) / (_to - _from);
	}

/// @function ease_constant(from, to, time)
function ease_constant(_from, _to, _time) {
	gml_pragma("forceinline");
	return (_time < 1) ? _from : _to;
	}

/// @function ease_linear(from, to, time)
function ease_linear(_from, _to, _time) {	
	gml_pragma("forceinline")
	return lerp(_from, _to, _time);
	}

/// @function ease_sine(from, to, time, direction)
function ease_sine(_from, _to, _time, _direction) {
	gml_pragma("forceinline")
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta * (cos(_time * (pi / 2))) + _from;};break;
		case EASE_OUT: {return delta * (sin(_time * (pi / 2))) + _from;};break;
		case EASE_INOUT: {return delta * 0.5 * (1 - cos(pi * _time)) + _from;};break;
		}
	}
	
/// @function ease_quad(from, to, time, direction)
function ease_quad(_from, _to, _time, _direction) {
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta*_time*_time + _from;};break;
		case EASE_OUT: {return -delta * _time*(_time-2) + _from;};break;
		case EASE_INOUT: {
			_time /= 0.5;
			if (_time < 1){return (delta * 0.5) * (_time * _time) + _from;}
			return (-delta * 0.5) * (--_time * (_time - 2) - 1) + _from;
			}
		}
	}

/// @function ease_cubic(from, to, time, direction)
function ease_cubic(_from, _to, _time, _direction) {
	gml_pragma("forceinline")
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta * power(_time, 3) + _from;};break;
		case EASE_OUT: {return delta * (power(_time - 1, 3) + 1) + _from;};break;
		case EASE_INOUT: {
			_time /= 0.5;
			if (_time < 1){return (delta * 0.5) * power(_time, 3) + _from;}
			return (delta * 0.5) * (power(_time - 2, 3) + 2) + _from;
			};break;
		}
	}
	
/// @function ease_quart(from, to, time, direction)
function ease_quart(_from, _to, _time, _direction) {
	gml_pragma("forceinline")
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta * power(_time, 4) + _from;};break;
		case EASE_OUT: {return -delta * (power(_time - 1, 4) - 1) + _from;};break;
		case EASE_INOUT: {
			_time /= 0.5;
			if (_time < 1) {return delta * 0.5 * power(_time, 4) + _from;}
			return -delta * 0.5 * (power(_time - 2, 4) - 2) + _from;
			};break;
		}
	}
	
/// @function ease_quint(from, to, time, direction)
function ease_quint(_from, _to, _time, _direction) {
	gml_pragma("forceinline")
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta * power(_time, 5) + _from;};break;
		case EASE_OUT: {return delta * (power(_time - 1, 5) + 1) + _from;};break;
		case EASE_INOUT: {
			_time /= 0.5;
			if (_time < 1) {return delta * 0.5 * power(_time, 5) + _from;}
			return delta * 0.5 * (power(_time - 2, 5) + 2) + _from;
			};break;
		}
	}
	
/// @function ease_expo(from, to, time, direction)
function ease_expo(_from, _to, _time, _direction) {
	gml_pragma("forceinline")
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta * power(2, 10 * (_time - 1)) + _from;};break;
		case EASE_OUT: {return delta * (-power(2, -10 * _time) + 1) + _from;};break;
		case EASE_INOUT: {
			_time /= 0.5;
			if (_time < 1) {return delta * 0.5 * power(2, 10 * (_time - 1)) + _from;}
			_time -= 1;
			return delta * 0.5 * (-power(2, -10 * _time) + 2) + _from;
			};break;
		}
	}
	
/// @function ease_circ(from, to, time, direction)
function ease_circ(_from, _to, _time, _direction) {
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta * (1 - sqrt(1 - _time * _time)) + _from;};break;
		case EASE_OUT: {
			_time--;
			return delta * sqrt(1 - _time * _time) + _from;
			};break;
		case EASE_INOUT: {
			_time /= 0.5;
			if (_time < 1) {return delta * 0.5 * (1 - sqrt(1 - _time * _time)) + _from;}
			_time -= 2;
			return delta * 0.5 * (sqrt(1 - _time * _time) + 1) + _from;
			};break;
		}
	}

/// @function ease_back(from, to, time, direction)
function ease_back(_from, _to, _time, _direction) {
	var delta = _to-_from;
	var bConst = 1.70158;
	switch(_direction) {
		case EASE_IN: {return delta * (_time) * _time * ((bConst + 1) * _time - bConst) + _from;};break;
		case EASE_OUT: {
			_time--;
			return delta * ((_time) * _time * ((bConst + 1) * _time + bConst) + 1) + _from;
			};break;
		case EASE_INOUT: {
			_time *= 2;
			bConst *= 1.525
			if ((_time) < 1) {return delta * 0.5 * (_time * _time * ((bConst + 1) * _time - bConst)) + _from;}
			_time -= 2;
			return delta * 0.5 * ((_time) * _time * ((bConst + 1) * _time + bConst) + 2) + _from;
			};break;
		}
	}
		
function __bounce_out(_time, _from, _delta) {
	if (_time < (1 / 2.75)) {
		return _delta * (7.5625 * _time * _time) + _from;
		}
	else if (_time < (2 / 2.75)) {
	    _time -= (1.5 / 2.75);
	    return _delta * (7.5625 * _time * _time + 0.75) + _from;
		}
	else if (_time < (2.5 / 2.75)) {
	    _time -= (2.25 / 2.75);
	    return _delta * (7.5625 * _time * _time + 0.9375) + _from;
		}
	else {
	    _time -= ( 2.625 / 2.75 );
	    return _delta * (7.5625 * _time * _time + 0.984375) + _from;
		}
	}
		
/// @function ease_bounce(from, to, time, direction)
function ease_bounce(_from, _to, _time, _direction) {	
	gml_pragma("forceinline")
	var delta = _to-_from;
	switch(_direction) {
		case EASE_IN: {return delta - __bounce_out(-_time, 0, delta) + _from;};break;
		case EASE_OUT: {return __bounce_out(_time,_from,delta)};break;
		case EASE_INOUT: {
			if (_time < 0.5) {return (__bounce_out(_time * 2, 0, delta) * 0.5 + _from);}
			return (__bounce_out(_time * 2 - 1, 0, delta) * 0.5 + delta * 0.5 + _from);
			};break;
		}
	}

/// @function ease_elastic(from, to, time, direction)
function ease_elastic(_from, _to, _time, _direction) {
	var eConst = 1.70158;
	var delta = _to-_from;
	var _p = 0;
	switch(_direction) {
		case EASE_IN: {
			var _a = delta;
			if (_time == 0 || _a == 0) { return _from; }
			if (_time == 1)  {return _from + delta; }
			if (_p == 0) {_p = 0.3;}
			if (_a < abs(delta)) { 
			    _a = delta; 
			    _s = _p * 0.25; 
				}
			else {_s = _p / (2 * pi) * arcsin (delta / _a);}
			return -(_a * power(2,10 * (--_time)) * sin((_time - _s) * (2 * pi) / _p)) + _from;
			};break;
		case EASE_OUT: {
			if (_time == 0 or delta == 0) {return _from;}
			if (_time == 1) {return _from + delta;}
			if (!_p) { _p = 0.3;}
			if (delta < abs(delta)) { 
			    delta = delta;
			    eConst = _p * 0.25; 
			    }
			else {
			    eConst = _p / (2 * pi) * arcsin (delta / delta);
			    }
			return delta * power(2, -10 * _time) * sin((_time - eConst) * (2 * pi) / _p ) + delta + _from;
			};break;
		case EASE_INOUT: {
			var _a = delta;
			if (_time == 0 || _a == 0){return _from;}
			_time /= (0.5);
			if (_time == 2){return _from + delta;}
			if (!_p) {_p = (0.3 * 1.5);}
			if (_a < abs(delta)) { 
			    _a = delta; 
			    eConst = _p * 0.25; 
				}
			else {eConst = _p / (2 * pi) * arcsin (delta / _a);}
			if (_time < 1) {return -0.5 * (_a * power(2, 10 * (--_time)) * sin((_time - eConst) * (2 * pi) / _p)) + _from;}
			return _a * power(2, -10 * (--_time)) * sin((_time - eConst) * (2 * pi) / _p) * 0.5 + delta + _from;
			};break;
		}
	}
	
/// @function bezier_point_find(p1, lhandle, rhandle, p2, lerp)
/// @author Andev, @blatantly_andev on twitter
function bezier_point_find(p1, lhandle, rhandle, p2, _lerp) {
	/*
	Lerp is a value from 0-1 to find on the line between p0 and p3
	p1 and p2 are the control points

	returns array (x,y)
	*/
	var t   = _lerp;
	var p0x = p1[0];
	var p0y = p1[1];
	var p1x = lhandle[0];
	var p1y = lhandle[1];
	var p2x = rhandle[0];
	var p2y = rhandle[1];
	var p3x = p2[0];
	var p3y = p2[1];

	//Precalculated power math
	var tt  = t  * t;
	var ttt = tt * t;
	var u   = 1  - t; //Inverted
	var uu  = u  * u;
	var uuu = uu * u;

	//Calculate the point
	var px =     uuu * p0x; //first term
	var py =     uuu * p0y;
	px += 3 * uu * t * p1x; //second term
	py += 3 * uu * t * p1y;
	px += 3 * u * tt * p2x; //third term 
	py += 3 * u * tt * p2y;
	px +=        ttt * p3x; //fourth term
	py +=        ttt * p3y;

	//Pack into an array
	var PA; PA[0] = px; PA[1] = py;
	return PA;
	}