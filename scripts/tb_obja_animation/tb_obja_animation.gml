global.OBJA_ANIM_USE_SMART_SAMPLING = false;
global.OBJA_ANIM_DEFAULT_SAMPLE_INTERVAL = 2;
global.OBJA_ANIM_USE_INTERPOLATION = true;

/// @function OBJA_Animation(name, armature)
function OBJA_Animation(_name,_armature) constructor{
	name = _name;
	armature = _armature;
	allFCurveGroups = []
	FCGroupsByBone = array_create(array_length(armature.allBones),undefined)
	length = 0;
	
	/// @function add_fcurve_group(group, boneid)
	/// @param group	{FCurve_Group}	The fcurve group to add
	static add_fcurve_group = function(_fcg) {
		array_push(allFCurveGroups,_fcg);
		FCGroupsByBone[@ _fcg.boneid] = _fcg;
		if(_fcg.lastFrame > length) {length = _fcg.lastFrame}
		}
		
	cachedSamples = [];
	//frameSampleInterval = global.OBJA_ANIM_DEFAULT_SAMPLE_INTERVAL;
	//useSmartSampling = global.OBJA_ANIM_USE_SMART_SAMPLING;
	//useSampleInterpolation = global.OBJA_ANIM_USE_INTERPOLATION;
	
	static clear_cached_samples = function() {	
		cachedSamples = [];
		}
	
	/// @function generate_cached_samples()
	static generate_cached_samples = function() {
		var b = benchmark_start("Baking samples for " + name)
		
		var frameSampleInterval = global.OBJA_ANIM_DEFAULT_SAMPLE_INTERVAL;
		var useSmartSampling = global.OBJA_ANIM_USE_SMART_SAMPLING;
		
		var mode = useSmartSampling ? "smart" : "basic";
		
		var framesToSample;
		if(useSmartSampling) {
			framesToSample = get_sample_frames_smart();
			}
		else {
			framesToSample = get_sample_frames_basic();
			}
		
		var numFrames = array_length(framesToSample);
		for(var i = 0; i < numFrames; i++) {
			var frame = framesToSample[i];
			var newsample = new OBJA_Animation_Sample(self,frame);
			newsample.bake_sample()
			array_push(cachedSamples,newsample);
			}
			
		
		var dif = round(((length-numFrames)/length)*100)
		debug_log(sprintf("%s: Generated %s samples using %s placement (interval %s), a %s% reduction. (%s)",name,numFrames, mode, frameSampleInterval, dif,benchmark_result(b)),$ffff88)
		
		delete b		
		}
			
	static get_sample_frames_smart = function() {
		var frameTimes = [];
		
		var importantFrames = ds_map_create()
		
		//iterate over every curve group in the skeleton and find each frame where a keyframe exists
		var numcgs = array_length(allFCurveGroups);
		for(var cgi = 0; cgi < numcgs; cgi++) {
			var fgc = allFCurveGroups[cgi];
			var tracks = [];
			//collect location tracks
			for(var o = 0; o < 3; o++) {
				if(fgc.location[o] == undefined) {continue;}
				array_push(tracks,fgc.location[o]);
				}
			//collect rotation tracks
			for(var o = 0; o < 4; o++) {
				if(fgc.rotation[o] == undefined) {continue;}
				array_push(tracks,fgc.rotation[o]);
				}
				
			//for each track, record when the keyframes are
			for(var ti = 0; ti < array_length(tracks); ti++) {
				var track = tracks[ti];
				var frames = array_length(track.allKeyframes);
				for(var kfi = 0; kfi < frames; kfi++)  {
					var kf = track.allKeyframes[kfi];
					importantFrames[? kf.frame] = true
					}
				}
			}
			
		var frameIDs = ds_map_keys_to_array(importantFrames)
		ds_map_destroy(importantFrames);
		
		array_sort(frameIDs,true)
		
		var impFrameCount = array_length(frameIDs);
		
		//add additional inbetween if important frames are too far apart
		//var additionalInbetweens = 0;
		for(var i = 0; i < impFrameCount; i++) {
			var frame = frameIDs[i];
			array_push(frameTimes,frame) //count the important frame
			
			//if we're not the last frame, calculate additional samples between here and the next frame
			if(i != impFrameCount-1) {
				var nextFrame = frameIDs[i+1]
				var distance = nextFrame-frame;
				var neededAdditionalSamples = floor(distance/global.OBJA_ANIM_DEFAULT_SAMPLE_INTERVAL);
				//add additional samples between this sample and the next sample if they are too far apart
				if(neededAdditionalSamples > 0) {
					// f can't ever be 0 or 1, because samples already exist there
					// so we add 1, so that the new frame has to lie somewhere between them
					var tFrames = 1+neededAdditionalSamples; 
					for(var o = 1; o < tFrames; o++) {
						var f = o/tFrames;
						var newSampleFrame = floor(lerp(frame,nextFrame,f))
						array_push(frameTimes,newSampleFrame)
						}
					//additionalInbetweens += neededAdditionalSamples
					}
				}
			}
		
		return frameTimes;
		}
			
	static get_sample_frames_basic = function() {
		var frameTimes = [];
		for(var i = 0; i < length; i += global.OBJA_ANIM_DEFAULT_SAMPLE_INTERVAL) {
			array_push(frameTimes,i);
			}
		array_push(frameTimes,length);
		return frameTimes;
		}
		
	//implementation based on TheSnidr's SMF sample_lerp
	static sample_lerp = function(_left,_right,_amount,_out) {
		var numBones = array_length(armature.allBones);
		
		//return full copies if the amount is out of bounds or on either edge
		if(_amount <= 0) {
			return _left.clone_into(_out);
			}
		if(_amount >= 1) {
			return _right.clone_into(_out);
			}
			
		//Linearly interpolate between the two samples
		var t1 = 1 - _amount;
		
		for(var i = 0; i < numBones; i++) {
			var l = _left.cachedBones[i];
			var r = _right.cachedBones[i];
			var obone = _out.cachedBones[i];
			//Make sure the dual quaternions are in the same half of the hypersphere
			var t2 = _amount * sign(l[0] * r[0] + l[1] * r[1] + l[2] * r[2] + l[3] * r[3]);
			var o = 0;
			repeat(8) {
				obone[@ o] = l[o] * t1 + r[o] * t2;
				o++;
				}
			}
		
		return _out;
		}
		
	/// @function get_sample_at_frame(frame, [out])
	static get_sample_at_frame = function(_frame) {
		//create a new out if we weren't provided with one
		var out = undefined;
		if(argument_count == 2) {
			out = argument[1]
			out.referenceAnimation = self;
			out.referenceArmature = armature;
			};
		else {out = new OBJA_Animation_Sample(self, _frame);}		
		
		//find the two closest samples
		var leftSample = cachedSamples[0];
		var rightSample = cachedSamples[1];
		var numSamples = array_length(cachedSamples);
		for(var i = 0; i < numSamples-1; i++) {
			leftSample = cachedSamples[i];
			rightSample= cachedSamples[i+1];
			if(_frame < leftSample.referenceFrame) {break}; //abort if we've gone too far somehow (e.g. frame < 0)
			if(_frame >= rightSample.referenceFrame) {continue;} //skip this pair if the target frame is further than the right side
			if(_frame >= leftSample.referenceFrame && _frame < rightSample.referenceFrame) {break;} //abort if we've found the correct two
			}
			
		//return the only matching sample if the frame was out of bounds
		if(_frame < leftSample.referenceFrame) {return leftSample.clone_into(out);}
		if(_frame >= rightSample.referenceFrame) {return rightSample.clone_into(out);}
		
		if(!global.OBJA_ANIM_USE_INTERPOLATION) {
			return leftSample.clone_into(out);
			}
		
		//find the interpolated pose and write it into out
		var amnt = inverse_lerp(leftSample.referenceFrame, rightSample.referenceFrame, _frame)
		sample_lerp(leftSample,rightSample,amnt,out);
		
		return out;
		}
}

