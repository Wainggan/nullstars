//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_back;
uniform vec2 u_off;
uniform float u_time;

#define FREQ (128.0)
#define WIDTH (1.0 / 960.0 * 1.0)

void main()
{
	vec4 mask = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec2 wave = vec2(sin((v_vTexcoord.y + u_off.y) * FREQ - u_time * 0.8) * WIDTH, 0.0);// * (point - 0.5) * 2.0 * 0.6;
	
	vec3 col = mask.rgb;
	vec3 back = texture2D(u_back, v_vTexcoord + wave).rgb;
	
	col = col * smoothstep(0.0, 1.0, back) * vec3(0.6, 0.6, 0.8) + vec3(0.1, 0.1, 0.2);
	
    gl_FragColor = vec4(col, mask.a);
}
