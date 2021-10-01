/// @function FCurve_Group(boneid)
function FCurve_Group(_bone) constructor {
	
	firstFrame = undefined;
	lastFrame = undefined;
	boneid = _bone;
	location = array_create(3,undefined)
	rotation = array_create(4,undefined)
	__locFallback = [0,0,0]
	__rotFallback = [0,0,0,1]
	__rotTemp = [0,0,0,0]
	
	/// @function set_location_fcurve(fcurve, axis)
	static set_location_fcurve = function(_fcurve, axis) {
		firstFrame = is_undefined(firstFrame) ? _fcurve.startingFrame : min(firstFrame,_fcurve.startingFrame)
		lastFrame = is_undefined(lastFrame) ? _fcurve.finalFrame : max(lastFrame,_fcurve.finalFrame)
		location[@ axis] = _fcurve;
		}
	
	/// @function set_rotation_fcurve(fcurve, axis)
	static set_rotation_fcurve = function(_fcurve, axis) {
		firstFrame = is_undefined(firstFrame) ? _fcurve.startingFrame : min(firstFrame,_fcurve.startingFrame)
		lastFrame = is_undefined(lastFrame) ? _fcurve.finalFrame : max(lastFrame,_fcurve.finalFrame)
		rotation[@ axis] = _fcurve;
		}
	
	/// @function get_location(frame)
	/// @description evaluates all 3 location curves at once, returing the fallback component if the groups a curve
	static get_location = function(_frame) {
		var out = array_create(3)
		for(var i = 0; i < 3; i++) {
			if(location[i] != undefined) {out[i] = location[i].evaluate(_frame)}
			else {out[i] = __locFallback[i]}
			}
		return out;
		}
		
	/// @function get_rotation(frame, fallback)
	/// @description evaluates all 4 rotation curves at once, returing the fallback component if the groups a curve
	static get_rotation = function(_frame) {
		var out = array_create(4)
		for(var i = 0; i < 4; i++) {
			if(rotation[i] != undefined) {out[i] = rotation[i].evaluate(_frame)}
			else {out[i] = __rotFallback[i]}
			}
		return out;
		}
	
	/// @function evaluate_dq(frame, target)
	static evaluate_dq = function(_frame, _target) {
		//set the rotation
		for(var i = 0; i < 4; i++) {
			if(rotation[i] != undefined) {__rotTemp[@ i] = rotation[i].evaluate(_frame)}
			else {__rotTemp[@ i] = __rotFallback[i]}
			}	
		quat_normalize(__rotTemp)	
		_target[@ 0] = __rotTemp[0]
		_target[@ 1] = __rotTemp[1]
		_target[@ 2] = __rotTemp[2]
		_target[@ 3] = __rotTemp[3]
		
			
		var _x = (location[0] != undefined) ?  location[0].evaluate(_frame) : 0;
		var _y = (location[1] != undefined) ?  location[1].evaluate(_frame) : 0;
		var _z = (location[2] != undefined) ?  location[2].evaluate(_frame) : 0;
		dq_set_translation(_target,_x,_y,_z)
		
		
		//pos = get_location(_frame);
		//rot = get_rotation(_frame);
		//dq_overwrite(poseDQ,rot,pos)
		//var dq = dq_create(0,1,0,0,pos[0],pos[1],pos[2])
		//return dq_normalize(dq_rotate(dq,rot))
		//return [0,0,0,1,0,0,0,0]
		}
	}


function FCurve() constructor{
	allKeyframes = []
	
	startingFrame = 0;
	startingValue = 0;
	
	finalValue = 0;
	finalFrame = 0;
	
	__bezierLeft = [0,0]
	__bezierRight = [0,0]
	
	
	/// @function add_keyframe(keyframe)
	static add_keyframe = function(_keyframe) {
		var desiredFrame = _keyframe.frame;
		var frames = array_length(allKeyframes);
		
		//set values on first frame
		if(frames == 0) {
			_keyframe.fcurve = self;
			array_push(allKeyframes,_keyframe);
			startingFrame = _keyframe.frame;
			startingValue = _keyframe.value;
			finalFrame = _keyframe.frame;
			finalValue = _keyframe.value;
			return;
			}
		
		var inserted = false		
		//attempt insert into correct position
		for(var i = 0; i < frames; i++) {
			var frameAt = allKeyframes[i].frame
			if(desiredFrame == frameAt) {show_error("Tried to add two keyframes to the same frame",false);return;}
			if(desiredFrame < frameAt) {
				_keyframe.fcurve = self;
				array_insert(allKeyframes,i,_keyframe);
				
				if(i == 0) { //if we're inserting at the start, update starting info
					startingFrame = _keyframe.frame;
					startingValue = _keyframe.value;
					}
				
				inserted = true;
				break;
				}
			}
			
		//if there wasn't anywhere to insert to, add to the end as new final frame
		if(!inserted) {
			array_push(allKeyframes,_keyframe)
			finalFrame = _keyframe.frame;
			finalValue = _keyframe.value;
			_keyframe.fcurve = self;
			}
		}
		
	/// @function evaluate(frame)
	static evaluate = function(_frame) {
		if(_frame <= startingFrame) {return startingValue}
		if(_frame >= finalFrame) {return finalValue}
		
		//find the two keyframes on either side of the current frame
		var numframes = array_length(allKeyframes);
		var leftKey, rightKey;
		for(var i = 0; i < numframes-1; i++) {
			var kf = allKeyframes[i];
			if(kf.frame <= _frame) {
				leftKey = kf;
				rightKey = allKeyframes[i+1]
				}
			}
			
		var lVal = leftKey.value;
		var rVal = rightKey.value;
		var time = lerp_inverse(leftKey.frame,rightKey.frame,_frame)
		
		switch(leftKey.interp) {
			case INTERP_CONSTANT: {return lVal;};break;
			case INTERP_LINEAR: {return ease_linear(lVal,rVal,time)};break;
			case INTERP_BEZIER: {
				__bezierLeft[0] = leftKey.frame; __bezierLeft[1] = lVal;
				__bezierRight[0] = rightKey.frame; __bezierRight[1] = rVal;
				return bezier_point_find(__bezierLeft,leftKey.bezier_handles[0],leftKey.bezier_handles[1],__bezierRight,time)[1]
				};break;
			case INTERP_SINE:  {return ease_sine(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_QUAD:  {return ease_quad(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_CUBIC: {return ease_cubic(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_QUART: {return ease_quart(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_QUINT: {return ease_quint(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_EXPO:  {return ease_expo(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_CIRC:  {return ease_circ(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_BACK:  {return ease_back(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_BOUNCE: {return ease_bounce(lVal,rVal,time,leftKey.easing)};break;
			case INTERP_ELASTIC: {return ease_elastic(lVal,rVal,time,leftKey.easing)};break;
			default: {show_error("Tried to evaluate unimplemented interpolation method " + string(leftKey.interp),false);}
			}
		
		}
}

/// @function FCurve_Keyframe(frame, value, interpolation, easing, [bezier_lefthandle], [bezier_righthandle])
function FCurve_Keyframe(_frame, _value, _interp, _ease) constructor {
	fcurve = undefined
	frame = _frame
	value = _value
	easing = _ease;
	interp = _interp;
	if(interp == INTERP_BEZIER) {bezier_handles = [argument[4],argument[5]]}
	else {bezier_handles = undefined}
		
	
	}