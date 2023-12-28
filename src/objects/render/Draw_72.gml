
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

draw_clear_alpha(c_black, 0);


// background

if !surface_exists(surf_background)
	surf_background = surface_create(_cam_w, _cam_h);

surface_set_target(surf_background);

var _shader_list = [undefined, shd_back_1, shd_back_2, shd_back_3, shd_back_4];
var _shader;

_shader = _shader_list[background_from];

if _shader == undefined || background_anim == 1 {
	draw_sprite_ext(
		spr_pixel, 0, 
		0, 0, 
		_cam_w, _cam_h, 
		0, #000209, 1
	);
} else {
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
}

_shader = _shader_list[background_mode];

if _shader == undefined {
	draw_sprite_ext(
		spr_pixel, 0, 
		0, 0, 
		_cam_w, _cam_h, 
		0, #000209, background_anim
	);
} else {
	shader_set(_shader);

	shader_set_uniform_f(shader_get_uniform(_shader, "u_offset"), _cam_x / 4, _cam_y / 4);
	shader_set_uniform_f(shader_get_uniform(_shader, "u_resolution"), _cam_w, _cam_h);
	shader_set_uniform_f(shader_get_uniform(_shader, "u_time"), current_time / 1000);

	draw_sprite_ext(
		spr_pixel, 0, 
		0, 0, 
		_cam_w, _cam_h, 
		0, c_white, background_anim
	);
}

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


// bubbles

if !surface_exists(surf_bubbles)
	surf_bubbles = surface_create(_cam_w, _cam_h);

surface_set_target(surf_bubbles);
draw_clear_alpha(c_black, 0)

with obj_spike_bubble {
	var _size = round_ext(wave(0.95, 1.1, 8, offset), 0.05)

	draw_sprite_ext(spr_spike_bubble, 0, x - _cam_x, y - _cam_y, _size, _size, 0, c_black, 1);
	
	draw_sprite_ext(spr_spike_bubble, 1, x - _cam_x, y - _cam_y, size, size, offset % 360, c_black, 1);
	
}

gpu_set_colorwriteenable(true, true, true, false)

var _col = #aa78fa

draw_sprite_tiled_ext(spr_spike_stars, 0, floor(- _cam_x / 2), floor(- _cam_y / 2), 2, 2, merge_color(c_white, _col, 1), 1)
draw_sprite_tiled_ext(spr_spike_stars, 0, floor(- _cam_x / 4), floor(- _cam_y / 4), 2, 2, merge_color(c_white, _col, 0.5), 1)
draw_sprite_tiled_ext(spr_spike_stars, 0, floor(- _cam_x / 8), floor(- _cam_y / 8), 2, 2, merge_color(c_white, _col, 0.25), 1)

with obj_spike_bubble {
	var _size = round_ext(wave(0.8, 2, 18, offset + 1000), 0.05)
	var _off_x = round_ext(wave(-6, 6, 24, offset * 2), 1)
	var _off_y = round_ext(wave(-6, 6, 24, offset * 3), 1)

	draw_sprite_ext(spr_spike_x, 0, x + _off_x - _cam_x, y + _off_y - _cam_y, _size, _size, 0, #49f273, 1)
}

gpu_set_colorwriteenable(true, true, true, true)

surface_reset_target()

gpu_set_blendmode_ext(bm_one, bm_zero)

surface_set_target(surf_blur_ping)

shader_set(shd_outline)

var _u_kernel = shader_get_uniform(shd_outline, "u_kernel")
var _u_texel = shader_get_uniform(shd_outline, "u_texel")

shader_set_uniform_f(_u_kernel, 2);
shader_set_uniform_f(_u_texel, 1 / _cam_w, 1 / _cam_h);

draw_surface_ext(surf_bubbles, 0, 0, 1, 1, 0, #49f273, 1);

shader_reset()

surface_reset_target()
surface_set_target(surf_bubbles)

draw_surface(surf_blur_ping, 0, 0);

surface_reset_target()

gpu_set_blendmode(bm_normal)