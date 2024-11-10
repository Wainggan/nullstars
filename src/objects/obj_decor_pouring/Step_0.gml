
repeat image_xscale {
	if random(1) < 1/(60 * 2) {
		game_render_particle_water(x + irandom_range(8, sprite_width - 8), y, ps_water_drip_1);
	}
}

