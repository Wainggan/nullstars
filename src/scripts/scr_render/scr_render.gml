
function game_render_blendmode_set(_mode) {
	shader_set(_mode)
	texture_set_stage(shader_get_sampler_index(_mode, "u_destination"), surface_get_texture(render.surf_app))
}
function game_render_blendmode_reset() {
	shader_reset()
}

function game_render_refresh() {
	surface_set_target(render.surf_app)
	draw_clear_alpha(c_black, 0)
	draw_surface(application_surface, 0, 0)
	surface_reset_target()
}

