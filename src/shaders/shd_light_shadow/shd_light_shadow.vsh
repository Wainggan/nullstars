
attribute vec3 in_Position;

uniform vec2 u_position;
uniform float u_z;

void main()
{
	vec2 position = in_Position.xy;
	
	if (in_Position.z > 0.0) {
		vec2 dist = position.xy - u_position;
		position += dist / sqrt(dist.x * dist.x + dist.y * dist.y) * 10000.0;
	}
	
    vec4 object_space_pos = vec4( position.x, position.y, u_z - 0.5, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
}
