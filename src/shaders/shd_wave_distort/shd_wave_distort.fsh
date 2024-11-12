//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_strength;
uniform float u_aspect;
uniform sampler2D u_normals;

void main()
{
	vec2 off = (texture2D(u_normals, v_vTexcoord).rg - 0.5) * 2.0 * u_strength;
	off.x /= u_aspect;
	
	vec4 col = texture2D(gm_BaseTexture, v_vTexcoord + off);
	
    gl_FragColor = col;
}
