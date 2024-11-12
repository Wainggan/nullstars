//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	base.rgb = mix(vec3(0.5, 0.5, 1.0), base.rgb, v_vColour.a);
    gl_FragColor = vec4(base.rgb, 1.0);
}
