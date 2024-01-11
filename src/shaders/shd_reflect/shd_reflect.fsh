
varying vec2 v_coord;
varying vec2 v_screen;
varying vec4 v_color;

uniform float u_top;
uniform vec2 u_texel;
uniform sampler2D u_surf;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_coord);
	
	vec3 c = floor(v_color.rgb * 100.0 + 0.5) / 100.0;
	float top = c.r + c.g / 100.0 + c.b / 100.0 / 100.0;
	
	float dist = abs(top - v_screen.y);
	
	vec4 new = texture2D(u_surf, vec2(v_screen.x, top - dist));
	
    gl_FragColor = vec4(new.rgb, base.a * v_color.a);
}
