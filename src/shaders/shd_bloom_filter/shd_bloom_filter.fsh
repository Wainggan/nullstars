//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_threshold;
uniform float u_range;


void main() {
    vec4 base = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	float lum = dot(base.rgb, vec3(0.229, 0.587, 0.114));
	float weight = smoothstep(u_threshold, u_threshold + u_range, lum);
	base.rgb = mix(vec3(0.0), base.rgb, weight);
	
	gl_FragColor = base;
}
