

varying vec2 v_fragcoord;
varying vec4 v_color;

uniform vec2 u_offset;
uniform vec2 u_resolution;
uniform float u_time;



#define OCTAVES 6

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

float fractal(vec2 p) {

    float o = 0.0;
    float strength = 0.5;
    vec2 position = p;
    
    for (int i = 0; i < OCTAVES; i++) {
        
        o += noise(position) * strength;
        position *= 2.0;
        strength *= 0.5;
        
    }
    
    // attempt to fix darkness issues
    o /= 1.0 - 0.5 * pow(0.5, float(OCTAVES - 1));
    
    return o;
    
}

mat2 rotate(float r) {
    return mat2(
        cos(r), -sin(r),
        sin(r), cos(r)
    );
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    uv /= 4.0;
    uv += vec2(4.0);
    
    float n = fractal((uv + u_time / 200.0) * 1.0);
    float r = n * 3.1415 * 2.0;
    
    uv += vec2(0.0, 1.0) * rotate(r);
    
    float n_0 = fractal((uv + u_time / 100.0) * 8.0);
    float r_0 = n_0 * 3.1415 * 2.0;
    
    float n_1 = fractal((uv + vec2(0.0, 0.1) * rotate(r_0) - u_time / 200.0) * 8.0);
    float r_1 = n_1 * 3.1415 * 2.0;
    
    uv += vec2(0.0, 0.1) * rotate(r_1);
    
    float m1 = sin(uv.y * 60.0 + u_time / 1.0) / 2.0 + 0.5;
    float m2 = sin(uv.y * 5.0 + u_time / 2.0) / 2.0 + 0.5;
    float m3 = sin(uv.y * 10.0 + u_time / 5.0) / 2.0 + 0.5;
    
    vec3 c1 = vec3(0.8, 0.2, 1.0);
    vec3 c2 = vec3(0.4, 0.5, 0.9);
    vec3 c3 = vec3(0.7, 0.4, 0.7);
    
    vec3 col = vec3(0.0) + (m1 * c1) + (m2 * c2) + (m3 * c3);
    col /= c1 + c2 + c3;
    
    gl_FragColor = vec4(col,1.0);
}