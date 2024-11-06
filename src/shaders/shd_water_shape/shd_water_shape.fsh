
varying vec2 v_coord;
varying vec4 v_vColour;

#define SIZE 4.0

float random(vec2 p) {
	return fract(sin(dot(p.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 s = floor(p);
    
	float a = random(s);
	float b = random(s + vec2(1.0, 0.0));
	float c = random(s + vec2(0.0, 1.0));
	float d = random(s + vec2(1.0, 1.0));
    
	vec2 f = smoothstep(0.0, 1.0, fract(p));
    
	float ab = mix(a, b, f.x);
	float cd = mix(c, d, f.x);
    
	float o = mix(ab, cd, f.y);
    
	return o;
}

uniform vec2 u_texel;
uniform vec2 u_off;
uniform float u_time;

void main() {
	vec2 uv = v_coord;
	vec2 center = vec2(0.5, 0.5);
    
	vec2 place = (uv / u_texel / 64.0 - u_off);
	place += vec2(sin(u_time * 0.735), sin(u_time * 0.777));
    
	float point = noise(place);
	
	vec2 dist = vec2(abs(uv.x - center.x), abs(uv.y - center.y));
	vec2 collide = step(dist, 0.5 - point * u_texel * SIZE - u_texel);
    
	gl_FragColor = vec4(vec3(1.0), min(collide.x, collide.y));
}
