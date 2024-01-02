//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_strength;
uniform sampler2D u_lut;

#define CELL_AMOUNT 16.0
#define CELL_SIZE (1.0 / CELL_AMOUNT)
#define LUTSIZE_X 256.0
#define LUTSIZE_Y 16.0
#define TEXEL_HALF_X (0.5 / LUTSIZE_X)
#define TEXEL_HALF_Y (0.5 / LUTSIZE_Y)
#define CELL_SIZE_FIXED_X (CELL_SIZE - (2.0 * TEXEL_HALF_X))
#define CELL_SIZE_FIXED_Y (1.0 - (2.0 * TEXEL_HALF_Y))

void main()
{
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	
	float blue = base.b * (CELL_AMOUNT - 1.0);
	
	vec2 low_samp, high_samp;
	
	low_samp.x = floor(blue) * CELL_SIZE + TEXEL_HALF_X + CELL_SIZE_FIXED_X * base.r;
	low_samp.y = TEXEL_HALF_Y + CELL_SIZE_FIXED_Y * base.g;
	
	high_samp.x = ceil(blue) * CELL_SIZE + TEXEL_HALF_X + CELL_SIZE_FIXED_X * base.r;
	high_samp.y = TEXEL_HALF_Y + CELL_SIZE_FIXED_Y * base.g;
	
	vec3 col = mix(texture2D(u_lut, low_samp).rgb, texture2D(u_lut, high_samp).rgb, fract(blue));
	col = mix(base.rgb, col, u_strength);
	
    gl_FragColor = v_vColour * vec4(col, base.a);
}
