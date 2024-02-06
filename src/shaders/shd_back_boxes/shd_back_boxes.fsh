
varying vec2 v_fragcoord;
varying vec4 v_color;

uniform vec2 u_offset;
uniform vec2 u_resolution;
uniform float u_time;

#define SCALE 8.0


vec3 palette(float i) {
    
    vec3 a = vec3(0.7, 0.2, 0.5);
    vec3 b = vec3(0.0, 0.5, 0.8);
    vec3 c = vec3(0.04, 0.0, 0.1);
    
    float h = 0.5;
    
    vec3 o = mix(mix(c, a, i / h), mix(b, a, (i - h) / (1.0 - h)), step(h, i));
    
    return o;
}

float hash(float i) {
    float s = sin(199.9 * i) + sin(77.7 * i) + sin(155.5 * i);
    s = (s + 3.0) / 6.0;
    return s;
}

float check(vec2 uv, vec2 scale) {
    uv += u_time / scale;
    
    vec2 grid = floor(uv * SCALE) / SCALE;
    
    float c = min(hash(grid.x), hash(grid.y));
    c = smoothstep(0.30, 0.60, c);
    
    return c;
}

void main() {
    vec2 uv = (gl_FragCoord.xy + u_offset.xy) / u_resolution.xy * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
        
    float o = 0.0;
	
	float lsc = 8.0;
    
    o = max(o, check(uv, vec2(lsc * 4.0, lsc * 2.0)));
    o = min(o, check(uv, vec2(lsc * -4.0, lsc * 2.5)));
    o = max(o, check(uv, vec2(lsc * 5.0, lsc * 12.0)));
    o = min(o, check(uv, vec2(lsc * -5.0, lsc * -12.0)));
    
    vec3 col = palette(o);
    
    gl_FragColor = vec4(col * v_color.rgb, v_color.a);
}
