/// @function ray_intersect_box(minB, maxB, origin, dir)
/// @description	returns the coordinates where the ray intersects the box, or undefined if they don't intersect
/// @param {Array<Real>}	minPos	the minimum coordinate for the box
/// @param {Array<Real>}	maxPos	the maximum coordinate for the box
/// @param {Array<Real>}	rayPos	the coordinate for the origin of the ray
/// @param {Array<Real>}	rayDir	the vector for the direction of the ray
/// @returns {Array<Real> | Undefined}
function ray_intersect_box(minB, maxB, origin, dir) {

	// Fast Ray-Box Intersection
	// by Andrew Woo
	// from "Graphics Gems", Academic Press, 1990
	//
	// Ported to GML by Flatgub, original C source available at https://github.com/erich666/GraphicsGems/blob/master/gems/RayBox.c 
	var coord = [0,0,0];


	#macro RB_RIGHT 0
	#macro RB_LEFT 1
	#macro RB_MIDDLE 2

	var inside = true;
	var quadrant = [0,0,0];
	var i, whichPlane;
	var maxT = [0,0,0];
	var candidatePlane = [0,0,0];

	// Find candidate Planes;
	for(i = 0; i < 3; i++) {
		if (origin[i] < minB[i]) {
			quadrant[i] = RB_LEFT;
			candidatePlane[i] = minB[i];
			inside = false;
		}else if (origin[i] > maxB[i]) {
			quadrant[i] = RB_RIGHT;
			candidatePlane[i] = maxB[i];
			inside = false;
		} else {
			quadrant[i] = RB_MIDDLE;
			}
		}
	
	// Ray origin inside bounding box
	if inside {
		return origin;
		}
	
	// Calculate T distances to candidate planes
	for(i = 0; i < 3; i++) {
		if (quadrant[i] != RB_MIDDLE && dir[i] != 0) {
			maxT[i] = (candidatePlane[i]-origin[i]) / dir[i];
			}
		else {maxT[i] = -1.0;}
		}
	
	// Get largest of the maxT's for the final choice of intersection
	whichPlane = 0;
	for(i = 1; i<3; i++) {
		if (maxT[whichPlane] < maxT[i]) {whichPlane = i;}
		}
	
	// Check final candidate actually inside box
	if (maxT[whichPlane] < 0) {return undefined}

	for(i = 0; i < 3; i++) {
		if (whichPlane != i) {
			coord[i] = origin[i] + maxT[whichPlane] * dir[i];
			if(coord[i] < minB[i] || coord[i] > maxB[i]) {return undefined};
			}
		else {
			coord[i] = candidatePlane[i];
			}
		}
	
	return coord;
}


/// @function ray_cast_nearest(pos, dir, filter)
/// @description	find the nearest collider, filtered by bitflags, or noone if the ray hits nothing
/// @param {Array<Real>}	pos		the coordinate for the origin of the ray
/// @param {Array<Real>}	dir		the vector for the direction of the ray
/// @param {Real}			filter	the bitflag filter for collissionlayers to include
function ray_cast_nearest(pos, dir, filter) {
	var hitcoord = -1;
	var hitinstance = noone;
	var hitdistance = -1;

	//var xPlane = sign(dir[0]);
	//var yPlane = sign(dir[1]);
	//var zPlane = sign(dir[2]);

	//var culled = 0;

	for(var i = 0; i < ds_list_size(global.RAYCAST_OBJECTS); i++) {
		var inst = global.RAYCAST_OBJECTS[| i];
	
		if !(inst.enabled) {continue;} //disregard disabled colliders
		if !(inst.collisionLayer & filter) {continue;} //filter using bitflags
	
		//ignore instances that the ray couldn't hit;
		//if ((xPlane>0 && inst.bboxMax.x < pos[0]) || (xPlane<0 && inst.bboxMin.x > pos[0])) {culled++;continue;}
		//if ((yPlane>0 && inst.bboxMax.y < pos[1]) || (yPlane<0 && inst.bboxMin.y > pos[1])) {culled++;continue;}
		//if ((zPlane>0 && inst.bboxMax.z < pos[2]) || (zPlane<0 && inst.bboxMin.z > pos[2])) {culled++;continue;}
	
		var tempcoord = ray_intersect_box(inst.bboxMin,inst.bboxMax,pos,dir);
	
		if tempcoord == undefined {continue;} //no intersection
	
		var tx = tempcoord[0]-pos[0];
		var ty = tempcoord[1]-pos[1];
		var tz = tempcoord[2]-pos[2];
	
		var dist = (tx*tx)+(ty*ty)+(tz*tz); //lazy distance
	
		if hitdistance == -1 {//allow the initial setting of collision
			hitcoord = tempcoord;
			hitinstance = inst;
			hitdistance = dist;
			} 
		else if dist < hitdistance{ //track collisions with the smallest distance
			hitcoord = tempcoord;
			hitinstance = inst;
			hitdistance = dist;
			}
		
		}
	
	if hitdistance >= 0 {hitdistance = sqrt(hitdistance)} //convert lazy distance into real distance on return;
	var outStruct = {pos: hitcoord, hit: hitinstance == noone ? noone : hitinstance.parent, dist: hitdistance};

	return outStruct;
}

/// @function ray_plane_intersection(planePos, planeNorm, rayPos, rayDir)
/// @description	returns the point where the ray intersects the plane, or undefined if they never intersect
/// @param {Array<Real>}	planeOrigin		the origin point of the plane
/// @param {Array<Real>}	planeNormal		the normal vector of the plane
/// @param {Array<Real>}	rayOrigin		the origin point of the ray
/// @param {Array<Real>}	rayDirection	the direction vector of hte ray
/// @returns {Array<Real> | Undefined}
function ray_plane_intersection(planePos, planeNorm, rayPos, rayDir) {

	if (r3_dot(planeNorm,rayDir) == 0) {return undefined;}

	//(planeNormal.dot(planePoint) - planeNormal.dot(linePoint)) / planeNormal.dot(lineDirection);
	var t = (r3_dot(planeNorm,planePos) - r3_dot(planeNorm,rayPos)) / r3_dot(planeNorm,rayDir);
	return r3_add(rayPos,r3_scale(rayDir,t));
}
