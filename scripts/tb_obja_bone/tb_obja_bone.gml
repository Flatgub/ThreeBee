function OBJA_Bone(_id, _name, _armature, _head, _axis, _angle, _length) constructor {
	boneid = _id;
	name = _name
	armature = _armature
	length = _length
	
	parent = undefined;
	children = [];
	
	headDQ = dq_create(_angle,_axis[0],_axis[1],_axis[2],_head[0],_head[1],_head[2])
	//tailDQ = dq_multiply(headDQ, dq_create(0,1,0,0,0,length,0))
	tailDQ = dq_create(0,1,0,0,0,length,0)
	poseDQ = [0,0,0,1,0,0,0,0]
	
	__localHeadDQ = [0,0,0,1,0,0,0,0]
	__headScaleMatrix = matrix_build(0,0,0,0,0,0,1,length,1);
	
	renderHighLighted = false
	
	render = method(self,function(_matrix) {
		var tex = renderHighLighted ? sprite_get_texture(texRed, 0) : -1
		
		matrix_set(matrix_world,_matrix);
		vertex_submit(global.__BONE_BOX_MESH,pr_linelist,tex);
		
		var mat = matrix_multiply(__headScaleMatrix,_matrix)
		var arrowmesh = renderHighLighted ? global.__BONE_ARROW_MESH_WHITE : global.__BONE_ARROW_MESH;
		matrix_set(matrix_world,mat);
		vertex_submit(arrowmesh,pr_linelist,tex);
		});
		
	static clone = function() {
		var newHeadDQ = array_clone(headDQ)
		var newTailDQ = array_clone(tailDQ)
		var n = {
			boneid: boneid,
			name: name,
			armature: armature,
			length: length,
			parent: undefined,
			children: [],
			headDQ: newHeadDQ,
			tailDQ: newTailDQ,
			poseDQ: [0,0,0,1,0,0,0,0],
			__localHeadDQ: [0,0,0,1,0,0,0,0],
			__headScaleMatrix: __headScaleMatrix
			}
			
		n.render = method(n, render)
		
		return n;
		}
	}