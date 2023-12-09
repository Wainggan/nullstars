
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

draw_clear_alpha(c_black, 0);


// background

if !surface_exists(surf_background)
	surf_background = surface_create(_cam_w, _cam_h);

surface_set_target(surf_background);

var _shader = [shd_back_1, shd_back_2, shd_back_3, shd_back_4];
_shader = _shader[mode];

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

shader_reset();

surface_reset_target();


// background lights

if !surface_exists(surf_background_lights)
	surf_background_lights = surface_create(_cam_w, _cam_h);

surface_set_target(surf_background_lights);
draw_clear(c_black);

gpu_set_blendmode(bm_add);

// lazy brighten
repeat background_lights_brightness
	draw_surface(surf_background, 0, 0);

gpu_set_blendmode(bm_normal);

surface_reset_target();

