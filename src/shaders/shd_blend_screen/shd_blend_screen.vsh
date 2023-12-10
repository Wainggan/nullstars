
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_coord;
varying vec2 v_screen;
varying vec4 v_color;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
	v_screen = gl_Position.xy*0.5 + 0.5;
	v_screen.y = 1.0 - v_screen.y;
	
    v_color = in_Colour;
    v_coord = in_TextureCoord;
}
