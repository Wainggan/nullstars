
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);


if !surface_exists(surf_lights) {
	surf_lights = surface_create(_cam_w, _cam_h, surface_rgba16float);
}

surface_set_target(surf_lights);
draw_clear_alpha(#555566, 1);

// draw lights

gpu_set_blendmode(bm_add);

shader_set(shd_lights);
var _u_position = shader_get_uniform(shd_lights, "u_position")
var _u_size = shader_get_uniform(shd_lights, "u_size")
var _u_intensity = shader_get_uniform(shd_lights, "u_intensity")

with obj_light {
	shader_set_uniform_f(_u_position, x - _cam_x, y - _cam_y);
	shader_set_uniform_f(_u_size, size);
	shader_set_uniform_f(_u_intensity, intensity);
	draw_sprite_stretched_ext(spr_pixel, 0, 0, 0, _cam_w, _cam_h, color, 1);
}

shader_reset();

gpu_set_blendmode(bm_normal);


// apply lights

gpu_set_blendmode_ext(bm_dest_color, bm_zero);

draw_surface(application_surface, 0, 0);

gpu_set_blendmode(bm_normal);


surface_reset_target();


draw_surface_ext(surf_lights, _cam_x, _cam_y, 1, 1, 0, c_white, 1);




