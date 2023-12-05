
varying vec2 v_fragcoord;
varying vec4 v_color;

uniform vec2 u_offset;
uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.141593238
#define SQ_AMOUNT 5.0
#define SQ_SCALE 16.0

vec3 palette(float t) {
    vec3 a = vec3(1.0, 0.0, 1.0);
    vec3 b = vec3(0.0, 1.0, 1.0);
    vec3 c = vec3(t);
    return mix(c, mix(a, b, t * 0.5), t * 0.5);
}

mat2 rot(float ang){
  return mat2(
    cos(ang), -sin(ang),
    sin(ang), cos(ang)
  );
}


vec3 m_circle(vec2 uv, float size) {
    vec2 nuv = vec2(uv.x, uv.y / 2.0 + 0.5);

    vec3 a = vec3(1.0, 0.2, 0.7);
    vec3 b = vec3(2.0, 0.6, 0.9);

    vec3 circle = vec3(nuv.y, nuv.y, nuv.y) * mix(a, b, sin(u_time * 0.3) / 2.0 + 0.5);
    
    float l = length(uv);
    
    circle *= l * 4.0;
    circle *= smoothstep(1.0 / size, 1.0 / size + 0.06, 1.0/l);
    
    return circle;
}



float m_squares1(vec2 uv) {
    uv.x += cos(u_time / 2.0) * 0.1;
    uv.y += sin(u_time / 2.0) * 0.1;
    float t = sin(uv.x * SQ_SCALE) / 2.0 + 0.5;
    t = min(t, sin(uv.y * SQ_SCALE) / 2.0 + 0.5);
    t = smoothstep(0.5, 0.51, t);
    return t;
}



float m_squares2(vec2 uv) {
    float col;

    for(float i = 0.; i < SQ_AMOUNT; i++){
        col += m_squares1(uv);
        uv *= rot(PI / SQ_AMOUNT);
    }
    
    col /= SQ_AMOUNT;

    return col;
}


void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
	
    vec2 uv2 = (gl_FragCoord.xy + u_offset) / u_resolution.xy * 2.0 - 1.0;
    uv2.x *= u_resolution.x / u_resolution.y;
    
    vec3 col = vec3(0.0);
    
    float csize = pow(sin(u_time), 8.0) / 2.0 + 0.5;
    csize = csize * 0.1 + 0.2;
    
    col += m_circle(uv + vec2(0.0, sin(u_time * 0.13) * 0.04), csize);
    
    float squares = m_squares2(uv2);
    squares *= pow(length(uv), 2.0);
    
    col += palette(squares) / 4.0;
    
    gl_FragColor = vec4(col * v_color.rgb, v_color.a);
}