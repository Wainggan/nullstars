
var _cam = game_camera_get()

surface_set_target(surf_layer_2);
draw_surface(application_surface, 0, 0);

// draw reflections

if global.config.graphics_reflectables {

	gpu_set_colorwriteenable(true, true, true, false);
	draw_surface_ext(surf_relection, _cam.x, _cam.y, 1, 1, 0, #bbaaff, 0.5)
	gpu_set_colorwriteenable(true, true, true, true);

}

if global.config.graphics_atmosphere_overlay {

	gpu_set_tex_filter(true)

	gpu_set_blendmode_ext_sepalpha(bm_one, bm_zero, bm_zero, bm_one)

	game_render_refresh()
	game_render_blendmode_set(shd_blend_fog)

	draw_sprite_tiled_ext(spr_atmosphere_overlay, 0, -_cam.x * 0.4 - (current_time / 100), -_cam.y * 0.4, 9, 9, c_white, 0.1);

	game_render_blendmode_reset()

	gpu_set_blendmode(bm_normal)

	gpu_set_tex_filter(false)

} else {
	
}

surface_reset_target();

draw_clear_alpha(c_black, 0);

