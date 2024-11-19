
varying vec4 v_color;

uniform vec2 u_position;
uniform float u_size;
uniform float u_intensity;

void main() {
	float dist = distance(gl_FragCoord.xy, u_position);
	float bright = 1.0 / max(1.5 / u_intensity, dist - u_size);
	// bright = pow(bright, 1.0 / 1.0);
	
	bright *= 1.0 - smoothstep(u_size * 1.5, u_size * 2.0, dist);
	
	float white = 1.0 - 1.5 / u_intensity;
	
	vec3 col = mix(v_color.rgb, vec3(1.0), white) * bright;
	
    gl_FragColor = vec4(col, v_color.a);
}
