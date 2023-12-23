//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_kernel;
uniform vec2 u_texel;

void main()
{
	
	vec4 spot = texture2D(gm_BaseTexture, v_vTexcoord);
	float collect = 0.0;
	
	for (float x = 1.0; x < u_kernel; x++) {
		for (float y = 1.0; y < u_kernel; y++) {
			collect += texture2D(gm_BaseTexture, v_vTexcoord + vec2(x, 0.0) * u_texel).a;
			collect += texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, y) * u_texel).a;
			collect += texture2D(gm_BaseTexture, v_vTexcoord - vec2(x, 0.0) * u_texel).a;
			collect += texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, y) * u_texel).a;
		}
	}
	
	gl_FragColor = mix(vec4(v_vColour.rgb, min(collect, 1.0)), spot, spot.a);
}
