//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;


float random(vec2 p) {
	return fract(sin(dot(p.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

mat2 rotate(float r) {
	return mat2(
	    cos(r), -sin(r),
	    sin(r), cos(r)
	);
}

uniform float u_time;
uniform vec2 u_texel;

#define AMOUNT 8.0

void main() {
    vec2 nuv = fract(v_vTexcoord * AMOUNT);
    float r = random(floor(v_vTexcoord * AMOUNT));
    vec2 d = floor(abs(v_vTexcoord * 2.0 - 1.0) * (AMOUNT * 0.5)) / (AMOUNT * 0.5);
    float dp = smoothstep(0.00, 0.2, max((d.x + d.y) / 2.0 - 0.3, 0.0));
    
    float t = (u_time + r * 200.0) * 0.1;
    
    vec2 p = vec2(
        cos(floor(t * 0.978)),
        sin(floor(t * 0.957))
    ) * 0.5 + 0.5;
    
    vec2 s = vec2(
        sin(floor(t * 0.895)),
        cos(floor(t * 0.867))
    ) * 0.5 + 0.5 + 0.4;
    
    vec2 o = vec2(0.0, 1.0) * rotate(sin(floor(t)));

    o *= step(p.x - s.x, nuv.x);
    o *= step(p.y - s.y, nuv.y);
    o *= 1.0 - step(p.x + s.x, nuv.x);
    o *= 1.0 - step(p.y + s.y, nuv.y);
    
    float k = step(sin(t * 1.173), -0.88);
    
    vec3 col = texture2D(gm_BaseTexture, v_vTexcoord + o * u_texel * dp * k).rgb;
    
    // col = vec3(dp);
    // col = vec3(k);
    
    gl_FragColor = vec4(col,1.0);
}
