
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0])

var _scale_w = window_get_width() / _cam_w,
	_scale_h = window_get_height() / _cam_h


if !surface_exists(surf_compose)
	surf_compose = surface_create(_cam_w, _cam_h);

surface_set_target(surf_compose)

draw_sprite_ext(
	spr_pixel, 0, 
	0, 0, 
	_cam_w, _cam_h, 
	0, #000209, 1
);

gpu_set_colorwriteenable(true, true, true, false);

draw_surface_ext(surf_background, 0, 0, 1, 1, 0, c_white, 1);
draw_surface_ext(application_surface, 0, 0, 1, 1, 0, c_white, 1);

gpu_set_colorwriteenable(true, true, true, true);

surface_reset_target();

var _p = [
	spr_grade_base,
	spr_grade_decorrelation_1,
	spr_grade_decorrelation_2,
	spr_grade_decorrelation_3,
	spr_grade_muddy,
	spr_grade_snow,
	spr_grade_saturate,
	spr_grade_cracked,
	spr_grade_meltingpot,
	spr_grade_contrast_lightness,
	spr_grade_bump_yellow,
	spr_grade_mild,
	spr_grade_waterfall,
]

if keyboard_check_pressed(ord("Y")) mode = (mode + 1) % array_length(_p)

if !surface_exists(surf_lut)
	surf_lut = surface_create(256, 16)

surface_set_target(surf_lut)
draw_clear_alpha(c_black, 1)
gpu_set_colorwriteenable(true, true, true, false);
	draw_sprite(_p[mode], 0, 0, 0);
gpu_set_colorwriteenable(true, true, true, true);
surface_reset_target()

var _u_strength = shader_get_uniform(shd_grade, "u_strength");
var _u_lut = shader_get_sampler_index(shd_grade, "u_lut");

gpu_set_tex_filter_ext(_u_lut, true)
shader_set(shd_grade);

	shader_set_uniform_f(_u_strength, 1)
	texture_set_stage(_u_lut, surface_get_texture(surf_lut));

	draw_surface_ext(surf_compose, 0, 0, _scale_w, _scale_h, 0, c_white, 1);

shader_reset();
gpu_set_tex_filter(false)
