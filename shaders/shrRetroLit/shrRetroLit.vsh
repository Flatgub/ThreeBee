//
// PSX Shader - Lit (Vertex snapping, Affine texture mapping and Lighting)
// snapping and affine textures based on https://github.com/keijiro/Retro3D/blob/master/Assets/Retro3D/Retro3D%20Unlit.shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)
attribute vec3 in_Normal;                  // (x,y,z)     

varying vec3 v_vTexcoord;
varying vec4 v_vColour;

//fog stuff for the fragment shader
varying vec4 v_vViewPos;

uniform vec3 u_vAmbientLightColour;

uniform float u_fGeoResolution;

#define NUM_LIGHTS 8
uniform vec3 u_vLightPosition[NUM_LIGHTS];
uniform vec3 u_vLightColour[NUM_LIGHTS];
uniform float u_fLightStrength[NUM_LIGHTS];
uniform float u_fLightRadiusMultiplier[NUM_LIGHTS];
uniform float u_fLightMix;


void main()
{
	float geores = u_fGeoResolution;
		
	//vertex snapping
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	
	vec4 wp = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;
	vec4 sp = gm_Matrices[MATRIX_PROJECTION] * wp;
	
	//affine texture mapping
	vec2 uv = in_TextureCoord;
	v_vTexcoord = vec3(uv * sp.w, sp.w);
	
	wp.xyz = floor(wp.xyz * geores)/ geores;
	
	sp = gm_Matrices[MATRIX_PROJECTION] * wp;
	
    	gl_Position = sp;
    
	
	//lighting
	
	vec3 totalLightCol = vec3(0.0);
	
	vec3 eyespaceVertex = wp.xyz;
	vec3 eyespaceDirection = vec3(0.0) - eyespaceVertex;
	vec3 eyespaceNormal = (gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Normal,0.0)).xyz;
	vec3 n = normalize(eyespaceNormal);
		
	for(int i = 0; i < NUM_LIGHTS; i++) {
		if (u_fLightStrength[i] == 0.0) {continue;};
		
		vec3 lightCol = u_vLightColour[i]/255.0;
				
		vec3 eyespaceLightPos = (gm_Matrices[MATRIX_VIEW] * vec4(u_vLightPosition[i],1.0)).xyz;
		vec3 eyespaceLightDir = eyespaceLightPos + eyespaceDirection;
	
		float dist = distance(eyespaceVertex,eyespaceLightPos);
		vec3 l = normalize(eyespaceLightDir);
		float cosTheta = max(dot(n,l),0.0);
		
		float radius = sqrt(1.0 / 0.00008) * u_fLightRadiusMultiplier[i];
		float att = clamp(1.0 - dist/radius, 0.0, 1.0);  
		totalLightCol += lightCol * (u_fLightStrength[i] * cosTheta) * att;
		}
	
	vec3 colour = u_vAmbientLightColour + (in_Colour.rgb * totalLightCol);
	
	colour = mix(in_Colour.rgb, colour, u_fLightMix);
	colour = min(colour, in_Colour.rgb); //colour can't become brighter than white
	
	//float lum = (colour.r+colour.r+colour.b+colour.g+colour.g+colour.g)/6.0;
	//colour = vec3(1.0) - colour;
	
    v_vColour = vec4(colour,1.0);
	
	//used for fog
	v_vViewPos = wp;
	    
}
