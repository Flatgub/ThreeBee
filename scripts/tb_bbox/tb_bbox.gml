/// @description a bounding box for raycasting against
/// @param	{Id.Instance}	parent	the object this BBCollider belongs to
/// @param	{Real}			_xsize	the size of the box along the x axis
/// @param	{Real}			_ysize	the size of the box along the y axis
/// @param	{Real}			_zsize	the size of the box along the z axis
/// @param	{Real}			_offx	how far to offset the bbox along the x axis
/// @param	{Real}			_offy	how far to offset the bbox along the y axis
/// @param	{Real}			_offz	how far to offset the bbox along the z axis
function BBoxCollider(_parent, _xsize, _ysize, _zsize, _offx = 0, _offy = 0, _offz = 0) constructor {
	parent = _parent;
	xsize = _xsize;
	_xradius = xsize/2;
	ysize = _ysize;
	_yradius = ysize/2;
	zsize = _zsize;
	_zradius = zsize/2;
	
	collisionLayer = COLLISION_GENERIC;
	enabled = true;
	
	xoffset = _offx;
	yoffset = _offy;
	zoffset = _offz;
				   
	/// @description	update the bounding box min and max coords relative to where the parent object is
	function update() {
		bboxMin = [parent.x - _xradius + xoffset,
			       parent.y - _yradius + yoffset,
			       parent.z - _zradius + zoffset]
			
		bboxMax = [parent.x + _xradius + xoffset,
				   parent.y + _yradius + yoffset,
				   parent.z + _zradius + zoffset]
		}
		
	/// @description	resize the bounding box
	function resize(_newx, _newy, _newz) {
		xsize = _newx;
		_xradius = xsize/2;
		ysize = _newy;
		_yradius = ysize/2;
		zsize = _newz;
		_zradius = zsize/2;
		
		update()
		}
		
	function cleanup() {
		for(var i = 0; i < ds_list_size(global.RAYCAST_OBJECTS); i++) {
			if(global.RAYCAST_OBJECTS[| i] == self) {
				ds_list_delete(global.RAYCAST_OBJECTS, i);
				return;
				}
			}
		}
		
	update();
	
	ds_list_add(global.RAYCAST_OBJECTS,self);
	}