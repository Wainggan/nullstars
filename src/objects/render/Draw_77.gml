
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0])

var _scale_w = window_get_width() / _cam_w,
	_scale_h = window_get_height() / _cam_h


surface_set_target(surf_compose)
draw_clear_alpha(c_black, 1);

draw_sprite_ext(
	spr_pixel, 0, 
	0, 0, 
	_cam_w, _cam_h, 
	0, #000209, 1
);

gpu_set_colorwriteenable(true, true, true, false);

draw_surface_ext(surf_background, 0, 0, 1, 1, 0, c_white, 1);

if global.config.graphics_post_outline {

	shader_set(shd_outline_post);
	var _u_texel = shader_get_uniform(shd_outline_post, "u_texel");
	shader_set_uniform_f(_u_texel, 1 / WIDTH, 1 / HEIGHT);

	draw_surface_ext(surf_layer_0, 0, 0, 1, 1, 0, c_black, 1);
	shader_reset();
	
	draw_surface_ext(surf_layer_1, 0, 0, 1, 1, 0, c_white, 1);
	
	shader_set(shd_outline_post);
	draw_surface_ext(surf_layer_2, 0, 0, 1, 1, 0, c_black, 1);
	shader_reset();

} else {
	
	draw_surface_ext(application_surface, 0, 0, 1, 1, 0, c_white, 1);
	
}

gpu_set_colorwriteenable(true, true, true, true);

surface_reset_target();


if keyboard_check_pressed(ord("Y")) mode = (mode + 1) % array_length(p)

if global.config.graphics_post_grading {

	if !surface_exists(surf_lut)
		surf_lut = surface_create(256, 16)

	surface_set_target(surf_lut)
	draw_clear_alpha(c_black, 1)
	gpu_set_colorwriteenable(true, true, true, false);
		var _lut_grade = lut_mode_grade.get()
		var _lut_mix = lut_mode_mix.get()
		var _lut_mix_value = lerp(_lut_mix.current, _lut_mix.target, _lut_mix.progress);
		draw_sprite(spr_grade_base, 0, 0, 0);
		draw_sprite_ext(
			_lut_grade.current, 0, 0, 0, 1, 1, 0, c_white, 
			_lut_mix_value * (1 - _lut_grade.progress)
		);
		draw_sprite_ext(
			_lut_grade.target, 0, 0, 0, 1, 1, 0, c_white, 
			_lut_mix_value * _lut_grade.progress
		);
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

} else {

	draw_surface_ext(surf_compose, 0, 0, _scale_w, _scale_h, 0, c_white, 1);
	
}

