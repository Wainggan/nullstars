
varying vec4 v_color;
varying vec2 v_coord;
varying vec2 v_screen;
uniform sampler2D u_destination;

void main()
{
	
	//Sample the source and destination textures
	vec4 src = texture2D(gm_BaseTexture, v_coord) * v_color;
	vec4 dst = texture2D(u_destination, v_screen);
	
	//vec4 col = (dst + src) / 2.0;
	//vec4 col = -(1.0 - pow(dst, vec4(8.0))) * (1.0 - src) + 1.0;
	//col = (dst + col) / 2.0;
	//col = max(col, dst);
	 // overlay-ish
	//col = 2.0 * col * src;
	//col = 1.0 - pow(1.0 - col, 1.0 / max(1.0 - src, 0.0001));
	
	vec4 col = (dst - 0.5) * (dst - 0.5) * 4.0;
	col = col * src + dst;
	col = min(col, 1.0);
	
	col.rgb = mix(dst.rgb, col.rgb, src.a);
	col.a = src.a + dst.a * (1.0 - src.a);

	gl_FragColor = col;
}
