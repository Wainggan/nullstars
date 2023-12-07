
varying vec2 v_coord;
varying vec4 v_color;

uniform vec2 u_position;
uniform float u_size;
uniform float u_intensity;

float acc(float x, float scale) {
	float s = pow(scale, scale);
	float curve = 1.0 - 1.0 / pow(s, x);
	float damp = s / max(s - 1.0, 1.0);
	return max(curve * damp, x);
}
vec3 acc(vec3 c, float scale) {
	return vec3(
		acc(c.r, scale),
		acc(c.g, scale),
		acc(c.b, scale)
	);
}

void main() {
	float dist = distance(gl_FragCoord.xy, u_position);
	float bright = 1.0 / max(1.5 / u_intensity, dist - u_size);
	// bright = pow(bright, 1.0 / 1.0);
	
	float white = 1.0 - 1.5 / u_intensity;
	
	vec3 col = mix(v_color.rgb, vec3(1.0), white) * bright;
	
    gl_FragColor = vec4(col, v_color.a);
}
