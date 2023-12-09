
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

var _lvl_onscreen = game_level_onscreen()

// finish surf_background_lights

surface_set_target(surf_background_lights);

draw_surface_ext(application_surface, 0, 0, 1, 1, 0, c_black, 1);

surface_reset_target()

part_system_drawit(particles_ambient)


// blur surf_background_lights

shader_set(shd_blur);
var _u_kernel = shader_get_uniform(shd_blur, "u_kernel")
var _u_sigma = shader_get_uniform(shd_blur, "u_sigma")
var _u_direction = shader_get_uniform(shd_blur, "u_direction")
var _u_texel = shader_get_uniform(shd_blur, "u_texel")

shader_set_uniform_f(_u_kernel, background_lights_kernel);
shader_set_uniform_f(_u_sigma, background_lights_sigma);
shader_set_uniform_f(_u_texel, 1 / _cam_w, 1 / _cam_h);

shader_set_uniform_f(_u_direction, 0, 1);

surface_set_target(surf_blur_ping);
draw_surface(surf_background_lights, 0, 0);
surface_reset_target();

shader_set_uniform_f(_u_direction, 1, 0);

surface_set_target(surf_background_lights);
draw_surface(surf_blur_ping, 0, 0);
surface_reset_target();

// lights

if !surface_exists(surf_lights) {
	surf_lights = surface_create(_cam_w, _cam_h, surface_rgba16float);
}

surface_set_target(surf_lights);
// ambient lights
draw_clear_alpha(#555566, 1);

// background lights

gpu_set_blendmode(bm_add);

draw_surface(surf_background_lights, 0, 0)

gpu_set_blendmode(bm_normal)


// draw lights


var _u_l_position = shader_get_uniform(shd_light_color, "u_position")
var _u_l_size = shader_get_uniform(shd_light_color, "u_size")
var _u_l_intensity = shader_get_uniform(shd_light_color, "u_intensity")
var _u_l_z = shader_get_uniform(shd_light_color, "u_z")

var _u_s_position = shader_get_uniform(shd_light_shadow, "u_position")
var _u_s_z = shader_get_uniform(shd_light_shadow, "u_z")

var _vb = lights_vb;

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

matrix_set(matrix_world, matrix_build(-_cam_x, -_cam_y, 0, 0, 0, 0, 1, 1, 1))

var _z = 0;
with obj_light {
	
	var _intensity = intensity;
	
	var _dist_x = min(
		x - _cam_x + size * 2, 
		(_cam_x + _cam_w + size * 2) - x
	);
	var _dist_y = min(
		y - _cam_y + size * 2, 
		(_cam_y + _cam_h + size * 2) - y
	);
	_dist_x = clamp(_dist_x / 60, 0, 1);
	_dist_y = clamp(_dist_y / 60, 0, 1);
	_intensity = herp(0, _intensity, min(_dist_x, _dist_y))
	
	if _intensity < 0.01 continue;
	
	shader_set(shd_light_shadow);
	shader_set_uniform_f(_u_s_position, x, y);
	shader_set_uniform_f(_u_s_z, _z);
	
	for (var i = 0; i < array_length(_lvl_onscreen); i++) {
		vertex_submit(_lvl_onscreen[i].vb, pr_trianglelist, -1);
	}
	
	shader_set(shd_light_color);
	shader_set_uniform_f(_u_l_position, x - _cam_x, y - _cam_y);
	shader_set_uniform_f(_u_l_size, size);
	shader_set_uniform_f(_u_l_intensity, _intensity);
	shader_set_uniform_f(_u_l_z, _z);
	
	gpu_set_blendmode(bm_add);
	draw_sprite_stretched_ext(spr_pixel, 0, _cam_x, _cam_y, _cam_w, _cam_h, color, 1);
	gpu_set_blendmode(bm_normal);
	
	_z--;
	
}

matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1))

gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);

shader_reset();


// apply lights

gpu_set_blendmode_ext(bm_dest_color, bm_zero);

draw_surface(application_surface, 0, 0);

gpu_set_blendmode(bm_normal);


surface_reset_target();


draw_surface_ext(surf_lights, _cam_x, _cam_y, 1, 1, 0, c_white, 1);


// level mask

if !surface_exists(surf_mask)
	surf_mask = surface_create(_cam_w, _cam_h);

surface_set_target(surf_mask)
draw_clear(c_black)

gpu_set_blendmode(bm_subtract);

for (var i = 0; i < array_length(_lvl_onscreen); i++) {
	var _lvl = _lvl_onscreen[i];
	draw_sprite_stretched(spr_pixel, 0, _lvl.x - _cam_x, _lvl.y - _cam_y, _lvl.width, _lvl.height)
}

gpu_set_blendmode(bm_normal)

surface_reset_target()

draw_surface(surf_mask, _cam_x, _cam_y);

