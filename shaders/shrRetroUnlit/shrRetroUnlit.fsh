//
// PSX Shader - Unlit: Apply fog, dither and blend
//
varying vec3 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vViewPos;

uniform vec3 u_vFogColour;

uniform float u_fFogStart;
uniform float u_fFogEnd;

uniform vec4 u_vBlend;

uniform float u_fDitherMatrix[16];

float getDither(float value) 
{
	float size = 4.0;
	
	//get pixel coordinates
	float xOff = mod(floor(gl_FragCoord.x),size);
	float yOff = mod(floor(gl_FragCoord.y),size);
	
	//convert position to index
	int index = int(floor(xOff+(size*yOff)));
	
	//calculate if above or below threshold
	return step(u_fDitherMatrix[index],value+1.0/32.0);
}

void main()
{
	
	vec2 uv = v_vTexcoord.xy / v_vTexcoord.z;
	vec4 inCol = v_vColour * u_vBlend * texture2D( gm_BaseTexture, uv);
	
	//cancel if base colour is too dim.
	if(getDither(inCol.a) == 0.0) {discard;}
	
	float dist = length(v_vViewPos);
	
	float fogFactor = (dist-u_fFogEnd)/(u_fFogEnd - u_fFogStart);
	fogFactor = 1.0 - clamp(fogFactor,0.0,1.0);
		
	vec4 fogCol = vec4(u_vFogColour,inCol.a);
	
	vec4 finalColour = mix(fogCol,inCol,fogFactor);
	finalColour.a = 1.0; //transparency is disabled due to dithering instead
	
    gl_FragColor = finalColour;
}

