//
// Simple passthrough fragment shader
//
varying vec2 v_coord;
varying vec4 v_color;

uniform float u_kernel;
uniform float u_sigma;
uniform vec2 u_direction;
uniform vec2 u_texel;

float weight(float x) {
	return exp(-x * x / (2.0 * u_sigma * u_sigma));
}

void main() {
	vec4 blurred = texture2D(gm_BaseTexture, v_coord);
	float kernel_weight = 2.0 * u_kernel + 1.0;
	float total_weight = 1.0;
	
	for (float i = 1.0; i < u_kernel; i++) {
		float sample_weight = weight(i / kernel_weight);
		total_weight += 2.0 * sample_weight;
		
		blurred += texture2D(gm_BaseTexture, 
			v_coord - i * u_texel * u_direction
		) * sample_weight;
		
		blurred += texture2D(gm_BaseTexture, 
			v_coord + i * u_texel * u_direction
		) * sample_weight;
	}
	
	
    gl_FragColor = v_color * blurred / total_weight;
}