/// @function OBJA_Animation_Sample(animation, frame)
function OBJA_Animation_Sample(_animation, _frame) constructor {
	referenceAnimation = _animation;
	referenceArmature = _animation.armature;
	referenceFrame = _frame;
	cachedBones = array_create(array_length(referenceArmature.allBones));
	
	static bake_sample = function() {
		//when called on its own, recall using the default arguments
		if(argument_count == 0) {
			//pre-fill the cached bones array with identity dual quaternions
			for(var i = 0; i < array_length(cachedBones); i++) {
				cachedBones[@ i] = [0,0,0,1,0,0,0,0]
				}
				
			bake_sample(referenceArmature.rootBone,[0,0,0,1,0,0,0,0]);
			}
		else {
			var bone = argument[0];
			var dq = argument[1];
			
			var fcg = referenceAnimation.FCGroupsByBone[bone.boneid];
			if(fcg != undefined && fcg != 0) {
				//write the evaluated pose into the cached bone id
				fcg.evaluate_dq(referenceFrame, cachedBones[bone.boneid])
				}
				
			//move to the head and pose pose deformations
			//this takes the poseDQ out of the cached bones list in order to make the full local DQ, then rewrites it
			dq_multiply(dq, bone.headDQ, dq);
			dq_multiply(dq, cachedBones[bone.boneid], dq );
			cachedBones[@ bone.boneid] = dq_duplicate(dq)
			
			//apply the tail deformation
			dq_multiply(dq, bone.tailDQ, dq);
			
			//update all children
			for(var i = 0; i < array_length(bone.children); i++) {
				bake_sample(bone.children[i], dq_duplicate(dq));
				}
			}
		}
		
	static clone = function() {
		var newclone = new OBJA_Animation_Sample(referenceAnimation, referenceFrame)
		var numbones = array_length(cachedBones);
		for(var i = 0; i < numbones; i++) {	
			newclone.cachedBones[i] = array_clone(cachedBones[i]);
			}
		return newclone;
		}
		
	static clone_into = function(_output) {
		_output.referenceAnimation = referenceAnimation;
		_output.referenceArmature = referenceArmature;
		_output.referenceFrame = referenceFrame
		var numbones = array_length(cachedBones);
		for(var i = 0; i < numbones; i++) {	
			_output.cachedBones[i] = array_clone(cachedBones[i]);
			}
		return _output;
		}
	}