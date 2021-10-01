//
// Basic Billboard Shader - (Fog Only)
//

attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)
//attribute vec3 in_Normal;                  // (x,y,z)     

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vViewPos;

void main()
{
	
	mat4 worldview = gm_Matrices[MATRIX_WORLD_VIEW];
	
	//force billboard
	worldview[0][0] = 1.0;
	worldview[0][1] = 0.0;
	worldview[0][2] = 0.0;
	worldview[1][0] = 0.0;
	worldview[1][1] = 1.0;
	worldview[1][2] = 0.0;
	worldview[2][0] = 0.0;
	worldview[2][1] = 0.0;
	worldview[2][2] = 1.0;
	
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	
	vec4 wp = worldview * object_space_pos;	
	
	vec4 sp = gm_Matrices[MATRIX_PROJECTION] * wp;
    gl_Position = sp;
 		
	//fog
	v_vViewPos = wp;

    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}
