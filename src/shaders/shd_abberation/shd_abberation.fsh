//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;
uniform float u_strength;

void main() {
	vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
	uv.x *= u_resolution.x / u_resolution.y;
    
	float dist = length(uv);
	
	vec3 base = texture2D(gm_BaseTexture, v_vTexcoord).rgb;
    
	vec3 col;
	col.r = texture2D(gm_BaseTexture, v_vTexcoord + vec2(u_strength, 0.0)).r;
	col.g = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, 0.0)).g;
	col.b = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-u_strength, 0.0)).b;

	vec3 com = mix(base, col, min(pow(dist, 3.0) * (1.0 / 8.0), 1.0));

	gl_FragColor = v_vColour * vec4(com, 1.0);
}
