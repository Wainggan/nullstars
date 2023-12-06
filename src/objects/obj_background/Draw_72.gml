
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0])
	
draw_sprite_ext(
	spr_pixel, 0, 
	_cam_x, _cam_y, 
	_cam_w, _cam_h, 
	0, #000209, 1
);
	
shader_set(shd_back_1);

shader_set_uniform_f(shader_1_u_resolution, _cam_w, _cam_h);
shader_set_uniform_f(shader_1_u_time, current_time / 1000);

draw_sprite_ext(
	spr_pixel, 0, 
	_cam_x, _cam_y, 
	_cam_w, _cam_h, 
	0, c_white, mode == 0
);

shader_reset()

shader_set(shd_back_2);

shader_set_uniform_f(shader_2_u_offset, _cam_x / 4, _cam_y / 4);
shader_set_uniform_f(shader_2_u_resolution, _cam_w, _cam_h);
shader_set_uniform_f(shader_2_u_time, current_time / 1000);

draw_sprite_ext(
	spr_pixel, 0, 
	_cam_x, _cam_y, 
	_cam_w, _cam_h, 
	0, c_white, mode == 1
);

shader_reset()

shader_set(shd_back_3);

shader_set_uniform_f(shader_3_u_offset, _cam_x / 5, _cam_y / 5);
shader_set_uniform_f(shader_3_u_resolution, _cam_w, _cam_h);
shader_set_uniform_f(shader_3_u_time, current_time / 1000);

draw_sprite_ext(
	spr_pixel, 0, 
	_cam_x, _cam_y, 
	_cam_w, _cam_h, 
	0, c_white, mode == 2
);

shader_reset()

shader_set(shd_back_4);

shader_set_uniform_f(shader_4_u_offset, _cam_x / 2, _cam_y / 2);
shader_set_uniform_f(shader_4_u_resolution, _cam_w, _cam_h);
shader_set_uniform_f(shader_4_u_time, current_time / 1000);

draw_sprite_ext(
	spr_pixel, 0, 
	_cam_x, _cam_y, 
	_cam_w, _cam_h, 
	0, c_white, mode == 3
);

shader_reset()
