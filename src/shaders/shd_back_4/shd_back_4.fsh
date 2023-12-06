
varying vec2 v_fragcoord;
varying vec4 v_color;

uniform vec2 u_offset;
uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.141593238

#define ITERATIONS 6.0

float field(vec2 uv) {
    
    float o;
    
    float weight = 0.5;
    
    mat2 rot = mat2(
        cos(0.4), sin(0.4), 
        -sin(0.4), cos(0.4)
    );
    
    for (float i = 0.0; i < ITERATIONS; i++) {
        vec2 com = vec2(
            sin(uv.x * 1.445), sin(uv.y * 1.597)
        ) / 2.0 + 0.5;
        
        uv *= 1.5;
        uv *= rot;
        
        o += (com.x + com.y) / 2.0 * weight;
        
        weight *= 0.5;
    }
    
    return o;
}

vec2 warp(vec2 uv) {
    float v = field(uv);
    return vec2(cos(v * PI * 2.0), sin(v * PI * 2.0));
}


void main() {
    vec2 uv = (gl_FragCoord.xy + u_offset) / u_resolution.xy * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    vec2 uv2 = (gl_FragCoord.xy) / u_resolution.xy * 2.0 - 1.0;
    uv2.x *= u_resolution.x / u_resolution.y;
	
    vec2 nuv = uv + vec2(0.0, u_time / 32.0);
    nuv *= 2.0;
    nuv += warp(nuv + vec2(0.0, u_time / 16.0)) / 2.0;
    nuv += warp(nuv + vec2(u_time / 4.0, 0.0)) / 6.0;
    
    vec3 col = vec3(sin(nuv.y * 32.0) / 2.0 + 0.5);
    col = smoothstep(0.8, 0.9, col);
    
    
    float t = sin(length(uv2) * 3.0 - u_time / 2.0) / 2.0 + 0.5;
    vec3 pr = mix(vec3(1.0, 0.0, 0.8), vec3(0.0, 1.0, 0.8), t) * 0.4;
    //pr = smoothstep(0.0, 1.0, pr);
    
    col *= pr;
    

    gl_FragColor = vec4(col * v_color.rgb, v_color.a);
}

