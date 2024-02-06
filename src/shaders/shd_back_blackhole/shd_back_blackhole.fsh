

varying vec2 v_fragcoord;
varying vec4 v_color;

uniform vec2 u_offset;
uniform vec2 u_resolution;
uniform float u_time;


float random(vec2 p) {
    return fract(sin(dot(p.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

mat2 rotate(float r) {
    return mat2(
        cos(r), -sin(r),
        sin(r), cos(r)
    );
}

float wave(float a, float b, float time) {
    float t = sin(time) / 2.0 + 0.5;
    return mix(a, b, t);
}

#define PI 3.141593238


float spiral(vec2 p, float scale, float dir, float time) {
    float d = (atan(p.y, p.x) + PI) / (PI * 2.0);
    float l = length(p) * scale;

    float o = mod(l + d * dir - time, 1.0);
    
    return o;
}

vec3 position(vec2 uv) {
    float len = length(uv);
    
    vec3 col_0 = vec3(spiral(uv, wave(1.0, 2.0, u_time / 3.0), 1.0, -u_time / 3.02));
    vec3 col_1 = vec3(spiral(uv, wave(1.5, 2.5, u_time / 4.0), -1.0, -u_time / 4.7));
    vec3 col_2 = vec3(spiral(uv, wave(3.0, 4.0, u_time / 2.0), 1.0, -u_time / 5.0));
    vec3 col_3 = vec3(spiral(uv, wave(1.0, 4.0, u_time / 6.0), -1.0, u_time / 6.3));
    
    col_0 *= vec3(1.0, 0.0, 1.0);
    col_1 *= vec3(0.0, 1.0, 1.0);
    col_2 *= vec3(0.8, 0.3, 1.0);
    col_3 *= vec3(1.0, 0.4, 0.3);
    
    vec3 col = col_0 + col_1 + col_2 + col_3;
    
    col /= 5.0 - len * 2.0;
    
    /*
    col /= sqrt(col.x * col.x + col.y * col.y + col.z * col.z);
    col = pow(col, vec3(2.0));
    */
    
    col = smoothstep(0.5, 0.52, col);
    
    return col;
}


void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    
    
    float len = length(uv);
    
    float r = random(uv);
    
    float direction = r * 3.1415 * 2.0;
    direction += (sin(u_time / 2.0 + r * 3.141 * 2.0) / 2.0 + 0.5);
    
    vec2 off = vec2(wave(0.3, 0.5, u_time / 5.0), 0.0) * rotate(direction);
    uv += off * pow(len / 8.0, 3.0);
    
    
    vec3 col = position(uv);
    
    gl_FragColor = vec4(col,1.0);
    
}