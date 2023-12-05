
varying vec2 v_fragcoord;
varying vec4 v_color;

uniform vec2 u_resolution;
uniform float u_time;

vec3 palette(float t)
{
    vec3 a = vec3(1.0, 0.0, 1.0);
    vec3 b = vec3(0.1, 0.8, 1.0);
    vec3 c = vec3(0.05, 0.0, 0.1);
    
    vec3 d = mix(a, b, t);
    
    return mix(c, d, pow(t, 0.7) * 0.5);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    
    vec3 col = vec3(0.0);
    
    vec2 nuv = uv;
    
    float amount = 3.0;
    
    for (float i = 0.0; i < amount; i++) {
        //float ind = dot(nuv, nuv) * 2.0;
        float ind = nuv.x * nuv.y * 6.0;
    
        float t = sin(ind + u_time / 3.0) / 2.0 + 0.5;

        col += palette(t);
        
        nuv *= nuv;
    }
    
    col /= amount;
    
    //col = smoothstep(0.49, 0.51, col);
    
    gl_FragColor = vec4(col * v_color.rgb, v_color.a);
}