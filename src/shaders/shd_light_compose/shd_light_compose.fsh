//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_destination;

void main() {
	vec4 base = texture2D(u_destination, v_vTexcoord);
	vec4 light = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec3 col = base.rgb * light.rgb;
    
	gl_FragColor = vec4(col, base.a);
}
