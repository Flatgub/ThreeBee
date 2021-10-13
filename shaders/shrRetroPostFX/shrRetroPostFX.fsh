//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define CRUSH 8.0


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
    vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec4 ocol = col;
	
	col = col * 255.0; //scale up from 0-1 to 0-255
	
	float redLo = floor(col.r  / CRUSH) * CRUSH;
	float redHi = ceil(col.r  / CRUSH) * CRUSH;
	float dist = distance(col.r, redLo)/CRUSH; //this will be 0 when the red is the same as redLo and 1 when redHi
	float select = getDither(dist);
	float redOut = mix(redLo, redHi, select);
	
	float greenLo = floor(col.g  / CRUSH) * CRUSH;
	float greenHi = ceil(col.g  / CRUSH) * CRUSH;
	dist = distance(col.g, greenLo)/CRUSH; 
	select = getDither(dist);
	float greenOut = mix(greenLo, greenHi, select);
	
	float blueLo = floor(col.b  / CRUSH) * CRUSH;
	float blueHi = ceil(col.b  / CRUSH) * CRUSH;
	dist = distance(col.b, blueLo)/CRUSH; 
	select = getDither(dist);
	float blueOut = mix(blueLo, blueHi, select);
	
	col = vec4(redOut, greenOut, blueOut, col.a);
	
	gl_FragColor = col / 255.0; //scale down back to 0-01
}
