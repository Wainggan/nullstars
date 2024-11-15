//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_destination;

#define THRESH 0.85

void main() {
	vec4 base = texture2D(u_destination, v_vTexcoord);
	vec3 light = texture2D(gm_BaseTexture, v_vTexcoord).rgb;
	
	vec3 col = base.rgb * light;
    col = min(col, vec3(1.0));
	
	vec3 damp = smoothstep(vec3(THRESH), vec3(1.0), col);
	col = mix(col, max(base.rgb, vec3(THRESH)), damp);
	
	gl_FragColor = vec4(col, base.a);
}
