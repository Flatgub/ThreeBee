//
// Basic Shader - Fog & Dithering
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
	
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	
	vec4 wp = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;	
	vec4 sp = gm_Matrices[MATRIX_PROJECTION] * wp;
    gl_Position = sp;
 		
	//fog
	v_vViewPos = wp;

    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}