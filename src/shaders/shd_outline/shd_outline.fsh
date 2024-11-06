//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel;

void main()
{
	
	vec4 spot = texture2D(gm_BaseTexture, v_vTexcoord);
	float collect = 0.0;
	
	collect += texture2D(gm_BaseTexture, v_vTexcoord + vec2(1.0, 0.0) * u_texel).a;
	collect += texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, 1.0) * u_texel).a;
	collect += texture2D(gm_BaseTexture, v_vTexcoord - vec2(1.0, 0.0) * u_texel).a;
	collect += texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, 1.0) * u_texel).a;
	
	gl_FragColor = mix(vec4(v_vColour.rgb, min(collect, 1.0) * v_vColour.a), spot, spot.a);
}
