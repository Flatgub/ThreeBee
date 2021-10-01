//
// PSX Shader - Unlit (Vertex snapping and Affine texture mapping)
// snapping and affine textures based on https://github.com/keijiro/Retro3D/blob/master/Assets/Retro3D/Retro3D%20Unlit.shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)
//attribute vec3 in_Normal;                  // (x,y,z)     

uniform float u_fGeoResolution;

varying vec3 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vViewPos;

void main()
{
		
	//vertex snapping
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	
	vec4 wp = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;
	wp.xyz = floor(wp.xyz * u_fGeoResolution)/ u_fGeoResolution;
	
	vec4 sp = gm_Matrices[MATRIX_PROJECTION] * wp;
    gl_Position = sp;
    
	//affine texture mapping
	vec2 uv = in_TextureCoord;
	v_vTexcoord = vec3(uv * sp.w, sp.w);
	
	//fog
	v_vViewPos = wp;

	
    v_vColour = in_Colour;
    
}

