//
// Basic Billboard Shader - (Fog Only)
//

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vViewPos;

uniform vec3 u_vFogColour;

uniform float u_fFogStart;
uniform float u_fFogEnd;


void main()
{

	vec4 inCol = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord);
	
	// fog
	float dist = length(v_vViewPos);
	
	float fogFactor = (dist-u_fFogEnd)/(u_fFogEnd - u_fFogStart);
	fogFactor = 1.0 - clamp(fogFactor,0.0,1.0);
		
	vec4 fogCol = vec4(u_vFogColour,inCol.a);
	
    gl_FragColor = mix(fogCol,inCol,fogFactor);
}

