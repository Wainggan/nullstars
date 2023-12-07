
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0])
	
draw_sprite_ext(
	spr_pixel, 0, 
	0, 0, 
	_cam_w, _cam_h, 
	0, #000209, 1
);


var _shader = shd_back_4;

shader_set(_shader);

shader_set_uniform_f(shader_get_uniform(_shader, "u_offset"), _cam_x / 4, _cam_y / 4);
shader_set_uniform_f(shader_get_uniform(_shader, "u_resolution"), _cam_w, _cam_h);
shader_set_uniform_f(shader_get_uniform(_shader, "u_time"), current_time / 1000);

draw_sprite_ext(
	spr_pixel, 0, 
	0, 0, 
	_cam_w, _cam_h, 
	0, c_white, 1
);

shader_reset()


draw_surface(application_surface, 0, 0);
