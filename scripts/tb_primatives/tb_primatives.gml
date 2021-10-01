/// @function define_vertex_format();
function define_vertex_format() {
	vertex_format_begin();

	//define format
	vertex_format_add_position_3d();
	vertex_format_add_color();
	vertex_format_add_texcoord();
	vertex_format_add_normal();

	global.VERTEX_FORMAT = vertex_format_end();
}

/// @function define_vertex(buffer, pos, colour, alpha, u, v, normal)
/// @param buffer
/// @param pos
/// @param col
/// @param alpha
/// @param u
/// @param v
/// @param normal
function define_vertex(buffer, pos, col, alpha, u, v, normal) {

	vertex_position_3d(buffer,pos[COMP_X],pos[COMP_Y],pos[COMP_Z]);
	vertex_color(buffer,col,alpha);
	vertex_texcoord(buffer,u,v);
	vertex_normal(buffer,normal[COMP_X],normal[COMP_Y],normal[COMP_Z]);

}

/// @function define_line(buffer, p1, p2, colour, alpha)
/// @param buffer
/// @param p1
/// @param p2
/// @param colour
/// @param alpha
function define_line(buffer, v1, v2, col, alpha) {
	define_vertex(buffer,v1,col,alpha,0,0,VEC3_ZERO);
	define_vertex(buffer,v2,col,alpha,0,0,VEC3_ZERO);
}

/// @function define_triangle(buffer, p1, p2, p3, uv1, uv2, uv3, colour, alpha)
/// @param buffer
/// @param p1
/// @param p2
/// @param p3
/// @param uv1
/// @param uv2
/// @param uv3
/// @param colour
/// @param alpha
function define_triangle(buff, p1, p2, p3, uv1, uv2, uv3, col, alpha) {

	var dir = r3_scale(r3_cross(r3_subtract(p2,p1),r3_subtract(p3,p1)),-1);
	var norm = r3_unit(dir);

	//var centerPos = r3_scale(r3_add(r3_add(p1,p2),p3),1/3);
	//var centerPlusNormal = r3_add(centerPos,r3_scale(norm,8))

	define_vertex(buff,p1,col,alpha,uv1[0],uv1[1],norm);
	define_vertex(buff,p2,col,alpha,uv2[0],uv2[1],norm);
	define_vertex(buff,p3,col,alpha,uv3[0],uv3[1],norm);

}

/// @function define_plane(buffer, p1, p2, p3, p4, uv1, uv2, colour, alpha, subdivisions)
/// @param buffer
/// @param p1
/// @param p2
/// @param p3
/// @param p4
/// @param uv1
/// @param uv2
/// @param colour
/// @param alpha
/// @param subdivisions
function define_plane(buff, p1, p2, p3, p4, uvtl, uvbr, col, alpha, sub) {

	var uvtr = r2(uvbr[0],uvtl[1]);
	var uvbl = r2(uvtl[0],uvbr[1]);

	if sub == 0 {
		define_triangle(buff,p1,p3,p2,uvtl,uvbl,uvtr,col,alpha);
		define_triangle(buff,p2,p3,p4,uvtr,uvbl,uvbr,col,alpha);
		}
	else {
		// point system
		// aa ba ca
		// ab bb cb
		// ac bc cc
	
		var aa = p1;
		var ca = p2;
		var ac = p3;
		var cc = p4;
	
		var ba = r3_lerp(aa,ca,0.5);
		var ab = r3_lerp(aa,ac,0.5);
		var cb = r3_lerp(ca,cc,0.5);
		var bc = r3_lerp(ac,cc,0.5);
		var bb = r3_lerp(ab,cb,0.5);
	
		// uv system
		// xx yx zx
		// xy yy zy
		// xz yz zz
	
		var xx = uvtl;
		var zx = uvtr;
		var xz = uvbl;
		var zz = uvbr;
	
		var yx = r2_lerp(xx,zx,0.5);
		var xy = r2_lerp(xx,xz,0.5);
		var zy = r2_lerp(zx,zz,0.5);
		var yz = r2_lerp(xz,zz,0.5);
		var yy = r2_lerp(xy,zy,0.5);
	
		define_plane(buff,aa,ba,ab,bb,xx,yy,col,alpha,sub-1);
		define_plane(buff,ba,ca,bb,cb,yx,zy,col,alpha,sub-1);
		define_plane(buff,ab,bb,ac,bc,xy,yz,col,alpha,sub-1);
		define_plane(buff,bb,cb,bc,cc,yy,zz,col,alpha,sub-1);
		}
}
	
/// @function define_wall(buffer, p1, p2, uv1, uv2, colour, alpha, subdivisions)
/// @param buffer
/// @param p1
/// @param p2
/// @param uv1
/// @param uv2
/// @param colour
/// @param alpha
/// @param subdivisions
function define_wall(buff, p1, p2, uv1, uv2, col, alpha, subdivions) {
	var p4 = p2;

	p2 = r3(p4[0],p4[1],p1[2]);
	var p3 = r3(p1[0],p1[1],p4[2]);

	define_plane(buff,p1,p2,p3,p4,uv1,uv2,col,alpha,subdivions)

}

/// @param buffer
/// @param p1
/// @param p2
/// @param uv1
/// @param uv2
/// @param colour
/// @param alpha
/// @param subdivisions
function define_floor(buff, p1, p4, uvtl, uvbr, col, alpha, subdivisions) {
	var p2 = [p4[0],p1[1],p1[2]];
	var p3 = [p1[0],p4[1],p1[2]];
	var uvtr = [uvbr[0],uvtl[1]];
	var uvbl = [uvtl[0],uvbr[1]];
	
	define_plane(buff,p1,p2,p3,p4,uvtl,uvbr,col,alpha,subdivisions)
}

/// @function define_line_cube(buffer, centerPos, size, colour, alpha)
/// @param	buffer		{vertexbuffer}	the buffer to add the linecube to
/// @param	centerPos	{vec3}			the position of the cube
/// @param	size		{real}			the size of the cube
/// @param	colour		{colour}		the colour of the cube
/// @param	alpha		{real}			the alpha of the cube
function define_line_cube(buffer, centerPos, size, colour, alpha) {
	var tp1 = r3_add(centerPos,[-size,-size,-size])
	var tp2 = r3_add(centerPos,[-size, size,-size])
	var tp3 = r3_add(centerPos,[ size,-size,-size])
	var tp4 = r3_add(centerPos,[ size, size,-size])
	
	var bp1 = r3_add(centerPos,[-size,-size, size])
	var bp2 = r3_add(centerPos,[-size, size, size])
	var bp3 = r3_add(centerPos,[ size,-size, size])
	var bp4 = r3_add(centerPos,[ size, size, size])
	
	var pairs = [tp1,tp2, tp1,tp3, tp2,tp4, tp3,tp4,
	             bp1,bp2, bp1,bp3, bp2,bp4, bp3,bp4,
				 tp1,bp1, tp2,bp2, tp3,bp3, tp4,bp4]
				 				 
	for(var i = 0; i < array_length(pairs); i+=2) {
		var p1 = pairs[i]
		var p2 = pairs[i+1]
		define_line(buffer,p1,p2,colour,alpha)
		}
	
	}