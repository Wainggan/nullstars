
repeat image_xscale {
	if random(1) < 1/(60 * 20) {
		game_render_particle_water(x + irandom_range(0, sprite_width), y, ps_water_drip_0);
	}
}

